-- ============================================
-- EHS SOLUTIONS - SCHEMA + SEED DATA
-- Ejecutar en Supabase SQL Editor
-- ============================================

-- ============================================
-- 1. SCHEMA
-- ============================================

CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) DEFAULT 'student' CHECK (role IN ('student', 'instructor', 'admin')),
  bio TEXT,
  avatar_url VARCHAR(500),
  phone VARCHAR(20),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS courses (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  short_description VARCHAR(500),
  instructor_id INTEGER NOT NULL REFERENCES users(id),
  category VARCHAR(100),
  thumbnail_url VARCHAR(500),
  is_published BOOLEAN DEFAULT FALSE,
  price DECIMAL(10, 2) DEFAULT 0,
  duration_hours INTEGER,
  difficulty_level VARCHAR(50) CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS modules (
  id SERIAL PRIMARY KEY,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  order_index INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lessons (
  id SERIAL PRIMARY KEY,
  module_id INTEGER NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  content_type VARCHAR(50) CHECK (content_type IN ('video', 'text', 'document', 'mixed')),
  content_url VARCHAR(500),
  video_url VARCHAR(500),
  document_url VARCHAR(500),
  content TEXT,
  duration_minutes INTEGER,
  order_index INTEGER,
  is_required BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS enrollments (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completion_date TIMESTAMP,
  status VARCHAR(50) DEFAULT 'enrolled' CHECK (status IN ('enrolled', 'in_progress', 'completed', 'dropped')),
  progress_percentage DECIMAL(5, 2) DEFAULT 0,
  UNIQUE(student_id, course_id)
);

CREATE TABLE IF NOT EXISTS lesson_progress (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  is_completed BOOLEAN DEFAULT FALSE,
  completion_date TIMESTAMP,
  time_spent_minutes INTEGER DEFAULT 0,
  UNIQUE(student_id, lesson_id)
);

CREATE TABLE IF NOT EXISTS quizzes (
  id SERIAL PRIMARY KEY,
  lesson_id INTEGER NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  passing_score DECIMAL(5, 2) DEFAULT 70,
  total_questions INTEGER,
  time_limit_minutes INTEGER,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quiz_questions (
  id SERIAL PRIMARY KEY,
  quiz_id INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  option_a TEXT,
  option_b TEXT,
  option_c TEXT,
  option_d TEXT,
  correct_answer VARCHAR(1) CHECK (correct_answer IN ('a', 'b', 'c', 'd')),
  explanation TEXT,
  order_index INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quiz_results (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quiz_id INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  score DECIMAL(5, 2),
  total_questions INTEGER,
  correct_answers INTEGER,
  answers JSONB,
  started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  UNIQUE(student_id, quiz_id)
);

CREATE TABLE IF NOT EXISTS certificates (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  certificate_number VARCHAR(100) UNIQUE,
  issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  pdf_url VARCHAR(500),
  is_valid BOOLEAN DEFAULT TRUE,
  UNIQUE(student_id, course_id)
);

-- ============================================
-- 2. SEED DATA
-- ============================================

-- Usuario Instructor
INSERT INTO users (first_name, last_name, email, password, role, bio, is_active)
VALUES ('Carlos', 'Ramírez', 'instructor@ehs-solutions.com', '$2b$10$J1NZQvHhPeT8Sbh0DP0N3usf/KiW3g6.jkbx7LKyk0OW3myY/zYUy', 'instructor', 'Instructor certificado en Seguridad Industrial y Salud Ocupacional con 15 años de experiencia.', true)
ON CONFLICT (email) DO NOTHING;

-- Usuario Admin
INSERT INTO users (first_name, last_name, email, password, role, bio, is_active)
VALUES ('Admin', 'EHS', 'admin@ehs-solutions.com', '$2b$10$J1NZQvHhPeT8Sbh0DP0N3usf/KiW3g6.jkbx7LKyk0OW3myY/zYUy', 'admin', 'Administrador del sistema EHS Solutions.', true)
ON CONFLICT (email) DO NOTHING;

-- Usuario Estudiante de ejemplo
INSERT INTO users (first_name, last_name, email, password, role, is_active)
VALUES ('Ana', 'García', 'estudiante@ehs-solutions.com', '$2b$10$J1NZQvHhPeT8Sbh0DP0N3usf/KiW3g6.jkbx7LKyk0OW3myY/zYUy', 'student', true)
ON CONFLICT (email) DO NOTHING;

-- ============================================
-- CURSO 1: Seguridad en Trabajos en Alturas
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Seguridad en Trabajos en Alturas',
  'Curso integral sobre seguridad en trabajos en alturas. Aprende los riesgos, equipos de protección, sistemas de detención de caídas y procedimientos de rescate conforme a la NOM-009-STPS-2011.',
  'Protege tu vida trabajando en alturas con los equipos y protocolos correctos.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 8, 'intermediate'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas'), 'Fundamentos y Marco Legal', 'Conceptos básicos, definiciones y normativa aplicable.', 1),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas'), 'Equipos y Sistemas de Protección', 'EPP, arneses, líneas de vida y puntos de anclaje.', 2),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas'), 'Procedimientos y Rescate', 'Procedimientos de trabajo seguro y planes de rescate.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Fundamentos y Marco Legal' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Introducción a Trabajos en Alturas', 'Definición, riesgos y marco normativo NOM-009-STPS-2011.', 'mixed',
   'El trabajo en alturas es una de las actividades de mayor riesgo en la industria. Se define como trabajo en alturas toda actividad realizada a una altura mayor a 1.8 metros sobre el nivel del suelo.

La NOM-009-STPS-2011 establece las condiciones de seguridad para realizar trabajos en alturas. Esta norma es obligatoria para todos los centros de trabajo donde se realicen actividades a alturas de más de 1.8 metros.

Los riesgos principales incluyen: caídas desde altura, golpes por objetos desprendidos, factores ambientales (viento, lluvia), fatiga y estrés térmico. La caída desde altura es una de las causas principales de accidentes mortales en el sector construcción e industrial.

Es fundamental que todo trabajador que realice actividades en alturas reciba capacitación específica antes de iniciar sus labores, y que cuente con el equipo de protección personal adecuado y certificado.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Fundamentos y Marco Legal' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Identificación de Riesgos en Altura', 'Evaluación de riesgos, factores de peligro y medidas preventivas.', 'mixed',
   'La identificación de riesgos es el primer paso para prevenir accidentes en trabajos en alturas. Debemos evaluar cada sitio de trabajo antes de iniciar cualquier actividad.

Los factores de riesgo a evaluar incluyen: altura de trabajo, tipo de superficie, condiciones meteorológicas, proximidad a líneas eléctricas, cargas suspendidas y tránsito de personal debajo del área de trabajo.

El análisis de riesgo debe documentarse en un permiso de trabajo en alturas que incluya: descripción de la tarea, ubicación, duración, equipos requeridos, personal autorizado y medidas de control.

Las medidas preventivas básicas son: delimitar el área, usar señalización, instalar barandillas o redes de seguridad, verificar condiciones del equipo antes de cada uso y mantener comunicación constante entre el trabajador y el supervisor.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Equipos y Sistemas de Protección' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Equipos de Protección Personal (EPP) para Altura', 'Arnés, casco, calzado y accesorios certificados.', 'mixed',
   'El EPP para trabajos en alturas es tu última línea de defensa contra una caída. Debe estar certificado y en óptimas condiciones.

El arnés de cuerpo completo es el elemento más importante. Debe ajustarse correctamente, con todas las hebillas cerradas y las correas sin torceduras. Un arnés mal ajustado puede causar lesiones graves durante una caída.

El casco con barbiquecho es obligatorio para prevenir que se caiga durante el trabajo. El calzado debe ser antideslizante y con punta de acero.

ACCESORIOS IMPORTANTES: Los mosquetones deben ser de seguridad (con bloqueo automático), las cuerdas deben ser de material resistente y certificadas para carga humana, y los absorbedores de energía son obligatorios para reducir el impacto de una caída.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Equipos y Sistemas de Protección' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Sistemas de Detención de Caídas', 'Líneas de vida, puntos de anclaje y conectores.', 'mixed',
   'Un sistema de detención de caídas está compuesto por tres elementos: punto de anclaje, conector y arnés. Cada elemento debe soportar como mínimo 5,000 libras (22.2 kN) de fuerza.

Los puntos de anclaje deben ser estructuralmente sólidos. Nunca deben usarse tuberías, ductos o estructuras no diseñadas como puntos de anclaje. Un ingeniero debe certificar cada punto de anclaje.

Las líneas de vida pueden ser horizontales o verticales. Las líneas de vida horizontal permiten el desplazamiento del trabajador a lo largo de una superficie, mientras que las verticales se usan en escaleras o estructuras altas.

LOS RETRACTILES son dispositivos que se bloquean automáticamente en caso de caída. Deben instalarse por encima del trabajador (punto de anclaje superior) para minimizar la distancia libre de caída.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true),

  ((SELECT id FROM modules WHERE title = 'Procedimientos y Rescate' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Procedimientos de Trabajo Seguro en Alturas', 'Permisos, inspecciones y protocolos operativos.', 'mixed',
   'Todo trabajo en alturas requiere un permiso de trabajo firmado por el supervisor responsable. Este permiso debe renovarse cada vez que cambien las condiciones o el personal.

Antes de iniciar el trabajo, se debe realizar una inspección del equipo: verificar arneses, mosquetones, cuerdas y puntos de anclaje. Cualquier equipo con signos de desgaste debe retirarse inmediatamente.

Durante el trabajo, se debe mantener comunicación constante con el compañero de trabajo o supervisor. Nunca se debe trabajar solo en alturas.

AL FINALIZAR el trabajo, se debe realizar una inspección post-uso del equipo, limpiar y almacenar correctamente, y reportar cualquier incidente o casi-incidente para mejorar los protocolos.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Procedimientos y Rescate' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos en Alturas')),
   'Plan de Rescate en Alturas', 'Procedimientos de emergencia y rescate de víctimas en altura.', 'mixed',
   'El plan de rescate es obligatorio y debe estar listo antes de iniciar cualquier trabajo en alturas. Ningún trabajador debe quedar suspendido por más de 15 minutos debido al síndrome de suspensión (trauma por suspension).

El síndrome de suspensión ocurre cuando una persona queda colgada inmovilizada después de una caída. La sangre se acumula en las piernas, reduciendo el flujo al cerebro, lo que puede causar la muerte en menos de 30 minutos.

El equipo de rescate debe incluir: cuerdas de rescate, poleas, descensores de rescate, camilla de canasta y botiquín de primeros auxilios. Todo el personal debe conocer la ubicación del equipo.

EL PROCEDIMIENTO DE RESCATE incluye: 1) Asegurar el área, 2) Evaluar el estado de la víctima, 3) Realizar el rescate con técnica adecuada, 4) Brindar primeros auxilios, 5) Trasladar a centro médico. Practicar este procedimiento regularmente con simulacros.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 2: Seguridad en Trabajos de Soldadura y Oxicorte
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Seguridad en Trabajos de Soldadura y Oxicorte',
  'Curso sobre seguridad en procesos de soldadura y oxicorte. Riesgos eléctricos, radiación, gases tóxicos, incendios y manejo de cilindros de gases comprimidos conforme a la NOM-027-STPS-2008.',
  'Solda con seguridad: protege tu vista, tu cuerpo y tu entorno de trabajo.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 6, 'intermediate'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte'), 'Riesgos de la Soldadura', 'Identificación de riesgos: eléctricos, radiación, humos y gases.', 1),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte'), 'Equipos de Protección', 'EPP para soldador y manejo seguro de equipos.', 2),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte'), 'Prevención de Incendios y Manejo de Cilindros', 'Prevención de incendios, ventilación y cilindros de gases.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Riesgos de la Soldadura' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte')),
   'Riesgos Eléctricos en Soldadura', 'Descargas eléctricas, arcos eléctricos y prevención.', 'mixed',
   'La soldadura eléctrica (SMAW, GMAW, FCAW, GTAW) utiliza corriente eléctrica para fundir metales. El riesgo de electrocución está siempre presente.

