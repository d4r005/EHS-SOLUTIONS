-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO:
-- MANEJO SEGURO DE SUSTANCIAS QUÍMICAS PELIGROSAS
-- Referencia normativa: NOM-018-STPS-2015 (Sistema armonizado para
-- la identificación y comunicación de peligros y riesgos por
-- sustancias químicas peligrosas)
-- Ejecutar en Supabase -> SQL Editor
-- Idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%');

INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%'),
   'Marco Normativo y Comunicación de Peligros',
   'Obligaciones del patrón, sistema armonizado, pictogramas y señalización.',
   1),
  ((SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%'),
   'Identificación, Almacenamiento y Respuesta',
   'Hojas de datos de seguridad, compatibilidad de almacenamiento y atención a derrames.',
   2);

INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%')
     AND order_index = 1),
  'Marco normativo y comunicación de peligros',
  'Alcance de la NOM-018-STPS-2015, inventario de sustancias y obligaciones del patrón.',
  'mixed',
  '# Marco Normativo y Comunicación de Peligros

Cada sustancia química peligrosa que entra a un centro de trabajo debe llegar acompañada de información que permita identificar su peligro, manejarla correctamente y responder ante una emergencia. Esa es la lógica central de la comunicación de peligros.

## Marco normativo

La NOM-018-STPS-2015 establece el Sistema Armonizado para la Identificación y Comunicación de Peligros y Riesgos por Sustancias Químicas Peligrosas en los centros de trabajo. Su cumplimiento es obligatorio en todo centro donde se manejen, almacenen, transporten o desechen sustancias químicas peligrosas.

La norma adopta el Sistema Globalmente Armonizado (SGA o GHS, por sus siglas en inglés), lo que permite que la información de peligro sea consistente con la que utilizan los proveedores y con los estándares internacionales.

## Obligaciones del patrón

1. Elaborar y mantener actualizado el inventario de sustancias químicas peligrosas del centro de trabajo.
2. Disponer de la hoja de datos de seguridad (SDS) de cada sustancia, en español, accesible para los trabajadores.
3. Etiquetar todos los recipientes y envases conforme al sistema armonizado.
4. Capacitar a los trabajadores expuestos sobre los peligros, las medidas de protección y los procedimientos de emergencia.
5. Establecer las condiciones de almacenamiento y compatibilidad de las sustancias.
6. Proporcionar el equipo de protección personal y los controles de ingeniería necesarios.
7. Contar con procedimientos de respuesta ante derrames, fugas y exposiciones.
8. Informar a los trabajadores sobre los resultados de los monitoreos cuando existan.

## Elementos de la comunicación de peligros

La comunicación de peligros se sostiene en tres elementos que deben coincidir entre sí:

- La etiqueta del recipiente
- La hoja de datos de seguridad
- La capacitación del trabajador

Si la etiqueta dice una cosa y la SDS dice otra, el sistema falla. La consistencia entre estos tres elementos es lo que se verifica en una auditoría.

IMPORTANTE: un recipiente sin etiqueta es un riesgo grave. Cuando se trasvasa una sustancia a un envase secundario, ese envase debe etiquetarse de inmediato con el nombre del producto y los pictogramas de peligro correspondientes.

## Inventario de sustancias

El inventario debe incluir, como mínimo:

| Dato | Uso |
| Nombre químico y comercial | Identificación inequívoca |
| Proveedor | Rastreo de la SDS actualizada |
| Cantidad máxima almacenada | Dimensionamiento de controles |
| Ubicación | Respuesta a emergencias |
| Peligros principales | Selección de EPP y extinción |
| Clasificación SGA | Etiquetado y señalización |
| Uso en el proceso | Evaluación de exposición |

Mantener el inventario actualizado permite saber, en una emergencia, qué sustancias están involucradas y qué riesgos representan para el personal y para quien atiende la emergencia.

# Conclusiones

La comunicación de peligros no es un trámite de compras: es el mecanismo que permite que cualquier trabajador, en cualquier turno, sepa qué está manejando y cómo protegerse. Si la información no está disponible en el punto de uso, el riesgo está presente.',
  'https://www.youtube.com/embed/Ro0T6mz6ktI',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%')
     AND order_index = 1),
  'Sistema armonizado: pictogramas, palabras de advertencia y etiquetas',
  'Los nueve pictogramas del SGA, palabras de advertencia, indicaciones de peligro y consejos de prudencia.',
  'mixed',
  '# Sistema Armonizado: Pictogramas y Etiquetas

El Sistema Globalmente Armonizado utiliza un lenguaje visual y textual estandarizado. Su ventaja es que el mismo símbolo significa lo mismo en cualquier país y en cualquier idioma.

