-- ============================================================
-- FIX: Esquema de Usuarios y Sincronización Auth
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Hacer que la contraseña sea opcional en public.users
-- (Supabase Auth ya maneja las contraseñas de forma segura)
ALTER TABLE public.users ALTER COLUMN password DROP NOT NULL;

-- 2. Asegurar que la columna auth_id exista y sea única
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='users' AND column_name='auth_id') THEN
        ALTER TABLE public.users ADD COLUMN auth_id UUID UNIQUE REFERENCES auth.users(id);
    END IF;
END $$;

-- 3. Función mejorada para crear el perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (auth_id, email, first_name, last_name, role, is_active)
  VALUES (
    new.id,
    new.email,
    COALESCE(new.raw_user_meta_data->>'first_name', ''),
    COALESCE(new.raw_user_meta_data->>'last_name', ''),
    COALESCE(new.raw_user_meta_data->>'role', 'student'),
    true
  )
  ON CONFLICT (email) DO UPDATE SET
    auth_id = EXCLUDED.auth_id,
    first_name = CASE WHEN public.users.first_name = '' THEN EXCLUDED.first_name ELSE public.users.first_name END,
    last_name = CASE WHEN public.users.last_name = '' THEN EXCLUDED.last_name ELSE public.users.last_name END;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Re-crear el trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 5. Habilitar RLS y políticas básicas
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.users;
CREATE POLICY "Enable insert for authenticated users only" ON public.users
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = auth_id);

DROP POLICY IF EXISTS "Enable select for users own profile" ON public.users;
CREATE POLICY "Enable select for users own profile" ON public.users
    FOR SELECT TO authenticated
    USING (auth.uid() = auth_id OR role = 'admin');

DROP POLICY IF EXISTS "Enable update for users own profile" ON public.users;
CREATE POLICY "Enable update for users own profile" ON public.users
    FOR UPDATE TO authenticated
    USING (auth.uid() = auth_id);
