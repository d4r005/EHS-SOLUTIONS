-- ============================================================
-- EHS SOLUTIONS - PORTADAS DE LOS 7 CURSOS NUEVOS
-- Imagenes reales recortadas a 1600x900, alojadas en CDN publico.
-- Ejecutar en Supabase -> SQL Editor. Es idempotente.
-- ============================================================

BEGIN;

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/e7144895c_Montacargas.jpg'
 WHERE title = 'Manejo Seguro de Montacargas';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/ec878280a_NOM-019.jpg'
 WHERE title = 'Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/aa3fec6fb_NOM-018.jpg'
 WHERE title = 'Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/02b556ec0_NOM-029.jpg'
 WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/2d8f8fef4_NOM-036.jpg'
 WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/f4b9d9f23_CTPAT.jpg'
 WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT';

UPDATE public.courses SET thumbnail_url = 'https://media.base44.com/images/public/6a73dc426a7411febfbb7960/6fe9838e1_Urgencias.jpg'
 WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)';

-- Verificacion: debe devolver 7
SELECT count(*) AS cursos_con_portada
FROM public.courses
WHERE thumbnail_url IS NOT NULL
  AND title IN (
    'Manejo Seguro de Montacargas',
    'Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)',
    'Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)',
    'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)',
    'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)',
    'Seguridad en la Cadena de Suministro y Concientización CTPAT',
    'Técnicos en Urgencias Médicas Nivel 1 (Básico)'
  );

COMMIT;

-- ============================================================
-- Creditos de las imagenes (Wikimedia Commons):
--   Montacargas.jpg      Forklift moviendo tarimas (dominio publico)
--   NOM-019.jpg          Trabajadores con casco en sitio industrial (dominio publico)
--   NOM-018.jpg          Respuesta HAZMAT con equipo de proteccion (dominio publico)
--   NOM-029.jpg          Electricistas reparando un generador (CC BY 2.0)
--   NOM-036.jpg          Trabajadores manipulando cajas en almacen (dominio publico)
--   CTPAT.jpg            Oficiales de CBP inspeccionando carga en contenedor (dominio publico)
--   Urgencias.jpg        Paramédicos en entrenamiento conjunto (dominio publico)
-- ============================================================