Los riesgos eléctricos principales son: contacto con electrodos energizados, cables dañados, conexiones defectuosas, trabajar en ambientes húmedos o con sudor, y equipos sin conexión a tierra.

La NOM-027-STPS-2008 establece las medidas de seguridad para trabajos de soldadura. Todo equipo de soldar debe tener cable de tierra, pinzas porta-electrodo en buen estado y cables sin empalmes.

PREVENCIÓN: Nunca soldar en ambientes húmedos sin protección adicional. Usar guantes secos. Inspeccionar cables antes de cada turno. No cambiar electrodos con la pinza energizada. Desconectar el equipo al terminar.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Riesgos de la Soldadura' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte')),
   'Radiación y Humos de Soldadura', 'Radiación UV/IR, humos metálicos y gases tóxicos.', 'mixed',
   'El arco de soldadura emite radiación ultravioleta (UV) e infrarroja (IR) que puede causar quemaduras en la piel y lesiones oculares graves como queratitis o ceguera temporal.

Los humos de soldadura contienen partículas metálicas que dependen del material base y el electrodo. El humo de soldadura de acero inoxidable contiene cromo hexavalente (Cancerígeno). El plomo y el cadmio también son extremadamente tóxicos.

La ventilación es crítica. Se debe soldar en áreas bien ventiladas o con sistemas de extracción local. En espacios confinados, la ventilación forzada es obligatoria.

