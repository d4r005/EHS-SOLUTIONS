-- ============================================================
-- FIX: Gestión de Usuarios (Borrado y Protección de Estado Inactivo)
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Habilitar permiso de DELETE para usuarios autenticados
GRANT DELETE ON public.users TO authenticated;

-- 2. Crear política RLS para que solo administradores puedan borrar usuarios
DROP POLICY IF EXISTS "admin delete any user" ON public.users;
CREATE POLICY "admin delete any user" ON public.users
    FOR DELETE TO authenticated
    USING (public.is_admin());

-- 3. Blindar el trigger handle_new_user para NO reactivar cuentas inactivas
-- Modificamos la función para que en el UPDATE respete el valor de is_active
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (
    auth_id,
    email,
    first_name,
    last_name,
    nombres,
    apellido_paterno,
    apellido_materno,
    role,
    is_active
  )
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'nombres', new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'apellido_paterno', new.raw_user_meta_data->>'last_name', ''),
    COALESCE(new.raw_user_meta_data->>'nombres', new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'apellido_paterno', new.raw_user_meta_data->>'last_name', ''),
    COALESCE(new.raw_user_meta_data->>'apellido_materno', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'student'),
    true
  )
  ON CONFLICT (email) DO UPDATE SET
    auth_id = EXCLUDED.auth_id,
    -- NO actualizamos is_active aquí para evitar reactivaciones automáticas
    -- is_active = public.users.is_active, -- Esto es implícito si no se incluye
    nombres = CASE WHEN public.users.nombres = '' OR public.users.nombres IS NULL THEN EXCLUDED.nombres ELSE public.users.nombres END,
    apellido_paterno = CASE WHEN public.users.apellido_paterno = '' OR public.users.apellido_paterno IS NULL THEN EXCLUDED.apellido_paterno ELSE public.users.apellido_paterno END,
    apellido_materno = CASE WHEN public.users.apellido_materno = '' OR public.users.apellido_materno IS NULL THEN EXCLUDED.apellido_materno ELSE public.users.apellido_materno END;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Verificar políticas activas
-- SELECT tablename, policyname, cmd FROM pg_policies WHERE tablename = 'users';
