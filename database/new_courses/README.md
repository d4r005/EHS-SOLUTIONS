# Contenido de los 7 cursos nuevos

Scripts SQL con módulos, lecciones y examen final para los 7 cursos que estaban
publicados en la base sin contenido.

## Cómo aplicarlos

1. Abrir Supabase del proyecto → **SQL Editor**.
2. Pegar el contenido de **un archivo** y ejecutar.
3. Repetir con el siguiente archivo.

Se pueden ejecutar en cualquier orden. Cada archivo es independiente y
**idempotente**: si lo vuelves a ejecutar, borra el contenido previo de ese
curso y lo vuelve a insertar, sin duplicar lecciones ni preguntas.

Al final de cada script hay una consulta de verificación que devuelve los
módulos y las lecciones cargadas de ese curso.

## Títulos exactos que usa cada script

Cada archivo localiza el curso por su **título exacto**. Si el título no
coincide, el script se detiene con un error y no inserta nada (no aplica el
contenido al curso equivocado).

| Archivo | Curso | ID |
|---|---|---|
| `01_montacargas.sql` | Manejo Seguro de Montacargas | 13 |
| `02_comision_seguridad_higiene_nom019.sql` | Formación para Integrantes de la Comisión de Seguridad e Higiene (NOM-019-STPS-2011) | 14 |
| `03_sustancias_quimicas_nom018.sql` | Manejo Seguro de Sustancias Químicas Peligrosas (NOM-018-STPS-2015) | 15 |
| `04_instalaciones_electricas_nom029.sql` | Seguridad en Trabajos de Operación y Mantenimiento de Instalaciones Eléctricas (NOM-029-STPS-2011) | 16 |
| `05_ergonomia_nom036.sql` | Ergonomía y Manejo Manual de Cargas (NOM-036-1-STPS-2018) | 17 |
| `06_ctpat_corregido.sql` | Seguridad en la Cadena de Suministro y Concientización CTPAT | 18 |
| `07_tecnicos_urgencias_medicas.sql` | Técnicos en Urgencias Médicas Nivel 1 (Básico) | 19 |

## Qué carga cada curso

- 2 módulos
- 4 lecciones con contenido técnico y video de YouTube verificado
- 1 examen final de 10 preguntas con retroalimentación (aprobación al 80%)

En total: 14 módulos, 28 lecciones y 70 preguntas.

## Pendiente

Los 7 cursos no tienen imagen de portada (`thumbnail_url` en null). La LMS
muestra un ícono y el sitio de marketing usa una imagen de respaldo, así que
nada se ve roto. Falta subir las portadas al bucket `thumbnails` y actualizar
la columna.

## 08. Examenes por leccion (3 preguntas) + examen final (10 preguntas)

`08_examenes_por_leccion.sql` completa el esquema de evaluacion igual que en
los 7 cursos originales:

| Tipo | Donde se aplica | Preguntas | Aprobacion |
|------|-----------------|-----------|------------|
| Examen de leccion | En cada una de las 3 primeras lecciones | 3 | 70% |
| Examen final | En la ultima leccion del curso | 10 | 80% |

Resultado por curso: 4 examenes y 19 preguntas. No modifica el examen final,
solo agrega los de leccion. Es idempotente.
