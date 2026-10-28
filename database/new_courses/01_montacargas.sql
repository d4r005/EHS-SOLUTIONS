-- ============================================================
-- EHS SOLUTIONS - CONTENIDO DEL CURSO: MANEJO SEGURO DE MONTACARGAS
-- Curso nuevo (sin módulos ni lecciones)
-- Referencia normativa: NOM-006-STPS (manejo y almacenamiento de
-- materiales mediante el uso de maquinaria).
-- Ejecutar en Supabase -> SQL Editor
-- Es idempotente: se puede volver a ejecutar sin duplicar contenido.
-- ============================================================

BEGIN;

-- 1. Limpieza del contenido previo de este curso
DELETE FROM public.quizzes
WHERE lesson_id IN (
  SELECT l.id FROM public.lessons l
  JOIN public.modules m ON m.id = l.module_id
  WHERE m.course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%')
);

DELETE FROM public.modules
WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%');

-- 2. Módulos
INSERT INTO public.modules (course_id, title, description, order_index) VALUES
  ((SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%'),
   'Fundamentos y Marco Legal',
   'Normativa aplicable, tipos de montacargas, componentes y responsabilidades del operador.',
   1),
  ((SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%'),
   'Operación Segura y Prevención',
   'Estabilidad de carga, inspección preoperacional, maniobras críticas y prevención de accidentes.',
   2);

-- 3. Lecciones
INSERT INTO public.lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required) VALUES

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%')
     AND order_index = 1),
  'Marco normativo y responsabilidades del operador',
  'Normativa aplicable, obligaciones del patrón y del operador, y consecuencias del incumplimiento.',
  'mixed',
  '# Marco Normativo y Responsabilidades del Operador

El montacargas es una de las máquinas más eficientes del almacén, pero también una de las más peligrosas cuando se opera sin controles. Un montacargas promedio pesa entre 2 y 4 toneladas, y su carga puede rebasar las 3 toneladas adicionales. Un impacto a baja velocidad es suficiente para causar lesiones graves o fatales.

## Normativa aplicable

En México, las condiciones de seguridad para el manejo y almacenamiento de materiales mediante el uso de maquinaria están reguladas por la NOM-006-STPS. La versión vigente de 2023 sustituyó a la NOM-006-STPS-2014 y amplió los requisitos de capacitación, evaluación del operador y verificación del equipo.

Los ejes principales que exige la norma son:

- Identificación de los riesgos por tipo de maquinaria y por tipo de carga
- Capacitación teórica y práctica del operador, debidamente documentada
- Autorización formal del operador para cada tipo de montacargas
- Inspección del equipo antes de cada turno
- Programa de mantenimiento preventivo y correctivo
- Restricción de áreas de circulación y separación del tránsito de peatones
- Registro de las condiciones de seguridad y de los eventos ocurridos

## Obligaciones del patrón

- Proporcionar capacitación y adiestramiento específico, y evaluar al operador
- Entregar equipo de protección personal: casco, calzado de seguridad, chaleco de alta visibilidad y protección auditiva cuando aplique
- Mantener el equipo en condiciones seguras y con su programa de mantenimiento documentado
- Delimitar rutas de circulación, señalizar áreas de maniobra y separar el tránsito de peatones
- Verificar que la capacidad de carga del equipo sea visible y respetada
- Establecer procedimientos de trabajo seguro por escrito
- Investigar y registrar los incidentes y accidentes

## Obligaciones del operador

- Operar únicamente el tipo de montacargas para el que fue capacitado y autorizado
- Realizar la inspección preoperacional antes de cada turno
- Respetar la capacidad nominal de carga y el centro de carga
- Usar el cinturón de seguridad y mantener todas las partes del cuerpo dentro de la cabina
- No transportar personas en las horquillas ni en el contrapeso
- Reportar de inmediato cualquier falla, ruido anormal, fuga o comportamiento irregular del equipo
- Circular a velocidad moderada y hacer sonar la bocina en cruces y esquinas sin visibilidad
- No operar bajo los efectos del alcohol, de medicamentos o de fatiga extrema

IMPORTANTE: el operador tiene autoridad para detener la operación cuando las condiciones no sean seguras. Ninguna meta de producción justifica una maniobra riesgosa.

