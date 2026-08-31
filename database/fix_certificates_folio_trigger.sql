-- ============================================================
-- GENERACIÓN AUTOMÁTICA DE FOLIOS DE CERTIFICADOS
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- 1. Función para generar el folio con formato EHS-YYYY-NNNN
CREATE OR REPLACE FUNCTION public.generate_certificate_folio()
RETURNS TRIGGER AS $$
DECLARE
    next_id INTEGER;
    current_year INTEGER;
BEGIN
    -- Si ya tiene un folio que no sea temporal, no hacemos nada
    IF NEW.certificate_number IS NOT NULL AND NEW.certificate_number NOT LIKE 'TEMP-%' THEN
        RETURN NEW;
    END IF;

    -- Obtenemos el ID que se le asignará (usamos la secuencia de la tabla)
    -- Nota: NEW.id ya debería estar disponible en un trigger BEFORE INSERT
    -- Pero para mayor seguridad, si es NULL, usamos el siguiente valor de la secuencia
    IF NEW.id IS NULL THEN
        next_id := nextval('certificates_id_seq');
        NEW.id := next_id;
    ELSE
        next_id := NEW.id;
    END IF;

    current_year := EXTRACT(YEAR FROM CURRENT_DATE);

    -- Formato: EHS-2026-0001
    NEW.certificate_number := 'EHS-' || current_year || '-' || LPAD(next_id::text, 4, '0');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Crear el trigger BEFORE INSERT
DROP TRIGGER IF EXISTS trg_generate_certificate_folio ON public.certificates;
CREATE TRIGGER trg_generate_certificate_folio
BEFORE INSERT ON public.certificates
FOR EACH ROW EXECUTE FUNCTION public.generate_certificate_folio();

-- 3. Habilitar UPDATE en RLS para certificados (por si acaso)
DROP POLICY IF EXISTS "self update certificate" ON public.certificates;
CREATE POLICY "self update certificate" ON public.certificates
  FOR UPDATE TO authenticated
  USING (student_id = public.current_user_id())
  WITH CHECK (student_id = public.current_user_id());

-- 4. CORRECCIÓN DE FOLIOS EXISTENTES
-- Actualiza cualquier folio 'TEMP-' al formato oficial
UPDATE public.certificates
SET certificate_number = 'EHS-' || EXTRACT(YEAR FROM issued_date) || '-' || LPAD(id::text, 4, '0')
WHERE certificate_number LIKE 'TEMP-%';

-- 5. Verificar resultados
SELECT id, certificate_number, issued_date FROM public.certificates ORDER BY id DESC LIMIT 10;