PROTECCIÓN RESPIRATORIA: Usar mascarillas o respiradores con filtros apropiados para el tipo de soldadura. La protección ocular requiere lentes con filtro adecuado al proceso (DIN 9 a 13 según intensidad).',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Equipos de Protección' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte')),
   'EPP Completo para Soldador', 'Careta, guantes, mandil, polainas y respirador.', 'mixed',
   'El EPP del soldador debe cubrir todo el cuerpo para proteger contra radiación, chispas, salpicaduras y quemaduras.

CARETA DE SOLDAR: Debe tener filtro óptico adecuado (mínimo DIN 10 para soldadura SMAW). La careta debe cubrir todo el rostro y cuello. Los lentes protectores debajo de la careta son obligatorios por si se levanta.

GUANTES Y ROPA: Guantes de cuero crudo largos que cubran hasta el codo. Mandil de cuero, polainas, mangas protectoras. Ropa de algodón sin bolsillos (las chispas pueden acumularse). Calzado de seguridad sin cordones expuestos.

RESPIRADORES: Para soldadura normal, respirador con filtro para partículas P100. Para materiales especiales (inoxidable, galvanizado), se requiere respirador con filtros específicos para gases y vapores.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Prevención de Incendios y Manejo de Cilindros' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte')),
   'Prevención de Incendios en Soldadura', 'Riesgos de incendio, áreas de trabajo y extintores.', 'mixed',
   'La soldadura y oxicorte generan chispas y calor que pueden iniciar incendios a varios metros de distancia. Las chispas pueden viajar hasta 10 metros y pasar por grietas.

ANTES DE SOLDAR: Retirar todo material combustible en un radio de 11 metros. Si no se puede retirar, proteger con mantas ignífugas. Cerrar todas las aberturas (conductos, ranuras) por donde puedan pasar chispas.

Un vigía contra incendios debe estar presente durante y al menos 30 minutos después de terminar el trabajo de soldadura en áreas con riesgo.

EXTINTORES: Deben estar al alcance inmediato, tipo ABC de mínimo 4 kg. El soldador debe conocer su uso. Nunca soldar sobre recipientes que hayan contenido materiales inflamables sin limpiar y purgar previamente.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 15, 1, true),

  ((SELECT id FROM modules WHERE title = 'Prevención de Incendios y Manejo de Cilindros' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Trabajos de Soldadura y Oxicorte')),
   'Manejo Seguro de Cilindros de Gases', 'Almacenamiento, transporte y uso de cilindros de oxígeno y acetileno.', 'mixed',
   'Los cilindros de gases comprimidos son extremadamente peligrosos si se manejan incorrectamente. El oxígeno acelera la combustión y el acetileno puede explotar bajo presión.

ALMACENAMIENTO: Los cilindros de oxígeno y combustibles deben almacenarse separados (mínimo 6 metros entre ellos) o con barrera cortafuego de 1.5m de altura. Nunca almacenar cilindros cerca de fuentes de calor o llamas.

TRANSPORTE: Los cilindros deben transportarse con capucha protectora colocada, en carritos diseñados para tal fin. Nunca arrastrar, rodar o dejar caer cilindros. Nunca levantar cilindros por la válvula.

USO: Abrir las válvulas lentamente. El oxígeno primero, luego el combustible. Para apagar: cerrar primero el combustible, luego el oxígeno. Inspeccionar mangueras por fugas con solución de jabón, NUNCA con llama.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 15, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 3: Formación de Brigadas de Emergencia
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Formación de Brigadas de Emergencia',
  'Curso para integrar y capacitar brigadas de emergencia empresariales. Responde a incendios, evacuación, primeros auxilios y sismos con protocolos organizados.',
  'Prepara a tu empresa para responder ante cualquier emergencia con una brigada capacitada.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 8, 'beginner'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia'), 'Organización de Brigadas', 'Estructura, roles y funciones de la brigada de emergencia.', 1),
  ((SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia'), 'Respuesta a Incendios', 'Uso de extintores, control de incendios y evacuación.', 2),
  ((SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia'), 'Primeros Auxilios y Evacuación', 'Atención de heridos, simulacros y procedimientos de evacuación.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Organización de Brigadas' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Estructura de la Brigada de Emergencia', 'Roles, responsabilidades y organización.', 'mixed',
   'Una brigada de emergencia es un grupo de personas capacitadas dentro de una organización para responder ante situaciones de emergencia. Su objetivo es proteger la vida y minimizar daños.

LOS ROLES PRINCIPALES son: Coordinador general (dirige la respuesta), Jefe de brigada (ejecuta acciones), Brigadistas contra incendios (combate incendios iniciales), Brigadistas de primeros auxilios (atiene heridos), Brigadistas de evacuación (guían al personal), y Brigadistas de comunicación (alertan y notifican).

La selección del personal debe considerar: buena condición física, disposición, liderazgo, capacidad de actuar bajo presión y permanencia en la organización.

La brigada debe estar constituida formalmente por escrito, con acta de constitución, registro de miembros y asignación de responsabilidades específicas a cada integrante.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Organización de Brigadas' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Plan de Emergencia Interno', 'Elaboración del plan de respuesta a emergencias.', 'mixed',
   'El Plan de Emergencia Interno (PEI) es el documento que establece las acciones a seguir ante una emergencia. Debe ser conocido por todo el personal y actualizado regularmente.

EL PLAN DEBE INCLUIR: identificación de riesgos, rutas de evacuación, puntos de reunión, inventario de recursos (extintores, botiquines, etc.), directorio de emergencia (bomberos, Cruz Roja, protección civil), y procedimientos específicos por tipo de emergencia.

Los procedimientos específicos deben cubrir: incendios, sismos, inundaciones, derrames químicos, amenazas de bomba, accidentes laborales y emergencias médicas.

El plan debe probarse mediante simulacros al menos 2 veces al año. Cada simulacro debe evaluarse para identificar áreas de mejora.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true),

  ((SELECT id FROM modules WHERE title = 'Respuesta a Incendios' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Uso de Extintores Portátiles', 'Tipos de extintores, método PASS y combate de incendios iniciales.', 'mixed',
   'Los extintores portátiles son la primera línea de defensa contra incendios pequeños. Conocer su uso correcto puede evitar que un pequeño conato se convierta en una catástrofe.

TIPOS DE EXTINTORES: Clase A (sólidos: madera, papel), Clase B (líquidos inflamables: gasolina, aceite), Clase C (eléctricos), Clase D (metales combustibles), Clase K (aceites de cocina). El extintor multipropósito ABC cubre la mayoría de las necesidades.

MÉTODO PASS: P = Pull (jalar el seguro), A = Aim (apuntar a la base del fuego), S = Squeeze (presionar la palanca), S = Sweep (barrer de lado a lado).

REGLAS DE SEGURIDAD: Solo atacar incendios en su fase inicial. Mantener siempre una ruta de escape. Si el fuego crece, evacuar inmediatamente. Nunca dar la espalda al fuego. El viento debe estar a tu espalda.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Respuesta a Incendios' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Detección y Reporte de Incendios', 'Sistemas de alarma, detección y protocolo de reporte.', 'mixed',
   'La detección temprana es fundamental para el control de incendios. Mientras antes se detecte, más fácil será controlarlo.

SISTEMAS DE DETECCIÓN: Detectores de humo (fotoeléctricos e iónicos), detectores de calor, alarmas manuales (pulsadores). Todos deben estar interconectados al sistema de alarma general.

AL DETECTAR UN INCENDIO: 1) Activar la alarma, 2) Llamar a emergencias (bomberos), 3) Notificar al coordinador de brigada, 4) Iniciar evacuación si es necesario, 5) Intentar combatir el incendio solo si es pequeño y hay extintores disponibles.

