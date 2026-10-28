-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- FORMACIÓN PARA INTEGRANTES DE LA COMISIÓN DE SEGURIDAD E HIGIENE
-- Referencia normativa: NOM-019-STPS-2011
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%'),
   'Marco Normativo y Constitución',
   'Obligaciones del patrón, constitución e integración de la comisión, perfil y funciones de los integrantes.',
   1),
  ((SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%'),
   'Operación y Funcionamiento',
   'Recorridos de verificación, reuniones, actas, seguimiento de acciones y registros.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%')
     AND order_index = 1),
  'Marco normativo y obligaciones del patrón',
  'Alcance de la NOM-019-STPS-2011, centros de trabajo obligados y obligaciones del patrón.',
  'mixed',
  '# Marco Normativo y Obligaciones del Patrón

La Comisión de Seguridad e Higiene es el órgano interno de participación mixta que existe entre el patrón y los trabajadores para identificar y atender los riesgos del centro de trabajo. No es un requisito documental: es el mecanismo que convierte la política de seguridad en acciones verificables.

## Marco normativo

La NOM-019-STPS-2011 establece la constitución, integración, organización y funcionamiento de las comisiones de seguridad e higiene en los centros de trabajo. Su cumplimiento es de carácter obligatorio.

La norma se apoya en el Reglamento Federal de Seguridad y Salud en el Trabajo y se complementa con las normas específicas de cada tipo de riesgo: trabajos en alturas, electricidad, sustancias químicas, ergonomía, entre otras.

## Centros de trabajo obligados

- Centros de trabajo con diez o más trabajadores: deben constituir e integrar una Comisión de Seguridad e Higiene, con igual número de representantes del patrón y de los trabajadores, y con representantes suplentes.
- Centros de trabajo con menos de diez trabajadores: deben designar a un encargado de seguridad e higiene que cumpla las funciones de promoción y verificación.
- Empresas con varios centros de trabajo: cada centro constituye su propia comisión, salvo que la autoridad determine otra cosa.

## Obligaciones del patrón

1. Constituir e integrar la comisión conforme a la norma.
2. Capacitar a los integrantes de la comisión en materia de seguridad e higiene.
3. Proporcionar los recursos materiales y el tiempo necesarios para las reuniones y recorridos.
4. Atender las observaciones y recomendaciones que emita la comisión.
5. Dar seguimiento a las acciones de mejora derivadas de los recorridos.
6. Registrar la constitución, los recorridos y las reuniones en las actas correspondientes.
7. Exhibir los registros cuando la autoridad laboral los solicite.

IMPORTANTE: la comisión puede observar y recomendar, pero la responsabilidad legal de corregir las condiciones inseguras permanece en el patrón. Una observación de la comisión sin respuesta del patrón se convierte en una evidencia de incumplimiento.

## Obligaciones de los integrantes

- Participar en los recorridos de verificación y en las reuniones
- Identificar y reportar condiciones inseguras o actos inseguros
- Promover entre sus compañeros el cumplimiento de las medidas de seguridad
- Dar seguimiento a los acuerdos hasta su cierre
- Guardar confidencialidad sobre la información sensible del centro de trabajo
- Mantenerse actualizado en materia de seguridad y salud

## Por qué importa operativamente

Una comisión que funciona reduce de forma directa la accidentabilidad. Los tres indicadores más claros de una comisión activa son:

- Recorridos realizados en la periodicidad establecida y con acta firmada
- Acciones de mejora con responsable y fecha compromiso
- Cierre efectivo de las acciones y verificación de su eficacia

# Conclusiones

La Comisión de Seguridad e Higiene es el puente formal entre la dirección y el personal operativo. Cuando ese puente funciona, los riesgos se detectan antes de que ocurra un accidente y las decisiones de seguridad se toman con información real del piso.',
  'https://www.youtube.com/embed/FZY2QnYn_6A',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%')
     AND order_index = 1),
  'Constitución, integración y funciones de la comisión',
  'Composición, elección de representantes, funciones del coordinador y del secretario, y acta de constitución.',
  'mixed',
  '# Constitución, Integración y Funciones de la Comisión

Una comisión mal integrada se convierte en un trámite: se firma el acta y no vuelve a operar. La norma exige un proceso claro de constitución para evitar exactamente eso.

## Composición

- Representantes del patrón y representantes de los trabajadores en igual número
- Un suplente por cada representante, con las mismas facultades en caso de ausencia
- Un coordinador designado por el patrón, que normalmente recae en el responsable de seguridad e higiene
- Un secretario electo de entre los representantes de los trabajadores

## Proceso de constitución

