-- ============================================
-- EHS SOLUTIONS - ACTUALIZACION DE CONTENIDO DE LECCIONES
-- Contenido de texto + videos de YouTube para las 28 lecciones
-- Ejecutar en Supabase SQL Editor
-- ============================================


-- Leccion 31: Marco normativo y riesgos de caída
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Marco Normativo y Riesgos de Caída en Trabajos en Alturas

## 1. Definición de Trabajo en Alturas

Se define como trabajo en alturas toda actividad laboral realizada a una altura mayor a 1.8 metros sobre el nivel del suelo o referencia inferior. Esto incluye trabajos en techos, andamios, plataformas, escaleras, torres, postes y estructuras elevadas.

## 2. Marco Normativo: NOM-009-STPS-2011

La Norma Oficial Mexicana NOM-009-STPS-2011 establece las condiciones de seguridad para realizar trabajos en alturas. Es obligatoria para todos los centros de trabajo donde se realicen actividades a más de 1.8 metros de altura.

**Disposiciones clave:**
- Todo trabajador en alturas debe recibir capacitación específica antes de iniciar labores
- El empleador debe proporcionar equipo de protección personal certificado
- Debe existir un análisis de riesgo previo a cada trabajo en alturas
- Se debe contar con un plan de rescate en caso de caída
- Los equipos de protección deben inspeccionarse antes de cada uso

## 3. Riesgos Principales

### Caídas desde altura
Es el riesgo principal y una de las causas más frecuentes de accidentes mortales en el sector construcción e industrial. La gravedad del daño depende de la altura de caída, la superficie de impacto y el peso del trabajador.

### Golpes por objetos desprendidos
Herramientas, materiales o escombros que caen desde altura pueden lesionar al trabajador que realiza la tarea o a personas que transitan debajo.

### Factores ambientales
Viento, lluvia, hielo y temperaturas extremas pueden afectar la estabilidad del trabajador y las condiciones de la superficie de trabajo.

### Fatiga y estrés térmico
El trabajo en alturas exige esfuerzo físico sostenido. La exposición prolongada al sol o al calor puede causar deshidratación, mareos y pérdida de equilibrio.

### Contacto con líneas eléctricas
El trabajo en alturas cerca de líneas eléctricas aéreas representa un riesgo de electrocución por contacto directo o por arco eléctrico.

## 4. Responsabilidades

**Del empleador:**
- Proporcionar capacitación certificada
- Suministrar EPP adecuado y certificado
- Elaborar análisis de riesgo y permisos de trabajo
- Garantizar condiciones seguras de la estructura

**Del trabajador:**
- Usar correctamente el EPP
- Seguir los procedimientos establecidos
- Reportar condiciones inseguras
- No realizar trabajos si las condiciones no son seguras

## 5. Conclusiones

El trabajo en alturas es una actividad de alto riesgo que requiere capacitación, equipamiento adecuado y procedimientos estrictos. La normativa NOM-009-STPS-2011 establece los requisitos mínimos para proteger la vida de los trabajadores. El cumplimiento de esta norma no es opcional: es una obligación legal y moral.',
  video_url = 'https://www.youtube.com/embed/dVEx7Eaacdw'
WHERE id = 31;

-- Leccion 32: Equipo de protección personal contra caídas
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Equipo de Protección Personal Contra Caídas

## 1. Introducción

El Equipo de Protección Personal (EPP) contra caídas es la última línea de defensa para un trabajador en alturas. Si bien las medidas colectivas (barandillas, redes) son prioritarias, el EPP individual es obligatorio cuando no es posible eliminar el riesgo de caída.

## 2. Componentes del Sistema de Protección Contra Caídas

Un sistema completo consta de tres elementos fundamentales:

### A. Arnés de Cuerpo Completo
Distribuye las fuerzas de impacto por todo el cuerpo en caso de caída. Debe:
- Ser certificado (ANSI Z359.1 o equivalente)
- Ajustarse firmemente al cuerpo sin causar lesiones
- Tener puntos de anclaje dorsal (espalda) y frontal (esternón)
- Inspeccionarse antes de cada uso buscando cortes, abrasiones, costuras dañadas o deformaciones

### B. Elemento de Conexión
Conecta el arnés al punto de anclaje. Puede ser:
- **Línea de retención:** evita que el trabajador llegue al borde de caída
- **Amortiguador de impacto:** absorbe energía durante una caída, reduciendo la fuerza de impacto a menos de 8 kN
- **Retractable (self-retracting lifeline):** se bloquea automáticamente ante una caída
- **Línea de posicionamiento:** permite al trabajador mantenerse en una posición específica con las manos libres

### C. Punto de Anclaje
Es el punto donde se conecta el elemento de conexión. Debe soportar como mínimo 22 kN (2,200 kg) por persona conectada.

## 3. Otros Elementos de Protección

### Casco de Seguridad
Protege contra golpes por objetos desprendidos y contra impacto en caso de caída. Debe contar con barbiquejo para evitar que se desprenda durante una caída.

### Calzado de Seguridad
Con puntera de acero o composite, suela antideslizante y clavos o tacos para mejor adherencia en superficies elevadas.

### Guantes de Protección
Mejoran el agarre y protegen contra abrasiones y cortes al manipular cuerdas y equipos.

## 4. Inspección del EPP

**Antes de cada uso:**
1. Examinar el arnés buscando cortes, quemaduras, costuras deshilachadas
2. Verificar que las hebillas y ajustes funcionen correctamente
3. Revisar el amortiguador de impacto para detectar señales de activación previa
4. Comprobar que las etiquetas de certificación estén legibles

**Después de una caída:**
Todo equipo que haya soportado una caída DEBE ser retirado de servicio inmediatamente, incluso si no presenta daños visibles. Debe ser inspeccionado por un fabricante o persona certificada antes de volver a usarse, o ser reemplazado.

## 5. Vida Útil del EPP

- Arnés: 5 años desde la fecha de fabricación (o antes si hay daños)
- Amortiguador de impacto: 5 años
- Retractable: según indicaciones del fabricante, con mantenimiento periódico
- Líneas de vida sintéticas: 5 años o según desgaste

## 6. Conclusiones

El EPP contra caídas salva vidas solo si se usa correctamente. Un arnés mal ajustado, un anclaje débil o un equipo dañado pueden ser tan peligrosos como no usar protección. La capacitación, la inspección rutinaria y el reemplazo oportuno son fundamentales.',
  video_url = 'https://www.youtube.com/embed/M8WYW5NutI8'
WHERE id = 32;

-- Leccion 33: Sistemas de anclaje y líneas de vida
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Sistemas de Anclaje y Líneas de Vida

## 1. Concepto de Punto de Anclaje

El punto de anclaje es el elemento que soporta al trabajador en caso de caída. Es el componente más crítico del sistema de protección, ya que si falla, ningún otro elemento puede evitar la caída.

**Requisitos mínimos:**
- Resistencia mínima de 22 kN (2,200 kg) por persona conectada
- Debe estar fijado a una estructura estructuralmente sólida
- No se deben usar tuberías, conductos eléctricos, barandillas no certificadas o puntos no estructurales

## 2. Tipos de Sistemas de Anclaje

### Anclajes Fijos
Puntos de anclaje permanentes instalados en la estructura del edificio o instalación. Incluyen argollas, ojillos y postes de anclaje certificados. Son ideales para trabajos recurrentes en la misma ubicación.

### Anclajes Temporales
Dispositivos que se instalan para una tarea específica y se retiran al finalizar. Incluyen cintas de anclaje (sling), cables de anclaje y trípodes para accesos verticales.

### Líneas de Vida Horizontales
Sistemas de cable o cuerda tensados entre dos o más puntos de anclaje, que permiten al trabajador desplazarse horizontalmente mientras permanece conectado. Pueden ser temporales o permanentes.

### Líneas de Vida Verticales
Cables o cuerdas instalados verticalmente, con un dispositivo de retracción o freno que sigue al trabajador durante su ascenso o descenso. Son comunes en torres, postes y escaleras fijas.

## 3. Consideraciones de Diseño

### Factor de Caída
Es la relación entre la altura de caída y la longitud de la línea de conexión. Un factor de caída 2 (máximo) significa que el trabajador cae el doble de la longitud de su línea. El factor debe mantenerse lo más bajo posible.

### Distancia Libre de Caída
Es el espacio libre necesario debajo del trabajador para que el sistema de detención funcione completamente sin que este golpee el suelo o un obstáculo. Se calcula considerando: longitud de la línea, despliegue del amortiguador, elongación, altura del trabajador y margen de seguridad (mínimo 1 metro).

### Ángulo de la Línea de Vida Horizontal
Las líneas de vida horizontales no deben tener una flecha (sag) mayor a 15 grados respecto a la horizontal. Un ángulo mayor aumenta enormemente las fuerzas sobre los puntos de anclaje.

## 4. Certificación y Mantenimiento

- Todo sistema de anclaje debe ser diseñado e instalado por personas certificadas
- Debe contar con documentación de cálculo estructural
- Inspección visual antes de cada uso
- Inspección detallada anual por persona competente
- Registro de inspecciones y mantenimiento

## 5. Errores Comunes

- Usar como anclaje puntos no certificados (barandillas, tuberías)
- Conectar más personas de las certificadas a un solo punto
- No considerar la distancia libre de caída
- Usar líneas de vida horizontal sin certificación de diseño
- No inspeccionar los puntos de anclaje antes de cada uso

## 6. Conclusiones

Un sistema de anclaje es tan fuerte como su eslabón más débil. La correcta selección, instalación e inspección de los puntos de anclaje y líneas de vida es lo que hace que el sistema completo funcione. Nunca se debe comprometer la seguridad del anclaje por conveniencia o rapidez.',
  video_url = 'https://www.youtube.com/embed/6KiICwTtj2Y'
WHERE id = 33;

-- Leccion 34: Procedimientos de rescate y emergencia
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Procedimientos de Rescate y Emergencia en Alturas

## 1. Importancia del Plan de Rescate

Un trabajador que queda suspendido en un arnés después de una caída tiene un tiempo limitado antes de sufrir el síndrome de suspensión (trauma por suspensión). Este síndrome puede causar la muerte en menos de 30 minutos debido a la acumulación de sangre en las piernas por la presión del arnés.

**El rescate no es una opción, es una obligación.** Todo trabajo en alturas debe tener un plan de rescate antes de comenzar.

## 2. Síndrome de Suspensión

Cuando un trabajador queda suspendido e inmóvil en un arnés, la sangre se acumula en las piernas, reduciendo el flujo sanguíneo al cerebro y al corazón. Los síntomas incluyen:
- Palidez, sudoración, náuseas
- Dificultad para respirar
- Pérdida de conciencia (en 5-20 minutos)
- Posible paro cardíaco (en 10-30 minutos)

**El rescate debe realizarse en menos de 10 minutos para evitar consecuencias graves.**

## 3. Tipos de Rescate

### Autorescate
El trabajador caído se rescata a sí mismo usando dispositivos de descenso controlado, escaleras cercanas o cuerdas de rescate.

### Rescate por Compañero
Un compañero entrenado ejecuta el rescate usando sistemas de poleas y cuerdas, dispositivos de descenso o camillas de rescate.

### Rescate por Equipo Especializado
Requiere un equipo de rescate profesional con equipos avanzados. Este es el último recurso y no debe ser la única opción planificada.

## 4. Elementos del Plan de Rescate

1. **Identificación de riesgos:** Analizar todos los escenarios posibles de caída
2. **Medios de comunicación:** Radio, teléfono o señales visuales para activar el rescate
3. **Equipo de rescate disponible:** En el sitio, no en un almacén lejano
4. **Personal capacitado:** Al menos una persona en el sitio debe saber ejecutar el rescate
5. **Ruta de evacuación:** Definir cómo se trasladará al trabajador a un centro médico
6. **Contactos de emergencia:** Números de bomberos, ambulancia, médico

## 5. Procedimiento de Rescate Paso a Paso

1. **Avisar inmediatamente:** Comunicar la emergencia con precisión (ubicación, condición del trabajador)
2. **Asegurar el área:** Evitar que otras personas se expongan al mismo riesgo
3. **Evaluar el estado del trabajador:** ¿Está consciente? ¿Tiene lesiones visibles?
4. **Ejecutar el rescate:** Usar el método planificado (auto, compañero, equipo)
5. **Bajar al trabajador:** Nunca dejarlo suspendido más tiempo del necesario
6. **Primeros auxilios:** Atender lesiones y monitorear signos vitales
7. **Traslado médico:** Llevar al trabajador a un centro médico para evaluación

