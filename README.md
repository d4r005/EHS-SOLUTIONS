# 🎓 EHS Solutions - Plataforma LMS Híbrida

**Estado:** FASE 1 - Fundación (Backend + Autenticación)

## 📊 Visión General

Plataforma LMS para capacitación en Seguridad, Salud y Medio Ambiente que mantiene la presencia de marketing actual mientras agrega funcionalidades de plataforma de educación en línea.

### ✨ Características Principales

- 👥 Sistema de autenticación con roles (estudiante, instructor, admin)
- 📚 Catálogo de cursos con módulos y lecciones
- 📊 Seguimiento de progreso de estudiantes
- 🧪 Sistema de evaluaciones y quizzes
- 🏆 Generación automática de certificados
- 📱 Diseño responsivo y moderno
- 🔐 Seguridad con JWT + bcrypt

## 🏗️ Estructura del Proyecto

```
EHS-SOLUTIONS/
│
├── frontend/                    # Frontend híbrido
│   ├── marketing/              # Página de marketing (index.html actual)
│   │   ├── index.html          # Landing page principal
│   │   ├── styles.css
│   │   └── assets/
│   │
│   └── lms/                    # Plataforma LMS (FASE 2)
│       ├── public/
│       ├── src/
│       │   ├── components/
│       │   ├── pages/
│       │   ├── services/
│       │   └── App.jsx
│       ├── package.json
│       └── README.md
│
├── backend/                     # Backend API
│   ├── src/
│   │   ├── config/             # Configuración
│   │   ├── controllers/        # Lógica de negocio
│   │   ├── middleware/         # Middlewares (auth, etc)
│   │   ├── routes/             # Definición de rutas
│   │   ├── utils/              # Utilidades
│   │   └── server.js           # Punto de entrada
│   ├── package.json
│   ├── .env.example
│   ├── .gitignore
│   └── README.md
│
├── database/                    # Scripts SQL
│   └── schema.sql              # Schema base de datos
│
├── docs/                        # Documentación
│   └── ARCHITECTURE.md         # Arquitectura técnica
│
└── README.md                    # Este archivo
```

## 🚀 Quick Start

### 1. Backend - FASE 1 (En Desarrollo)

```bash
cd backend
npm install
npm run dev
```

Ver [backend/README.md](./backend/README.md) para instrucciones completas.

### 2. Frontend - Marketing (Existente)

Tu página actual en `index.html` se mantiene funcional.

### 3. Frontend - LMS (FASE 2)

Por implementar en próximas semanas.

## 📋 FASES DE DESARROLLO

| Fase | Duración | Status | Entregables |
|------|----------|--------|------------|
| **FASE 1** | 5-8 sem | 🔄 En progreso | Backend + Auth + DB |
| **FASE 2** | 5-7 sem | ⏳ Planeada | Frontend LMS + Catálogo |
| **FASE 3** | 5-7 sem | ⏳ Planeada | Evaluaciones + Certs |
| **FASE 4** | 3-4 sem | ⏳ Planeada | Admin + Reportes |

### FASE 1: Fundación ✅ En Desarrollo
- [x] Estructura de directorios
- [x] Configuración de base de datos (PostgreSQL)
- [x] Sistema de autenticación (JWT)
- [x] Middleware de autorización
- [x] Endpoints básicos (Register, Login, Profile)
- [ ] Pruebas unitarias
- [ ] Documentación API completa

### FASE 2: Plataforma Base ⏳ Próxima
- [ ] Frontend React/Vue.js
- [ ] Catálogo de cursos
- [ ] Dashboard de estudiante
- [ ] Visor de lecciones
- [ ] Sistema de progreso

### FASE 3: Evaluaciones
- [ ] Sistema de quizzes
- [ ] Generación de certificados PDF
- [ ] Panel de instructor
- [ ] Evaluación de tareas

### FASE 4: Administración
- [ ] Dashboard administrativo
- [ ] Reportes y analytics
- [ ] Gestión de usuarios
- [ ] Sistema de comunicación

## 🔧 Requisitos del Sistema

- **Node.js:** v16+
- **PostgreSQL:** v12+
- **npm/yarn:** Último LTS
- **Navegador:** Chrome, Firefox, Safari (últimas versiones)

## 🗂️ Configuración Inicial

### Backend
```bash
cd backend
cp .env.example .env
# Editar .env con tus credenciales
npm install
npm run dev
```

### Base de Datos
```bash
createdb ehs_solutions
psql -U postgres -d ehs_solutions -f database/schema.sql
```

## 📚 Documentación

- [Backend Setup](./backend/README.md) - Guía de instalación y endpoints
- [Database Schema](./database/schema.sql) - Estructura de BD completa
- [Architecture (Próximo)](./docs/ARCHITECTURE.md)

## 🤝 Convenciones de Código

- **JavaScript:** ES6+ modules
- **Naming:** camelCase para variables/funciones
- **Commits:** "feat:", "fix:", "docs:" prefixes
- **Branches:** feature/nombre, bugfix/nombre

## 🔐 Seguridad

- ✅ Contraseñas hasheadas con bcrypt
- ✅ Autenticación JWT de 7 días
- ✅ CORS configurado
- ✅ Variables sensibles en .env (nunca commitear)
- ⏳ Rate limiting (FASE 2)
- ⏳ Validación de entrada (en desarrollo)

## 📞 Support

Problemas o preguntas? Revisar los logs o contactar al equipo.

---

**Última actualización:** 2024-08-26  
**Versión:** 1.0.0 FASE 1  
**Maintainer:** EHS Solutions Dev Team
