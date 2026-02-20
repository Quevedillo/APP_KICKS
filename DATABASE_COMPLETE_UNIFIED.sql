-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

-- ============================================================================
-- ROW LEVEL SECURITY POLICIES
-- ============================================================================

CREATE POLICY "Brands readable by all" ON public.brands AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY admins_manage_brands ON public.brands AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM user_profiles
  WHERE ((user_profiles.id = auth.uid()) AND (user_profiles.is_admin = true)))));

CREATE POLICY brands_public_read ON public.brands AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Users can manage own cart" ON public.cart_items AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Categories are viewable by everyone" ON public.categories AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Categories readable by all" ON public.categories AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY categories_public_read ON public.categories AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Colors readable by all" ON public.colors AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY colors_public_read ON public.colors AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY service_insert_uses ON public.discount_code_uses AS PERMISSIVE FOR INSERT TO public  WITH CHECK ((current_setting('role'::text, true) = 'service_role'::text));

CREATE POLICY users_see_own_uses ON public.discount_code_uses AS PERMISSIVE FOR SELECT TO public USING (((auth.uid() = user_id) OR ((user_id IS NULL) AND (current_setting('role'::text, true) = 'service_role'::text))));

CREATE POLICY admins_manage_codes ON public.discount_codes AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM user_profiles up
  WHERE ((up.id = auth.uid()) AND (up.is_admin = true)))));

CREATE POLICY anyone_can_validate_codes ON public.discount_codes AS PERMISSIVE FOR SELECT TO public USING ((is_active = true));

CREATE POLICY "Favorites readable by all" ON public.favorites AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Users can manage own favorites" ON public.favorites AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));

CREATE POLICY admins_manage_featured ON public.featured_product_selections AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM user_profiles up
  WHERE ((up.id = auth.uid()) AND (up.is_admin = true)))));

CREATE POLICY public_read_featured ON public.featured_product_selections AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY service_manage_featured ON public.featured_product_selections AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY "Anyone can subscribe to newsletter" ON public.newsletter_subscribers AS PERMISSIVE FOR INSERT TO public  WITH CHECK (true);

CREATE POLICY "Anyone can unsubscribe from newsletter" ON public.newsletter_subscribers AS PERMISSIVE FOR DELETE TO public USING (true);

CREATE POLICY "Service role full access newsletter" ON public.newsletter_subscribers AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY anyone_can_read_newsletter ON public.newsletter_subscribers AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY anyone_can_select ON public.newsletter_subscribers AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY anyone_can_subscribe ON public.newsletter_subscribers AS PERMISSIVE FOR INSERT TO public  WITH CHECK (true);

CREATE POLICY anyone_can_unsubscribe ON public.newsletter_subscribers AS PERMISSIVE FOR DELETE TO public USING (true);

CREATE POLICY service_role_all_newsletter ON public.newsletter_subscribers AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY service_role_full_orders ON public.orders AS PERMISSIVE FOR ALL TO public USING ((current_setting('role'::text, true) = 'service_role'::text)) WITH CHECK ((current_setting('role'::text, true) = 'service_role'::text));

CREATE POLICY users_create_orders ON public.orders AS PERMISSIVE FOR INSERT TO public  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY users_update_own_orders ON public.orders AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));

CREATE POLICY users_view_own_orders ON public.orders AS PERMISSIVE FOR SELECT TO public USING (((auth.uid() = user_id) OR ((user_id IS NULL) AND (current_setting('role'::text, true) = 'service_role'::text))));

CREATE POLICY admins_manage_sections ON public.page_sections AS PERMISSIVE FOR ALL TO public USING ((EXISTS ( SELECT 1
   FROM user_profiles up
  WHERE ((up.id = auth.uid()) AND (up.is_admin = true)))));

CREATE POLICY public_read_sections ON public.page_sections AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY service_manage_sections ON public.page_sections AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY "Product colors readable by all" ON public.product_colors AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Reviews readable by all" ON public.product_reviews AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Users can create own reviews" ON public.product_reviews AS PERMISSIVE FOR INSERT TO public  WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Products are readable by everyone" ON public.products AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY "Products are viewable by everyone" ON public.products AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY authenticated_manage_products ON public.products AS PERMISSIVE FOR ALL TO public USING ((auth.role() = 'authenticated'::text)) WITH CHECK ((auth.role() = 'authenticated'::text));

CREATE POLICY products_public_read ON public.products AS PERMISSIVE FOR SELECT TO public USING (true);

CREATE POLICY public_read_active_products ON public.products AS PERMISSIVE FOR SELECT TO public USING ((is_active = true));