PROTOCOLO DE REPORTACIÓN: El reporte debe incluir ubicación exacta, tipo de material en combustión, tamaño del incendio, personas en riesgo y medidas tomadas.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 15, 2, true),

  ((SELECT id FROM modules WHERE title = 'Primeros Auxilios y Evacuación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Evacuación y Puntos de Reunión', 'Rutas de evacuación, puntos de reunión y conteo de personal.', 'mixed',
   'La evacuación es el desplazamiento ordenado del personal desde el área de riesgo hasta un lugar seguro. Debe ejecutarse de forma rápida y organizada.

RUTAS DE EVACUACIÓN: Deben estar señalizadas, iluminadas (con iluminación de emergencia), libres de obstáculos y tener un ancho mínimo de 1.2 metros. Nunca usar elevadores durante una evacuación.

PUNTOS DE REUNIÓN: Deben estar ubicados en zonas seguras, lejos del edificio (mínimo 50 metros), accesibles para vehículos de emergencia y con capacidad suficiente para todo el personal.

CONTEO DE PERSONAL: En el punto de reunión, cada jefe de área debe reportar si todo su personal está presente. Es crítico saber si alguien quedó dentro del edificio. Los brigadistas de evacuación son los responsables de este conteo.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Primeros Auxilios y Evacuación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Brigadas de Emergencia')),
   'Primeros Auxilios Básicos para Brigadistas', 'RCP básico, control de hemorragias y manejo de heridos.', 'mixed',
   'Los brigadistas de primeros auxilios deben estar capacitados para proporcionar atención inicial a las víctimas mientras llega ayuda médica profesional.

RCP BÁSICO: Verificar inconsciencia, llamar a emergencias, iniciar compresiones torácicas (100-120 por minuto, profundidad de 5-6 cm en adultos). Alternar 30 compresiones con 2 ventilaciones.

HEMORRAGIAS: Presión directa sobre la herida con tela limpia. Si no se controla, aplicar torniquete (solo en extremidades, documentar hora de aplicación). Elevar la extremidad si es posible.

QUEMADURAS: Enfriar con agua corriente por 20 minutos. No aplicar cremas, hielo ni romper ampollas. Cubrir con tela limpia. Las quemaduras graves requieren atención médica inmediata.

REGLA DE ORO: No mover a personas con posibles lesiones de columna salvo que haya peligro inminente. Inmovilizar y esperar ayuda especializada.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 4: Seguridad en Espacios Confinados
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Seguridad en Espacios Confinados',
  'Curso sobre seguridad en espacios confinados conforme a la NOM-034-STPS-2017. Aprende sobre atmósferas peligrosas, ventilación, monitoreo y rescate.',
  'Trabaja seguro en espacios confinados: monitorea, ventila y rescata con protocolos correctos.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 6, 'advanced'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados'), 'Identificación y Clasificación', 'Conceptos, tipos y riesgos de espacios confinados.', 1),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados'), 'Monitoreo y Ventilación', 'Atmósferas peligrosas, medición de gases y ventilación.', 2),
  ((SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados'), 'Entrada y Rescate', 'Permisos, procedimientos de entrada y rescate.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Identificación y Clasificación' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   '¿Qué es un Espacio Confinado?', 'Definición, características y tipos según NOM-034-STPS-2017.', 'mixed',
   'Un espacio confinado es un lugar con apertura limitada para entrada y salida, no diseñado para ocupación continua, y que puede presentar riesgos atmosféricos, físicos o de configuración.

CARACTERÍSTICAS: 1) Tamaño suficiente para que entre una persona, 2) Medios limitados de entrada y salida, 3) No diseñado para ocupación continua. Ejemplos: tanques, silos, sótanos, túneles, ductos, fosas, calderas.

TIPOS DE ESPACIOS CONFINADOS según la NOM-034-STPS-2017: Clase A (peligro inmediato para la vida), Clase B (peligro potencial), Clase C (sin peligro pero requiere medidas especiales).

Los riesgos principales incluyen: atmósferas deficientes de oxígeno, gases tóxicos, atmósferas explosivas, riesgos físicos (caídas, atrapamiento), riesgos térmicos, y riesgos de inmersión o ahogamiento.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Identificación y Clasificación' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   'Evaluación de Riesgos en Espacios Confinados', 'Identificación de peligros y evaluación de riesgos específicos.', 'mixed',
   'Antes de entrar a un espacio confinado, se debe realizar una evaluación de riesgos completa. Esta evaluación determina las medidas de control necesarias.

RIESGOS ATMOSFÉRICOS: Deficiencia de oxígeno (menos de 19.5%), enriquecimiento de oxígeno (más de 23.5%), gases tóxicos (H2S, CO, amoníaco, metano), atmósferas inflamables o explosivas.

RIESGOS FÍSICOS: Temperaturas extremas, ruido, vibraciones, configuración interna (obstrucciones, superficies resbaladizas), riesgos eléctricos, riesgo de atrapamiento por materiales.

RIESGOS DE PROCESO: Residuos químicos, reacciones químicas, materiales en suspensión, líquidos que pueden inundar el espacio.

La evaluación debe documentarse en el permiso de entrada, que debe firmar un supervisor autorizado antes de cualquier trabajo.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Monitoreo y Ventilación' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   'Monitoreo de Atmósferas Peligrosas', 'Uso de detectores de gases, interpretación de lecturas y límites.', 'mixed',
   'El monitoreo atmosférico es el paso más crítico antes y durante la entrada a un espacio confinado. Nunca debe confiarse en el sentido del olfato para detectar gases peligrosos.

PARÁMETROS A MEDIR: Oxígeno (rango seguro 19.5% - 23.5%), Gases inflamables (LEL - límite inferior de explosividad, debe ser 0%), Gases tóxicos (H2S máximo 10 ppm, CO máximo 25 ppm).