## 6. Equipo de Rescate Básico

- Cuerdas de rescate certificadas
- Dispositivo de descenso controlado
- Poleas y bloqueantes
- Camilla de rescate (si aplica)
- Botiquín de primeros auxilios
- Radio de comunicación
- Navaja o cuchillo para cortar cuerdas si es necesario

## 7. Conclusiones

Un plan de rescate no es un documento que se archiva: es un plan que se practica. Los trabajadores que realizan labores en alturas deben saber qué hacer en caso de una caída, tener el equipo necesario a mano y practicar el rescate regularmente. Un rescate tardío puede convertir una caída sin lesiones graves en un accidente mortal.',
  video_url = 'https://www.youtube.com/embed/4R4rW1Lr5cs'
WHERE id = 34;

-- Leccion 35: Identificación de riesgos de soldadura y oxicorte
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Identificación de Riesgos en Soldadura y Oxicorte

## 1. Introducción

Los trabajos de soldadura y oxicorte son actividades de alto riesgo que involucran temperaturas extremas, gases comprimidos, electricidad y generación de humos tóxicos. La identificación de riesgos es el primer paso para prevenir accidentes.

## 2. Riesgos Eléctricos

La soldadura por arco eléctrico utiliza corrientes de 50 a 500 amperios. Los riesgos incluyen:
- **Electrocución:** Por contacto con partes eléctricamente vivas del equipo o electrodos
- **Arco eléctrico:** Por cortocircuitos en el equipo o cables dañados
- **Quemaduras eléctricas:** Por paso de corriente a través del cuerpo

**Medidas preventivas:** Verificar el estado de cables y pinzas antes de cada uso, asegurar que el equipo esté conectado a tierra, no soldar en ambientes húmedos o con ropa mojada, usar guantes dieléctricos y calzado aislante.

## 3. Riesgos por Radiación

El arco eléctrico emite radiación en tres espectros:
- **Ultravioleta (UV):** Causa flash burn (quemadura de córnea) y cáncer de piel
- **Infrarroja (IR):** Causa cataratas y quemaduras térmicas
- **Visible:** Causa fatiga visual y dolor de cabeza

**Medidas preventivas:** Usar casco de soldar con filtro adecuado (mínimo grado 10), proteger a personas cercanas con pantallas o biombos, usar ropa que cubra todo el cuerpo.

## 4. Riesgos por Humos y Gases

La soldadura genera humos metálicos que pueden contener: hierro (irritación respiratoria), manganeso (daño neurológico), cromo hexavalente (cancerígeno), níquel (cancerígeno), plomo (daño neurológico), cadmio (daño pulmonar). Los gases incluyen ozono, monóxido de carbono y óxidos de nitrógeno.

**Medidas preventivas:** Ventilación localizada cerca del punto de soldadura, ventilación general del área, respirador con filtro para metales si la ventilación no es suficiente, monitoreo de calidad del aire en espacios cerrados.

## 5. Riesgos de Incendio y Explosión

Las chispas y el calor del proceso de soldadura pueden alcanzar más de 1,500°C. Los riesgos incluyen ignición de materiales combustibles cercanos, explosión de gases o vapores inflamables, explosión de cilindros de gases comprimidos por daño o calor.

**Medidas preventivas:** Limpiar el área de materiales combustibles en un radio de 10 metros, usar permiso de trabajo en caliente, tener un extintor a mano (tipo ABC o CO2), ventilar el área para eliminar vapores inflamables, inspeccionar cilindros y mangueras antes de cada uso.

## 6. Riesgos Ergonómicos

Los soldadores trabajan frecuentemente en posiciones incómodas (arrodillado, acostado, con el brazo levantado). Esto causa lesiones musculoesqueléticas, fatiga y lumbalgias.

**Medidas preventivas:** Rotar tareas para evitar posturas sostenidas, usar soportes y posicionadores para piezas, realizar pausas activas.

## 7. Conclusiones

La soldadura y el oxicorte combinan múltiples riesgos: eléctrico, radiación, humos tóxicos, incendio y ergonómico. La identificación de cada riesgo y la implementación de medidas preventivas son esenciales. La norma NOM-027-STPS establece los requisitos de seguridad para estos trabajos en México.',
  video_url = 'https://www.youtube.com/embed/s9zmCuPhLWI'
WHERE id = 35;

-- Leccion 36: Equipo de protección personal especializado
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Equipo de Protección Personal Especializado para Soldadura

## 1. Introducción

El soldador trabaja con temperaturas extremas, radiación intensa, chispas, humos y riesgos eléctricos. El EPP especializado para soldadura es más completo que el de muchas otras actividades y debe usarse en su totalidad.

## 2. Protección de la Cabeza y Ojos

### Casco de Soldar
Es el elemento más importante del EPP del soldador. Protege los ojos de la radiación y la cara de chispas y salpicaduras.

**Tipos:**
- **Manual (fijo):** El soldador levanta y baja el filtro manualmente
- **Automático (fotoquímico):** El filtro se oscurece automáticamente al detectar el arco

**Especificaciones del filtro:** Grado de oscurecimiento 9-13 según el proceso y amperaje. Protección UV e IR siempre activa. Debe cumplir norma ANSI Z49.1 o equivalente.

### Gafas de Seguridad
Se usan debajo del casco de soldar para proteger los ojos al levantar el filtro (inspeccionar la soldadura). Deben tener protección lateral.

## 3. Protección Respiratoria

Cuando la ventilación no es suficiente, el soldador debe usar un respirador con filtro para partículas metálicas (filtro P100) o filtro combinado para partículas y gases. En ambientes confinados o con metales altamente tóxicos (cromo, níquel), puede requerirse respirador con suministro de aire o equipo de respiración autónomo (SCBA).

## 4. Protección del Cuerpo

### Chaqueta y Pantalón de Cuero
El cuero cromado es el material estándar para la ropa del soldador. Protege contra chispas, salpicaduras y calor radiante.

### Mandil de Cuero
Protege el pecho y el regazo cuando se suelda en posiciones verticales o sobre cabeza.

### Capucha (Pasamontañas) de Cuero
Protege el cuello, orejas y parte posterior de la cabeza de chispas y calor radiante. Es indispensable para soldadura sobre cabeza.

### Mangas de Cuero
Protegen los brazos cuando se usa solo chaqueta corta o camisola.

## 5. Protección de Manos y Pies

### Guantes de Soldador
Guantes largos de cuero que protegen hasta el antebrazo. Deben ser resistentes al calor y chispas, dieléctricos y flexibles para permitir el manejo de la pinza.

### Calzado de Seguridad
Botas de cuero con puntera de acero, suela resistente al calor y sin cordones expuestos (o con cubierta) para evitar que las chispas los quemen.

## 6. Protección del Entorno

### Biombos o Pantallas
Protegen a otros trabajadores de la radiación del arco eléctrico. Deben rodear el área de soldadura.

### Manta Ignífuga
Cubre materiales o superficies que no se pueden retirar del área de trabajo.

## 7. Inspección y Mantenimiento del EPP

- Inspeccionar el casco de soldar antes de cada uso (filtro, batería si es automático)
- Revisar la ropa de cuero en busca de agujeros o desgaste
- Reemplazar filtros del respirador según indicaciones del fabricante
- Limpiar el EPP regularmente (el cuero grasiento se daña)
- No usar EPP dañado: una chaqueta con agujeros no protege contra chispas

## 8. Conclusiones

El EPP para soldadura es extenso y específico. Cada pieza tiene un propósito: el casco protege los ojos, el cuero protege la piel, el respirador protege los pulmones. Ningún elemento debe omitirse. Un soldador que no usa todo su EPP está expuesto a quemaduras, lesiones oculares, enfermedades respiratorias y cáncer.',
  video_url = 'https://www.youtube.com/embed/YWLFrlibDJI'
WHERE id = 36;

-- Leccion 37: Permisos de trabajo en caliente
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Permisos de Trabajo en Caliente

## 1. ¿Qué es un Permiso de Trabajo en Caliente?

Un permiso de trabajo en caliente es un documento autorizado que permite realizar actividades que generan calor, chispas o llamas en áreas donde pueden existir materiales combustibles o inflamables. Es un control administrativo fundamental para prevenir incendios y explosiones.

## 2. Actividades que Requieren Permiso

- Soldadura (arco eléctrico, gas, TIG, MIG, puntos)
- Oxicorte (corte con soplete)
- Esmerilado que genere chispas
- Uso de sopletes o antorchas
- Trabajo con herramientas que generen calor o chispas
- Aplicación de pintura con pistola a presión
- Trabajos con soldadura plástica (termofusión)

## 3. Contenido del Permiso

### Información General
- Fecha y hora de inicio y fin del trabajo
- Ubicación exacta (área, piso, equipo)
- Descripción de la tarea a realizar
- Nombre del trabajador que ejecuta la tarea
- Nombre del supervisor que autoriza

### Evaluación de Riesgos
- Materiales combustibles/inflamables presentes en el área
- Medidas de control implementadas
- Ventilación del área
- Atmósfera segura (sin gases inflamables)

### Medidas de Control
- Limpieza del área (radio mínimo 10 metros)
- Retiro o protección de materiales combustibles
- Extintor disponible y tipo correcto
- Vigía de fuego asignado
- Barreras y señalización del área

### Firmas
- Trabajador: confirma que entiende los riesgos
- Supervisor: autoriza el trabajo
- Vigía de fuego: confirma que puede vigilar

## 4. Proceso de Autorización

1. **Solicitud:** El trabajador o supervisor solicita el permiso con anticipación
2. **Inspección:** El supervisor o personal de seguridad inspecciona el área
3. **Evaluación:** Se evalúan los riesgos y se definen medidas de control
4. **Autorización:** El supervisor autorizado firma el permiso
5. **Ejecución:** El trabajo se realiza siguiendo los controles establecidos
6. **Cierre:** Al finalizar, se inspecciona el área para detectar puntos calientes
7. **Monitoreo:** Se vigila el área durante 30-60 minutos después de finalizado el trabajo

## 5. El Vigía de Fuego

El vigía de fuego es una persona asignada específicamente para vigilar el área durante el trabajo en caliente. Sus funciones:
- Permanecer en el área durante todo el trabajo
- Observar la generación de chispas y su trayectoria
- Tener un extintor listo para usar
- Detener el trabajo si aparecen riesgos no controlados
- Inspeccionar el área después de finalizado el trabajo

## 6. Prohibiciones

- No realizar trabajo en caliente sin permiso vigente
- No trabajar en áreas con atmósferas inflamables sin certificar
- No trabajar cerca de almacenamiento de líquidos inflamables
- No trabajar en espacios confinados sin ventilación adecuada
- No realizar trabajo en caliente si no hay vigía de fuego asignado
- No continuar el trabajo si las condiciones cambian

## 7. Casos Especiales

### Trabajo en Caliente en Paredes o Suelos
Las chispas pueden viajar a través de grietas o conductos a áreas adyacentes. Se debe inspeccionar el otro lado de la pared/piso y proteger las áreas adyacentes.

### Trabajo en Caliente en Tanques o Recipientes
Los tanques que contuvieron líquidos inflamables deben limpiarse, purgarse y certificarse como seguros antes de cualquier trabajo en caliente.

## 8. Conclusiones

El permiso de trabajo en caliente no es un trámite burocrático: es una herramienta de prevención. Cada permiso obliga a evaluar el área, controlar los riesgos y asignar responsables. Un permiso bien elaborado puede prevenir incendios, explosiones y accidentes mortales.',
  video_url = 'https://www.youtube.com/embed/xnMxgSJWoQs'
WHERE id = 37;

-- Leccion 38: Prevención de incendios y explosiones
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Prevención de Incendios y Explosiones en Trabajos en Caliente

## 1. El Triángulo del Fuego

Para que exista fuego se requieren tres elementos: 1) Combustible (material que arde), 2) Oxígeno (presente en el aire), 3) Calor (fuente de ignición). La prevención de incendios se basa en eliminar al menos uno de estos elementos.

## 2. Fuentes de Ignición en Trabajos en Caliente

- Chispas de soldadura (alcanzan hasta 1,500°C y viajan varios metros)
- Chispas de esmerilado
- Llamas de soplete
- Superficies calientes (metal recién soldado)
- Escorias incandescentes que pueden caer por grietas o conductos

## 3. Materiales Combustibles Comunes

