# Contenido de los 7 cursos nuevos

Estos scripts cargan módulos, lecciones y examen final de los 7 cursos que estaban
publicados en la base pero vacíos (sin módulos, sin lecciones y sin contenido).

Cursos incluidos:

| Archivo | Curso | Norma de referencia |
|---|---|---|
| `01_montacargas.sql` | Manejo Seguro de Montacargas | NOM-006-STPS |
| `02_comision_seguridad_higiene_nom019.sql` | Comisión de Seguridad e Higiene | NOM-019-STPS-2011 |
| `03_sustancias_quimicas_nom018.sql` | Manejo Seguro de Sustancias Químicas Peligrosas | NOM-018-STPS-2015 |
| `04_instalaciones_electricas_nom029.sql` | Operación y Mantenimiento de Instalaciones Eléctricas | NOM-029-STPS-2011 |
| `05_ergonomia_nom036.sql` | Ergonomía y Manejo Manual de Cargas | NOM-036-1-STPS-2018 |
| `06_ctpat.sql` | Seguridad en la Cadena de Suministro y CTPAT | CTPAT (CBP) |
| `07_tecnicos_urgencias_medicas.sql` | Técnicos en Urgencias Médicas Nivel 1 | Atención médica prehospitalaria |

## Qué incluye cada curso

- 2 módulos
- 4 lecciones con contenido técnico en formato enriquecido
- Video de YouTube verificado en las lecciones que lo tienen
- Examen final de 10 preguntas con retroalimentación, meta de aprobación del 80%

Total: **14 módulos, 28 lecciones y 70 preguntas de examen**.

## Cómo ejecutarlos

1. Entrar a Supabase → SQL Editor.
2. Abrir el archivo del curso que se quiera cargar.
3. Copiar todo el contenido y ejecutarlo.

Los scripts son **idempotentes**: eliminan el contenido previo del curso antes de
insertarlo de nuevo. Se pueden volver a ejecutar sin generar duplicados ni lecciones
repetidas.

Al final de cada script hay una consulta de verificación que devuelve el número de
módulos y lecciones cargados para ese curso.

## Orden recomendado

Se pueden ejecutar en cualquier orden, uno por uno. No hay dependencias entre cursos.

## Nota sobre los videos

Todos los IDs de YouTube incluidos se verificaron contra la API de oEmbed de YouTube
para confirmar que el video existe y es público. Dos lecciones quedaron sin video y se
marcaron con `content_type = 'text'`:

- NOM-018, lección 4 (almacenamiento y respuesta a derrames)
- CTPAT, lección 4 (concientización y reporte de incidentes)
- TUM Nivel 1, lección 1 (rol del TUM, marco legal y bioseguridad)

Se les puede agregar video después desde el editor de cursos sin tocar el SQL.

## Pendiente fuera de este alcance

- Imágenes de portada (`thumbnail_url`): los 7 cursos nuevos no tienen imagen. El
  catálogo de la LMS muestra un ícono genérico y el sitio de marketing usa una imagen
  de respaldo, así que nada se ve roto, pero conviene subir las portadas al bucket
  `thumbnails` y actualizarlas.