1. El patrón informa a los trabajadores el inicio del proceso de integración.
2. Se convoca a los trabajadores a participar como candidatos a representantes.
3. Se realiza la elección de los representantes de los trabajadores y de sus suplentes.
4. El patrón designa a sus propios representantes y al coordinador.
5. Se levanta el acta de constitución con nombre, puesto y firma de cada integrante.
6. Se capacita a los integrantes y se les informa formalmente sobre sus funciones.

## Funciones del coordinador

- Convocar a las reuniones y a los recorridos de verificación
- Dirigir la sesión de trabajo y ordenar los puntos del orden del día
- Informar al patrón sobre las condiciones inseguras detectadas
- Verificar que las acciones acordadas se ejecuten
- Mantener actualizado el archivo de actas y registros
- Promover la participación de todo el personal

## Funciones del secretario

- Elaborar el orden del día de cada sesión
- Levantar el acta de la reunión y la del recorrido de verificación
- Recabar las firmas de los asistentes
- Llevar el control del libro de actas
- Dar seguimiento documental a los acuerdos

## Funciones de los representantes

- Recorrer las áreas que les correspondan y detectar condiciones y actos inseguros
- Registrar los hallazgos en el formato correspondiente
- Proponer medidas de prevención y control
- Recibir observaciones de sus compañeros y llevarlas a la comisión
- Difundir las decisiones y las medidas adoptadas en su área

## Perfil del integrante

La norma no exige un perfil académico específico, pero sí requiere que los integrantes estén capacitados. Para que la comisión funcione se recomienda que cumplan con:

- Disposición para participar y disponibilidad de tiempo
- Conocimiento del área de trabajo donde fueron asignados
- Capacitación en seguridad e higiene
- Capacidad de comunicación con sus compañeros y con la dirección

IMPORTANTE: los representantes de los trabajadores no deben ser nombrados de forma unilateral por el patrón. Si la elección no se realizó, la constitución de la comisión es cuestionable ante una inspección laboral.

## Vigencia y renovación

Los integrantes permanecen en el cargo por el periodo que se establezca en el acta de constitución, y se renuevan conforme a la propia comisión. No renovar la comisión ni actualizar el acta cuando cambia el personal es una de las observaciones más frecuentes en las inspecciones.

# Conclusiones

La comisión se sostiene sobre tres documentos: el acta de constitución, el libro de actas de reunión y los registros de recorrido. Si esos tres registros existen y son consistentes, la comisión está funcionando; si falta uno, solo existe en papel.',
  'https://www.youtube.com/embed/UMjjfRBFoTI',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%')
     AND order_index = 2),
  'Recorridos de verificación de condiciones de seguridad',
  'Preparación del recorrido, listas de verificación, registro de hallazgos y clasificación por riesgo.',
  'mixed',
  '# Recorridos de Verificación de Condiciones de Seguridad

El recorrido de verificación es la herramienta operativa de la comisión. En él se observa el centro de trabajo, se documentan las condiciones y los actos inseguros, y se acuerdan acciones concretas.

## Periodicidad

La norma establece la obligación de realizar recorridos de verificación con una periodicidad mínima y de documentar cada uno mediante acta. Además, pueden realizarse recorridos extraordinarios cuando ocurra un cambio de proceso, un incidente o una situación que lo justifique.

## Preparación del recorrido

1. Definir la ruta y las áreas a verificar.
2. Formar el equipo de recorrido, procurando la participación mixta.
3. Llevar la lista de verificación del área y el formato de acta.
4. Revisar los hallazgos del recorrido anterior y el estado de las acciones pendientes.
5. Portar el equipo de protección personal requerido para las áreas a visitar.

## Elementos a verificar

| Elemento | Qué se revisa |
| Orden y limpieza | Áreas libres de obstáculos, residuos dispuestos correctamente |
| Equipo de protección personal | Disponibilidad, uso correcto y estado |
| Instalaciones eléctricas | Tapas, conexiones, señalización, ausencia de empalmes improvisados |
| Rutas y salidas de emergencia | Despejadas, señalizadas e iluminadas |
| Extintores | Carga, señalización, acceso libre y vigencia |
| Herramienta y equipo | Estado, guardas, mantenimiento |
| Sustancias químicas | Etiquetado, almacenamiento y hojas de datos de seguridad |
| Almacenamiento | Estabilidad de estiba, altura y capacidad |
| Ergonomía | Posturas forzadas, levantamiento de cargas, estaciones de trabajo |
| Documentación | Permisos, registros y procedimientos vigentes |

## Registro de hallazgos

Cada hallazgo debe describirse de forma objetiva, indicando:

