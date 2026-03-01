-- ============================================================
-- GUEST CHECKOUT: RPC Functions Migration
-- Run this in Supabase SQL Editor to enable guest orders
-- These use SECURITY DEFINER to bypass RLS safely
-- ============================================================

-- 1. Function to create a guest order (bypasses RLS via SECURITY DEFINER)
CREATE OR REPLACE FUNCTION public.create_guest_order(
  p_stripe_payment_intent_id text,
  p_total_amount integer,
  p_items jsonb,
  p_billing_email text,
  p_user_id uuid DEFAULT NULL,
  p_shipping_name text DEFAULT NULL,
  p_shipping_phone text DEFAULT NULL,
  p_shipping_address jsonb DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_order record;
BEGIN
  INSERT INTO orders (
    stripe_payment_intent_id,
    total_amount,
    status,
    items,
    billing_email,
    user_id,
    shipping_name,
    shipping_phone,
    shipping_address,
    created_at
  ) VALUES (
    p_stripe_payment_intent_id,
    p_total_amount,
    'paid',
    p_items,
    p_billing_email,
    p_user_id,
    COALESCE(p_shipping_name, split_part(p_billing_email, '@', 1)),
    p_shipping_phone,
    p_shipping_address,
    now()
  )
  RETURNING * INTO v_order;

  RETURN row_to_json(v_order)::jsonb;
END;
$$;

-- 2. Function to link guest orders to a user after login/signup
CREATE OR REPLACE FUNCTION public.link_guest_orders(
  p_email text,
  p_user_id uuid
)
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count integer;
BEGIN
  UPDATE orders
  SET user_id = p_user_id,
      updated_at = now()
  WHERE billing_email = p_email
    AND user_id IS NULL;

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;

-- Grant execute to anon and authenticated roles
GRANT EXECUTE ON FUNCTION public.create_guest_order TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.link_guest_orders TO authenticated;