Madera, cartón, papel, plásticos, fibra de vidrio, líquidos inflamables (gasolina, solventes, pinturas, thinner), gases inflamables (acetileno, propano, gas natural), polvos combustibles (aserrín, polvo de grano, polvo metálico), grasa y aceites, ropa y textiles.

## 4. Medidas de Prevención

### Antes del Trabajo
1. Limpiar el área: retirar todos los materiales combustibles en un radio mínimo de 10 metros
2. Proteger lo que no se puede retirar: cubrir con mantas ignífugas
3. Verificar el otro lado: si se suelda en una pared o piso, verificar que no haya materiales combustibles al otro lado
4. Drenar y purgar tanques y tuberías
5. Ventilar el área para eliminar vapores inflamables
6. Verificar atmósfera: medir concentración de gases inflamables con detector

### Durante el Trabajo
1. Asignar vigía de fuego
2. Mantener extintor a mano (tipo ABC o CO2, cargado y certificado)
3. Controlar chispas con pantallas o barreras
4. Revisar periódicamente el área
5. Detener si hay cambios

### Después del Trabajo
1. Inspeccionar el área buscando puntos calientes, brasas ocultas
2. Mantener vigilancia 30-60 minutos después
3. Cerrar el permiso

## 5. Prevención de Explosiones

### Explosión de Gases
Ocurre cuando un gas inflamable se mezcla con aire en concentraciones dentro del rango de explosividad (LEL-UEL). Prevenir ventilando áreas cerradas, midiendo concentración de gas antes de trabajar, no realizar trabajo en caliente si la concentración supera el 0% del LEL.

### Explosión de Polvo
Polvos combustibles suspendidos en el aire pueden explotar. Prevenir limpiando el polvo acumulado, ventilando para dispersar polvo suspendido.

### Explosión de Cilindros de Gas
Los cilindros de acetileno o propano pueden explotar si se exponen a calor o fuego. Prevenir manteniendo cilindros alejados del área, asegurándolos en posición vertical con cadenas, cerrando válvulas cuando no se usen.

## 6. Uso de Extintores: Método PASS

- **P**ull (jalar): Jalar el seguro del extintor
- **A**im (apuntar): Apuntar la manguera a la base del fuego
- **S**queeze (apretar): Apretar la palanca
- **S**weep (barrer): Barrer de lado a lado

## 7. Conclusiones

La prevención de incendios en trabajos en caliente se basa en la preparación: limpiar el área, proteger materiales, ventilar, medir gases, asignar vigía y tener extintor. Un solo descuido puede causar un incendio que destruya instalaciones y cueste vidas. La disciplina en el procedimiento es la mejor protección.',
  video_url = 'https://www.youtube.com/embed/dcIT4ySKY0Y'
WHERE id = 38;

-- Leccion 39: Roles y funciones del brigadista
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Roles y Funciones del Brigadista de Emergencia

## 1. ¿Qué es una Brigada de Emergencia?

Una brigada de emergencia es un grupo de trabajadores capacitados, entrenados y organizados dentro de una empresa para prevenir, responder y controlar situaciones de emergencia. Su objetivo es proteger la vida, los bienes y el medio ambiente ante incidentes.

## 2. Tipos de Brigadas

- **Brigada de Combate de Incendios:** Capacitada para combatir conatos de incendio usando extintores portátiles y mangueras.
- **Brigada de Evacuación:** Encargada de dirigir la evacuación del personal hacia puntos de reunión seguros.
- **Brigada de Primeros Auxilios:** Capacitada para atender lesionados, aplicar RCP, controlar hemorragias y estabilizar víctimas.
- **Brigada de Búsqueda y Rescate:** Encargada de localizar y rescatar personas atrapadas o perdidas durante una emergencia.

## 3. Roles Específicos

### Jefe de Brigada
Coordina a todos los brigadistas durante la emergencia, toma decisiones sobre evacuación, combate y solicitud de ayuda externa. Es el enlace con servicios de emergencia externos (bomberos, ambulancia).

### Brigadista de Combate
Combate el fuego con extintores y mangueras, verifica que el área esté libre de personas antes de combatir, cierra válvulas y corta servicios (gas, electricidad) si es necesario.

### Brigadista de Evacuación
Recorre las áreas asignadas verificando que no quede personal, guía al personal por rutas de evacuación hacia puntos de reunión, asiste a personas con movilidad reducida, reporta al jefe de brigada que su área está desalojada.

### Brigadista de Primeros Auxilios
Atiende a los lesionados en el punto de reunión, aplica RCP, controla hemorragias, entablilla fracturas, mantiene comunicación con servicios médicos externos.

### Brigadista de Búsqueda y Rescate
Busca personas en áreas de difícil acceso, utiliza técnicas de rescate seguras, traslada víctimas a zonas seguras para atención médica.

## 4. Requisitos para ser Brigadista

- Disposición voluntaria
- Estado físico y mental adecuado
- Disponibilidad de tiempo para capacitación
- Liderazgo y capacidad de decisión
- Mantener la calma bajo presión

## 5. Capacitación del Brigadista

Todo brigadista debe recibir capacitación periódica en: combate de incendios (uso de extintores y mangueras), primeros auxilios (RCP, control de hemorragias, inmovilización), evacuación y rutas de escape, comunicación de emergencia, identificación de riesgos, primer respondiente.

La capacitación debe ser práctica, no solo teórica. Los simulacros son la mejor forma de entrenar a las brigadas.

## 6. Organización Interna

- La brigada debe estar estructurada por áreas o pisos
- Cada área debe tener al menos un brigadista asignado
- Debe existir un organigrama visible y accesible
- Los brigadistas deben ser identificables (chalecos, cascos de color distintivo)
- Debe haber suplentes para cada rol

## 7. Conclusiones

Una brigada de emergencia bien organizada puede salvar vidas. Cada brigadista tiene un rol específico y debe conocerlo a la perfección. La capacitación continua, los simulacros y la actualización del plan de emergencia son lo que hace que la brigada funcione cuando se necesita.',
  video_url = 'https://www.youtube.com/embed/s0cnn1uHzHw'
WHERE id = 39;

-- Leccion 40: Plan de emergencia y evacuación
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Plan de Emergencia y Evacuación

## 1. ¿Qué es un Plan de Emergencia?

Un plan de emergencia es un documento que establece las acciones, responsabilidades y procedimientos para responder a situaciones de emergencia en una organización. Su objetivo es proteger la vida de las personas, minimizar daños y restablecer la normalidad.

## 2. Tipos de Emergencias a Considerar

- Incendios (en oficinas, almacenes, producción)
- Sismos y terremotos
- Inundaciones
- Fuga de gases o sustancias peligrosas
- Accidentes químicos
- Atrapamiento de personas
- Amenazas de bomba
- Emergencias médicas (paro cardíaco, lesiones graves)
- Cortes de energía

## 3. Componentes del Plan de Emergencia

1. **Identificación de Riesgos:** Inventario de todos los riesgos potenciales, evaluando probabilidad y severidad.
2. **Recursos Disponibles:** Personal de brigada, equipos (extintores, mangueras, camillas, botiquines), sistemas de alarma y comunicación.
3. **Procedimientos de Respuesta:** Procedimientos específicos para cada tipo de emergencia.
4. **Rutas de Evacuación:** Mínimo dos rutas por área, señalizadas e iluminadas, libres de obstáculos.
5. **Puntos de Reunión:** Ubicados en zonas seguras, lejos del edificio, con capacidad suficiente.
6. **Directorio de Emergencia:** Bomberos, ambulancia, policía, Cruz Roja, Protección Civil, autoridades internas.

## 4. Procedimiento de Evacuación

1. Activación de la alarma (timbre, sirena, campana)
2. El personal debe dejar de trabajar inmediatamente
3. Los brigadistas guían al personal por las rutas asignadas
4. Caminar rápido, no correr; mantenerse en fila, no empujar
5. Asistir a personas con movilidad reducida
6. No usar elevadores
7. Todo el personal se dirige al punto de reunión
8. Los brigadistas cuentan al personal y reportan al jefe de brigada
9. El jefe evalúa la situación y decide si es seguro regresar
10. No se regresa hasta que se confirme que es seguro

## 5. Simulacros

Los simulacros son la mejor forma de probar el plan de emergencia. Deben realizarse al menos 2 veces al año, con diferente tipo de emergencia cada vez, con evaluación posterior (tiempo de evacuación, problemas detectados) y participación de todo el personal.

### Tipos de Simulacro
- **Avisado:** El personal sabe la fecha y hora (para entrenamiento)
- **Parcial:** Solo se evacúa un área o piso
- **Total con aviso:** Se evacúa todo el edificio, personal avisado
- **Sin aviso (sorpresivo):** El personal no sabe cuándo ocurrirá (evalúa la respuesta real)

## 6. Mantenimiento del Plan

- Revisión anual del plan
- Actualización cuando cambien las instalaciones, personal o riesgos
- Actualización del directorio de emergencia
- Inspección de equipos de emergencia (extintores, luces de emergencia, alarmas)
- Capacitación periódica de brigadistas y personal

## 7. Conclusiones

Un plan de emergencia bien diseñado y practicado puede salvar vidas. La clave no está en el documento, sino en que todo el personal sepa qué hacer, dónde ir y quién coordina. Los simulacros transforman el plan en respuesta automática.',
  video_url = 'https://www.youtube.com/embed/Pg7VmiX8UJ8'
WHERE id = 40;

-- Leccion 41: Combate de incendios y uso de extintores
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Combate de Incendios y Uso de Extintores

## 1. Clases de Fuego

- **Clase A (Sólidos):** Madera, papel, cartón, tela. Extintor: agua, espuma, polvo ABC.
- **Clase B (Líquidos inflamables):** Gasolina, aceite, pintura, solventes. Extintor: espuma, CO2, polvo ABC.
- **Clase C (Eléctricos):** Tableros, motores, cables. Extintor: CO2, polvo ABC (nunca agua).
- **Clase D (Metales):** Magnesio, titanio, sodio. Extintor: polvo especial clase D.
- **Clase K (Aceites de cocina):** Extintor clase K.

## 2. El Extintor Portátil

### Componentes
Cilindro (contiene el agente), válvula/palanca (libera el agente), seguro (previene activación accidental), manguera (dirige el agente), manómetro (indica presión: verde = cargado), etiqueta (clase, capacidad, instrucciones).

### Tipos
- **Agua:** Solo clase A. No usar en eléctricos o líquidos inflamables.
- **CO2:** Clases B y C. No deja residuos. Ideal para equipos eléctricos.
- **Polvo Químico ABC:** Clases A, B y C. El más versátil. Deja residuo.
- **Espuma:** Clases A y B. Forma una capa que sofoca el fuego.

## 3. Método PASS

1. **P (Pull/Jalar):** Jalar el seguro (pasador) de la válvula
2. **A (Aim/Apuntar):** Apuntar la manguera a la BASE del fuego, no a las llamas
3. **S (Squeeze/Apretar):** Apretar la palanca para liberar el agente
4. **S (Sweep/Barrer):** Barrer la manguera de lado a lado cubriendo la base del fuego

## 4. Reglas para el Combate de Incendios

### Antes de Combatir
- Evaluar el tamaño: solo combatir conatos de incendio (fuego en fase inicial)
- Tener salida: nunca combatir un fuego sin una ruta de escape segura
- Llamar a emergencia: avisar a bomberos antes o durante el combate
- Verificar extintor: confirmar que es el tipo correcto para el fuego

### Durante el Combate
- Mantenerse a 2-3 metros del fuego
- Apuntar siempre a la base, no a las llamas
- Moverse alrededor del fuego si es necesario
- No dar la espalda al fuego
- Si el fuego no se apaga en 10-15 segundos, evacuar

## 5. Lo que NO se Debe Hacer

- No usar agua en fuego clase B (líquidos inflamables)
- No usar agua en fuego clase C (eléctrico)
- No combatir fuego grande o que se propaga rápido
- No combatir si no hay ruta de escape
- No inhalar los gases de combustión (son tóxicos)

## 6. Mantenimiento de Extintores

- Inspección visual mensual: ubicación accesible, manómetro en verde, seguro colocado
- Mantenimiento anual por personal certificado
- Recarga después de cada uso
- Prueba hidrostática cada 5 años

## 7. Conclusiones

El combate de incendios con extintores portátiles solo es efectivo en la fase inicial del fuego (conato). Conocer las clases de fuego, el tipo de extintor adecuado y el método PASS es fundamental. La regla de oro: si el fuego es grande o no se controla en 15 segundos, evacuar y dejar que los bomberos lo manejen.',
  video_url = 'https://www.youtube.com/embed/YdQndqfwX0c'