- Área y ubicación exacta
- Descripción de la condición observada
- Clasificación del riesgo: alto, medio o bajo
- Fotografía o referencia, cuando aplique
- Acción recomendada
- Responsable y fecha compromiso

IMPORTANTE: un hallazgo debe describir la condición observada, no a la persona. Se registra (por ejemplo) que una escalera móvil no está asegurada, no que un trabajador sea descuidado. Esto evita conflictos internos y permite corregir la causa.

## Clasificación y priorización

- Riesgo alto: existe peligro inmediato de lesión grave o fatal. Requiere contención inmediata y suspensión de la actividad si es necesario.
- Riesgo medio: puede derivar en lesión si no se atiende en el corto plazo. Se programa en días.
- Riesgo bajo: desviación de orden documental o de condición menor. Se programa en el mes.

## Cierre de acciones

El recorrido no termina con el acta. Cada acción debe verificarse en sitio y marcarse como cerrada solo cuando se compruebe que la condición fue corregida. Las acciones que se repiten en varios recorridos indican que la causa raíz no fue atendida: ahí debe intervenir el análisis de fondo y no solo la corrección superficial.

# Conclusiones

Un recorrido bien hecho produce una lista corta de acciones reales, con responsables y fechas. Un recorrido mal hecho produce un acta extensa y ninguna corrección. La diferencia está en la calidad de la descripción de los hallazgos y en el seguimiento.',
  'https://www.youtube.com/embed/WGSmw_IhOUs',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-019%')
     AND order_index = 2),
  'Reuniones, actas y seguimiento',
  'Orden del día, elaboración de actas, acuerdos, difusión y archivo de registros.',
  'mixed',
  '# Reuniones, Actas y Seguimiento

La reunión de la comisión es donde los hallazgos se convierten en decisiones. Sin reunión, el recorrido produce observaciones sin destino.

## Periodicidad y convocatoria

Las reuniones de trabajo se realizan con la periodicidad que establece la norma y en todos los casos cuando exista un incidente o una situación que requiera atención inmediata. La convocatoria debe ser previa y debe incluir el orden del día.

## Orden del día típico

1. Pase de lista y verificación del quórum
2. Lectura y aprobación del acta anterior
3. Seguimiento de acuerdos pendientes
4. Presentación de los hallazgos del recorrido de verificación
5. Análisis de incidentes o accidentes ocurridos en el periodo
6. Propuestas de medidas de prevención y control
7. Acuerdos, responsables y fechas compromiso
8. Asuntos generales
9. Cierre y firma del acta

## Contenido mínimo del acta

- Fecha, hora y lugar de la reunión
- Nombre y firma de los asistentes
- Orden del día desarrollado
- Hallazgos y observaciones presentadas
- Acuerdos adoptados con responsable y fecha compromiso
- Asuntos pendientes de la sesión anterior
- Firma del coordinador y del secretario

## Del acuerdo al cierre

Un acuerdo sin responsable y sin fecha no es un acuerdo, es una intención. Cada acuerdo debe redactarse con:

- Acción concreta y verificable
- Responsable con nombre y puesto
- Fecha compromiso
- Evidencia de cierre esperada

IMPORTANTE: el acta se firma al término de la sesión o dentro de los días siguientes, y debe estar disponible para consulta de los trabajadores y de la autoridad laboral.

## Difusión

La comisión debe informar a los trabajadores sobre los resultados relevantes: riesgos detectados, medidas adoptadas y cambios en los procedimientos. La difusión puede hacerse por medios internos, en las juntas de área o mediante publicaciones en los tableros de avisos.

## Archivo y conservación

Los registros que deben conservarse y exhibirse son:

- Acta de constitución de la comisión
- Actas de reunión
- Actas o registros de recorrido de verificación
- Evidencia de la capacitación de los integrantes
- Registro de seguimiento de acciones

Estos documentos son la prueba objetiva del funcionamiento de la comisión. Se recomienda mantenerlos ordenados por fecha y con respaldo digital.

## Indicadores de una comisión efectiva

- Porcentaje de recorridos realizados contra programados
- Número de hallazgos por tipo y por área
- Porcentaje de acciones cerradas en el plazo comprometido
- Reincidencia de hallazgos: mide si la causa raíz se atendió
- Participación promedio de los integrantes en las sesiones

# Puntos clave

- La comisión se demuestra con registros, no con declaraciones
- Todo acuerdo necesita responsable, fecha y evidencia de cierre
- La difusión a los trabajadores forma parte de la función de la comisión
- La reincidencia de hallazgos es la señal de que se está corrigiendo el síntoma y no la causa

# Conclusiones