CREATE POLICY "Users can manage own alerts" ON public.restock_alerts AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));

CREATE POLICY "Admins pueden actualizar cualquier perfil" ON public.user_profiles AS PERMISSIVE FOR UPDATE TO public USING ((EXISTS ( SELECT 1
   FROM user_profiles up
  WHERE ((up.id = auth.uid()) AND (up.is_admin = true)))));

CREATE POLICY "Usuarios autenticados pueden leer sus datos" ON public.user_profiles AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = id));

CREATE POLICY "Usuarios pueden actualizar su perfil" ON public.user_profiles AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));

CREATE POLICY "Usuarios pueden insertar su propio perfil" ON public.user_profiles AS PERMISSIVE FOR INSERT TO public  WITH CHECK ((auth.uid() = id));

CREATE POLICY service_role_all_profiles ON public.user_profiles AS PERMISSIVE FOR ALL TO public USING ((current_setting('role'::text, true) = 'service_role'::text)) WITH CHECK ((current_setting('role'::text, true) = 'service_role'::text));

CREATE POLICY users_insert_own_profile ON public.user_profiles AS PERMISSIVE FOR INSERT TO public  WITH CHECK (((auth.uid() = id) OR (current_setting('role'::text, true) = 'service_role'::text)));

CREATE POLICY users_read_own_profile ON public.user_profiles AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = id));

CREATE POLICY users_update_own_profile ON public.user_profiles AS PERMISSIVE FOR UPDATE TO public USING ((auth.uid() = id)) WITH CHECK ((auth.uid() = id));

CREATE POLICY service_manage_reads ON public.vip_notification_reads AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY users_own_reads ON public.vip_notification_reads AS PERMISSIVE FOR ALL TO public USING ((auth.uid() = user_id)) WITH CHECK ((auth.uid() = user_id));

CREATE POLICY service_manage_vip_notif ON public.vip_notifications AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY service_manage_vip ON public.vip_subscriptions AS PERMISSIVE FOR ALL TO public USING (true) WITH CHECK (true);

CREATE POLICY users_see_own_vip ON public.vip_subscriptions AS PERMISSIVE FOR SELECT TO public USING ((auth.uid() = user_id));

-- ============================================================================
-- TABLE DEFINITIONS
-- ============================================================================

CREATE TABLE public.brands (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL UNIQUE,
  slug character varying NOT NULL UNIQUE,
  logo_url text,
  description text,
  display_order integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT brands_pkey PRIMARY KEY (id)
);

CREATE TABLE public.cart_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  product_id uuid,
  size character varying NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT cart_items_pkey PRIMARY KEY (id),
  CONSTRAINT cart_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT cart_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  description text,
  icon character varying,
  display_order integer DEFAULT 0,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT categories_pkey PRIMARY KEY (id)
);

CREATE TABLE public.colors (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  hex_code character varying NOT NULL,
  display_order integer DEFAULT 0,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT colors_pkey PRIMARY KEY (id)
);

CREATE TABLE public.discount_code_uses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code_id uuid NOT NULL,
  user_id uuid,
  order_id uuid,
  discount_amount integer NOT NULL,
  used_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discount_code_uses_pkey PRIMARY KEY (id),
  CONSTRAINT discount_code_uses_code_id_fkey FOREIGN KEY (code_id) REFERENCES public.discount_codes(id),
  CONSTRAINT discount_code_uses_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

CREATE TABLE public.discount_codes (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  code character varying NOT NULL UNIQUE,
  description text,
  discount_type character varying NOT NULL DEFAULT 'percentage'::character varying,
  discount_value integer NOT NULL,
  min_purchase integer DEFAULT 0,
  max_uses integer,
  max_uses_per_user integer DEFAULT 1,
  current_uses integer DEFAULT 0,
  is_active boolean DEFAULT true,
  starts_at timestamp with time zone DEFAULT now(),
  expires_at timestamp with time zone,
  created_by uuid,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discount_codes_pkey PRIMARY KEY (id),
  CONSTRAINT discount_codes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);