## Consecuencias del incumplimiento

Los accidentes con montacargas suelen involucrar a personas que no son el operador: peatones, ayudantes de almacén y personal de carga. Los escenarios más frecuentes son atropellamiento en maniobra de reversa, atrapamiento entre el equipo y una estructura, caída de carga sobre el personal y volcadura lateral.

Además del daño humano, el incumplimiento normativo expone a la empresa a sanciones, a la clausura parcial de áreas y a responsabilidades civiles y penales.

# Conclusiones

La seguridad con montacargas no depende solo de la habilidad del operador: depende de un sistema que combina capacitación documentada, equipo en buen estado, áreas segregadas y supervisión constante. El operador es la última línea de defensa, pero no la única.',
  'https://www.youtube.com/embed/4t2vupLJsvQ',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%')
     AND order_index = 1),
  'Tipos de montacargas, componentes y revisión preoperacional',
  'Clasificación del equipo, componentes principales y verificación diaria antes de operar.',
  'mixed',
  '# Tipos de Montacargas y Revisión Preoperacional

No todos los montacargas son iguales ni se operan de la misma forma. Conocer el tipo de equipo que se va a operar es el primer paso para identificar sus riesgos.

## Clasificación por fuente de energía

- Eléctricos: alimentados por batería, ideales para interiores y almacenes cerrados porque no generan emisiones. Requieren área de carga de baterías con ventilación y control de derrames.
- Combustión interna a gas LP o gasolina: mayor potencia, para exteriores o instalaciones bien ventiladas.
- Diésel: para patios, obra y manejo de cargas pesadas en superficies irregulares.

## Clasificación por tipo de operación

- Contrabalanceado: el más común. La carga se equilibra con el contrapeso trasero.
- Reach o de alcance: para pasillos angostos y racks de gran altura.
- Transpaleta eléctrica: para movimiento horizontal de tarimas a nivel de piso.
- Todo terreno: para obra exterior y superficies sin pavimento.

## Componentes principales

| Componente | Función | Punto de verificación |
| Mástil | Eleva y sostiene la carga | Cadenas, mangueras, soldaduras |
| Horquillas | Soportan la tarima | Desgaste, grietas, seguro de posición |
| Contrapeso | Equilibra la carga | Fijación, sin modificaciones |
| Frenos | Detención del equipo | Carrera del pedal, fuga de líquido |
| Dirección | Control de trayectoria | Juego excesivo, ruido |
| Llantas | Contacto y tracción | Desgaste, cortes, presión |
| Alarma de reversa | Aviso a peatones | Funcionamiento y volumen |
| Cinturón | Retención del operador | Anclaje y estado de la banda |

## Revisión preoperacional

La revisión se realiza al inicio de cada turno, con el equipo apagado y estacionado en superficie plana. Debe quedar registrada en el formato correspondiente.

1. Revisar niveles de aceite hidráulico, refrigerante y combustible, o el estado de carga de la batería.
2. Inspeccionar el mástil, las cadenas y las mangueras hidráulicas en busca de fugas, desgaste o deformaciones.
3. Verificar el estado de las horquillas: sin grietas, sin desgaste excesivo y con el seguro de posición en su lugar.
4. Comprobar llantas, espejos, luces, alarma de reversa, claxon y torreta de advertencia.
5. Revisar el asiento, el cinturón de seguridad y los controles en busca de holguras.
6. Verificar el nivel de líquido de frenos y la respuesta del freno de estacionamiento.
7. Probar la dirección y el sistema hidráulico en vacío, elevando y bajando el mástil sin carga.

IMPORTANTE: si alguna verificación falla, el equipo se etiqueta como fuera de servicio, se retira la llave y se reporta al supervisor. Nunca se opera un montacargas con una falla conocida en frenos, dirección o sistema hidráulico.

## Registro y trazabilidad

El formato de revisión diaria debe incluir fecha, hora, número económico del equipo, nombre del operador y las observaciones detectadas. Este registro es evidencia de cumplimiento y permite detectar fallas recurrentes antes de que provoquen un accidente.

# Conclusiones