Una comisión activa es uno de los sistemas de prevención con mejor relación costo-beneficio en una empresa: detecta riesgos reales con personal que conoce el proceso, y genera acciones que la dirección puede priorizar y financiar con información concreta.',
  'https://www.youtube.com/embed/-YuMNJxf1B8',
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Comisión de Seguridad e Higiene (NOM-019)',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title ILIKE '%NOM-019%'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es el objeto de la NOM-019-STPS-2011?',
   'Regular el manejo de sustancias químicas', 'Establecer la constitución, integración, organización y funcionamiento de las comisiones de seguridad e higiene', 'Definir los límites de carga manual', 'Regular el mantenimiento de instalaciones eléctricas', 'b',
   'La NOM-019-STPS-2011 regula la constitución, integración, organización y funcionamiento de las comisiones de seguridad e higiene en los centros de trabajo.', 1),
  ('¿A partir de cuántos trabajadores se debe constituir una Comisión de Seguridad e Higiene?',
   'Cinco', 'Diez', 'Veinte', 'Cincuenta', 'b',
   'En centros de trabajo con diez o más trabajadores se constituye la comisión. Con menos de diez se designa un encargado de seguridad e higiene.', 2),
  ('¿Cómo deben integrarse los representantes del patrón y de los trabajadores?',
   'Con mayoría de representantes del patrón', 'En igual número, con un suplente por cada representante', 'Solo con representantes de los trabajadores', 'Con un representante externo que dirija la comisión', 'b',
   'La comisión se integra con igual número de representantes del patrón y de los trabajadores, cada uno con su suplente.', 3),
  ('¿Quién preside o coordina la comisión?',
   'El sindicato', 'El coordinador designado por el patrón', 'Un inspector de la autoridad laboral', 'El trabajador con mayor antigüedad', 'b',
   'El coordinador es designado por el patrón y normalmente recae en el responsable de seguridad e higiene del centro de trabajo.', 4),
  ('¿Cuál es una función del secretario de la comisión?',
   'Autorizar el presupuesto de seguridad', 'Levantar las actas de reunión y de recorrido, y recabar las firmas', 'Sancionar a los trabajadores', 'Sustituir al coordinador en todo momento', 'b',
   'El secretario elabora el orden del día, levanta las actas, recaba las firmas y lleva el control del libro de actas.', 5),
  ('Al registrar un hallazgo en un recorrido, ¿cómo debe describirse?',
   'Señalando el nombre del trabajador responsable', 'Describiendo la condición observada, su ubicación y su clasificación de riesgo', 'Solo con una fotografía sin texto', 'Indicando únicamente el área afectada', 'b',
   'Los hallazgos se describen de forma objetiva: condición observada, ubicación, clasificación de riesgo, acción recomendada, responsable y fecha compromiso.', 6),
  ('¿Qué caracteriza a un hallazgo clasificado como riesgo alto?',
   'Puede esperar al siguiente mes', 'Existe peligro inmediato de lesión grave o fatal y requiere contención inmediata', 'Es solo un tema documental', 'Solo aplica en áreas administrativas', 'b',
   'El riesgo alto implica peligro inmediato de lesión grave o fatal, por lo que exige contención inmediata y puede requerir suspender la actividad.', 7),
  ('¿Qué debe incluir todo acuerdo de la comisión para ser verificable?',
   'Solo la descripción de la acción', 'Acción concreta, responsable con nombre, fecha compromiso y evidencia de cierre', 'La firma de la autoridad laboral', 'Únicamente la fecha de la próxima reunión', 'b',
   'Un acuerdo sin responsable y sin fecha no es verificable. Debe indicar acción, responsable, fecha compromiso y evidencia esperada.', 8),
  ('¿Cuándo se considera cerrada una acción derivada de un recorrido?',
   'Cuando se firma el acta', 'Cuando se comprueba en sitio que la condición fue corregida', 'Cuando se asigna el recurso económico', 'Al pasar al siguiente recorrido', 'b',
   'La acción se cierra solo cuando se verifica en sitio que la condición fue corregida; de lo contrario permanece abierta.', 9),
  ('¿Qué indica la reincidencia de un mismo hallazgo en varios recorridos?',
   'Que la comisión trabaja bien', 'Que se está corrigiendo el síntoma y no la causa raíz', 'Que el hallazgo debe eliminarse del formato', 'Que el riesgo es bajo', 'b',
   'La reincidencia muestra que la corrección fue superficial. Se requiere analizar la causa raíz para evitar que la condición vuelva a presentarse.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Comisión de Seguridad e Higiene (NOM-019)';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title ILIKE '%NOM-019%';