WHERE id = 41;

-- Leccion 42: Primeros auxilios y búsqueda y rescate
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Primeros Auxilios y Búsqueda y Rescate

## 1. Principios de Primeros Auxilios

Los primeros auxilios son las acciones inmediatas que se aplican a una persona lesionada antes de recibir atención médica profesional. El objetivo es preservar la vida, evitar el agravamiento de las lesiones y promover la recuperación.

**Regla de Oro:** Proteger (asegurar el área), Avisar (llamar a emergencias), Socorrer (atender al lesionado).

## 2. Evaluación Primaria (ABC)

- **A - Vía Aérea:** Verificar si la vía aérea está libre. Si no respira, inclinar la cabeza hacia atrás y levantar el mentón.
- **B - Respiración:** Observar el movimiento del pecho, sentir el aire. Si no respira, iniciar RCP.
- **C - Circulación:** Verificar pulso (carótida). Si no hay pulso, iniciar compresiones. Controlar hemorragias graves.

## 3. RCP (Reanimación Cardiopulmonar)

1. Colocar al paciente boca arriba en superficie firme
2. Colocar el talón de una mano en el centro del pecho (entre los pezones)
3. Colocar la otra mano encima, entrelazar dedos
4. Comprimir 5-6 cm de profundidad, a ritmo de 100-120 por minuto
5. Después de 30 compresiones, 2 ventilaciones
6. Continuar hasta que llegue ayuda o el paciente recupere el pulso

## 4. Control de Hemorragias

### Hemorragia Externa
1. Aplicar presión directa sobre la herida con gasa o tela limpia
2. Si la gasa se empapa, colocar otra encima (no retirar la anterior)
3. Elevar la extremidad si es posible
4. Si no se controla, aplicar torniquete (último recurso, marcar la hora)

## 5. Otras Emergencias Comunes

### Quemaduras
- Enfriar con agua corriente durante 15-20 minutos (no hielo)
- No romper ampollas
- No aplicar cremas o remedios caseros
- Cubrir con gasa estéril

### Fracturas
- No mover al paciente si se sospecha fractura de columna
- Inmovilizar la extremidad en la posición en que se encuentra
- No intentar colocar el hueso en su lugar

### Desmayo
- Acostar a la persona boca arriba, elevar las piernas 30 cm
- Aflojar ropa ajustada
- Si no recupera el conocimiento en 1 minuto, llamar a emergencia

## 6. Búsqueda y Rescate

### Técnicas de Búsqueda
- **Búsqueda en cuadrícula:** Dividir el área en sectores y revisar cada uno
- **Búsqueda en línea:** Los rescatistas se alinean y avanzan juntos
- **Llamado y escucha:** Llamar a las personas y escuchar respuestas
- **Búsqueda visual:** Revisar bajo muebles, en baños, armarios, sótanos

### Protocolo de Rescate
1. Asegurar el área antes de entrar (no convertirse en víctima)
2. Entrar en parejas mínimo
3. Llevar equipos de comunicación
4. Localizar a la víctima y evaluar su estado
5. Si está consciente: guiar hacia la salida
6. Si está inconsciente: trasladar en camilla o arrastre seguro
7. Llevar al punto de reunión para evaluación médica

### Equipos de Rescate Básico
Camilla plegable, tabla espinal, collar cervical, linternas, radios, cuerdas, botiquín, casco y guantes.

## 7. Conclusiones

Los primeros auxilios y la búsqueda y rescate son habilidades que todo brigadista debe dominar. La diferencia entre vida y muerte puede ser cuestión de minutos. La capacitación práctica, los simulacros y la actualización periódica son lo que permite actuar con eficacia cuando se necesita.',
  video_url = 'https://www.youtube.com/embed/8E_tHsTNK6g'
WHERE id = 42;

-- Leccion 43: Definición y clasificación de espacios confinados
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Definición y Clasificación de Espacios Confinados

## 1. Definición de Espacio Confinado

Un espacio confinado es un lugar con las siguientes características: 1) Tamaño y configuración suficientes para que una persona pueda entrar y realizar trabajo, 2) Medios limitados de entrada y salida (no diseñado para ocupación continua), 3) No diseñado para ser ocupado permanentemente por personas.

Ejemplos: tanques, silos, recipientes, pozos, túneles, ductos, alcantarillas, cámaras subterráneas, calderas, reactores.

## 2. Tipos de Espacios Confinados

### Según su Riesgo

**Espacio Confinado de Alto Riesgo (Permiso Requerido):** Tiene una o más de las siguientes características: contiene o puede contener una atmósfera peligrosa, contiene material que puede envolver o asfixiar a una persona, tiene una configuración interna que puede atrapar o asfixiar, contiene cualquier otro riesgo serio.

**Espacio Confinado de Bajo Riesgo (Sin Permiso):** No contiene riesgos atmosféricos o físicos significativos. No requiere permiso de entrada, pero sí procedimientos de seguridad.

## 3. La Norma NOM-033-STPS-2015

Establece las condiciones de seguridad para realizar trabajos en espacios confinados en México: obligación de identificar todos los espacios confinados, clasificación (con y sin permiso), procedimientos de entrada, requisitos de monitoreo atmosférico, obligación de tener un vigilante (atendedor) durante la entrada, plan de rescate antes de cada entrada.

## 4. Por Qué los Espacios Confinados Son Peligrosos

### Atmósfera Peligrosa
El riesgo más común y mortal. Puede ser: falta de oxígeno (menos de 19.5%), exceso de oxígeno (más de 23.5%), gases tóxicos (monóxido de carbono, sulfuro de hidrógeno, amoníaco), gases inflamables (metano, vapores de solventes).

### Riesgos Físicos
Temperaturas extremas, ruido amplificado (reverberación), superficies resbaladizas, caídas desde altura, derrumbes.

### Riesgos Mecánicos
Equipos que pueden activarse (mezcladores, agitadores), energía residual (eléctrica, hidráulica, neumática), engranajes y partes móviles.

### Riesgos de Atrapamiento
Material que puede caer o fluir (granos, líquidos), configuración interna que dificulta la salida, espacios estrechos.

## 5. Estadísticas y Realidad

Los espacios confinados causan múltiples accidentes mortales cada año. Un patrón trágico común es que un trabajador cae en el espacio confinado, y otros intentan rescatarlo sin equipo, resultando en múltiples víctimas. **Nunca entrar a un espacio confinado para rescatar a alguien sin el equipo adecuado.**

## 6. Identificación en el Centro de Trabajo

1. Inventario de todos los espacios confinados
2. Señalización de cada espacio identificado
3. Clasificación (con o sin permiso)
4. Documentación de los riesgos específicos de cada espacio
5. Procedimientos de entrada específicos para cada espacio

## 7. Conclusiones

La identificación correcta de los espacios confinados y sus riesgos es el primer paso para prevenir accidentes. Muchas muertes ocurren porque los trabajadores no saben que están entrando a un espacio confinado o no conocen sus riesgos. La norma NOM-033-STPS-2015 establece los requisitos obligatorios para proteger a los trabajadores.',
  video_url = 'https://www.youtube.com/embed/nBybLn7-d7I'
WHERE id = 43;

-- Leccion 44: Atmósferas peligrosas y monitoreo de gases
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Atmósferas Peligrosas y Monitoreo de Gases en Espacios Confinados

## 1. La Atmósfera en un Espacio Confinado

La atmósfera dentro de un espacio confinado puede cambiar rápidamente y sin previo aviso. Un espacio que era seguro hace una hora puede ser letal ahora. El monitoreo atmosférico es la única forma de garantizar que el aire es respirable.

## 2. Parámetros a Monitorear

### Oxígeno (O2)
- Rango normal: 20.9%
- Deficiente: Menos de 19.5% (causa desmayo y muerte)
- Enriquecido: Más de 23.5% (aumenta la inflamabilidad)

### Gases Inflamables (LEL)
El Límite Inferior de Explosividad es la concentración mínima de gas en aire que puede explotar. 0% LEL = seguro, 10% LEL = alarma, 100% LEL = explosivo.

### Gases Tóxicos
- **Sulfuro de hidrógeno (H2S):** 0-10 ppm causa la muerte. Huele a huevos podridos a bajas concentraciones, pero a altas paraliza el olfato.
- **Monóxido de carbono (CO):** Incoloro, inodoro. 35 ppm es límite permisible.
- **Amoníaco (NH3):** Irritante respiratorio severo.
- **Dióxido de carbono (CO2):** Desplaza el oxígeno, causa asfixia.

## 3. El Detector de Gases

Un detector multigás portátil debe medir como mínimo: O2, gases inflamables (LEL), CO, H2S. Debe tener alarmas visuales, audibles y vibratorias, bomba de muestreo, pantalla con lecturas en tiempo real y calibración vigente.

## 4. Procedimiento de Monitoreo

### Antes de Entrar (Monitoreo Remoto)
1. Encender el detector y esperar a que calibre
2. Verificar alarmas (prueba de bump test)
3. Introducir la sonda del detector en el espacio
4. Medir a diferentes alturas: gases pesados (CO2, H2S) en el fondo, gases ligeros (CH4, H2) arriba, gases con densidad similar al aire (CO) uniformemente
5. Esperar 30-60 segundos por punto
6. Registrar resultados

### Durante la Estancia
- Monitoreo continuo con detector portátil
- Si suena una alarma, evacuar inmediatamente

## 5. Criterios de Entrada Segura

| Parámetro | Rango Seguro | Acción |
|-----------|-------------|--------|
| O2 | 19.5%-23.5% | No entrar fuera de este rango |
| LEL | 0% | No entrar si LEL > 0% |
| CO | <25 ppm | No entrar si CO > 25 ppm |
| H2S | <10 ppm | No entrar si H2S > 10 ppm |

## 6. Calibración del Detector

- **Bump test:** Antes de cada uso. Expone el detector a gas conocido para verificar respuesta.
- **Calibración completa:** Cada 3-6 meses. Ajusta lecturas a valores certificados.
- Un detector sin calibración vigente NO debe usarse.

## 7. Errores Comunes

- No medir antes de entrar
- Medir solo a una altura (los gases se estratifican)
- Usar detector sin calibración vigente
- Confiar en el olfato (muchos gases son inodoros)
- Apagar el detector después de entrar
- No evacuar cuando suena la alarma

## 8. Conclusiones

El monitoreo de gases es el control más crítico en espacios confinados. La mayoría de las muertes se deben a atmósferas peligrosas que no fueron detectadas o no fueron monitoreadas continuamente. Un detector calibrado y en funcionamiento es la diferencia entre entrar seguro y entrar a morir.',
  video_url = 'https://www.youtube.com/embed/8rREL0hv2_M'
WHERE id = 44;

-- Leccion 45: Permiso de entrada y ventilación
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Permiso de Entrada y Ventilación en Espacios Confinados

## 1. El Permiso de Entrada

El permiso de entrada a un espacio confinado es un documento que autoriza y controla el acceso a espacios confinados de alto riesgo. Debe ser firmado por el responsable autorizado antes de cada entrada.

## 2. Contenido del Permiso

- Identificación del espacio confinado
- Propósito de la entrada (tarea a realizar)
- Fecha y hora de inicio y cierre
- Personal autorizado (entrantistas y vigía)
- Resultados del monitoreo atmosférico
- Equipos de protección requeridos
- Procedimientos de aislamiento (LOTO)
- Plan de rescate (método, equipos, personal)
- Firmas del autorizante, entrantistas y vigía

## 3. Procedimiento de Entrada

### Antes de Entrar
1. Aislar el espacio: bloquear todas las energías usando LOTO
2. Limpiar y purgar: vaciar el contenido
3. Ventilar: introducir aire fresco
4. Monitorear: medir gases a diferentes alturas
5. Verificar criterios: confirmar parámetros en rango seguro
6. Firmar el permiso
7. Colocar equipos: trípode y línea de vida en accesos verticales

### Durante la Estancia
8. Vigía en su puesto durante toda la estancia
9. Monitoreo continuo
10. Comunicación constante
11. Respetar tiempo máximo de estancia

### Al Salir
12. Retirar equipos y herramientas
13. Cerrar el espacio
14. Cerrar el permiso
15. Reportar incidentes

## 4. El Vigía (Atendedor)

El vigía permanece fuera del espacio confinado durante toda la entrada. Sus funciones: mantener comunicación constante, monitorear el estado de los entrantistas, mantener registro de quienes están dentro, no abandonar el puesto, activar el plan de rescate si es necesario, prevenir entrada de personal no autorizado.