La revisión preoperacional toma entre cinco y diez minutos y previene la mayoría de las fallas que derivan en accidentes. Es una obligación normativa, pero sobre todo es la forma más económica de proteger al operador y a quienes trabajan alrededor del equipo.',
  'https://www.youtube.com/embed/ovZUfpv5bjE',
  30, 2, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%')
     AND order_index = 2),
  'Estabilidad, centro de carga y capacidad nominal',
  'Triángulo de estabilidad, centro de carga, volcaduras y reglas de manejo de carga.',
  'mixed',
  '# Estabilidad, Centro de Carga y Capacidad Nominal

La mayoría de las volcaduras de montacargas no ocurren por exceso de peso, sino por manejo incorrecto de la carga y de la altura. Entender la física del equipo es lo que permite anticipar la pérdida de estabilidad.

## El triángulo de estabilidad

El montacargas se apoya en tres puntos: las dos ruedas delanteras y el eje de dirección trasero. Con esos tres puntos se forma un triángulo imaginario. El equipo permanece estable mientras el centro de gravedad combinado del montacargas y de la carga permanece dentro de ese triángulo.

Cuando el centro de gravedad sale del triángulo, el equipo vuelca. Esto puede ocurrir de dos formas:

- Volcadura lateral: giro demasiado cerrado con carga elevada y velocidad alta.
- Volcadura longitudinal: carga excesiva, mástil inclinado hacia adelante o carga levantada en pendiente.

## Centro de carga

El centro de carga es la distancia horizontal entre la cara vertical de las horquillas y el centro de gravedad de la carga. La mayoría de los montacargas se diseñan para un centro de carga de 24 pulgadas (600 mm).

La placa de capacidades indica cuánto peso puede levantar el equipo a distintas alturas y con distintos centros de carga. Si la carga es más profunda que el centro de carga de diseño, la capacidad real disminuye aunque el peso nominal no cambie.

- Carga compacta y centrada: capacidad completa
- Carga profunda o voluminosa: capacidad reducida
- Carga elevada a gran altura: capacidad reducida adicionalmente

IMPORTANTE: la capacidad nominal solo es válida con el mástil en posición vertical y la carga recogida cerca del piso. A mayor altura, menor capacidad real.

## Reglas de manejo de carga

1. Verificar el peso de la carga antes de levantarla. Nunca estimar por percepción.
2. Centrar la carga en las horquillas y recogerla completamente hasta el respaldo.
3. Inclinar ligeramente el mástil hacia atrás durante el traslado.
4. Transportar siempre con la carga baja, a no más de 15 a 20 cm del piso.
5. Circular en reversa cuando la carga obstruya la visibilidad frontal.
6. No girar con la carga elevada. Bajar la carga, girar y volver a elevarla.
7. Descender pendientes en reversa y subirlas de frente, siempre con la carga baja.
8. No permitir que ninguna persona se coloque bajo la carga ni frente al mástil.

## Volcaduras: qué hacer y qué no hacer

Si el equipo comienza a volcar, el instinto de saltar es el más peligroso. Saltar expone al operador a quedar atrapado bajo el techo de protección o bajo el contrapeso.

- Permanecer en la cabina con el cinturón abrochado
- Sujetarse firmemente del volante
- Inclinar el cuerpo en dirección opuesta a la volcadura
- No saltar en ningún caso

# Conclusiones

La estabilidad se gestiona antes de mover la carga: verificando peso, centro de carga y altura. Un operador que entiende el triángulo de estabilidad anticipa la volcadura en lugar de reaccionar a ella.',
  'https://www.youtube.com/embed/khaAy2gTQ4o',
  30, 1, true
),