## Los nueve pictogramas

Los pictogramas son rombos con borde rojo, fondo blanco y símbolo negro. El SGA contempla nueve:

| Pictograma | Representa | Ejemplo de sustancia |
| Llama | Inflamables | Acetona, gasolina |
| Llama sobre círculo | Comburentes | Peróxido de hidrógeno |
| Bomba explotando | Explosivos | Percloratos |
| Cilindro de gas | Gases a presión | Oxígeno, acetileno |
| Corrosión | Corrosivos a metales y piel | Ácido sulfúrico |
| Calavera y tibias | Toxicidad aguda | Cianuro |
| Signo de exclamación | Irritantes y nocivos | Variables |
| Peligro para la salud | Carcinógenos, sensibilizantes | Benceno |
| Medio ambiente | Peligro acuático | Variables |

## Partes de una etiqueta conforme

- Identificación del producto: nombre químico o comercial
- Pictogramas de peligro aplicables
- Palabra de advertencia: PELIGRO o ATENCION, según la severidad
- Indicaciones de peligro: frases que describen la naturaleza del riesgo
- Consejos de prudencia: acciones de prevención y respuesta
- Datos del proveedor: nombre, domicilio y teléfono de emergencia

## Palabras de advertencia

- PELIGRO: se utiliza para las categorías de mayor severidad
- ATENCION: se utiliza para categorías de menor severidad

La palabra de advertencia no sustituye al pictograma: ambos deben aparecer. Una etiqueta que solo dice PELIGRO sin pictograma no cumple con el sistema.

IMPORTANTE: los pictogramas nunca se seleccionan por costumbre ni por el color del producto. Se determinan a partir de la clasificación de peligro que aparece en la hoja de datos de seguridad del proveedor.

## Señalización en áreas de almacenamiento

Además de las etiquetas de los recipientes, las áreas donde se almacenan sustancias químicas deben estar señalizadas con:

- Pictogramas de los peligros presentes en el área
- Prohibición de fumar y de generar flamas abiertas
- Ubicación de regaderas, lavaojos y extintores
- Rutas de evacuación y punto de reunión
- Restricción de acceso a personal no autorizado

## Errores frecuentes

- Reutilizar envases de alimentos o bebidas para sustancias químicas
- Etiquetas escritas a mano sin pictogramas ni palabra de advertencia
- Etiquetas deterioradas por humedad o solventes
- Recipientes secundarios sin identificación
- Pictogramas impresos en blanco y negro sin el borde rojo

Cualquiera de estos errores rompe la cadena de comunicación y es una de las causas más comunes de exposición accidental en el puesto de trabajo.

# Puntos clave

- El rombo con borde rojo es la forma estándar del pictograma del SGA
- Pictograma, palabra de advertencia e indicaciones de peligro deben aparecer juntos
- El envase secundario siempre se etiqueta
- La información debe ser legible y estar en el idioma del trabajador

# Conclusiones

El sistema armonizado funciona porque es visual y consistente. Un trabajador que reconoce los nueve pictogramas puede identificar el riesgo de un recipiente que nunca ha visto antes, incluso antes de leer su nombre químico.',
  'https://www.youtube.com/embed/i_zneqBZzVo',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%')
     AND order_index = 2),
  'Hojas de datos de seguridad (SDS) y su uso real',
  'Estructura de las 16 secciones de la SDS y cómo usarlas en la operación y en emergencias.',
  'mixed',
  '# Hojas de Datos de Seguridad (SDS)

La hoja de datos de seguridad es el documento técnico que describe la sustancia, sus peligros, los controles requeridos y la respuesta ante una emergencia. Es la fuente principal de información y el respaldo documental de la etiqueta.

## Estructura de las 16 secciones

El formato armonizado contempla dieciséis secciones:

1. Identificación de la sustancia y del proveedor
2. Identificación de los peligros
3. Composición e información sobre los componentes
4. Primeros auxilios
5. Medidas de lucha contra incendios
6. Medidas que deben tomarse en caso de derrame o fuga
7. Manipulación y almacenamiento
8. Controles de exposición y protección personal
9. Propiedades físicas y químicas
10. Estabilidad y reactividad
11. Información toxicológica
12. Información ecotoxicológica
13. Consideraciones sobre la eliminación
14. Información relativa al transporte
15. Información reglamentaria
16. Otra información, incluida la fecha de revisión

## Cómo usar la SDS en la práctica

- Antes de recibir una sustancia nueva: revisar secciones 2, 7, 8 y 10 para definir EPP, almacenamiento y compatibilidad.
- Para atender una emergencia: revisar secciones 4, 5 y 6, que contienen primeros auxilios, extinción y contención de derrames.
- Para verificar compatibilidad de almacenamiento: revisar sección 10, sobre estabilidad y reactividad.
- Para conocer el equipo de protección requerido: revisar sección 8, que define los controles de exposición.