PROCEDIMIENTO DE MEDICIÓN: 1) Calibrar el equipo, 2) Medir desde el exterior (introducir la sonda por la apertura), 3) Medir a diferentes alturas (los gases se estratifican), 4) Medir en diferentes puntos del espacio, 5) Registrar resultados en el permiso.

El monitoreo debe ser CONTINUO durante toda la operación. Los detectores deben tener alarmas visuales y sonoras que se activen antes de los niveles peligrosos.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Monitoreo y Ventilación' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   'Ventilación de Espacios Confinados', 'Tipos de ventilación, cálculo de caudal y procedimientos.', 'mixed',
   'La ventilación es la medida de control primaria para asegurar una atmósfera segura en espacios confinados. Su objetivo es suministrar oxígeno y eliminar contaminantes.

TIPOS DE VENTILACIÓN: Natural (apertura de entradas), Mecánica por dilución (inyectar aire limpio para reducir concentración de contaminantes), Mecánica por extracción local (extraer contaminantes en su fuente).

CÁLCULO DE CAUDAL: El caudal mínimo recomendado es de 4 a 8 cambios de aire por hora, dependiendo del tipo de espacio y los contaminantes presentes. La fórmula básica es: Q = (K × V) / T donde Q=caudal, V=volumen del espacio, T=tiempo de cambio, K=factor de seguridad.

PRECAUCIONES: Nunca usar oxígeno puro para ventilar (riesgo de explosión). El aire de ventilación debe ser limpio (no cerca de escapes de motores). Verificar que la ventilación no recircule el aire contaminado.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Entrada y Rescate' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   'Permiso de Entrada a Espacio Confinado', 'Requisitos del permiso, responsabilidades y autorizaciones.', 'mixed',
   'El permiso de entrada es un documento obligatorio que autoriza el ingreso a un espacio confinado. Debe estar firmado por el supervisor autorizado antes de cualquier entrada.

EL PERMISO DEBE INCLUIR: Identificación del espacio, propósito de la entrada, personal autorizado (entrantes y asistente), resultados del monitoreo atmosférico, medidas de control implementadas, equipos requeridos, duración del permiso, procedimientos de emergencia.

RESPONSABILIDADES: El Supervisor autoriza y verifica condiciones. El Asistente (standby person) permanece fuera del espacio, mantiene comunicación constante, nunca entra, y activa el rescate si es necesario. Los Entrantes ejecutan el trabajo con el EPP adecuado.

El permiso es válido solo para la tarea especificada y por el tiempo indicado. Cualquier cambio de condiciones invalida el permiso y requiere uno nuevo.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Entrada y Rescate' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad en Espacios Confinados')),
   'Procedimientos de Rescate en Espacios Confinados', 'Planes de rescate, equipos y técnicas de extracción.', 'mixed',
   'El rescate en espacios confinados es una operación de alto riesgo. Más del 60% de las muertes en espacios confinados son personas que intentan rescatar a otros sin el equipo adecuado.

TIPOS DE RESCATE: Autorescate (la víctima usa equipos de escape de emergencia), Rescate no-entrada (se saca a la víctima sin que el rescatista entre al espacio), Rescate con entrada (el rescatista entra al espacio). El rescate no-entrada es el preferido.

EQUIPOS DE RESCATE: Trípode con winche (para espacios verticales), arnés de rescate, línea de vida, equipo de respiración autónomo (SCBA), detector de gases portátil, radio de comunicación.

PROCEDIMIENTO: 1) No entrar sin verificar la atmósfera, 2) Activar el plan de emergencia, 3) Usar SCBA si hay atmósfera peligrosa, 4) Estabilizar a la víctima, 5) Extraer usando el trípode/wintch, 6) Brindar primeros auxilios, 7) Trasladar a centro médico.

REGLA CRÍTICA: Nunca intentar un rescate sin el equipo adecuado. Un rescatista sin protección se convierte en otra víctima.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 5: Aseguramiento de Energía (LOTO)
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Aseguramiento de Energía (LOTO)',
  'Curso sobre el estándar Lockout/Tagout (Bloqueo y Etiquetado) para el control de energías peligrosas conforme a la NOM-020-STPS-2011.',
  'Evita arranques accidentales: bloquea, etiqueta y verifica antes de trabajar.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 4, 'intermediate'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)'), 'Fundamentos del LOTO', 'Conceptos, tipos de energía y marco normativo.', 1),
  ((SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)'), 'Procedimientos de Bloqueo y Etiquetado', 'Aplicación práctica de LOTO en equipos industriales.', 2)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Fundamentos del LOTO' AND course_id = (SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)')),
   'Introducción al Bloqueo y Etiquetado', 'Conceptos del LOTO y tipos de energía peligrosa.', 'mixed',
   'El Lockout/Tagout (LOTO) es un procedimiento de seguridad que asegura que las máquinas y equipos estén aislados de sus fuentes de energía antes de realizar mantenimiento o servicio.

TIPOS DE ENERGÍA PELIGROSA: Eléctrica, neumática, hidráulica, mecánica (resortes, contrapesos), térmica, química, gravitacional, de vapor. Todas deben ser aisladas.

La NOM-020-STPS-2011 establece los requisitos para el control de energías peligrosas. El estándar exige que cada empresa tenga un programa de LOTO por escrito.

BLOQUEO (Lockout): Colocar un candado físico que impide la activación del equipo. ETIQUETADO (Tagout): Colocar una etiqueta de advertencia que indica que el equipo no debe operarse. El bloqueo es siempre preferido sobre el etiquetado.

El objetivo del LOTO es prevenir lesiones graves o mortales causadas por la activación accidental de equipos durante el mantenimiento. Una sola omisión puede ser fatal.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Fundamentos del LOTO' AND course_id = (SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)')),
   'Tipos de Energía y Aislamiento', 'Identificación de fuentes de energía y métodos de aislamiento.', 'mixed',
   'Cada tipo de energía requiere un método específico de aislamiento. Es fundamental identificar TODAS las fuentes antes de comenzar el trabajo.

ENERGÍA ELÉCTRICA: Abrir el disyuntor o interruptor principal y colocar candado. Verificar ausencia de voltaje con un detector (prueba de ausencia de tensión).

ENERGÍA NEUMÁTICA/HIDRÁULICA: Cerrar las válvulas, bloquear y etiquetar. Aliviar la presión residual. Drenar los acumuladores. Verificar que las líneas estén despresurizadas.

ENERGÍA MECÁNICA: Bloquear partes móviles (resortes, contrapesos, volantes). Asegurar que no haya energía almacenada que pueda causar movimiento.

ENERGÍA TÉRMICA/QUÍMICA: Esperar a que el equipo se enfríe. Drenar y purgar líneas de químicos. Bloquear válvulas de suministro de vapor o fluidos calientes.

