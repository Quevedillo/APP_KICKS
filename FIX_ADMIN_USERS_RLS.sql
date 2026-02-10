-- ============================================================
-- Fix: Permitir a los administradores ver todos los usuarios
-- Ejecutar en Supabase SQL Editor
-- ============================================================

-- 1. Función RPC para que los admins obtengan todos los perfiles
CREATE OR REPLACE FUNCTION get_all_user_profiles()
RETURNS SETOF user_profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Verificar que el usuario actual es admin
  IF NOT EXISTS (
    SELECT 1 FROM user_profiles 
    WHERE id = auth.uid() AND is_admin = true
  ) THEN
    RAISE EXCEPTION 'No autorizado: se requiere rol de administrador';
  END IF;

  RETURN QUERY SELECT * FROM user_profiles ORDER BY created_at DESC;
END;
$$;

-- 2. Alternativa: Política RLS para que admins vean todos los perfiles
-- (Descomenta si prefieres esta opción en vez de la función RPC)

-- DROP POLICY IF EXISTS "Admins can view all profiles" ON user_profiles;
-- CREATE POLICY "Admins can view all profiles" ON user_profiles
--   FOR SELECT
--   USING (
--     auth.uid() = id 
--     OR 
--     EXISTS (
--       SELECT 1 FROM user_profiles WHERE id = auth.uid() AND is_admin = true
--     )
--   );

-- 3. Asegurarse de que la columna cancelled_reason existe en orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_reason TEXT;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMPTZ;