**El vigía NO debe:** entrar al espacio, realizar otras tareas que lo distraigan, ausentarse para buscar ayuda.

## 5. Ventilación de Espacios Confinados

### Objetivos
- Mantener niveles de oxígeno seguros (19.5%-23.5%)
- Eliminar gases tóxicos o inflamables
- Controlar temperatura y humedad
- Proporcionar aire respirable continuo

### Tipos
- **Ventilación natural:** Apertura de escotillas. No confiable para espacios peligrosos.
- **Ventilación mecánica (forzada):** Introducción de aire fresco con ventiladores. El método más confiable.

### Configuraciones
- **Soplado (Push):** El ventilador introduce aire fresco, el viciado sale.
- **Extracción (Pull):** El ventilador extrae aire viciado, el fresco entra. Mejor para gases tóxicos.
- **Combinado:** Soplado en un extremo y extracción en el otro. Lo más efectivo.

### Consideraciones
- El conducto debe llegar cerca del fondo del espacio
- La ventilación debe funcionar durante toda la estancia
- Si se apaga, los entrantistas deben salir inmediatamente
- Verificar que el aire de entrada sea limpio
- Capacidad mínima: 20 cambios de aire por hora

## 6. Cancelación del Permiso

El permiso se cancela si: las condiciones atmosféricas cambian (suena alarma), se excede el tiempo autorizado, se presenta una condición no prevista, el vigía abandona su puesto, se termina el trabajo.

## 7. Conclusiones

El permiso de entrada y la ventilación son los controles más importantes para espacios confinados. El permiso obliga a evaluar, aislar, ventilar y monitorear antes de entrar. La ventilación continua mantiene la atmósfera segura. Nunca entrar a un espacio confinado sin permiso firmado y ventilación funcionando.',
  video_url = 'https://www.youtube.com/embed/G-eiUGtgH3s'
WHERE id = 45;

-- Leccion 46: Rescate en espacios confinados
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Rescate en Espacios Confinados

## 1. La Realidad del Rescate

El rescate en espacios confinados es una de las operaciones más peligrosas en seguridad industrial. El patrón más trágico es: una persona cae, otras intentan rescatarla sin equipo y mueren también (efecto dominó).

**Regla absoluta:** Nunca entrar a un espacio confinado para rescatar a alguien sin el equipo adecuado y el plan de rescate activado.

## 2. El Plan de Rescate

Antes de cada entrada debe existir un plan de rescate que defina: quién ejecuta el rescate, qué equipos se usan, cómo se ejecuta, cuándo se activa, a quién se llama.

### Tipos de Rescate
- **Autorescate:** El trabajador sale por sí mismo. Es lo más seguro pero requiere que esté consciente y móvil.
- **Rescate sin entrada:** El trabajador es rescatado desde el exterior (trípode, winche, línea de vida). Es el método preferido.
- **Rescate con entrada:** Un rescatista entra al espacio. Es el más peligroso, ejecutado por personal entrenado.

## 3. Equipo de Rescate

- **Trípode y winche:** Instalado sobre la abertura vertical, permite subir al trabajador con control mecánico. Capacidad mínima 150 kg.
- **Arnés de rescate:** Con anillos de rescate dorsal y frontal.
- **Equipo de respiración:** Respirador con suministro de aire o SCBA para el rescatista.
- **Detector de gases:** Para reevaluar la atmósfera antes del rescate.
- **Camilla de rescate:** Flexible o rígida para extraer por espacios estrechos.
- Otros: cuerdas certificadas, radios, botiquín, linternas a prueba de explosión.

## 4. Procedimiento de Rescate

### Fase 1: Detección y Comunicación
1. El vigía detecta el problema (el trabajador no responde, suena alarma)
2. Activa el plan de rescate inmediatamente
3. Llama a servicios de emergencia externos

### Fase 2: Preparación
4. No entrar al espacio
5. Reevaluar la atmósfera con detector
6. Verificar/aumentar la ventilación
7. Preparar el equipo (trípode, winche, respirador)

### Fase 3: Ejecución
8. Rescate sin entrada: usar el winche para subir al trabajador
9. Rescate con entrada: el rescatista entra con respirador y línea de vida
10. Conectar al trabajador al sistema de extracción
11. Extraer al trabajador lo más rápido posible

### Fase 4: Atención
12. Trasladar a zona segura
13. Aplicar primeros auxilios
14. Entregar a servicios médicos
15. Aislar el espacio confinado

## 5. Errores Fatales

- Entrar al espacio sin equipo para ayudar a un compañero
- No tener plan de rescate antes de entrar
- No tener equipo de rescate en el sitio
- Depender de bomberos externos como único plan
- No practicar el rescate con anticipación
- No usar trípode y winche en accesos verticales

## 6. Entrenamiento de Rescate

El equipo de rescate debe practicar regularmente: simulacros de rescate sin entrada (winche), simulacros de rescate con entrada, uso de equipo de respiración, primeros auxilios, comunicación de emergencia. La práctica debe hacerse en el espacio confinado real o similar, con el equipo real, bajo condiciones controladas.

## 7. Conclusiones

El rescate en espacios confinados debe planificarse desde el principio. Un plan que no se ha practicado es solo un documento. El equipo de rescate debe estar en el sitio antes de que alguien entre. Y la regla absoluta: nunca entrar sin equipo para rescatar a un compañero. Llamar a profesionales y usar el equipo adecuado.',
  video_url = 'https://www.youtube.com/embed/_uhtpq_oqQo'
WHERE id = 46;

-- Leccion 47: Tipos de energía peligrosa
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Tipos de Energía Peligrosa y LOTO

## 1. ¿Qué es LOTO?

LOTO (Lockout/Tagout) o Bloqueo y Etiquetado es un procedimiento de seguridad que asegura que las máquinas y equipos estén completamente aislados de sus fuentes de energía antes de realizar mantenimiento, limpieza o reparación. Su objetivo es prevenir la activación accidental de equipos que podría causar lesiones graves o la muerte.

## 2. Tipos de Energía Peligrosa

### Energía Eléctrica
La forma más común. Incluye corriente de alimentación (120V, 220V, 440V), corriente de control (24V DC), energía almacenada en capacitores. Riesgos: electrocución, quemaduras eléctricas, activación de partes móviles.

### Energía Mecánica
Energía en componentes en movimiento o bajo tensión: partes giratorias (ejes, poleas, volantes), resortes bajo tensión, contrapesos, partes que pueden caer por gravedad. Riesgos: atrapamiento, cortes, golpes, aplastamiento.

### Energía Hidráulica
Energía en sistemas de fluidos a presión: cilindros hidráulicos, acumuladores, líneas de aceite a presión. Riesgos: movimiento inesperado de cilindros, proyección de fluido, atrapamiento.

### Energía Neumática
Energía en sistemas de aire comprimido: cilindros neumáticos, tanques de aire, líneas de aire a presión. Riesgos: movimiento inesperado de cilindros, proyección de componentes.

### Energía Térmica
Energía almacenada como calor: superficies calientes (motores, calderas, tuberías), fluidos calientes (vapor, aceite térmico). Riesgos: quemaduras térmicas.

### Energía Química
Energía en sustancias químicas: gases comprimidos, líquidos inflamables o corrosivos, productos reactivos. Riesgos: exposición a químicos tóxicos, quemaduras químicas, incendio, explosión.

### Energía Potencial (Gravedad)
Energía en objetos elevados: cargas suspendidas, partes que pueden caer, plataformas elevadas. Riesgos: caída de objetos, aplastamiento.

## 3. La Norma NOM-004-STPS-2023

Establece los requisitos para el bloqueo y etiquetado de equipos y maquinaria en México. La norma OSHA 29 CFR 1910.147 es su equivalente en EE.UU.

## 4. ¿Por Qué es Necesario LOTO?

El escenario típico: un trabajador está limpiando una máquina. Otro trabajador, sin saber que hay alguien dentro, enciende la máquina. El resultado puede ser fatal.

LOTO es obligatorio para: mantenimiento de maquinaria, limpieza de equipos, reparación de fallas, desatoramientos, inspección interna, cambio de piezas.

## 5. Diferencia entre Bloqueo y Etiquetado

- **Bloqueo (Lockout):** Uso de candados físicos que impiden físicamente la activación. Es el método más seguro. Solo la persona que puso el candado puede quitarlo.
- **Etiquetado (Tagout):** Uso de etiquetas de advertencia sin bloqueo físico. Menos seguro. Solo se usa cuando no es posible instalar un candado.

**Preferencia:** El bloqueo siempre es preferible al etiquetado.

## 6. Energía Almacenada o Residual

Incluso después de aislar la fuente, puede quedar energía almacenada: capacitores cargados, resortes bajo tensión, cilindros presurizados, calor residual, material acumulado. **Esta energía debe liberarse o controlarse antes de comenzar el trabajo.**

## 7. Conclusiones

LOTO no es solo apagar un interruptor: es aislar todas las formas de energía que pueden causar daño. Cada tipo de energía requiere un método específico de aislamiento. Un procedimiento incompleto que bloquea la electricidad pero no la energía hidráulica puede ser tan peligroso como no hacer nada.',
  video_url = 'https://www.youtube.com/embed/8VNR4Sw5Xmc'
WHERE id = 47;

-- Leccion 48: Procedimiento de bloqueo y etiquetado
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Procedimiento de Bloqueo y Etiquetado (LOTO)

## 1. Los 6 Pasos del Procedimiento LOTO

### Paso 1: Notificación
Informar a todos los trabajadores afectados que se va a realizar bloqueo. Identificar qué equipos y procesos se detendrán.

### Paso 2: Identificación de Energías
Identificar TODAS las fuentes de energía del equipo. Elaborar un diagrama de energías. Determinar el método de aislamiento para cada fuente.

### Paso 3: Apagado del Equipo
Apagar el equipo siguiendo el procedimiento normal del fabricante. No usar paradas de emergencia como método normal. Verificar que el equipo se haya detenido completamente.

### Paso 4: Aislamiento de Energías
Abrir interruptores eléctricos, cerrar válvulas de fluidos, bloquear partes mecánicas móviles, drenar fluidos a presión, liberar resortes bajo tensión, descargar capacitores.

### Paso 5: Aplicación de Candados y Etiquetas
Instalar candados en cada punto de aislamiento. Colocar etiquetas con: nombre del trabajador, fecha, motivo, contacto. Cada trabajador que realice mantenimiento debe colocar su propio candado.

### Paso 6: Verificación de Energía Cero
Intentar encender el equipo (no debe encenderse). Devolver el interruptor a OFF. Medir voltaje (debe ser 0V). Verificar que no haya presión en líneas. Confirmar que no haya partes móviles. Confirmar que la temperatura sea segura.

## 2. Candados de Bloqueo

### Características
Deben ser exclusivos para LOTO. Cada trabajador tiene su propio candado con llave única. Deben ser identificables (color, nombre, número). NUNCA se debe prestar la llave.

### Candados Múltiples (Hasp)
Cuando varios trabajadores trabajan en el mismo equipo: se usa un dispositivo de múltiples candados (hasp). Cada trabajador coloca su candado individual. El equipo no puede activarse hasta que TODOS los candados sean retirados.

### Caja de Bloqueo Grupal (Lockbox)
Para equipos con muchos trabajadores: todos los candados se colocan en una caja. La llave del equipo se guarda dentro. La caja se bloquea con candados de todos. El equipo se activa solo cuando todos retiraron sus candados.

## 3. Etiquetas de Bloqueo

Contenido: nombre del trabajador, fecha y hora, motivo del bloqueo, contacto, peligros específicos. Reglas: la etiqueta NO sustituye al candado cuando el candado es posible. La etiqueta debe ser duradera y visible. No reutilizar etiquetas.

## 4. Retiro de Candados

Cada trabajador retira su propio candado. NUNCA retirar el candado de otra persona. Si un trabajador no puede retirar su candado: verificar que no esté en el área, contactar por teléfono, autorizar con aprobación del supervisor, inspeccionar el equipo, retirar con herramienta, documentar.

## 5. Dispositivos de Bloqueo Específicos

- **Eléctrico:** Candado en el interruptor principal, cubiertas de bloqueo para breaker.
- **Válvulas:** Candado en la manija, brida de bloqueo, cadena de bloqueo.
- **Tapones y ciegos:** Tapones ciegos en líneas de fluido, placas ciegas entre bridas.

## 6. Errores Comunes

