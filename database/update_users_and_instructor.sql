-- ============================================
-- EHS SOLUTIONS - División de Nombres y Actualización de Instructor
-- Ejecutar en Supabase → SQL Editor
-- ============================================

-- 1. Agregar nuevas columnas a public.users
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS nombres VARCHAR(100);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS apellido_paterno VARCHAR(100);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS apellido_materno VARCHAR(100);

-- 2. Migrar datos existentes (best-effort)
UPDATE public.users
SET
  nombres = first_name,
  apellido_paterno = last_name
WHERE nombres IS NULL;

-- 3. Actualizar al instructor principal
UPDATE public.users
SET
  nombres = 'JESUS DARIO',
  apellido_paterno = 'ROBLES',
  apellido_materno = 'TRUJILLO',
  first_name = 'JESUS DARIO',
  last_name = 'ROBLES TRUJILLO'
WHERE email = 'instructor@ehs-solutions.com';

-- 4. Actualizar administrador
UPDATE public.users
SET
  nombres = 'DARIO',
  apellido_paterno = 'ROBLES',
  apellido_materno = '',
  first_name = 'Dario',
  last_name = 'Robles'
WHERE role = 'admin' AND email = 'd4r005@gmail.com';

-- 5. Actualizar la función de trigger para nuevos usuarios
-- Esto asegura que los registros nuevos también llenen los campos divididos
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
    nombres = EXCLUDED.nombres,
    apellido_paterno = EXCLUDED.apellido_paterno,
    apellido_materno = EXCLUDED.apellido_materno;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
