-- ============================================================
-- ACTUALIZACIÓN DE CURSOS CON FOTOS REALES (SUPABASE STORAGE)
-- Ejecutar en Supabase → SQL Editor
-- ============================================================

-- Nota: Reemplaza los nombres de archivo si los subiste con nombres distintos.
-- El bucket debe llamarse 'thumbnails' y ser PUBLIC.

-- 1. Seguridad en Trabajos en Alturas
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/alturas.jpg'
WHERE title ILIKE '%Alturas%';

-- 2. Seguridad en Trabajos de Soldadura y Oxicorte
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/soldadura.jpg'
WHERE title ILIKE '%Soldadura%';

-- 3. Formación de Brigadas de Emergencia
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/brigadas.jpg',
  title = 'Formación de Brigadas de Emergencia (Evacuación, Búsqueda y Rescate, Contra Incendios, Primeros Auxilios)'
WHERE title ILIKE '%Brigadas%';

-- 4. Seguridad en Espacios Confinados
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/confinados.jpg'
WHERE title ILIKE '%Confinados%';

-- 5. Aseguramiento de Energía (LOTO)
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/loto.jpg'
WHERE title ILIKE '%LOTO%';

-- 6. Formación de Instructores
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/instructores.jpg'
WHERE title ILIKE '%Formación de Instructores%';

-- 7. Formación de Supervisores de Seguridad y Salud Ocupacional
UPDATE public.courses SET
  thumbnail_url = 'https://tsqlpjliqslgzookdqvg.supabase.co/storage/v1/object/public/thumbnails/supervisores.jpg'
WHERE title ILIKE '%Supervisores%';

-- 8. Limpiar precios (asegurar $350)
UPDATE public.courses SET price = 350.00 WHERE is_published = true;

-- Verificar
SELECT id, title, thumbnail_url FROM public.courses ORDER BY id;