NUNCA confiar en un solo método. Verificar el aislamiento de TODAS las fuentes de energía.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Procedimientos de Bloqueo y Etiquetado' AND course_id = (SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)')),
   'Procedimiento LOTO Paso a Paso', 'Secuencia correcta de bloqueo, etiquetado y verificación.', 'mixed',
   'El procedimiento LOTO debe seguirse estrictamente, sin omitir ningún paso. Cada omisión puede resultar en un accidente grave.

PASOS DEL PROCEDIMIENTO: 1) Notificar al personal afectado del bloqueo, 2) Identificar TODAS las fuentes de energía, 3) Apagar el equipo por procedimiento normal, 4) Aislar cada fuente de energía, 5) Colocar candados y etiquetas en cada punto de aislamiento, 6) Verificar ausencia de energía (prueba de tensión, intentar arranque), 7) Liberar energía residual (drenar, purgar, enfriar), 8) Realizar el trabajo.

EL CANDADO debe ser personal y único. Cada trabajador tiene su propio candado con su nombre. NUNCA usar el candado de otra persona. En trabajos grupales, usar cajas de bloqueo múltiple (lock box).

LA ETIQUETA debe incluir: nombre del trabajador, fecha, motivo del bloqueo, y contacto. La etiqueta no proporciona aislamiento físico, solo advertencia.

AL TERMINAR el trabajo: 1) Verificar que el área esté despejada, 2) Retirar herramientas y materiales, 3) Notificar al personal, 4) Retirar candados y etiquetas, 5) Restablecer energía por procedimiento normal.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Procedimientos de Bloqueo y Etiquetado' AND course_id = (SELECT id FROM courses WHERE title = 'Aseguramiento de Energía (LOTO)')),
   'Dispositivos de Bloqueo y Restablecimiento', 'Candados, bloqueadores de válvulas, dispositivos múltiples.', 'mixed',
   'Los dispositivos de bloqueo son herramientas físicas que previenen la activación accidental de equipos. Cada tipo de fuente de energía requiere un dispositivo específico.

TIPOS DE DISPOSITIVOS: Candados de seguridad (con cuerpo no conductor para eléctricos), Bloqueadores de válvulas (para neumáticas e hidráulicas), Bloqueadores de interruptores, Cadenas y cables de bloqueo, Tapones cónicos, Dispositivos universales.

CAJAS DE BLOQUEO MÚLTIPLE (LOCK BOX): Cuando varios trabajadores intervienen en un equipo, cada uno coloca su candado en la caja. Nadie puede restablecer la energía hasta que TODOS retiren sus candados. Esto evita que alguien encienda el equipo mientras otro trabajador está dentro.

PROCEDIMIENTO DE RESTABLECIMIENTO: 1) Verificar que todo el personal esté fuera del área, 2) Confirmar que no haya herramientas ni materiales en el equipo, 3) Retirar todos los candados y etiquetas, 4) Notificar al personal que se restablecerá la energía, 5) Activar el equipo por procedimiento normal, 6) Verificar funcionamiento correcto.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 6: Formación de Instructores
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Formación de Instructores',
  'Curso para capacitar instructores de seguridad industrial. Aprende técnicas didácticas, evaluación del aprendizaje y diseño de cursos conforme a requisitos de la STPS.',
  'Conviértete en instructor de seguridad: domina la pedagogía y la técnica de capacitación.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 8, 'advanced'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Formación de Instructores'), 'Pedagogía y Didáctica', 'Principios del aprendizaje adulto y técnicas didácticas.', 1),
  ((SELECT id FROM courses WHERE title = 'Formación de Instructores'), 'Diseño y Evaluación', 'Diseño de cursos, materiales y evaluación del aprendizaje.', 2),
  ((SELECT id FROM courses WHERE title = 'Formación de Instructores'), 'Gestión de la Capacitación', 'Registros, documentación y mejora continua.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Pedagogía y Didáctica' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Principios del Aprendizaje en Adultos', 'Andragogía, estilos de aprendizaje y motivación.', 'mixed',
   'La capacitación a adultos (andragogía) es diferente a la educación tradicional. Los adultos aprenden mejor cuando el contenido es relevante, práctico y aplicable a su trabajo.

CARACTERÍSTICAS DEL APRENDIZ ADULTO: Tiene experiencia previa, busca aplicación inmediata, necesita saber por qué aprende algo, prefiere el autoaprendizaje, y responde mejor al respeto que a la autoridad.

ESTILOS DE APRENDIZAJE: Visual (aprende viendo: diagramas, videos, demostraciones), Auditivo (aprende escuchando: explicaciones, debates), Kinestésico (aprende haciendo: prácticas, simulaciones). Un buen instructor combina los tres estilos.

MOTIVACIÓN: Los adultos se motivan cuando perciben que la capacitación resuelve un problema real, mejora su desempeño o aumenta su seguridad. Conectar el contenido con su experiencia laboral es clave.

PRINCIPIOS: Partir de lo conocido a lo desconocido, de lo simple a lo complejo, de lo teórico a lo práctico. Fomentar la participación, respetar las experiencias y crear un ambiente de confianza.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Pedagogía y Didáctica' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Técnicas Didácticas para Capacitación', 'Exposición, demostración, casos de estudio y dinámicas.', 'mixed',
   'El instructor debe dominar múltiples técnicas didácticas para mantener la atención y facilitar el aprendizaje.

EXPOSICIÓN INTERACTIVA: Presentar información clara, estructurada y con ejemplos. Nunca leer diapositivas. Usar el 80% del tiempo en interacción y 20% en exposición. Cada 15 minutos cambiar de actividad.

DEMOSTRACIÓN: Mostrar cómo hacer algo paso a paso. Explicar mientras se demuestra. Luego pedir al participante que lo repita. Corregir errores de forma constructiva.

CASOS DE ESTUDIO: Presentar situaciones reales o simuladas. Los participantes analizan, discuten y proponen soluciones. Ideal para temas de seguridad donde el análisis de incidentes reales es valioso.

DINÁMICAS DE GRUPO: Juegos de roles, simulacros, debates, lluvia de ideas. Mantener grupos pequeños (4-6 personas). Asignar roles específicos. Debriefing al final para extraer aprendizajes.

REGLA DE ORO: La variedad mantiene la atención. Nunca usar la misma técnica más de 20 minutos seguidos.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true),

  ((SELECT id FROM modules WHERE title = 'Diseño y Evaluación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Diseño de Cursos de Capacitación', 'Estructura, objetivos, contenidos y materiales.', 'mixed',
   'El diseño de un curso de capacitación debe seguir una estructura lógica que garantice el aprendizaje efectivo.

FASES DEL DISEÑO: 1) Análisis de necesidades (qué saben, qué necesitan saber), 2) Definición de objetivos (qué serán capaces de hacer al terminar), 3) Estructura de contenidos (módulos, sesiones, duración), 4) Selección de métodos didácticos, 5) Diseño de materiales, 6) Diseño de evaluación.

