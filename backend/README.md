# 🏗️ EHS Solutions Backend - FASE 1

## Descripción

Backend API REST para la plataforma LMS (Learning Management System) de EHS Solutions. Sistema de capacitación en Seguridad, Salud y Medio Ambiente con soporte para cursos, evaluaciones y certificados.

**Estado:** FASE 1 - Autenticación y Base de Datos

## 📋 Requisitos Previos

- Node.js v16 o superior
- PostgreSQL 12 o superior
- npm o yarn

## 🚀 Instalación y Setup

### 1. Instalar dependencias
```bash
cd backend
npm install
```

### 2. Configurar Base de Datos

**Crear base de datos en PostgreSQL:**
```sql
CREATE DATABASE ehs_solutions;
```

**Ejecutar schema:**
```bash
psql -U postgres -d ehs_solutions -f ../database/schema.sql
```

### 3. Configurar Variables de Entorno

Copiar `.env.example` a `.env` y configurar:

```bash
cp .env.example .env
```

**Editar `.env` con tus valores:**
```
PORT=5000
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5432
DB_NAME=ehs_solutions
DB_USER=postgres
DB_PASSWORD=tu_contraseña

JWT_SECRET=tu_jwt_secret_super_seguro_min_32_caracteres
JWT_EXPIRE=7d

FRONTEND_URL=http://localhost:3000
API_URL=http://localhost:5000
```

### 4. Iniciar Servidor

**Desarrollo (con auto-reload):**
```bash
npm run dev
```

**Producción:**
```bash
npm start
```

El servidor estará disponible en `http://localhost:5000`

## 🔌 API Endpoints - FASE 1

### Autenticación

#### Registro de Usuarios
```
POST /api/auth/register
Content-Type: application/json

Body:
{
  "first_name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "password": "SecurePassword123!",
  "role": "student"  // 'student', 'instructor', 'admin'
}

Response (201):
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@example.com",
    "role": "student"
  }
}
```

#### Login
```
POST /api/auth/login
Content-Type: application/json

Body:
{
  "email": "juan@example.com",
  "password": "SecurePassword123!"
}

Response (200):
{
  "success": true,
  "message": "Sesión iniciada exitosamente",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@example.com",
    "role": "student"
  }
}
```

#### Obtener Perfil (Protegido)
```
GET /api/auth/profile
Authorization: Bearer <TOKEN>

Response (200):
{
  "success": true,
  "user": {
    "id": 1,
    "first_name": "Juan",
    "last_name": "Pérez",
    "email": "juan@example.com",
    "role": "student",
    "created_at": "2024-08-26T08:30:00Z"
  }
}
```

#### Health Check
```
GET /api/health

Response (200):
{
  "success": true,
  "message": "Backend EHS Solutions está en línea",
  "timestamp": "2024-08-26T08:30:00Z"
}
```

## 📁 Estructura de Directorios

```
backend/
├── src/
│   ├── config/
│   │   └── database.js          # Configuración conexión PostgreSQL
│   ├── controllers/
│   │   └── authController.js    # Lógica de autenticación
│   ├── middleware/
│   │   └── auth.js              # Middleware de autenticación JWT
│   ├── routes/
│   │   └── authRoutes.js        # Rutas de autenticación
│   ├── utils/
│   └── server.js                # Punto de entrada de la aplicación
├── .env                         # Variables de entorno (NO COMMITEAR)
├── .env.example                 # Plantilla de variables de entorno
├── .gitignore
├── package.json
└── README.md
```

## 🔑 Autenticación JWT

Todos los endpoints protegidos requieren:
```
Authorization: Bearer <TOKEN>
```

El token se obtiene al hacer login o registro y es válido por 7 días.

## 🗄️ Estructura de Base de Datos (FASE 1)

### Tabla: users
- id (PRIMARY KEY)
- first_name, last_name, email, password
- role (student/instructor/admin)
- is_active, created_at, updated_at

**Próximas tablas en FASE 2:**
- courses, modules, lessons
- enrollments, lesson_progress
- quizzes, quiz_questions, quiz_attempts
- certificates

## 📝 Próximos Pasos (FASE 2)

- [ ] Endpoints CRUD para Cursos
- [ ] Endpoints CRUD para Módulos y Lecciones
- [ ] Inscripciones a cursos
- [ ] Seguimiento de progreso
- [ ] Frontend React/Vue.js para LMS

## 🐛 Troubleshooting

### Error: "Cannot connect to database"
- Verificar que PostgreSQL está corriendo
- Revisar DB_HOST, DB_PORT, DB_USER, DB_PASSWORD en `.env`

### Error: "JWT Secret not defined"
- Asegurar que JWT_SECRET está en `.env` (mínimo 32 caracteres)

### Error: "CORS error"
- Verificar que FRONTEND_URL en `.env` coincide con tu frontend

## 📞 Soporte

Para errores o preguntas, revisar los logs en consola.

---

**Versión:** 1.0.0 FASE 1  
**Última actualización:** 2024-08-26  
**Autor:** EHS Solutions Team
