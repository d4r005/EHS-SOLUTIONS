-- ============================================================
-- FIX 2.0: Cimentación LMS y Sincronización Automática
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Asegurar que existe la columna auth_id
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS auth_id UUID UNIQUE REFERENCES auth.users(id);

-- 2. Habilitar RLS en tablas clave si no lo están
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lesson_progress ENABLE ROW LEVEL SECURITY;

-- 3. Funciones de ayuda para políticas
CREATE OR REPLACE FUNCTION public.current_user_id()
RETURNS integer LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT id FROM public.users WHERE auth_id = auth.uid();
$$;

CREATE OR REPLACE FUNCTION public.current_user_role()
RETURNS text LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid();
$$;

-- 4. Políticas para la tabla USERS
DROP POLICY IF EXISTS "allow_read_self" ON public.users;
CREATE POLICY "allow_read_self" ON public.users FOR SELECT USING (auth_id = auth.uid() OR role IN ('admin', 'instructor'));

DROP POLICY IF EXISTS "allow_update_self" ON public.users;
CREATE POLICY "allow_update_self" ON public.users FOR UPDATE USING (auth_id = auth.uid());

-- 5. Políticas para la tabla COURSES
DROP POLICY IF EXISTS "allow_read_published" ON public.courses;
CREATE POLICY "allow_read_published" ON public.courses FOR SELECT USING (is_published = true OR instructor_id = public.current_user_id() OR public.current_user_role() = 'admin');

-- 6. Trigger para Sincronización Automática de Usuarios
-- Esto evita el error "No autenticado" creando el perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (auth_id, email, first_name, last_name, role)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'last_name', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'student')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 7. Corregir registros huérfanos actuales
UPDATE public.users u
SET auth_id = a.id
FROM auth.users a
WHERE a.email = u.email AND u.auth_id IS NULL;

-- 8. Insertar usuarios que están en Auth pero no en public.users
INSERT INTO public.users (auth_id, email, first_name, last_name, role)
SELECT id, email, raw_user_meta_data->>'first_name', raw_user_meta_data->>'last_name', COALESCE(raw_user_meta_data->>'role', 'student')
FROM auth.users
WHERE email NOT IN (SELECT email FROM public.users)
ON CONFLICT (email) DO NOTHING;