CREATE TABLE public.favorites (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  product_id uuid,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT favorites_pkey PRIMARY KEY (id),
  CONSTRAINT favorites_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT favorites_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.featured_product_selections (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  section_id uuid,
  product_id uuid,
  display_order integer NOT NULL DEFAULT 0,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT featured_product_selections_pkey PRIMARY KEY (id),
  CONSTRAINT featured_product_selections_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.page_sections(id),
  CONSTRAINT featured_product_selections_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.newsletter_subscribers (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  email character varying NOT NULL UNIQUE,
  verified boolean DEFAULT false,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  verification_token text,
  subscribed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  metadata jsonb DEFAULT '{}'::jsonb,
  CONSTRAINT newsletter_subscribers_pkey PRIMARY KEY (id)
);

CREATE TABLE public.order_items (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  order_id uuid,
  product_id uuid,
  size character varying NOT NULL,
  quantity integer NOT NULL CHECK (quantity > 0),
  price_at_purchase integer NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  CONSTRAINT order_items_pkey PRIMARY KEY (id),
  CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.orders (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  status character varying DEFAULT 'pending'::character varying,
  total_amount integer NOT NULL DEFAULT 0,
  items jsonb NOT NULL DEFAULT '[]'::jsonb,
  stripe_session_id text UNIQUE,
  stripe_payment_intent_id text,
  shipping_name text,
  shipping_phone text,
  shipping_address jsonb,
  billing_email text,
  notes text,
  cancelled_at timestamp with time zone,
  cancelled_reason text,
  shipped_at timestamp with time zone,
  delivered_at timestamp with time zone,
  return_requested_at timestamp with time zone,
  return_status character varying,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT orders_pkey PRIMARY KEY (id),
  CONSTRAINT orders_new_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

CREATE TABLE public.page_sections (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  section_type text NOT NULL,
  title text,
  subtitle text,
  content jsonb DEFAULT '{}'::jsonb,
  display_order integer NOT NULL DEFAULT 0,
  is_visible boolean DEFAULT true,
  settings jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT page_sections_pkey PRIMARY KEY (id)
);

CREATE TABLE public.product_colors (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  color_id uuid,
  is_primary boolean DEFAULT false,
  CONSTRAINT product_colors_pkey PRIMARY KEY (id),
  CONSTRAINT product_colors_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_colors_color_id_fkey FOREIGN KEY (color_id) REFERENCES public.colors(id)
);

CREATE TABLE public.product_reviews (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  product_id uuid,
  user_id uuid,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review text,
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT product_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT product_reviews_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id),
  CONSTRAINT product_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

CREATE TABLE public.products (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  description text,
  detailed_description jsonb,
  price integer NOT NULL CHECK (price >= 0),
  original_price integer,
  stock integer NOT NULL DEFAULT 0,
  sizes_available jsonb,
  category_id uuid,
  brand character varying,
  model character varying,
  colorway character varying,
  sku character varying NOT NULL UNIQUE,
  release_date date,
  is_limited_edition boolean DEFAULT false,
  release_type character varying DEFAULT 'standard'::character varying,
  tags ARRAY DEFAULT '{}'::text[],
  images ARRAY NOT NULL DEFAULT '{}'::text[],
  created_at timestamp without time zone DEFAULT now(),
  updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  brand_id uuid,
  cost_price numeric DEFAULT NULL::numeric,
  material character varying,
  color character varying,
  compare_price integer,
  is_featured boolean DEFAULT false,
  is_active boolean DEFAULT true,
  discount_type character varying,
  discount_value numeric,
  CONSTRAINT products_pkey PRIMARY KEY (id),
  CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id),
  CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id)
);

CREATE TABLE public.restock_alerts (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  product_id uuid,
  size character varying NOT NULL,
  created_at timestamp without time zone DEFAULT now(),
  notified_at timestamp without time zone,
  CONSTRAINT restock_alerts_pkey PRIMARY KEY (id),
  CONSTRAINT restock_alerts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT restock_alerts_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  email text NOT NULL UNIQUE,
  full_name text,
  is_admin boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);

CREATE TABLE public.vip_notification_reads (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  notification_id uuid,
  user_id uuid,
  read_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vip_notification_reads_pkey PRIMARY KEY (id),
  CONSTRAINT vip_notification_reads_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.vip_notifications(id),
  CONSTRAINT vip_notification_reads_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);

CREATE TABLE public.vip_notifications (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  type text NOT NULL,
  product_id uuid,
  title text NOT NULL,
  message text NOT NULL,
  metadata jsonb DEFAULT '{}'::jsonb,
  sent_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vip_notifications_pkey PRIMARY KEY (id),
  CONSTRAINT vip_notifications_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id)
);

CREATE TABLE public.vip_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid,
  email text NOT NULL,
  stripe_customer_id text,
  stripe_subscription_id text UNIQUE,
  status text NOT NULL DEFAULT 'pending'::text,
  plan_type text NOT NULL DEFAULT 'monthly'::text,
  price_cents integer NOT NULL DEFAULT 999,
  current_period_start timestamp with time zone,
  current_period_end timestamp with time zone,
  cancelled_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vip_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT vip_subscriptions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