IMPORTANTE: la SDS debe estar en español, actualizada y accesible en el área donde se usa la sustancia. Una SDS guardada en una oficina cerrada no cumple su función: en una emergencia nadie va a ir a buscarla.

## Verificación de actualidad

- Confirmar la fecha de revisión en la sección 16
- Solicitar la versión vigente al proveedor con cada compra o cambio de formulación
- Sustituir la versión anterior en el archivo físico y digital
- Comunicar los cambios relevantes a los trabajadores expuestos

## Lo que la SDS no resuelve

La SDS describe el peligro de la sustancia, pero no evalúa el riesgo de la operación completa. La evaluación de la exposición real depende de:

- Cantidad manejada
- Frecuencia y duración de la tarea
- Condiciones de ventilación
- Controles de ingeniería instalados
- Prácticas de trabajo observadas

Por eso la SDS se complementa con la evaluación de riesgo del puesto y con el monitoreo ambiental cuando aplica.

# Conclusiones

La SDS es un documento de consulta operativa, no un requisito de archivo. Un trabajador capacitado que sabe qué secciones consultar puede resolver en minutos una duda de compatibilidad, de primeros auxilios o de protección personal.',
  'https://www.youtube.com/embed/vRPNGlJADZs',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%NOM-018%')
   AND order_index = 2),
  'Almacenamiento seguro, compatibilidad y respuesta a derrames',
  'Segregación por incompatibilidad, condiciones de almacén y procedimiento ante derrames y exposiciones.',
  'text',
  '# Almacenamiento Seguro y Respuesta a Derrames

Una parte importante de los incidentes químicos ocurre en el almacén y no en el proceso. La causa suele ser la mezcla de sustancias incompatibles o el deterioro de los envases.

## Reglas generales de almacenamiento

- Almacenar en áreas ventiladas, frescas y protegidas de la luz solar directa
- Mantener los envases cerrados y en posición vertical
- No almacenar por encima de la altura recomendada ni sobre estanterías inestables
- Separar sólidos de líquidos y evitar el contacto entre ellos en caso de derrame
- Colocar diques o charolas de contención bajo los envases de líquidos
- Identificar cada área con pictogramas y con restricción de acceso
- Mantener extintores, lavaojos y regaderas de emergencia accesibles y verificados

## Incompatibilidad de sustancias

La incompatibilidad es la tendencia de dos sustancias a reaccionar de forma peligrosa al contacto. Las combinaciones de mayor riesgo son:

| Grupo | Incompatible con | Consecuencia |
| Oxidantes | Inflamables, orgánicos | Incendio o explosión |
| Ácidos | Bases, cianuros, metales | Reacción violenta, gases tóxicos |
| Bases | Ácidos, metales reactivos | Generación de hidrógeno |
| Agua reactivos | Agua | Reacción exotérmica o incendio |
| Peróxidos | Calor, luz, contaminantes | Descomposición explosiva |

IMPORTANTE: la compatibilidad de almacenamiento se define con la sección 10 de la hoja de datos de seguridad de cada sustancia. Cuando exista duda sobre dos productos, no se almacenan juntos.

## Segregación práctica

1. Agrupar por familia química compatible, no por orden de llegada.
2. Dejar pasillos libres para inspección y para respuesta a emergencias.
3. Colocar los productos más peligrosos en áreas de acceso controlado.
4. Rotar existencias aplicando primero lo más antiguo.
5. Revisar periódicamente la fecha de caducidad y el estado de los envases.

## Procedimiento ante un derrame

1. Alertar al personal y delimitar la zona.
2. Evacuar a quien no participe en la respuesta.
3. Identificar la sustancia con la etiqueta y consultar la SDS, sección 6.
4. Colocarse el equipo de protección personal indicado.
5. Detener la fuente si es posible hacerlo sin exponerse.
6. Contener con material absorbente adecuado, trabajando de afuera hacia adentro.
7. Ventilar el área.
8. Recoger el material contaminado en recipiente identificado para su disposición.
9. Reportar el evento y evaluar si se requiere atención médica.

## Exposición y primeros auxilios

- Contacto con la piel: retirar la ropa contaminada y lavar con agua abundante al menos quince minutos.
- Salpicadura en ojos: irrigar con agua en el lavaojos, manteniendo los párpados abiertos, y acudir a valoración médica.
- Inhalación: mover a la persona a un lugar con aire fresco y mantenerla en reposo.
- Ingestión: no inducir el vómito salvo indicación médica; consultar de inmediato la SDS y a urgencias.

