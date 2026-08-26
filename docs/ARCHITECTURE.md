# 🏗️ ARQUITECTURA TÉCNICA - EHS Solutions LMS

## Descripción General

Plataforma LMS híbrida que mantiene sitio de marketing con plataforma de educación en línea. Arquitectura modular, escalable y segura.

---

## 📐 Flujo de Aplicación

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO FINAL                            │
└────────────┬────────────────────────────────────────────────┘
             │
    ┌────────┴────────┐
    ▼                 ▼
┌────────────┐   ┌──────────────┐
│ Marketing  │   │ LMS Platform │
│ (HTML)     │   │ (React)      │
└────────────┘   └──────────────┘
    │                 │
    └────────────┬────┘
                 ▼
        ┌─────────────────────┐
        │  Backend API        │
        │ (Node.js/Express)   │
        └──────────┬──────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │  PostgreSQL         │
        │  Database           │
        └─────────────────────┘
```

---

## 🔌 Backend Architecture

### Stack Tecnológico

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| Runtime | Node.js | 16+ |
| Framework | Express.js | 4.18+ |
| BD | PostgreSQL | 12+ |
| Auth | JWT | - |
| Hashing | bcryptjs | 2.4+ |
| Validación | express-validator | 7.0+ |
| CORS | cors | 2.8+ |

### Flujo de Autenticación (FASE 1)

```
1. Usuario → POST /api/auth/register
   │
   ├─→ Validar email único
   ├─→ Hash contraseña con bcrypt
   ├─→ Insertar en BD (tabla users)
   ├─→ Generar JWT
   └─→ Retornar token + user data

2. Usuario → POST /api/auth/login
   │
   ├─→ Verificar email existe
   ├─→ Comparar contraseña con bcrypt
   ├─→ Generar JWT
   └─→ Retornar token

3. Cliente → GET /api/auth/profile
   │         + Authorization: Bearer <TOKEN>
   │
   ├─→ Middleware verifica JWT
   ├─→ Extrae user.id del token
   ├─→ Query BD por user
   └─→ Retorna perfil usuario
```

---

## 💾 Base de Datos

### Tablas Implementadas (FASE 1)

- **users** - Usuarios con roles (student/instructor/admin)
- **courses** - Metadatos cursos
- **modules** - Módulos dentro de cursos
- **lessons** - Lecciones dentro de módulos
- **enrollments** - Inscripciones de estudiantes
- **lesson_progress** - Progreso por lección
- **quizzes** - Evaluaciones
- **quiz_questions** - Preguntas de evaluaciones
- **quiz_options** - Opciones de respuesta
- **quiz_attempts** - Intentos de estudiantes
- **quiz_answers** - Respuestas del estudiante
- **certificates** - Certificados emitidos

---

## 🔐 Seguridad

### FASE 1 Implementado

✅ **Autenticación JWT**
✅ **Hashing de Contraseñas** (bcryptjs)
✅ **CORS Configurado**
✅ **Variables Sensibles en .env**
⏳ **Rate Limiting** (Próximo)
⏳ **Validación Input** (Próximo)
⏳ **HTTPS/SSL** (Producción)

---

## 📅 Timeline

| Fase | Duración | Estado |
|------|----------|--------|
| 1 | 5-8 sem | ✅ Estructurado |
| 2 | 5-7 sem | ⏳ Siguiente |
| 3 | 5-7 sem | ⏳ Siguiente |
| 4 | 3-4 sem | ⏳ Siguiente |

---

**Versión:** 1.0 FASE 1  
**Fecha:** 2024-08-26
