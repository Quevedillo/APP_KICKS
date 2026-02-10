+-- ============================================================================
-- KICKSPREMIUM - MIGRACION Y CORRECCIONES DE BASE DE DATOS
-- ============================================================================
-- Ejecutar en Supabase Dashboard > SQL Editor > New Query
-- Fecha: 10 de febrero de 2026
--
-- CORRECCIONES:
-- ✅ Asegurar que existan las columnas correctas en orders
-- ✅ Stock automático: reducir al comprar, restaurar al cancelar
-- ✅ Bucket de Storage para imágenes de productos
-- ✅ RPC para admin listar usuarios
-- ✅ Políticas RLS correctas para admin
-- ============================================================================

-- ============================================================================
-- SECCIÓN 1: ASEGURAR COLUMNAS EN ORDERS
-- ============================================================================

-- La tabla orders usa total_amount (no total_price).
-- Asegurar columnas necesarias existen:
DO $$
BEGIN
  -- cancelled_reason
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'cancelled_reason'
  ) THEN
    ALTER TABLE orders ADD COLUMN cancelled_reason TEXT;
  END IF;

  -- cancelled_at
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'cancelled_at'
  ) THEN
    ALTER TABLE orders ADD COLUMN cancelled_at TIMESTAMPTZ;
  END IF;

  -- return_requested_at
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'return_requested_at'
  ) THEN
    ALTER TABLE orders ADD COLUMN return_requested_at TIMESTAMPTZ;
  END IF;

  -- stripe_payment_intent_id
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'stripe_payment_intent_id'
  ) THEN
    ALTER TABLE orders ADD COLUMN stripe_payment_intent_id TEXT;
  END IF;

  -- subtotal_amount
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'subtotal_amount'
  ) THEN
    ALTER TABLE orders ADD COLUMN subtotal_amount INTEGER;
  END IF;

  -- shipping_amount
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'orders' AND column_name = 'shipping_amount'
  ) THEN
    ALTER TABLE orders ADD COLUMN shipping_amount INTEGER DEFAULT 0;
  END IF;
END $$;

-- ============================================================================
-- SECCIÓN 2: FUNCIONES DE GESTIÓN DE STOCK
-- ============================================================================

-- FUNCIÓN: Reducir stock de una talla específica al comprar
CREATE OR REPLACE FUNCTION reduce_size_stock(
  p_product_id UUID,
  p_size TEXT,
  p_quantity INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_sizes JSONB;
  v_current_qty INTEGER;
  v_new_qty INTEGER;
  v_new_sizes JSONB;
BEGIN
  -- Obtener tallas actuales
  SELECT sizes_available INTO v_current_sizes
  FROM products WHERE id = p_product_id;

  IF v_current_sizes IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'Producto no encontrado');
  END IF;

  -- Obtener cantidad actual de esa talla
  v_current_qty := COALESCE((v_current_sizes ->> p_size)::INTEGER, 0);

  IF v_current_qty < p_quantity THEN
    RETURN jsonb_build_object('success', false, 'error', 
      format('Stock insuficiente para talla %s: tiene %s, necesita %s', p_size, v_current_qty, p_quantity));
  END IF;

  v_new_qty := v_current_qty - p_quantity;

  -- Actualizar el JSONB
  IF v_new_qty > 0 THEN
    v_new_sizes := jsonb_set(v_current_sizes, ARRAY[p_size], to_jsonb(v_new_qty));
  ELSE
    v_new_sizes := v_current_sizes - p_size;
  END IF;

  -- Actualizar producto (el trigger sync_stock_from_sizes se encargará del stock total)
  UPDATE products
  SET sizes_available = v_new_sizes,
      updated_at = NOW()
  WHERE id = p_product_id;

  RETURN jsonb_build_object(
    'success', true,
    'new_sizes', v_new_sizes,
    'removed_qty', p_quantity
  );
END;
$$;