OBJETIVOS DE APRENDIZAJE: Deben ser específicos, medibles y observables. Usar verbos de acción: "identificar", "demostrar", "aplicar", "evaluar". Evitar verbos vagos como "comprender" o "conocer".

MATERIALES DIDÁCTICOS: Presentaciones visuales (mínimo texto, máximo imágenes), guías del participante, manuales de procedimiento, videos demostrativos, formularios de práctica, equipos para simulación.

EVALUACIÓN: Debe medir si se lograron los objetivos. Puede ser: escrita (examen), práctica (demostración de habilidad), o de actitud (cuestionario de percepción). La evaluación práctica es la más efectiva para capacitación de seguridad.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Diseño y Evaluación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Evaluación del Aprendizaje', 'Métodos de evaluación, reacción, aprendizaje y transferencia.', 'mixed',
   'La evaluación de la capacitación debe medir cuatro niveles según el modelo Kirkpatrick: Reacción, Aprendizaje, Comportamiento y Resultados.

NIVEL 1 - REACCIÓN: ¿Qué pensaron los participantes? Se mide con encuestas de satisfacción al final del curso. Evalúa el instructor, los materiales, las instalaciones y la relevancia del contenido.

NIVEL 2 - APRENDIZAJE: ¿Qué aprendieron? Se mide con exámenes teóricos, demostraciones prácticas y observación directa. Debe hacerse inmediatamente después del curso y, idealmente, semanas después para medir retención.

NIVEL 3 - COMPORTAMIENTO: ¿Aplican lo aprendido en su trabajo? Se mide observando el desempeño en el puesto semanas o meses después de la capacitación. Requiere coordinación con supervisores.

NIVEL 4 - RESULTADOS: ¿Impactó en la organización? Se mide con indicadores: reducción de accidentes, disminución de incidentes, mejora en auditorías de seguridad, aumento en reportes de condiciones inseguras.

