-- ============================================================
-- EHS SOLUTIONS - PORTADAS DE LOS 7 CURSOS NUEVOS
-- Imagenes proporcionadas por EHS Solutions, subidas al bucket
-- bucket thumbnails de Supabase Storage.
-- Estas URLs ya estan aplicadas en la base; el script queda como respaldo
-- y para reconstruir el entorno. Ejecutar en Supabase -> SQL Editor.
-- ============================================================

BEGIN;

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/Montacargas.jpg'
 WHERE title = 'Manejo Seguro de Montacargas';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/NOM-019.jpg'
 WHERE title = 'Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011)';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/NOM-018.jpg'
 WHERE title = 'Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015)';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/NOM-029.jpg'
 WHERE title = 'Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011)';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/NOM-036.jpg'
 WHERE title = 'Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018)';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/CTPAT.jpg'
 WHERE title = 'Seguridad en la Cadena de Suministro y Concientización CTPAT';

UPDATE public.courses SET thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/Urgencias.jpg'
 WHERE title = 'Técnicos en Urgencias Médicas Nivel 1 (Básico)';

-- Verificacion: debe devolver 7
SELECT count(*) AS cursos_con_portada
FROM public.courses
WHERE thumbnail_url LIKE '%/thumbnails/%'
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