-- FUNCIÓN: Añadir stock a una talla (restaurar al cancelar)
CREATE OR REPLACE FUNCTION add_size_stock(
  p_product_id UUID,
  p_size TEXT,
  p_quantity INTEGER DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_current_sizes JSONB;
  v_current_qty INTEGER;
  v_new_qty INTEGER;
  v_new_sizes JSONB;
BEGIN
  SELECT sizes_available INTO v_current_sizes
  FROM products WHERE id = p_product_id;

  IF v_current_sizes IS NULL THEN
    v_current_sizes := '{}'::jsonb;
  END IF;

  v_current_qty := COALESCE((v_current_sizes ->> p_size)::INTEGER, 0);
  v_new_qty := v_current_qty + p_quantity;
  v_new_sizes := jsonb_set(v_current_sizes, ARRAY[p_size], to_jsonb(v_new_qty));

  UPDATE products
  SET sizes_available = v_new_sizes,
      updated_at = NOW()
  WHERE id = p_product_id;

  RETURN jsonb_build_object(
    'success', true,
    'new_sizes', v_new_sizes,
    'added_qty', p_quantity
  );
END;
$$;

-- FUNCIÓN: Cancelar pedido atómicamente (restaura stock + cambia estado)
CREATE OR REPLACE FUNCTION cancel_order_atomic(
  p_order_id UUID,
  p_user_id UUID,
  p_reason TEXT DEFAULT 'Cancelado por el cliente'
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_order RECORD;
  v_items JSONB;
  v_item JSONB;
  v_product_id UUID;
  v_size TEXT;
  v_quantity INTEGER;
BEGIN
  -- Verificar que el pedido existe y pertenece al usuario (o el usuario es admin)
  SELECT * INTO v_order FROM orders
  WHERE id = p_order_id
  AND (user_id = p_user_id OR EXISTS (
    SELECT 1 FROM user_profiles WHERE id = p_user_id AND is_admin = true
  ));

  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'error', 'Pedido no encontrado o no autorizado');
  END IF;

  IF v_order.status NOT IN ('pending', 'paid', 'processing') THEN
    RETURN jsonb_build_object('success', false, 'error', 'No se puede cancelar un pedido con estado: ' || v_order.status);
  END IF;

  -- Obtener items del pedido
  v_items := v_order.items;

  -- Restaurar stock para cada item
  IF v_items IS NOT NULL AND jsonb_array_length(v_items) > 0 THEN
    FOR v_item IN SELECT * FROM jsonb_array_elements(v_items)
    LOOP
      v_product_id := (v_item ->> 'product_id')::UUID;
      v_size := v_item ->> 'size';
      v_quantity := COALESCE((v_item ->> 'quantity')::INTEGER, 1);

      IF v_product_id IS NOT NULL AND v_size IS NOT NULL THEN
        PERFORM add_size_stock(v_product_id, v_size, v_quantity);
      END IF;
    END LOOP;
  END IF;

  -- Actualizar estado del pedido
  UPDATE orders
  SET status = 'cancelled',
      cancelled_at = NOW(),
      cancelled_reason = p_reason,
      updated_at = NOW()
  WHERE id = p_order_id;

  RETURN jsonb_build_object('success', true, 'message', 'Pedido cancelado y stock restaurado');
END;
$$;

-- ============================================================================
-- SECCIÓN 3: TRIGGER PARA SINCRONIZAR STOCK TOTAL DESDE TALLAS
-- ============================================================================

-- FUNCIÓN: Calcular stock total desde sizes_available
CREATE OR REPLACE FUNCTION calculate_total_stock_from_sizes(sizes_json JSONB)
RETURNS INTEGER
LANGUAGE plpgsql
IMMUTABLE
AS $$
DECLARE
  total INTEGER := 0;
  size_key TEXT;
  size_qty INTEGER;
BEGIN
  IF sizes_json IS NULL OR sizes_json = '{}'::jsonb THEN
    RETURN 0;
  END IF;

  FOR size_key IN SELECT jsonb_object_keys(sizes_json)
  LOOP
    size_qty := COALESCE((sizes_json ->> size_key)::INTEGER, 0);
    IF size_qty > 0 THEN
      total := total + size_qty;
    END IF;
  END LOOP;

  RETURN total;
END;
$$;

-- FUNCIÓN: Trigger para sincronizar stock
CREATE OR REPLACE FUNCTION sync_stock_from_sizes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  calculated_stock INTEGER;
BEGIN
  IF NEW.sizes_available IS NOT NULL AND NEW.sizes_available != '{}'::jsonb THEN
    calculated_stock := calculate_total_stock_from_sizes(NEW.sizes_available);
    NEW.stock := calculated_stock;
  END IF;
  RETURN NEW;
END;
$$;

-- Crear trigger
DROP TRIGGER IF EXISTS trigger_sync_stock ON products;
CREATE TRIGGER trigger_sync_stock
  BEFORE INSERT OR UPDATE OF sizes_available
  ON products
  FOR EACH ROW
  EXECUTE FUNCTION sync_stock_from_sizes();

-- ============================================================================
-- SECCIÓN 4: RPC PARA ADMIN - LISTAR TODOS LOS USUARIOS
-- ============================================================================

CREATE OR REPLACE FUNCTION get_all_user_profiles()
RETURNS SETOF user_profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar que el usuario es admin
  IF NOT EXISTS (
    SELECT 1 FROM user_profiles 
    WHERE id = auth.uid() AND is_admin = true
  ) THEN
    RAISE EXCEPTION 'No autorizado: solo administradores';
  END IF;

  RETURN QUERY SELECT * FROM user_profiles ORDER BY created_at DESC;
END;
$$;

-- ============================================================================
-- SECCIÓN 5: POLÍTICA RLS PARA ADMINS - GESTIÓN DE PEDIDOS
-- ============================================================================

-- Admin puede actualizar todos los pedidos (para cambiar estado, cancelar, etc.)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'orders' AND policyname = 'admins_update_all_orders'
  ) THEN
    CREATE POLICY "admins_update_all_orders" ON orders
      FOR UPDATE USING (
        EXISTS (
          SELECT 1 FROM user_profiles 
          WHERE user_profiles.id = auth.uid() AND user_profiles.is_admin = true
        )
      );
  END IF;
