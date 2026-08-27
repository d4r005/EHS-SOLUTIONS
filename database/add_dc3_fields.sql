-- ============================================
-- EHS SOLUTIONS - Campos para generar el Formato DC-3 oficial
-- Datos adicionales del trabajador/empresa requeridos por la STPS
-- ============================================

ALTER TABLE public.users ADD COLUMN IF NOT EXISTS curp VARCHAR(18);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS ocupacion VARCHAR(255);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS puesto VARCHAR(255);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS company_name VARCHAR(255);
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS company_rfc VARCHAR(15);