- No identificar todas las fuentes de energía
- Olvidar la energía almacenada (capacitores, resortes, presión)
- No verificar energía cero después de bloquear
- Compartir candados o llaves
- Retirar el candado de otra persona
- Aplicar LOTO solo parcialmente

## 7. Conclusiones

El procedimiento LOTO es simple pero debe ser completo. Cada paso es importante y ninguno puede omitirse. La verificación de energía cero es el paso que confirma que el bloqueo funcionó. El candado personal garantiza que nadie puede activar el equipo mientras el trabajador está dentro. La disciplina en el procedimiento es lo que evita accidentes.',
  video_url = 'https://www.youtube.com/embed/DpGqaHLUjgk'
WHERE id = 48;

-- Leccion 49: Verificación de energía cero
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Verificación de Energía Cero

## 1. ¿Qué es la Energía Cero?

La energía cero es el estado en el que un equipo no tiene ninguna fuente de energía activa que pueda causar movimiento, activación o daño. Es el estado que se debe verificar después de aplicar el bloqueo y antes de comenzar cualquier trabajo.

## 2. Por Qué la Verificación es el Paso Más Importante

El bloqueo puede fallar por múltiples razones: el interruptor bloqueado no corresponde al equipo, hay una segunda fuente de energía no bloqueada, el mecanismo está defectuoso, hay energía almacenada no liberada. **La verificación de energía cero es lo que confirma que el bloqueo funcionó.**

## 3. Procedimiento de Verificación

### Verificación Eléctrica
1. Medir voltaje con multímetro o detector en los terminales del motor y conductores
2. Medir de fase a fase y de fase a tierra
3. Verificar circuitos de control (24V DC)
4. Descargar capacitores con herramienta apropiada

### Verificación Mecánica
1. Verificar que no haya partes en movimiento
2. Bloquear partes que puedan caer (calzos, soportes)
3. Liberar resortes bajo tensión (pasadores)
4. Verificar contrapesos

### Verificación Hidráulica
1. Medir presión con manómetro (debe ser 0)
2. Drenar acumuladores
3. Verificar cilindros (no deben moverse)
4. Bloquear válvulas

### Verificación Neumática
1. Medir presión (debe ser 0)
2. Descargar tanques de aire
3. Verificar cilindros neumáticos
4. Bloquear válvulas de aire

### Verificación Térmica
1. Medir temperatura con pirómetro
2. Esperar enfriamiento si es necesario
3. Verificar fluidos calientes

### Prueba de Funcionamiento
1. Intentar encender el equipo desde el panel de control
2. El equipo NO debe encenderse
3. Devolver controles a posición OFF

## 4. Herramientas para la Verificación

- Multímetro o detector de voltaje (calibrado)
- Manómetro para presión
- Pirómetro o termómetro infrarrojo
- Detector de gases (si aplica)
- Linterna para inspección visual

## 5. Casos de Energía Almacenada

- **Capacitores:** Pueden mantener voltaje durante horas. Descargar con herramienta apropiada.
- **Acumuladores hidráulicos:** Mantienen presión durante días. Drenar con válvula de purga.
- **Tanques de aire:** Descargar abriendo válvula de purga.
- **Resortes:** Mantienen fuerza significativa. Asegurar con pasadores.
- **Calor residual:** Causar quemaduras. Esperar o usar protección.

## 6. Registro de Verificación

La verificación debe documentarse: equipo bloqueado, fuentes verificadas, resultados, nombre del verificador, fecha y hora.

## 7. Conclusiones

La verificación de energía cero es el paso que separa un bloqueo exitoso de un accidente. No es opcional: es la confirmación de que el equipo es seguro. Cada fuente de energía debe verificarse por separado. La prueba final (intentar encender) es la confirmación definitiva.',
  video_url = 'https://www.youtube.com/embed/y_XCB9-KoxM'
WHERE id = 49;

-- Leccion 50: Restauración segura de energía
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Restauración Segura de Energía

## 1. Introducción

El procedimiento LOTO no termina cuando se completa el trabajo: termina cuando el equipo se restablece a operación segura. La restauración de energía requiere el mismo nivel de cuidado que el bloqueo. Un error en la restauración puede causar lesiones graves o daños al equipo.

## 2. Antes de Restaurar la Energía

### Verificación del Trabajo Completado
- Confirmar que todo el trabajo planificado ha sido completado
- Verificar que no queden herramientas, materiales o desechos dentro del equipo
- Inspeccionar visualmente el área de trabajo
- Confirmar que todas las piezas de seguridad (resguardos, cubiertas) están instaladas

### Limpieza del Área
- Retirar herramientas y materiales
- Limpiar derrames
- Retirar señalización temporal
- Asegurar que el área esté despejada

### Verificación del Personal
- Confirmar que todos los trabajadores hayan salido
- Verificar que nadie esté en posición de riesgo
- Hacer un conteo de personas

## 3. Procedimiento de Retiro de Candados

**Regla fundamental:** Cada trabajador retira su propio candado. NUNCA retirar el candado de otra persona.

### Caso Especial: Trabajador Ausente
1. Intentar contactar al trabajador por teléfono
2. Si no es posible, el supervisor autoriza el retiro
3. Inspeccionar visualmente para confirmar que el trabajador no está presente
4. Retirar el candado con herramienta (corta candados)
5. Documentar el retiro
6. Notificar al trabajador en su regreso

## 4. Restablecimiento de Energías (Orden Inverso)

1. **Restaurar energía mecánica:** Retirar calzos y soportes, liberar pasadores de resortes, verificar partes móviles libres.
2. **Restaurar energía hidráulica/neumática:** Cerrar válvulas de purga, retirar placas ciegas, abrir válvulas de alimentación, verificar fugas, verificar presión.
3. **Restaurar energía eléctrica:** Verificar que los controles están en OFF, retirar candados, cerrar interruptor principal, verificar que el equipo no arranque automáticamente.

## 5. Pruebas de Funcionamiento

1. Encender el equipo desde el panel de control normal
2. Observar arranque (ruidos anormales, vibraciones, humo)
3. Verificar que todas las funciones operen correctamente
4. Verificar que los resguardos y protecciones de seguridad funcionan
5. Probar el paro de emergencia

## 6. Notificación de Restablecimiento

1. Informar a todos los trabajadores afectados que el equipo está operativo
2. Retirar señalización de Equipo Fuera de Servicio
3. Comunicar al supervisor de operaciones
4. Documentar la finalización del trabajo

## 7. Registro y Documentación

El registro completo del LOTO debe incluir: fecha y hora de bloqueo, lista de trabajadores que aplicaron candados, trabajo realizado, fecha y hora de retiro, nombre de quien retiró cada candado, fecha y hora de restablecimiento, resultado de pruebas, firma del supervisor.

## 8. Errores Comunes

- Retirar candados de otros trabajadores
- Restaurar energías en el orden incorrecto
- No verificar que todos los trabajadores hayan salido
- No limpiar el área antes de restaurar
- No probar el equipo después de restaurar
- No avisar que el equipo está operativo
- No documentar el cierre del procedimiento

## 9. Conclusiones

La restauración de energía es la última oportunidad para prevenir accidentes. Un procedimiento de bloqueo perfecto puede arruinarse con una restauración apresurada. El orden de restauración, la verificación de que todos están fuera, y las pruebas de funcionamiento son los pasos que garantizan que el equipo vuelva a operar de forma segura.',
  video_url = 'https://www.youtube.com/embed/4MMnwTTpESs'
WHERE id = 50;

-- Leccion 51: Principios de aprendizaje de adultos
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Principios del Aprendizaje en Adultos (Andragogía)

## 1. ¿Qué es la Andragogía?

La andragogía es la ciencia y el arte de educar a adultos. A diferencia de la pedagogía (educación de niños), reconoce que los adultos aprenden de manera diferente. Malcolm Knowles identificó seis principios fundamentales.

## 2. Los 6 Principios de Knowles

### 1. Necesidad de Saber
Los adultos necesitan entender por qué deben aprender algo antes de comprometerse. Si no ven el propósito, no se involucran. **Aplicación:** Al inicio de cada capacitación, explicar claramente por qué el tema es importante y cómo beneficia al trabajador.

### 2. Autoconcepto del Aprendiz
Los adultos se consideran responsables de sus decisiones. Quieren ser tratados como capaces de autodirigir su aprendizaje. **Aplicación:** Dar control sobre el aprendizaje. Permitir preguntas, discusiones y elecciones.

### 3. Experiencia Previa
Los adultos acumulan experiencia que es un recurso de aprendizaje. Puede ser un activo (apoyo) o un pasivo (resistencia). **Aplicación:** Conectar el nuevo contenido con la experiencia de los participantes. Pedir ejemplos de sus trabajos.

### 4. Disposición para Aprender
Los adultos están dispuestos a aprender aquello que necesitan para enfrentar situaciones reales. No aprenden por aprender: aprenden para resolver problemas. **Aplicación:** Enfocar el contenido en problemas reales del trabajo.

### 5. Orientación al Aprendizaje
El aprendizaje está centrado en problemas, no en materias. No quieren estudiar seguridad: quieren aprender a no accidentarse. **Aplicación:** Estructurar la capacitación alrededor de problemas reales, no de temas académicos.

### 6. Motivación
La motivación más poderosa es interna: autoestima, calidad de vida, reconocimiento. **Aplicación:** Apelar a la motivación interna. Reconocer logros. Crear un ambiente donde hacer las cosas bien sea valorado.

## 3. Barreras del Aprendizaje en Adultos

### Psicológicas
- Yo ya sé esto (resistencia)
- Esto no funciona en mi caso
- No tengo tiempo para esto
- Miedo a verse incompetente

### Organizacionales
- Capacitación vista como pérdida de tiempo
- Falta de apoyo del supervisor
- Contenido no relevante
- Horarios inadecuados

### Cómo Superarlas
Reconocer la experiencia, conectar con el trabajo real, usar tono de colaboración, permitir dudas, hacer la capacitación práctica.

## 4. Estilos de Aprendizaje

- **Visual:** Aprenden viendo (diagramas, videos, demostraciones)
- **Auditivo:** Aprenden escuchando (explicaciones, discusiones)
- **Kinestésico:** Aprenden haciendo (práctica, simulacros)

Una buena capacitación debe combinar los tres estilos.

## 5. Aplicación en Capacitaciones de Seguridad

1. Empezar con el por qué: qué accidentes pueden ocurrir
2. Conectar con la experiencia: preguntar sobre situaciones similares
3. Enfocar en problemas reales: usar casos del propio centro de trabajo
4. Hacer práctica: los simulacros son la mejor forma de aprender
5. Evaluar comprensión: verificar que pueden aplicarlo
6. Dar seguimiento: la capacitación se refuerza en el trabajo diario

## 6. Conclusiones

Enseñar a adultos no es lo mismo que enseñar a niños. Los adultos aprenden cuando ven el propósito, cuando se respeta su experiencia, y cuando el contenido es relevante para sus problemas reales. Un instructor que ignora estos principios puede dar una capacitación que los participantes aprueben pero no apliquen.',
  video_url = 'https://www.youtube.com/embed/yPEKJw8WeR4'
WHERE id = 51;

-- Leccion 52: Diseño de contenido didáctico
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Diseño de Contenido Didáctico para Capacitación

## 1. Introducción

El diseño de contenido didáctico es el proceso de estructurar la información de manera que sea fácil de aprender, recordar y aplicar. No es simplemente hacer diapositivas: es planificar la experiencia de aprendizaje completa.

## 2. Modelo ADDIE

- **A (Analyze):** ¿Quiénes son los participantes? ¿Qué necesitan aprender? ¿Cuál es el contexto?
- **D (Design):** Definir objetivos de aprendizaje, estructurar el contenido, seleccionar métodos, diseñar evaluaciones.
- **D (Develop):** Crear materiales, preparar ejercicios, desarrollar evaluaciones, probar con grupo piloto.
- **I (Implement):** Impartir la capacitación, facilitar el aprendizaje.
- **E (Evaluate):** Evaluar el aprendizaje, evaluar la efectividad, recoger feedback, mejorar.

## 3. Objetivos de Aprendizaje

Deben ser específicos, medibles, alcanzables y relevantes.

**Ejemplo mal:** El participante entenderá sobre seguridad en alturas.
**Ejemplo bien:** Al finalizar, el participante podrá inspeccionar un arnés identificando al menos 5 defectos comunes.

## 4. Estructura de una Capacitación

