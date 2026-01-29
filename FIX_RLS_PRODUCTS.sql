-- ============================================================================
-- FIX: Actualizar RLS de productos para permitir que usuarios autenticados 
-- puedan crear/editar productos (para admin panel)
-- ============================================================================
-- INSTRUCCIONES:
-- 1. Ir a Supabase Dashboard > SQL Editor > New Query
-- 2. Copiar TODO este contenido
-- 3. Ejecutar
-- ============================================================================

-- OPCIÓN 1: Permitir solo a admins (recomendado para seguridad)
-- Primero marca el usuario como admin en user_profiles:
UPDATE user_profiles SET is_admin = true WHERE email = 'joseluisgq17@gmail.com';

-- OPCIÓN 2: Si quieres permitir a todos los usuarios autenticados (menos seguro):
-- Ejecuta esto en su lugar:

-- Eliminar políticas anteriores
DROP POLICY IF EXISTS "admins_manage_products" ON products;

-- Nueva política: Usuarios autenticados pueden crear/editar productos
-- (En producción, cambiar a que solo admins lo hagan)
CREATE POLICY "authenticated_manage_products" ON products
  FOR ALL USING (
    auth.role() = 'authenticated'
  )
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir lectura pública de productos activos
CREATE POLICY "public_read_active_products" ON products
  FOR SELECT USING (is_active = true);

-- ============================================================================
-- VERIFICACIÓN
-- ============================================================================
SELECT 'Políticas RLS actualizadas ✅' as status;

-- Ver políticas de products
SELECT schemaname, tablename, policyname, permissive, roles, qual, with_check
FROM pg_policies
WHERE tablename = 'products'
ORDER BY policyname;