(
  (SELECT id FROM public.modules
   WHERE course_id = (SELECT id FROM public.courses WHERE title ILIKE '%Montacargas%')
     AND order_index = 2),
  'Maniobras críticas, peatones y prevención de accidentes',
  'Circulación, visibilidad, interacción con peatones, almacenamiento en racks y carga de transporte.',
  'mixed',
  '# Maniobras Críticas y Prevención de Accidentes

Cerca de la mitad de los accidentes graves con montacargas involucran a un peatón. Por eso la operación segura se diseña alrededor de la separación entre personas y equipos.

## Reglas de circulación

- Respetar los límites de velocidad del área; en interiores no se recomienda exceder 10 km/h
- Hacer sonar la bocina en cruces, esquinas y puertas sin visibilidad
- Mantener distancia de seguridad con otros equipos y con peatones
- Encender luces y torreta de advertencia durante todo el turno
- No usar el teléfono celular ni audífonos durante la operación
- Detenerse por completo antes de cambiar de dirección

## Interacción con peatones

- Establecer rutas peatonales delimitadas y respetarlas
- Hacer contacto visual con el peatón antes de pasar cerca de él
- Detener el equipo cuando una persona se encuentre a menos de dos metros del área de maniobra
- No permitir que nadie pase por debajo de las horquillas ni del mástil
- Prohibir el transporte de pasajeros, salvo que el equipo tenga asiento homologado para ello

## Maniobras críticas

### Carga y descarga de transporte

1. Verificar que el vehículo esté frenado y con calzas en las ruedas.
2. Comprobar que el piso del transporte soporte el peso del montacargas.
3. Usar rampas con pendiente controlada y con bordes de retención.
4. Entrar de frente y salir en reversa cuando la maniobra lo permita.

### Almacenamiento en racks

- Verificar la capacidad del rack y el nivel de carga permitido
- Alinear la carga con el compartimento antes de elevarla
- Elevar con el mástil vertical y sin movimiento de avance simultáneo
- Confirmar que la tarima quede completamente apoyada antes de retirar las horquillas
- Reportar de inmediato cualquier golpe al rack: un rack dañado puede colapsar

### Áreas de carga de baterías

- Ventilación permanente y prohibición de flamas abiertas
- Equipo de protección para manejo de ácido y para el cambio de batería
- Control de derrames con material absorbente
- Procedimiento específico para conexión y desconexión del cargador

## Factores humanos

El cansancio, la prisa y la rutina son las tres causas más frecuentes de error del operador. Un turno de 12 horas sin pausas incrementa de forma significativa la probabilidad de error en maniobras de precisión.

- Respetar las pausas y los periodos de descanso
- Rotar tareas cuando sea posible
- Reportar la fatiga antes de que se convierta en un error
- No operar después de una jornada nocturna sin dormir

# Puntos clave

- La separación entre peatones y montacargas es la medida preventiva de mayor impacto
- Todo golpe a un rack debe reportarse y evaluarse estructuralmente
- El transporte de personas es una de las causas más graves de accidente fatal
- La fatiga es un riesgo operativo, no un asunto personal

# Conclusiones

Operar un montacargas de forma segura es una decisión sostenida: en cada cruce, en cada reversa y en cada carga elevada. La técnica se aprende, pero la disciplina se practica todos los días.',
  'https://www.youtube.com/embed/c3QVUZNv77o',
  30, 2, true
);

-- 4. Examen final (10 preguntas) sobre la última lección del curso
INSERT INTO public.quizzes (lesson_id, title, description, passing_score, total_questions, is_active)
SELECT l.id,
       'Examen Final: Manejo Seguro de Montacargas',
       'Evaluación técnica de 10 preguntas. Requiere 80% para aprobar.',
       80, 10, true
FROM public.lessons l
JOIN public.modules m ON m.id = l.module_id
JOIN public.courses c ON c.id = m.course_id
WHERE c.title ILIKE '%Montacargas%'
ORDER BY l.id DESC
LIMIT 1;