### Apertura (10-15% del tiempo)
- Presentación del instructor y participantes
- Objetivos de la capacitación
- Por qué es importante
- Activación de conocimientos previos

### Desarrollo (60-70% del tiempo)
- Contenido dividido en módulos lógicos
- Cada módulo: teoría + ejemplo + aplicación
- Pausas para preguntas y discusión
- Ejercicios prácticos

### Cierre (15-20% del tiempo)
- Resumen de puntos clave
- Evaluación del aprendizaje
- Plan de aplicación
- Feedback de los participantes

## 5. Técnicas para Hacer el Contenido Memorable

- **Regla del 3:** Los adultos recuerdan mejor grupos de 3 elementos
- **Repetición espaciada:** Repetir conceptos clave en diferentes formatos
- **Casos reales:** Usar ejemplos del propio centro de trabajo
- **Visualización:** El cerebro procesa imágenes 60,000 veces más rápido que texto
- **Práctica:** Un simulacro enseña más que 50 diapositivas
- **Narrativa (Storytelling):** Las historias se recuerdan mejor que los datos

## 6. Materiales Didácticos

### Presentaciones
- Máximo 6 líneas por diapositiva, 6 palabras por línea
- Una idea por diapositiva
- Imágenes relevantes, no decorativas
- Contraste alto, fuentes legibles

### Manuales
- Lenguaje claro y directo
- Incluir ejercicios y autoevaluaciones
- Usar esquemas y diagramas
- Espacios para notas

### Videos
- Duración máxima 5-7 minutos
- Un concepto por video
- Subtítulos en español

## 7. Evaluación del Aprendizaje (Modelo Kirkpatrick)

1. **Reacción:** Les gustó? (encuesta)
2. **Aprendizaje:** Aprendieron? (examen, demostración)
3. **Comportamiento:** Lo aplican? (observación en el trabajo)
4. **Resultados:** Cambió algo? (reducción de accidentes)

## 8. Conclusiones

El diseño didáctico es lo que separa una capacitación efectiva de una pérdida de tiempo. La clave no está en el contenido, sino en cómo se estructura, presenta y evalúa. Un buen instructor con malos materiales tiene menos impacto que un instructor promedio con materiales bien diseñados.',
  video_url = 'https://www.youtube.com/embed/bt6oAKP5ouU'
WHERE id = 52;

-- Leccion 53: Técnicas de facilitación y evaluación
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Técnicas de Facilitación y Evaluación

## 1. Diferencia entre Enseñar y Facilitar

**Enseñar** es transmitir conocimiento del instructor al participante. **Facilitar** es guiar el proceso de aprendizaje, creando las condiciones para que los participantes descubran y apliquen el conocimiento. La facilitación es más efectiva con adultos porque aprovecha su experiencia.

## 2. Técnicas de Facilitación

### Preguntas Abiertas
En lugar de dar la respuesta, hacer preguntas que lleven a los participantes a descubrirla: ¿Qué creen que puede pasar si...? ¿Cómo manejarían esta situación?

### Discusión en Grupos Pequeños
Dividir al grupo en equipos de 3-5 personas para discutir un caso o resolver un problema. Luego, cada grupo comparte conclusiones. Mayor participación de personas tímidas, aprovecha la experiencia de todos.

### Estudio de Casos
Presentar una situación real y pedir a los participantes que la analicen: identificar qué salió mal, proponer medidas preventivas, discutir qué harían diferente.

### Juego de Roles (Role Play)
Asignar roles y simular una situación: un supervisor corrigiendo a un trabajador, un brigadista atendiendo a un herido. Practica habilidades, no solo conocimiento.

### Demostración + Práctica
1. El instructor demuestra la habilidad, 2. Un participante la repite, 3. Los demás observan y dan feedback, 4. Cada participante practica.

## 3. Manejo de Grupos

### Participante Dominante
Habla mucho y no deja que otros participen. **Solución:** Gracias por tu aporte. ¿Qué piensan los demás?

### Participante Silencioso
No participa. **Solución:** Hacer preguntas directas pero fáciles sobre su experiencia.

### Participante Negativo
Critica todo. **Solución:** Entiendo tu punto. ¿Qué propones en su lugar?

### Pregunta que el Instructor no Sabe
**Solución:** No estoy seguro, pero lo investigo. ¿Alguien del grupo sabe? No inventar respuestas.

## 4. Técnicas de Evaluación

### Evaluación Diagnóstica
Antes de la capacitación: ¿Qué saben ya? (preguntas orales, encuesta rápida).

### Evaluación Formativa
Durante la capacitación: ¿Están aprendiendo? (preguntas, ejercicios, discusiones).

### Evaluación Sumativa
Al final: ¿Lograron los objetivos? (examen escrito, demostración práctica).

## 5. Diseño de Exámenes

- **Opción múltiple:** Una respuesta correcta clara, distractores plausibles
- **Verdadero/Falso:** Útiles para conceptos clave
- **Demostración práctica:** La mejor evaluación para habilidades, con checklist de criterios observables

## 6. Retroalimentación

### Regla del Sándwich
1. Positivo: Reconocer lo que hizo bien
2. Mejora: Señalar lo que puede mejorar
3. Positivo: Animar a que lo intente de nuevo

### Características de Buena Retroalimentación
Específica, inmediata, constructiva, privada si puede avergonzar.

## 7. Conclusiones

Facilitar es más difícil que enseñar: requiere leer al grupo, adaptar el ritmo, manejar personalidades. Las técnicas de evaluación deben ir más allá del examen escrito: la seguridad se demuestra en la práctica. Un instructor que facilita en lugar de dictar genera un aprendizaje que los participantes recordarán y aplicarán.',
  video_url = 'https://www.youtube.com/embed/pFXVmdKhG_Y'
WHERE id = 53;

-- Leccion 54: Manejo de grupos y retroalimentación
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Manejo de Grupos y Retroalimentación en Capacitación

## 1. La Dinámica de Grupos

Todo grupo de capacitación tiene su propia dinámica. El instructor debe leer esa dinámica y adaptarse. Un grupo participativo requiere una facilitación diferente a uno silencioso.

## 2. Etapas de un Grupo

### Etapa 1: Formación (Primeros 15 min)
Los participantes se conocen, hay incertidumbre. **Qué hacer:** Actividad rompehielos, presentación de expectativas, establecer normas.

### Etapa 2: Tormenta (Mitad inicial)
Surgen preguntas, dudas, resistencia. Algunos cuestionan el contenido. **Qué hacer:** Manejar objeciones con respeto, aprovechar la experiencia.

### Etapa 3: Normalización (Mitad final)
El grupo se acostumbra al ritmo, la participación se vuelve natural. **Qué hacer:** Aumentar la complejidad, introducir casos más difíciles.

### Etapa 4: Desempeño (Final)
El grupo trabaja cohesionado, los participantes se ayudan mutuamente. **Qué hacer:** Ejercicios de aplicación, planes de acción, evaluación.

## 3. Técnicas de Manejo de Grupos

### Establecer Normas desde el Inicio
- Preguntas en cualquier momento
- Respeto a todas las opiniones
- Teléfonos en silencio
- Confidencialidad

### Mantener la Energía
- Pausas cada 60-90 minutos
- Cambiar de actividad cada 20-30 minutos
- Mezclar teoría con práctica
- Pedir a los participantes que se muevan

### Involucrar a Todos
- Hacer preguntas a personas específicas
- Usar trabajo en parejas
- Pedir opiniones por área de trabajo
- Reconocer las contribuciones

## 4. Tipos de Participantes Difíciles

### El Que Sabe Todo
Interrumpe con yo ya sé esto. **Estrategia:** Reconocer su experiencia, pedirle que comparta casos, canalizar como co-facilitador.

### El Desinteresado
Está ahí porque lo mandaron. **Estrategia:** Conectar con su trabajo específico, hacer preguntas directas, mostrar el beneficio personal.

### El Negativo
Critica todo. **Estrategia:** No discutir. Preguntar: ¿Qué propones tú? Invitar a que comparta su experiencia.

### El Interrumpidor
Habla en momentos inapropiados. **Estrategia:** Excelente pregunta, la anoto para después. Podemos hablar en el descanso.

### El Tímido
No participa. **Estrategia:** No forzarlo frente al grupo. Aprovechar trabajo en parejas. Acercarse en los descansos.

## 5. Técnicas de Retroalimentación Efectiva

### Modelo COIN
- **Context:** Dónde y cuándo ocurrió
- **Observation:** Qué se observó, sin juicios
- **Impact:** Qué efecto tuvo
- **Next:** Qué se sugiere hacer diferente

### Retroalimentación Constructiva
- Enfocada en el comportamiento, no en la persona
- Específica, no general
- Oportuna (inmediata)
- Privada si puede avergonzar
- Balanceada: reconocer lo bueno y mejorar lo que falta

## 6. Cierre de la Capacitación

- **Resumen:** Repasar puntos clave (pedir a los participantes que los digan)
- **Compromiso:** Cada participante dice una cosa que hará diferente
- **Evaluación:** Examen o demostración
- **Agradecimiento:** Reconocer la participación
- **Seguimiento:** Cómo se dará seguimiento

## 7. Conclusiones

El manejo de grupos es un arte que se perfecciona con la práctica. La retroalimentación efectiva es lo que convierte una capacitación en un cambio de comportamiento. Un instructor que sabe manejar grupos y dar retroalimentación constructiva genera un ambiente donde los adultos aprenden, participan y se comprometen con la seguridad.',
  video_url = 'https://www.youtube.com/embed/GwcbMaq0Spk'
WHERE id = 54;

-- Leccion 55: Liderazgo en seguridad y salud ocupacional
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Liderazgo en Seguridad y Salud Ocupacional

## 1. El Rol del Supervisor de Seguridad

El supervisor de seguridad es la figura clave entre la dirección y los trabajadores en materia de seguridad y salud ocupacional. Su rol va más allá de vigilar el uso de EPP: es un líder que influye en la cultura de seguridad de toda la organización.

### Responsabilidades Principales
- Implementar el programa de seguridad en su área
- Vigilar el cumplimiento de normas y procedimientos
- Identificar y controlar riesgos
- Capacitar al personal a su cargo
- Investigar accidentes e incidentes
- Mantener registros de seguridad
- Comunicar a la dirección el estado de la seguridad

### Perfil del Supervisor
Conocimiento técnico en seguridad, liderazgo, capacidad de comunicación, observación, decisión, integridad, empatía, constancia.

## 2. La NOM-030-STPS-2009

Establece los requisitos para los servicios preventivos de seguridad y salud en el trabajo. El supervisor debe conocer esta norma y aplicarla en su gestión diaria.

## 3. Estilos de Liderazgo en Seguridad

### Liderazgo Reactivo
La seguridad solo importa después del accidente. **Resultado:** Accidentes recurrentes, cultura reactiva.

### Liderazgo de Cumplimiento
Se cumple la norma porque es obligatorio. **Resultado:** Cumplimiento mínimo, accidentes cuando no hay supervisión.

### Liderazgo Proactivo
Se buscan riesgos antes de que causen daño. Se invierte en prevención. **Resultado:** Menos accidentes, cultura de mejora continua.

### Liderazgo Resiliente
La seguridad es un valor fundamental. Todos participan. El supervisor lidera con el ejemplo. **Resultado:** Cultura de seguridad fuerte, accidentes mínimos.

## 4. Liderazgo Visible

### Caminatas de Seguridad
El supervisor camina por las áreas regularmente para observar condiciones, hablar con los trabajadores, escuchar preocupaciones, identificar riesgos, reconocer comportamientos seguros.

### Predicar con el Ejemplo
- Si el supervisor no usa EPP, nadie lo usará
- Si el supervisor salta procedimientos, los trabajadores también
- Si el supervisor detiene trabajo inseguro, los trabajadores saben que es serio

### Reconocimiento Positivo
Reconocer públicamente a quienes trabajan de forma segura. Las consecuencias positivas son más efectivas que las negativas.

## 5. Cultura de Seguridad

Son los valores, creencias y comportamientos compartidos que determinan cómo se hace la seguridad en una organización.

### Indicadores de Cultura Fuerte
- Los trabajadores reportan condiciones inseguras sin temor
- Detienen trabajo inseguro por propia iniciativa
- Sugieren mejoras de seguridad
- Los líderes participan activamente
- La seguridad no se compromete por producción

### Indicadores de Cultura Débil
- Los trabajadores ocultan accidentes por temor a sanciones
- Siempre se ha hecho así es una respuesta aceptada
- La producción es prioritaria sobre la seguridad
- El EPP se usa solo cuando hay supervisión