# Puntos clave

- La segregación por incompatibilidad previene la mayor parte de los incidentes de almacén
- Todo derrame se atiende con la SDS en mano y con el EPP indicado
- Los absorbentes deben ser compatibles con la sustancia
- La disposición final de residuos requiere recipientes identificados

# Conclusiones

Un almacén químico seguro se reconoce por tres señales: etiquetas completas y legibles, segregación visible por familia química y equipos de emergencia accesibles y verificados. Lo demás es documentación que sostiene esas tres condiciones.',
  NULL,
  30, 2, true
);

INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Sustancias Químicas Peligrosas (NOM-018)',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title ILIKE '%NOM-018%'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es el objetivo de la NOM-018-STPS-2015?',
   'Regular el manejo de montacargas', 'Establecer el sistema armonizado de identificación y comunicación de peligros por sustancias químicas', 'Definir los límites de carga manual', 'Regular las comisiones de seguridad', 'b',
   'La NOM-018-STPS-2015 adopta el Sistema Globalmente Armonizado para identificar y comunicar los peligros de las sustancias químicas en los centros de trabajo.', 1),
  ('¿Cuántos pictogramas contempla el sistema globalmente armonizado?',
   'Seis', 'Nueve', 'Doce', 'Dieciséis', 'b',
   'El SGA contempla nueve pictogramas, todos en forma de rombo con borde rojo, fondo blanco y símbolo negro.', 2),
  ('¿Cuáles son las dos palabras de advertencia que utiliza el sistema armonizado?',
   'Cuidado y Precaución', 'PELIGRO y ATENCION', 'Alto y Riesgo', 'Advertencia y Cuidado', 'b',
   'Se utilizan PELIGRO para las categorías de mayor severidad y ATENCION para las de menor severidad.', 3),
  ('¿Qué se debe hacer al trasvasar una sustancia química a un envase secundario?',
   'Etiquetarlo de inmediato con el nombre del producto y los pictogramas', 'Usarlo dentro del mismo turno sin etiqueta', 'Identificarlo solo de forma verbal', 'Marcarlo con una letra si el trabajador la recuerda', 'a',
   'Todo envase secundario debe etiquetarse de inmediato con nombre del producto y pictogramas. Un recipiente sin etiqueta es un riesgo grave.', 4),
  ('¿En qué sección de la hoja de datos de seguridad se consultan los primeros auxilios?',
   'Sección 2', 'Sección 4', 'Sección 8', 'Sección 14', 'b',
   'La sección 4 contiene las medidas de primeros auxilios. La 5 corresponde a extinción de incendios y la 6 a derrames y fugas.', 5),
  ('¿Qué sección de la SDS indica la compatibilidad de almacenamiento?',
   'Sección 3', 'Sección 10, estabilidad y reactividad', 'Sección 13', 'Sección 16', 'b',
   'La sección 10 describe la estabilidad y reactividad, e incluye las incompatibilidades que condicionan el almacenamiento conjunto.', 6),
  ('¿Qué combinación representa un riesgo grave de incendio o explosión?',
   'Agua y sal', 'Oxidantes con materiales inflamables', 'Aceite y arena', 'Detergente y agua', 'b',
   'Los oxidantes reaccionan violentamente con materiales inflamables y orgánicos, con riesgo de incendio o explosión.', 7),
  ('¿Cuál es el primer paso ante un derrame de sustancia química?',
   'Limpiar de inmediato sin protección', 'Alertar al personal y delimitar la zona', 'Salir del área sin avisar', 'Agregar agua para diluir', 'b',
   'Primero se alerta y se delimita la zona. Después se identifica la sustancia, se consulta la SDS y se actúa con el EPP indicado.', 8),
  ('¿Cuánto tiempo mínimo se recomienda irrigar un ojo salpicado con sustancia química?',
   'Diez segundos', 'Un minuto', 'Al menos quince minutos con agua abundante', 'Hasta que deje de arder', 'c',
   'La irrigación debe ser abundante y sostenida por al menos quince minutos, manteniendo los párpados abiertos, y con valoración médica posterior.', 9),
  ('¿Qué condición debe cumplir la hoja de datos de seguridad en el centro de trabajo?',
   'Estar archivada en oficina central', 'Estar en español, actualizada y accesible en el área de uso', 'Estar solo en formato digital', 'Estar en el idioma del proveedor', 'b',
   'La SDS debe estar en español, vigente y disponible en el punto de uso, para que pueda consultarse durante una emergencia.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Sustancias Químicas Peligrosas (NOM-018)';

COMMIT;

SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title ILIKE '%NOM-018%';