INSERT INTO public.quiz_questions (quiz_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, order_index)
SELECT q.id, v.qt, v.a, v.b, v.c, v.d, v.correct, v.exp, v.ord
FROM public.quizzes q
CROSS JOIN (VALUES
  ('¿Cuál es la norma mexicana que regula el manejo y almacenamiento de materiales mediante el uso de maquinaria?',
   'NOM-019-STPS', 'NOM-006-STPS', 'NOM-036-1-STPS', 'NOM-029-STPS', 'b',
   'La NOM-006-STPS establece las condiciones de seguridad para el manejo y almacenamiento de materiales con maquinaria, incluidos los montacargas.', 1),
  ('¿Cuántos puntos de apoyo conforman el triángulo de estabilidad de un montacargas contrabalanceado?',
   'Dos', 'Tres', 'Cuatro', 'Cinco', 'b',
   'Son tres: las dos ruedas delanteras y el eje de dirección trasero. Mientras el centro de gravedad permanezca dentro de ese triángulo, el equipo es estable.', 2),
  ('¿Qué es el centro de carga de un montacargas?',
   'El peso máximo que puede levantar', 'La distancia entre la cara de las horquillas y el centro de gravedad de la carga', 'El punto donde se engancha el remolque', 'La altura máxima del mástil', 'b',
   'El centro de carga es la distancia horizontal entre la cara vertical de las horquillas y el centro de gravedad de la carga. Si la carga es más profunda, la capacidad real se reduce.', 3),
  ('¿Cuál es la altura recomendada para transportar una carga con el montacargas?',
   'A la altura máxima del mástil', 'Entre 15 y 20 cm del piso', 'A un metro del piso', 'A la altura de la cintura del operador', 'b',
   'La carga debe transportarse baja, a no más de 15 a 20 cm del piso, con el mástil inclinado ligeramente hacia atrás.', 4),
  ('¿Qué debe hacer el operador si el montacargas comienza a volcar?',
   'Saltar del equipo de inmediato', 'Permanecer en la cabina con el cinturón abrochado y sujetarse del volante', 'Extender los brazos para amortiguar la caída', 'Acelerar para enderezar el equipo', 'b',
   'Saltar es la reacción más peligrosa: expone al operador a quedar atrapado bajo el techo de protección o el contrapeso. Debe permanecer en la cabina con el cinturón puesto.', 5),
  ('¿Qué se debe hacer si durante la revisión preoperacional se detecta una falla en los frenos?',
   'Operar solo tareas ligeras', 'Reportarlo al final del turno', 'Etiquetar el equipo como fuera de servicio, retirar la llave y reportar de inmediato', 'Compensar la falla frenando con el mástil', 'b',
   'Ante cualquier falla en frenos, dirección o sistema hidráulico, el equipo se retira de servicio de inmediato y se reporta al supervisor.', 6),
  ('¿En qué caso se recomienda circular en reversa?',
   'Siempre que se transporte carga', 'Cuando la carga obstruye la visibilidad frontal', 'Cuando se sube una pendiente', 'Solo en el área de carga de baterías', 'b',
   'Cuando la carga impide ver el camino se circula en reversa para mantener la visibilidad, salvo al subir pendientes, donde se avanza de frente con carga baja.', 7),
  ('¿Cómo se debe ascender una pendiente con carga?',
   'En reversa, con la carga elevada', 'De frente, con la carga baja', 'De frente, con la carga elevada', 'En diagonal para reducir el esfuerzo', 'b',
   'Las pendientes se suben de frente con la carga baja y se descienden en reversa, para mantener la estabilidad del conjunto.', 8),
  ('¿Cuál es la medida preventiva de mayor impacto para evitar atropellamientos en el almacén?',
   'Colocar espejos en las esquinas', 'La separación y delimitación de rutas peatonales', 'Aumentar la velocidad de circulación', 'Reducir el número de operadores', 'b',
   'Delimitar rutas peatonales y separar el tránsito de personas y equipos es la medida con mayor impacto para prevenir atropellamientos.', 9),
  ('¿Qué se debe hacer ante un golpe a un rack de almacenamiento?',
   'Nada, si la tarima sigue en su lugar', 'Reportarlo de inmediato y evaluar estructuralmente el rack', 'Repintar la zona dañada', 'Mover la carga a otro nivel y continuar', 'b',
   'Un rack dañado puede colapsar. Todo golpe debe reportarse y evaluarse estructuralmente antes de seguir usándolo.', 10)
) AS v(qt, a, b, c, d, correct, exp, ord)
WHERE q.title = 'Examen Final: Manejo Seguro de Montacargas';

COMMIT;

-- Verificación
SELECT c.title AS curso,
       (SELECT COUNT(*) FROM public.modules m WHERE m.course_id = c.id) AS modulos,
       (SELECT COUNT(*) FROM public.lessons l
        JOIN public.modules m ON m.id = l.module_id
        WHERE m.course_id = c.id) AS lecciones
FROM public.courses c
WHERE c.title ILIKE '%Montacargas%';