## 6. El Supervisor como Agente de Cambio

1. Predicar con el ejemplo: usar EPP, seguir procedimientos
2. Comunicar el por qué: no solo usa el arnés, sino el arnés salva tu vida
3. Reconocer lo positivo: elogiar comportamientos seguros
4. Corregir lo inseguro: inmediatamente, con respeto, explicando el por qué
5. Involucrar a los trabajadores: pedir su opinión, escuchar sus ideas
6. Ser constante: la seguridad es todos los días

## 7. Comunicación Efectiva

### Reuniones de Seguridad (Toolbox Talks)
Charlas cortas (10-15 minutos) al inicio del turno. Tema específico, relevante para el trabajo del día. Interactivas, no monólogos.

### Barreras de Comunicación
- Siempre se ha hecho así
- Nunca ha pasado nada
- Es trabajo extra
Abordar estas barreras con datos, no con órdenes.

## 8. Conclusiones

El supervisor de seguridad es el líder más influyente en la cultura de seguridad. Su ejemplo, comunicación y constancia son lo que determina si los trabajadores trabajarán de forma segura cuando nadie los vigila. Un buen supervisor no solo vigila: educa, motiva y lidera con el ejemplo.',
  video_url = 'https://www.youtube.com/embed/prXHuJ-iaYU'
WHERE id = 55;

-- Leccion 56: Identificación y evaluación de riesgos
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Identificación y Evaluación de Riesgos (IPERC)

## 1. ¿Qué es IPERC?

IPERC (Identificación de Peligros, Evaluación de Riesgos y Control) es una metodología sistemática para: 1) Identificar los peligros en el lugar de trabajo, 2) Evaluar el riesgo asociado, 3) Implementar controles, 4) Monitorear y revisar.

## 2. Conceptos Clave

- **Peligro:** Fuente, situación o acto con potencial de causar daño (electricidad, altura, químicos, ruido).
- **Riesgo:** Combinación de probabilidad de que ocurra un daño y severidad de ese daño. Riesgo = Probabilidad x Severidad.
- **Control:** Medida para reducir el riesgo.

## 3. Proceso IPERC

### Paso 1: Identificar Peligros
Recorrer el área e identificar todos los peligros: físicos (ruido, temperatura, radiación), químicos (gases, vapores, polvos), biológicos, ergonómicos (posturas, esfuerzo), mecánicos (partes móviles, atrapamiento), eléctricos, psicosociales (estrés).

### Paso 2: Evaluar Riesgos
- **Probabilidad:** Baja (improbable), Media (posible), Alta (muy probable)
- **Severidad:** Leve (primeros auxilios), Moderada (días de baja), Grave (incapacidad), Catastrófica (muerte)

### Paso 3: Matriz de Riesgo
Cruza probabilidad con severidad:
- Crítico: acción inmediata
- Alto: acción prioritaria
- Medio: gestionar a corto plazo
- Bajo: gestionar a mediano plazo

### Paso 4: Priorizar Riesgos
Los riesgos críticos y altos requieren acción inmediata.

## 4. Jerarquía de Controles

De más efectivo a menos efectivo:

1. **Eliminación:** Eliminar el peligro completamente. Ej: automatizar un proceso para que nadie entre al espacio confinado.
2. **Sustitución:** Reemplazar por algo menos peligroso. Ej: usar solvente no tóxico.
3. **Controles de Ingeniería:** Aislar a las personas del peligro. Ej: resguardos, ventilación, barreras.
4. **Controles Administrativos:** Cambiar cómo trabajan las personas. Ej: procedimientos, capacitación, señalización.
5. **EPP:** Última línea de defensa. Ej: arnés, casco, respirador.

Los controles superiores no dependen del comportamiento humano. Los inferiores sí, por lo que son menos confiables.

## 5. Documentación IPERC

### Matriz IPERC
Documento que lista todos los peligros, riesgos evaluados, nivel de riesgo, controles existentes y controles adicionales necesarios.

### Actualización
Debe actualizarse cuando: cambia el proceso o equipo, se introducen nuevos materiales, ocurre un accidente, al menos una vez al año.

## 6. Aplicación Práctica del Supervisor

1. Conocer la matriz IPERC de su área
2. Participar en su elaboración y actualización
3. Comunicar los riesgos a los trabajadores
4. Verificar que los controles estén en su lugar
5. Reportar nuevos peligros
6. Priorizar controles para riesgos altos y críticos

## 7. Errores Comunes

- Considerar solo peligros obvios (ignorar ergonómicos, psicosociales)
- Confiar solo en EPP como control
- No actualizar la matriz cuando cambian las condiciones
- Hacer el IPERC como documento y no como herramienta de gestión
- No involucrar a los trabajadores

## 8. Conclusiones

La identificación de riesgos es el proceso fundamental para prevenir accidentes. Un riesgo no identificado es un riesgo no controlado. La metodología IPERC proporciona un marco sistemático. La jerarquía de controles guía la selección de medidas más efectivas. El supervisor es responsable de que este proceso se realice y se mantenga actualizado.',
  video_url = 'https://www.youtube.com/embed/LatBNnHA8ss'
WHERE id = 56;

-- Leccion 57: Normativa STPS aplicable
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Normativa STPS Aplicable a Seguridad y Salud Ocupacional

## 1. ¿Qué es la STPS?

La Secretaría del Trabajo y Previsión Social (STPS) es la dependencia del gobierno mexicano responsable de establecer y vigilar el cumplimiento de las normas de seguridad y salud en el trabajo. Las Normas Oficiales Mexicanas (NOM) son de cumplimiento obligatorio.

## 2. Programa de Seguridad y Salud en el Trabajo (PSST)

La NOM-030-STPS-2009 establece que todo centro de trabajo debe contar con un PSST.

### Contenido del PSST
1. Política de seguridad y salud
2. Organización del programa
3. Identificación de riesgos (IPERC)
4. Objetivos y metas
5. Acciones preventivas y correctivas
6. Capacitación al personal
7. Gestión de EPP
8. Salud ocupacional
9. Simulacros y respuesta a emergencias
10. Investigación de accidentes
11. Auditorías internas

### Revisión del PSST
Al menos una vez al año, actualización cuando cambien las condiciones, documentación formal.

## 3. Normas NOM Más Relevantes

- **NOM-001-STPS-2008:** Edificios, locales e instalaciones
- **NOM-004-STPS-2023:** Sistemas de protección y LOTO en maquinaria
- **NOM-009-STPS-2011:** Trabajos en alturas
- **NOM-017-STPS-2008:** Equipo de protección personal
- **NOM-027-STPS-2008:** Soldadura y corte
- **NOM-030-STPS-2009:** Servicios preventivos (PSST)
- **NOM-033-STPS-2015:** Espacios confinados
- **NOM-035-STPS-2018:** Factores de riesgo psicosocial
- **NOM-036-STPS-2018:** Factores de riesgo ergonómico
- **NOM-002-STPS-2010:** Prevención y protección contra incendios

## 4. Obligaciones del Empleador

- Proporcionar capacitación y adiestramiento
- Proporcionar EPP adecuado y certificado
- Mantener instalaciones seguras
- Elaborar y mantener actualizado el PSST
- Investigar accidentes y enfermedades
- Reportar accidentes graves a la STPS
- Permitir inspecciones de la STPS

## 5. Obligaciones del Trabajador

- Cumplir las normas y procedimientos
- Usar correctamente el EPP
- Participar en capacitaciones
- Reportar condiciones inseguras
- Cooperar en investigaciones

## 6. Consecuencias del Incumplimiento

### Sanciones Administrativas
Multas, clausura temporal o definitiva, suspensión de actividades.

### Consecuencias Legales
Responsabilidad civil (indemnizaciones), responsabilidad penal en caso de accidentes graves por negligencia.

### Consecuencias Operacionales
Accidentes, pérdida de producción, daño a la reputación, aumento de costos.

## 7. Indicadores del PSST

- **Índice de Frecuencia (IF):** (Accidentes x 1,000,000) / Horas trabajadas
- **Índice de Gravedad (IG):** (Días perdidos x 1,000,000) / Horas trabajadas
- **Cumplimiento del Programa (%):** Acciones completadas / Acciones planeadas x 100
- **Eficacia de Capacitación (%):** Personal capacitado / Personal total x 100

## 8. Conclusiones

La normativa STPS establece los requisitos mínimos de seguridad. El supervisor es responsable de conocer estas normas, implementarlas y verificar su cumplimiento. El cumplimiento normativo no es una carga: es el marco que protege la vida de los trabajadores.',
  video_url = 'https://www.youtube.com/embed/949z0LmanNU'
WHERE id = 57;

-- Leccion 58: Investigación de incidentes y acciones correctivas
UPDATE lessons SET
  content_type = 'mixed',
  content = '# Investigación de Incidentes y Accidentes

## 1. Propósito de la Investigación

La investigación de accidentes tiene un único objetivo: encontrar las causas raíz para evitar que el accidente vuelva a ocurrir. No es buscar culpables, sino encontrar soluciones.

### Diferencia entre Incidente y Accidente
- **Incidente:** Evento que no causó lesión pero pudo causarla (cuasi-accidente)
- **Accidente:** Evento que causó lesión, daño o pérdida

## 2. Tipos de Causas

### Causas Inmediatas
- **Actos inseguros:** No usar EPP, operar sin autorización, saltarse procedimientos
- **Condiciones inseguras:** Equipo dañado, señalización deficiente, iluminación insuficiente

### Causas Básicas (Raíz)
- **Factores personales:** Falta de capacitación, fatiga, estrés
- **Factores organizacionales:** Procedimientos inadecuados, falta de supervisión, presión de producción

## 3. Pasos de la Investigación

### Paso 1: Asegurar el Área
- Atender a los heridos (prioridad absoluta)
- Controlar el riesgo
- Aislar el área (no alterar la escena)
- Notificar a autoridades

### Paso 2: Recopilar Evidencia
- Fotografías del área, del equipo y de las condiciones
- Videos de cámaras de seguridad
- Registros: mantenimiento, capacitación, inspecciones, permisos
- Reportes previos de condiciones inseguras

### Paso 3: Entrevistar Testigos
- Entrevistar lo antes posible
- Cada testigo por separado
- Preguntas abiertas: ¿Qué viste? ¿Qué escuchaste? ¿Qué pasaba antes?
- No sugerir respuestas, no juzgar

### Paso 4: Analizar Causas

#### Técnica de los 5 ¿Por Qué?
Ejemplo:
1. El trabajador se cayó - Porque resbaló
2. - Porque había aceite en el piso
3. - Porque la máquina tiene una fuga
4. - Porque el sello está dañado
5. - Porque no se ha hecho mantenimiento preventivo

Causa raíz: ausencia de mantenimiento preventivo.

### Paso 5: Definir Acciones Correctivas
Deben atacar causas raíz, ser específicas (qué, quién, cuándo), tener responsable, fecha y seguimiento.

### Paso 6: Elaborar Reporte
Incluir: descripción del accidente, personas involucradas, testigos, evidencia, análisis de causas, acciones correctivas, firmas.

### Paso 7: Seguimiento
Verificar que las acciones se implementaron, evaluar efectividad, cerrar formalmente, comunicar lecciones aprendidas.

## 4. Reporte a Autoridades

En México, los accidentes graves deben reportarse a la STPS dentro de las 72 horas: accidentes mortales, con incapacidad permanente, que requieran hospitalización.

## 5. Lecciones Aprendidas

La investigación no termina con el reporte. Las lecciones deben compartirse: comunicar a otros supervisores, incorporar en capacitaciones, actualizar procedimientos, modificar la matriz IPERC, verificar áreas similares.

## 6. Errores Comunes

- Investigar para culpar, no para prevenir
- Detenerse en causas inmediatas (no buscar raíz)
- No entrevistar a todos los testigos
- No recopilar evidencia física
- No asignar responsables ni fechas
- No dar seguimiento
- No compartir lecciones aprendidas
- Demorar la investigación

## 7. Conclusiones

La investigación de accidentes es la herramienta más poderosa para prevenir que se repitan. Un accidente investigado correctamente puede prevenir decenas de accidentes futuros. La clave está en buscar causas raíz, no culpables. Las acciones correctivas deben atacar las causas raíz y tener seguimiento. Un supervisor que sabe investigar accidentes es un supervisor que construye seguridad, no solo reacciona a ella.',
  video_url = 'https://www.youtube.com/embed/qZxlYp4lpNE'
WHERE id = 58;
