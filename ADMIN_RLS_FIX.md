# 🔧 INSTRUCCIONES PARA ARREGLAR EL ERROR DE RLS EN PRODUCTS

## ❌ Error Actual
```
PostgrestException(message: new row violates row-level security policy for table "products", code: 42501)
```

## ✅ Solución

### Opción 1: RECOMENDADA - Convertir usuario actual a ADMIN

Este es el método más seguro. Tu usuario debe ser admin para acceder al panel de administración.

**Pasos:**

1. Ve a **Supabase Dashboard** > **SQL Editor**
2. Crea una **New Query**
3. Copia y pega EXACTAMENTE ESTO:

```sql
UPDATE user_profiles 
SET is_admin = true 
WHERE email = 'joseluisgq17@gmail.com';

SELECT email, is_admin FROM user_profiles WHERE is_admin = true;
```

4. Click en **Run** (botón azul abajo a la derecha)
5. Verifica que el resultado muestre tu email con `is_admin = true`
6. Cierra la sesión en la app y vuelve a iniciar sesión
7. Prueba crear un producto desde el panel admin

---

### Opción 2: ALTERNATIVA - Permitir todos los usuarios autenticados

Si NO quieres usar la Opción 1, ejecuta esto en Supabase SQL Editor:

```sql
-- Eliminar la política restrictiva anterior
DROP POLICY IF EXISTS "admins_manage_products" ON products;

-- Nueva política: Cualquier usuario autenticado puede CRUD
CREATE POLICY "users_manage_products" ON products
  FOR ALL 
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Permitir lectura pública de productos activos
CREATE POLICY "public_read_active" ON products
  FOR SELECT 
  USING (is_active = true);
```

Luego cierra sesión y vuelve a iniciar.

---

## 📱 Pasos en la App Después

1. Abre la app en el simulador
2. Navega al **Admin Panel**
3. Sección **Productos**
4. Presiona botón **+ Nuevo Producto**
5. Completa el formulario:
   - Nombre
   - Precio (en euros)
   - Stock
   - Brand (ej: Nike)
   - SKU (código único)
6. Presiona **Guardar**

## ⚠️ Importante

- **Opción 1 es más segura** para producción
- **Opción 2 es solo para desarrollo**
- La app seguirá mostrando el error si NO haces uno de estos pasos
- Debes **cerrar sesión y volver a iniciar** para que los cambios tomen efecto

## ✨ Cambios Realizados en la App

✅ Eliminado apartado **Email** del admin panel
✅ Mejorada la estética del app bar
✅ Mejorados los estilos del bottom navigation
✅ Consistencia visual con el resto de la aplicación