El instructor debe usar estos resultados para mejorar continuamente el curso.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true),

  ((SELECT id FROM modules WHERE title = 'Gestión de la Capacitación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Registros y Documentación de Capacitación', 'Listas de asistencia, constancias y evidencias documentales.', 'mixed',
   'La documentación de capacitación es un requisito legal y una herramienta de gestión. La STPS puede solicitar evidencia de capacitación en cualquier momento.

DOCUMENTOS OBLIGATORIOS: Lista de asistencia firmada por cada participante, constancia de habilidades con datos del curso e instructor, registro en la DC-3, material didáctico utilizado, evidencias de evaluación.

LA CONSTANCIA DC-3 debe incluir: datos del trabajador, datos del centro de trabajo, nombre del curso, duración, fecha, nombre y firma del instructor, objetivos del curso. Debe registrarse ante la STPS.

REGISTROS INTERNOS: Bitácora de capacitación, programa anual de capacitación, evaluaciones de cada participante, reportes de evaluación del curso, plan de mejora continua.

CONSERVACIÓN: Los registros deben conservarse por al menos 2 años. Se recomienda llevarlos también en formato digital para facilitar la consulta y el seguimiento.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 1, true),

  ((SELECT id FROM modules WHERE title = 'Gestión de la Capacitación' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Instructores')),
   'Mejora Continua del Programa', 'Retroalimentación, actualización y evaluación del instructor.', 'mixed',
   'La mejora continua es lo que diferencia a un instructor promedio de un excelente instructor. Cada curso debe ser mejor que el anterior.

FUENTES DE RETROALIMENTACIÓN: Evaluaciones de los participantes (encuestas de reacción), observación de pares (otro instructor observa la sesión), autoevaluación (grabar la sesión y analizarla), resultados de evaluación (¿aprendieron lo esperado?), retroalimentación de supervisores (¿cambiaron el comportamiento?).

ACTUALIZACIÓN DE CONTENIDO: Las normativas cambian, los equipos evolucionan, nuevos casos de estudio surgen. El instructor debe mantenerse actualizado con: nuevas normas, incidentes recientes en la industria, nuevas tecnologías y mejores prácticas.

INDICADORES DE CALIDAD DEL INSTRUCTOR: Satisfacción de participantes (>85%), Tasa de aprobación de exámenes (>90%), Aplicación en el trabajo (encuesta a supervisores), Reducción de incidentes en áreas capacitadas.

CICLO PDCA: Planificar (diseñar el curso), Hacer (impartirlo), Verificar (evaluar resultados), Actuar (implementar mejoras). Repetir en cada ciclo de capacitación.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 7: Formación de Supervisores de Seguridad y Salud Ocupacional
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Formación de Supervisores de Seguridad y Salud Ocupacional',
  'Curso para supervisores de seguridad. Aprende liderazgo en seguridad, gestión de programas SST, investigación de accidentes y cumplimiento normativo conforme a la NOM-030-STPS-2009.',
  'Lidera la seguridad: gestiona programas SST, investiga accidentes y asegura el cumplimiento.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 10, 'advanced'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional'), 'Liderazgo en Seguridad', 'Rol del supervisor, cultura de seguridad y comunicación.', 1),
  ((SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional'), 'Gestión del Programa SST', 'Planeación, implementación y control del programa de seguridad.', 2),
  ((SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional'), 'Investigación de Accidentes', 'Metodología de investigación, análisis de causas y acciones correctivas.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, content, video_url, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Liderazgo en Seguridad' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'El Rol del Supervisor de Seguridad', 'Responsabilidades, funciones y perfil del supervisor SST.', 'mixed',
   'El supervisor de seguridad es la figura clave entre la dirección y los trabajadores en materia de seguridad y salud ocupacional. Su rol va más allá de vigilar el uso de EPP.

RESPONSABILIDADES PRINCIPALES: Implementar el programa de seguridad, vigilar el cumplimiento de normas, identificar y controlar riesgos, capacitar al personal, investigar accidentes, mantener registros, comunicar a la dirección sobre el estado de la seguridad.

PERFIL DEL SUPERVISOR: Conocimiento técnico en seguridad, liderazgo, capacidad de comunicación, observación, decisión, integridad, empatía con los trabajadores, y constancia.

La NOM-030-STPS-2009 establece los requisitos para los servicios de seguridad y salud en el trabajo. El supervisor debe conocer esta norma y aplicarla en su gestión.

CLAVE DEL ÉXITO: Un buen supervisor no solo vigila, también educa, motiva y lidera con el ejemplo. Si el supervisor no usa el EPP, nadie lo usará.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Liderazgo en Seguridad' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'Cultura de Seguridad en la Organización', 'Construcción de cultura, liderazgo visible y compromiso.', 'mixed',
   'La cultura de seguridad son los valores, creencias y comportamientos compartidos que determinan cómo se hace la seguridad en una organización. Una cultura fuerte previene accidentes.

NIVELES DE CULTURA: Reactiva (la seguridad solo importa después del accidente), Cumplimiento (se cumple porque es obligatorio), Proactiva (se buscan riesgos antes de que causen daño), Resiliente (la seguridad es un valor, no una prioridad).

LIDERAZGO VISIBLE: Los líderes demuestran compromiso con la seguridad. Caminan las áreas, hablan con los trabajadores, escuchan sus preocupaciones, participan en simulacros, detienen trabajo inseguro.

COMUNICACIÓN EFECTIVA: La seguridad se comunica de forma clara, positiva y constante. No solo órdenes, sino también "por qué". Reconocer el buen comportamiento es más efectivo que sancionar el malo.

INDICADORES DE CULTURA FUERTE: Los trabajadores reportan condiciones inseguras sin temor, detienen trabajo inseguro por propia iniciativa, sugieren mejoras, participan en comités de seguridad.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true),

  ((SELECT id FROM modules WHERE title = 'Liderazgo en Seguridad' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'Comunicación de Riesgos', 'Técnicas de comunicación, reuniones de seguridad y toolbox talks.', 'mixed',
   'La comunicación es la herramienta más importante del supervisor de seguridad. Un riesgo no comunicado es un riesgo no controlado.

REUNIONES DE SEGURIDAD (TOOLBOX TALKS): Charlas cortas (10-15 minutos) al inicio del turno. Tema específico, relevante para el trabajo del día. Interactivas, no monólogos. Registrar asistencia y tema.

COMUNICACIÓN DE RIESGOS: Cuando se identifica un riesgo, debe comunicarse de inmediato a: los trabajadores expuestos, el supervisor inmediato, y el área de seguridad. Usar canales formales (reporte) e informales (conversación directa).

TÉCNICAS DE COMUNICACIÓN: Escuchar activamente (no interrumpir), hacer preguntas abiertas, parafrasear para confirmar comprensión, usar ejemplos concretos, evitar tecnicismos innecesarios.

BARRERAS COMUNES: "Siempre se ha hecho así", "Nunca ha pasado nada", "Es trabajo extra". El supervisor debe abordar estas barreras con datos, no con órdenes. Mostrar el costo humano y económico de los accidentes.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 20, 3, true),

  ((SELECT id FROM modules WHERE title = 'Gestión del Programa SST' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'Programa de Seguridad y Salud en el Trabajo', 'Estructura del PSST, requisitos legales y componentes.', 'mixed',
   'El Programa de Seguridad y Salud en el Trabajo (PSST) es el documento rector que establece las acciones preventivas y correctivas de una organización en materia de seguridad.

CONTENIDO DEL PSST: Política de seguridad, organización del programa, identificación de riesgos y peligros, objetivos y metas, acciones preventivas, capacitación, equipos de protección personal, salud ocupacional, simulacros, investigación de accidentes, auditorías.

La NOM-030-STPS-2009 establece que el PSST debe revisarse al menos una vez al año, actualizarse cuando cambien las condiciones de trabajo y documentarse formalmente.

EL SUPERVISOR es responsable de implementar el PSST en su área: asegurar que se ejecuten las acciones preventivas, que el personal esté capacitado, que los EPP se entreguen y usen, y que se mantengan registros.

INDICADORES DEL PSST: Índice de frecuencia (accidentes/millón horas), Índice de gravedad (días perdidos/millón horas), Tasa de incidentes, Cumplimiento del programa (%), Eficacia de capacitación (%).',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true),

  ((SELECT id FROM modules WHERE title = 'Gestión del Programa SST' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'Identificación de Riesgos y Peligros', 'IPERC, matriz de riesgo y jerarquía de controles.', 'mixed',
   'La identificación de riesgos es el proceso fundamental para prevenir accidentes. Se debe identificar, evaluar y controlar cada riesgo en el lugar de trabajo.

IPERC (Identificación de Peligros, Evaluación de Riesgos y Control): Metodología que permite priorizar riesgos y asignar recursos. El proceso es: 1) Identificar peligros, 2) Evaluar el riesgo (probabilidad × severidad), 3) Implementar controles, 4) Monitorear y revisar.

MATRIZ DE RIESGO: Herrarquía de probabilidad (Baja, Media, Alta) vs Severidad (Leve, Moderada, Grave, Catastrófica). El resultado determina prioridad: Crítica, Alta, Media, Baja.

JERARQUÍA DE CONTROLES (de más a menos efectivo): 1) Eliminación (eliminar el riesgo), 2) Sustitución (cambiar por algo menos peligroso), 3) Controles de ingeniería (resguardos, barreras, ventilación), 4) Controles administrativos (procedimientos, capacitación, señalización), 5) EPP (última línea de defensa).

ACTUALIZACIÓN: La identificación de riesgos debe actualizarse cuando: cambia el proceso, se introducen nuevos equipos, ocurre un accidente, o al menos una vez al año.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 2, true),

  ((SELECT id FROM modules WHERE title = 'Investigación de Accidentes' AND course_id = (SELECT id FROM courses WHERE title = 'Formación de Supervisores de Seguridad y Salud Ocupacional')),
   'Metodología de Investigación de Accidentes', 'Pasos de la investigación, árbol de causas y reporte.', 'mixed',
   'La investigación de accidentes tiene como objetivo encontrar las causas raíz para evitar que vuelvan a ocurrir. No es buscar culpables, sino encontrar soluciones.

PASOS DE LA INVESTIGACIÓN: 1) Asegurar el área (atender heridos, controlar el riesgo), 2) Recopilar evidencia (fotos, testigos, registros), 3) Entrevistar testigos (por separado, sin presiones), 4) Analizar causas (árbol de causas), 5) Definir acciones correctivas, 6) Elaborar reporte, 7) Dar seguimiento a las acciones.

ÁRBOL DE CAUSAS: Técnica que parte del accidente y va hacia atrás preguntando "¿por qué?" hasta llegar a las causas raíz. Las causas raíz suelen ser: fallas en el sistema de gestión, falta de capacitación, procedimientos inadecuados, mantenimiento deficiente.

CAUSAS INMEDIATAS: Actos inseguros (no usar EPP, operar sin autorización, saltarse procedimientos) y Condiciones inseguras (equipo dañado, señalización deficiente, iluminación insuficiente).

REPORTE DE INVESTIGACIÓN: Debe incluir descripción del accidente, secuencia de eventos, análisis de causas, acciones correctivas con responsables y fechas. El supervisor firma y da seguimiento.',
   'https://www.youtube.com/embed/dQw4w9WgXcQ', 25, 1, true)
ON CONFLICT DO NOTHING;