END $$;

-- ============================================================================
-- SECCIÓN 6: STORAGE BUCKET PARA IMÁGENES DE PRODUCTOS
-- ============================================================================
-- NOTA: Debes crear el bucket manualmente desde Supabase Dashboard:
--
-- 1. Ve a Storage en Supabase Dashboard
-- 2. Click "New Bucket"
-- 3. Nombre: product-images
-- 4. Marca "Public bucket" = ON
-- 5. Click "Create bucket"
-- 6. Luego añade esta política (en SQL):

-- Permitir a cualquiera leer imágenes (público)
-- INSERT INTO storage.policies (name, bucket_id, definition, operation, owner)
-- VALUES ('Public Read', 'product-images', 'true', 'SELECT', null);

-- Permitir a admins subir imágenes
-- Ejecutar en SQL Editor:
/*
CREATE POLICY "Admin Upload product-images" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (
    bucket_id = 'product-images' AND
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );

CREATE POLICY "Public Read product-images" ON storage.objects
  FOR SELECT
  USING (bucket_id = 'product-images');

CREATE POLICY "Admin Delete product-images" ON storage.objects
  FOR DELETE TO authenticated
  USING (
    bucket_id = 'product-images' AND
    EXISTS (
      SELECT 1 FROM public.user_profiles
      WHERE id = auth.uid() AND is_admin = true
    )
  );
*/

-- ============================================================================
-- SECCIÓN 7: VERIFICAR QUE TODO FUNCIONE
-- ============================================================================

-- Test: Verificar columnas de orders
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'orders' 
ORDER BY ordinal_position;

-- Test: Verificar funciones creadas
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'public' 
AND routine_name IN (
  'reduce_size_stock', 
  'add_size_stock', 
  'cancel_order_atomic',
  'sync_stock_from_sizes',
  'calculate_total_stock_from_sizes',
  'get_all_user_profiles'
);

-- ============================================================================
-- ¡LISTO! Después de ejecutar este script:
-- 1. Crea el bucket 'product-images' en Storage (Dashboard > Storage > New Bucket)
-- 2. Marca como público
-- 3. Ejecuta las políticas de Storage del Sección 6 (están comentadas arriba)
-- ============================================================================
