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
  question_type VARCHAR(50) CHECK (question_type IN ('multiple_choice', 'true_false', 'short_answer', 'essay')),
  correct_answer TEXT,
  order_index INTEGER,
  points INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS quiz_options (
  id SERIAL PRIMARY KEY,
  question_id INTEGER NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  option_text TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  order_index INTEGER
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  quiz_id INTEGER NOT NULL REFERENCES quizzes(id) ON DELETE CASCADE,
  score DECIMAL(5, 2),
  passed BOOLEAN,
  attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  completed_at TIMESTAMP,
  time_spent_minutes INTEGER
);

CREATE TABLE IF NOT EXISTS quiz_answers (
  id SERIAL PRIMARY KEY,
  attempt_id INTEGER NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_id INTEGER NOT NULL REFERENCES quiz_questions(id) ON DELETE CASCADE,
  student_answer TEXT,
  is_correct BOOLEAN
);

CREATE TABLE IF NOT EXISTS certificates (
  id SERIAL PRIMARY KEY,
  student_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  course_id INTEGER NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  certificate_number VARCHAR(100) UNIQUE,
  issued_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expiry_date TIMESTAMP,
  certificate_url VARCHAR(500),
  is_valid BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_courses_instructor_id ON courses(instructor_id);
CREATE INDEX IF NOT EXISTS idx_modules_course_id ON modules(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_module_id ON lessons(module_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_student_id ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course_id ON enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_lesson_progress_student_id ON lesson_progress(student_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_student_id ON quiz_attempts(student_id);
CREATE INDEX IF NOT EXISTS idx_certificates_student_id ON certificates(student_id);

-- ============================================
-- 2. SEED DATA
-- ============================================

-- Usuario Instructor (password: Password123!)
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
-- CURSO 1: Seguridad Industrial Básica
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Seguridad Industrial Básica',
  'Curso fundamental sobre principios de seguridad industrial en el entorno laboral. Aprende a identificar riesgos, usar equipos de protección personal y aplicar protocolos de seguridad en el workplace.',
  'Aprende los fundamentos de la seguridad industrial y protege tu integridad en el trabajo.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Seguridad Industrial',
  true, 0, 8, 'beginner'
) ON CONFLICT DO NOTHING;

-- Módulos del Curso 1
INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica'), 'Introducción a la Seguridad Industrial', 'Conceptos básicos y marco legal de la seguridad industrial.', 1),
  ((SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica'), 'Equipos de Protección Personal (EPP)', 'Tipos, selección y uso correcto del EPP.', 2),
  ((SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica'), 'Identificación de Riesgos', 'Metodologías para identificar y evaluar riesgos laborales.', 3)
ON CONFLICT DO NOTHING;

-- Lecciones del Módulo 1
INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Introducción a la Seguridad Industrial' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   '¿Qué es la Seguridad Industrial?', 'Definición e importancia de la seguridad industrial.', 'text', 15, 1, true),
  ((SELECT id FROM modules WHERE title = 'Introducción a la Seguridad Industrial' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Marco Legal y Normativas', 'Ley Federal del Trabajo, NOMs aplicables y responsibilities del empleador.', 'text', 20, 2, true),
  ((SELECT id FROM modules WHERE title = 'Introducción a la Seguridad Industrial' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Cultura de Seguridad', 'Cómo construir una cultura de seguridad en la organización.', 'text', 15, 3, true)
ON CONFLICT DO NOTHING;

-- Lecciones del Módulo 2
INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Equipos de Protección Personal (EPP)' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Tipos de EPP', 'Clasificación de equipos: cabeza, ojos, oídos, respiratorio, manos, pies.', 'text', 20, 1, true),
  ((SELECT id FROM modules WHERE title = 'Equipos de Protección Personal (EPP)' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Selección y Uso Correcto', 'Criterios de selección y uso adecuado del EPP según el riesgo.', 'text', 25, 2, true),
  ((SELECT id FROM modules WHERE title = 'Equipos de Protección Personal (EPP)' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Mantenimiento del EPP', 'Limpieza, almacenamiento y cuándo reemplazar el equipo.', 'text', 15, 3, true)
ON CONFLICT DO NOTHING;

-- Lecciones del Módulo 3
INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Identificación de Riesgos' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Metodología de Identificación', 'Técnicas para identificar peligros en el workplace.', 'text', 20, 1, true),
  ((SELECT id FROM modules WHERE title = 'Identificación de Riesgos' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Evaluación de Riesgos', 'Matriz de riesgo y priorización de controles.', 'text', 25, 2, true),
  ((SELECT id FROM modules WHERE title = 'Identificación de Riesgos' AND course_id = (SELECT id FROM courses WHERE title = 'Seguridad Industrial Básica')), 
   'Controles y Medidas Preventivas', 'Jerarquía de controles: eliminación, sustitución, ingeniería, administrativos, EPP.', 'text', 20, 3, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 2: Salud Ocupacional y Ergonomía
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Salud Ocupacional y Ergonomía',
  'Curso enfocado en la prevención de lesiones musculoesqueléticas y enfermedades ocupacionales. Aprende principios ergonómicos, evaluación de puestos de trabajo y programas de vigilancia de la salud.',
  'Protege tu salud laboral con principios ergonómicos y preventivos.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Salud Ocupacional',
  true, 0, 10, 'intermediate'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía'), 'Fundamentos de Ergonomía', 'Principios básicos y aplicación en el workplace.', 1),
  ((SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía'), 'Evaluación de Puestos de Trabajo', 'Métodos de evaluación ergonómica.', 2),
  ((SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía'), 'Vigilancia de la Salud', 'Programas de vigilancia médica y epidemiológica.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Fundamentos de Ergonomía' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   '¿Qué es la Ergonomía?', 'Definición, objetivos y áreas de aplicación.', 'text', 15, 1, true),
  ((SELECT id FROM modules WHERE title = 'Fundamentos de Ergonomía' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Posturas y Movimientos', 'Biomecánica corporal y posturas correctas.', 'text', 20, 2, true),
  ((SELECT id FROM modules WHERE title = 'Fundamentos de Ergonomía' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Levantamiento de Cargas', 'Técnicas correctas y límites de peso.', 'text', 20, 3, true),
  ((SELECT id FROM modules WHERE title = 'Evaluación de Puestos de Trabajo' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Método RULA', 'Evaluación rápida de miembros superiores.', 'text', 25, 1, true),
  ((SELECT id FROM modules WHERE title = 'Evaluación de Puestos de Trabajo' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Método NIOSH', 'Ecuación para levantamiento de cargas.', 'text', 30, 2, true),
  ((SELECT id FROM modules WHERE title = 'Vigilancia de la Salud' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Exámenes Médicos', 'Tipos y periodicidad de exámenes ocupacionales.', 'text', 20, 1, true),
  ((SELECT id FROM modules WHERE title = 'Vigilancia de la Salud' AND course_id = (SELECT id FROM courses WHERE title = 'Salud Ocupacional y Ergonomía')), 
   'Enfermedades Profesionales', 'Reconocimiento y prevención.', 'text', 25, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 3: Gestión Ambiental
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Gestión Ambiental para Empresas',
  'Curso integral sobre gestión ambiental empresarial. Aprende sobre normativas ambientales, manejo de residuos, huella de carbono e implementación de sistemas de gestión ambiental ISO 14001.',
  'Implementa prácticas ambientales sostenibles en tu organización.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Medio Ambiente',
  true, 0, 6, 'intermediate'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas'), 'Marco Normativo Ambiental', 'Leyes y regulaciones ambientales aplicables.', 1),
  ((SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas'), 'Manejo de Residuos', 'Clasificación, almacenamiento y disposición de residuos.', 2),
  ((SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas'), 'ISO 14001', 'Sistemas de gestión ambiental y certificación.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Marco Normativo Ambiental' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Ley General del Equilibrio Ecológico', 'LGEEPA y su aplicación.', 'text', 20, 1, true),
  ((SELECT id FROM modules WHERE title = 'Marco Normativo Ambiental' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'NOMs Ambientales', 'Normas Oficiales Mexicanas ambientales aplicables.', 'text', 20, 2, true),
  ((SELECT id FROM modules WHERE title = 'Manejo de Residuos' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Clasificación de Residuos', 'Residuos peligrosos, de manejo especial y sólidos urbanos.', 'text', 25, 1, true),
  ((SELECT id FROM modules WHERE title = 'Manejo de Residuos' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Minimización y Reciclaje', 'Estrategias para reducir residuos.', 'text', 20, 2, true),
  ((SELECT id FROM modules WHERE title = 'Manejo de Residuos' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Bitácora de Residuos', 'Documentación y seguimiento.', 'text', 15, 3, true),
  ((SELECT id FROM modules WHERE title = 'ISO 14001' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Introducción a ISO 14001', 'Estructura y requisitos del estándar.', 'text', 25, 1, true),
  ((SELECT id FROM modules WHERE title = 'ISO 14001' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Implementación', 'Pasos para implementar un SGA.', 'text', 30, 2, true),
  ((SELECT id FROM modules WHERE title = 'ISO 14001' AND course_id = (SELECT id FROM courses WHERE title = 'Gestión Ambiental para Empresas')), 
   'Auditorías Ambientales', 'Tipos y metodología de auditorías.', 'text', 25, 3, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- CURSO 4: Primeros Auxilios
-- ============================================
INSERT INTO courses (title, description, short_description, instructor_id, category, is_published, price, duration_hours, difficulty_level)
VALUES (
  'Primeros Auxilios en el Trabajo',
  'Curso práctico sobre primeros auxilios para responder emergencias laborales. RCP, control de hemorragias, atención a quemaduras y manejo de emergencias.',
  'Aprende a responder ante emergencias médicas en el trabajo.',
  (SELECT id FROM users WHERE email = 'instructor@ehs-solutions.com'),
  'Primeros Auxilios',
  true, 0, 4, 'beginner'
) ON CONFLICT DO NOTHING;

INSERT INTO modules (course_id, title, description, order_index)
VALUES
  ((SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo'), 'Conceptos Básicos', 'Principios de primeros auxilios y botiquín.', 1),
  ((SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo'), 'RCP y Emergencias Cardiacas', 'Técnica de reanimación cardiopulmonar.', 2),
  ((SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo'), 'Heridas y Quemaduras', 'Manejo inicial de lesiones.', 3)
ON CONFLICT DO NOTHING;

INSERT INTO lessons (module_id, title, description, content_type, duration_minutes, order_index, is_required)
VALUES
  ((SELECT id FROM modules WHERE title = 'Conceptos Básicos' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'Principios de Primeros Auxilios', 'Reglas básicas y cadena de supervivencia.', 'text', 15, 1, true),
  ((SELECT id FROM modules WHERE title = 'Conceptos Básicos' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'El Botiquín de Primeros Auxilios', 'Contenido y ubicación del botiquín.', 'text', 10, 2, true),
  ((SELECT id FROM modules WHERE title = 'RCP y Emergencias Cardiacas' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'Técnica de RCP', 'Pasos de la reanimación cardiopulmonar.', 'text', 20, 1, true),
  ((SELECT id FROM modules WHERE title = 'RCP y Emergencias Cardiacas' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'Uso del DEA', 'Desfibrilador externo automático.', 'text', 15, 2, true),
  ((SELECT id FROM modules WHERE title = 'Heridas y Quemaduras' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'Control de Hemorragias', 'Técnicas de presión directa y torniquete.', 'text', 15, 1, true),
  ((SELECT id FROM modules WHERE title = 'Heridas y Quemaduras' AND course_id = (SELECT id FROM courses WHERE title = 'Primeros Auxilios en el Trabajo')), 
   'Quemaduras', 'Clasificación y tratamiento inicial.', 'text', 15, 2, true)
ON CONFLICT DO NOTHING;

-- ============================================
-- FIN DEL SCRIPT
-- ============================================
-- Usuarios creados:
--   instructor@ehs-solutions.com / Password123! (rol: instructor)
--   admin@ehs-solutions.com / Password123! (rol: admin)
--   estudiante@ehs-solutions.com / Password123! (rol: student)
--
-- Cursos creados:
--   1. Seguridad Industrial Básica (beginner, 8h, gratis)
--   2. Salud Ocupacional y Ergonomía (intermediate, 10h, gratis)
--   3. Gestión Ambiental para Empresas (intermediate, 6h, gratis)
--   4. Primeros Auxilios en el Trabajo (beginner, 4h, gratis)
-- ============================================
