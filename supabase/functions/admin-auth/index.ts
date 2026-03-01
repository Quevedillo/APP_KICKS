// Supabase Edge Function: admin-auth
// Handles admin-level auth operations that require the service_role key.
//
// Environment variables (set automatically by Supabase):
//   SUPABASE_URL
//   SUPABASE_SERVICE_ROLE_KEY
//
// Actions:
//   get-banned   - Returns list of banned user IDs
//   ban          - Bans a user
//   unban        - Unbans a user
//   delete       - Deletes a user from auth.users + user_profiles

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
};

async function verifyAdmin(
    supabase: any,
    token: string
): Promise<{ isAdmin: boolean; userId: string | null; error: string | null }> {
    const {
        data: { user },
        error,
    } = await supabase.auth.getUser(token);
    if (error || !user) {
        return { isAdmin: false, userId: null, error: "Unauthorized" };
    }

    const { data: profile } = await supabase
        .from("user_profiles")
        .select("is_admin")
        .eq("id", user.id)
        .single();

    if (!profile?.is_admin) {
        return { isAdmin: false, userId: user.id, error: "Admin access required" };
    }

    return { isAdmin: true, userId: user.id, error: null };
}

serve(async (req: Request) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
        const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
        const supabase = createClient(supabaseUrl, serviceKey);

        // Verify JWT + admin status
        const authHeader = req.headers.get("Authorization");
        if (!authHeader) {
            return new Response(
                JSON.stringify({ error: "Missing authorization" }),
                { status: 401, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const token = authHeader.replace("Bearer ", "");
        const { isAdmin, error: adminError } = await verifyAdmin(supabase, token);
        if (!isAdmin) {
            return new Response(
                JSON.stringify({ error: adminError }),
                { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        const body = await req.json();
        const { action, userId } = body;

        // ─── GET BANNED USERS ────────────────────────────────────────────
        if (action === "get-banned") {
            const response = await fetch(
                `${supabaseUrl}/auth/v1/admin/users?per_page=1000`,
                {
                    headers: {
                        Authorization: `Bearer ${serviceKey}`,
                        apikey: serviceKey,
                    },
                }
            );

            if (response.ok) {
                const data = await response.json();
                const users = data.users || [];
                const bannedIds: string[] = [];
                const now = new Date();

                for (const u of users) {
                    const bannedUntil = u.banned_until;
                    if (
                        bannedUntil &&
                        bannedUntil !== "0001-01-01T00:00:00Z"
                    ) {
                        const until = new Date(bannedUntil);
                        if (until > now) {
                            bannedIds.push(u.id);
                        }
                    }
                }

                return new Response(
                    JSON.stringify({ bannedIds }),
                    { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            return new Response(
                JSON.stringify({ bannedIds: [] }),
                { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── BAN USER ────────────────────────────────────────────────────
        if (action === "ban") {
            if (!userId) {
                return new Response(
                    JSON.stringify({ error: "userId required" }),
                    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            const response = await fetch(
                `${supabaseUrl}/auth/v1/admin/users/${userId}`,
                {
                    method: "PUT",
                    headers: {
                        Authorization: `Bearer ${serviceKey}`,
                        apikey: serviceKey,
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({ ban_duration: "876000h" }),
                }
            );

            return new Response(
                JSON.stringify({ success: response.ok }),
                { status: response.ok ? 200 : 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── UNBAN USER ──────────────────────────────────────────────────
        if (action === "unban") {
            if (!userId) {
                return new Response(
                    JSON.stringify({ error: "userId required" }),
                    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            const response = await fetch(
                `${supabaseUrl}/auth/v1/admin/users/${userId}`,
                {
                    method: "PUT",
                    headers: {
                        Authorization: `Bearer ${serviceKey}`,
                        apikey: serviceKey,
                        "Content-Type": "application/json",
                    },
                    body: JSON.stringify({ ban_duration: "none" }),
                }
            );

            return new Response(
                JSON.stringify({ success: response.ok }),
                { status: response.ok ? 200 : 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
            );
        }

        // ─── DELETE USER ─────────────────────────────────────────────────
        if (action === "delete") {
            if (!userId) {
                return new Response(
                    JSON.stringify({ error: "userId required" }),
                    { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
                );
            }

            // Delete from user_profiles first (FK), then from auth.users
            await supabase.from("user_profiles").delete().eq("id", userId);

            const response = await fetch(
                `${supabaseUrl}/auth/v1/admin/users/${userId}`,
                {
                    method: "DELETE",
                    headers: {
                        Authorization: `Bearer ${serviceKey}`,
                        apikey: serviceKey,
                    },
                }
            );

            return new Response(
                JSON.stringify({ success: response.ok }),
                { status: response.ok ? 200 : 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
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
