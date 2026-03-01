// Supabase Edge Function: stripe-proxy
// Handles Stripe operations server-side so the secret key never reaches the client.
//
// Environment variables (set via Supabase dashboard):
//   STRIPE_SECRET_KEY - Stripe secret key (sk_test_... or sk_live_...)
//
// Endpoints:
//   POST /create-payment-intent  - Creates a PaymentIntent
//   POST /refund                 - Processes a refund

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const STRIPE_SECRET_KEY = Deno.env.get("STRIPE_SECRET_KEY");
    if (!STRIPE_SECRET_KEY) {
      return new Response(
        JSON.stringify({ error: "STRIPE_SECRET_KEY not configured" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Verify the user is authenticated via the JWT
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(
        JSON.stringify({ error: "Missing authorization header" }),
        { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const body = await req.json();
    const { action } = body;

    if (action === "create-payment-intent") {
      const { amount, currency, orderId, metadata } = body;

      if (!amount || amount <= 0) {
        return new Response(
          JSON.stringify({ error: "Amount must be > 0" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Build form body
      const params = new URLSearchParams();
      params.append("amount", amount.toString());
      params.append("currency", currency || "eur");
      params.append("automatic_payment_methods[enabled]", "true");
      params.append("metadata[orderId]", orderId || "");

      if (metadata) {
        for (const [key, value] of Object.entries(metadata)) {
          params.append(`metadata[${key}]`, String(value));
        }
      }

      const stripeResponse = await fetch(
        "https://api.stripe.com/v1/payment_intents",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: params.toString(),
        }
      );

      const data = await stripeResponse.json();

      if (!stripeResponse.ok) {
        return new Response(
          JSON.stringify({
            error: data.error?.message || "Stripe error",
          }),
          { status: stripeResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      return new Response(
        JSON.stringify({
          clientSecret: data.client_secret,
          paymentIntentId: data.id,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (action === "refund") {
      const { paymentIntentId } = body;

      if (!paymentIntentId) {
        return new Response(
          JSON.stringify({ error: "paymentIntentId required" }),
          { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      // Verify caller is admin
      const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
      const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
      const supabase = createClient(supabaseUrl, supabaseServiceKey);

      const token = authHeader.replace("Bearer ", "");
      const { data: { user }, error: authError } = await supabase.auth.getUser(token);
      if (authError || !user) {
        return new Response(
          JSON.stringify({ error: "Unauthorized" }),
          { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const { data: profile } = await supabase
        .from("user_profiles")
        .select("is_admin")
        .eq("id", user.id)
        .single();

      if (!profile?.is_admin) {
        return new Response(
          JSON.stringify({ error: "Admin only" }),
          { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      const params = new URLSearchParams();
      params.append("payment_intent", paymentIntentId);

      const stripeResponse = await fetch(
        "https://api.stripe.com/v1/refunds",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${STRIPE_SECRET_KEY}`,
            "Content-Type": "application/x-www-form-urlencoded",
          },
          body: params.toString(),
        }
      );

      const data = await stripeResponse.json();

      if (!stripeResponse.ok) {
        return new Response(
          JSON.stringify({ error: data.error?.message || "Refund failed" }),
          { status: stripeResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
        );
      }

      return new Response(
        JSON.stringify({ success: true, refundId: data.id }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    return new Response(
      JSON.stringify({ error: `Unknown action: ${action}` }),
      { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err) {
    return new Response(
      JSON.stringify({ error: err.message }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
