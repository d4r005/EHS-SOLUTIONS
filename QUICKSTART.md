# 🚀 GUÍA DE INICIO RÁPIDO - EHS Solutions LMS FASE 1

## ✅ Lo que hemos hecho

### Estructura del Proyecto
```
EHS-SOLUTIONS/
├── backend/                      # ✅ LISTO
│   ├── src/
│   │   ├── config/database.js
│   │   ├── controllers/authController.js
│   │   ├── middleware/auth.js
│   │   ├── routes/authRoutes.js
│   │   └── server.js
│   ├── package.json
│   ├── .env.example
│   └── README.md
│
├── frontend/                     # 📦 Estructura lista
│   ├── marketing/               # ✅ Tu página actual
│   │   ├── index.html
│   │   ├── logo.png
│   │   └── README.md
│   └── lms/                     # 📝 Documentación para FASE 2
│       └── README.md
│
├── database/                     # ✅ Schema completo
│   └── schema.sql               # 13 tablas diseñadas
│
├── docs/                         # ✅ Documentación
│   └── ARCHITECTURE.md
│
└── README.md                     # ✅ Proyecto general
```

### Archivos Creados: 13

| Archivo | Propósito | Status |
|---------|-----------|--------|
| `backend/package.json` | Dependencias Node | ✅ |
| `backend/src/server.js` | Express app | ✅ |
| `backend/src/config/database.js` | Pool PostgreSQL | ✅ |
| `backend/src/controllers/authController.js` | Lógica autenticación | ✅ |
| `backend/src/middleware/auth.js` | JWT middleware | ✅ |
| `backend/src/routes/authRoutes.js` | Rutas API | ✅ |
| `database/schema.sql` | 13 tablas BD | ✅ |
| `backend/.env.example` | Variables entorno | ✅ |
| `backend/README.md` | Documentación backend | ✅ |
| `frontend/marketing/README.md` | Doc marketing | ✅ |
| `frontend/lms/README.md` | Doc LMS futuro | ✅ |
| `docs/ARCHITECTURE.md` | Arquitectura técnica | ✅ |
| `README.md` | Proyecto general | ✅ |

---

## 🎯 PRÓXIMOS PASOS

### PASO 1️⃣: Instalar y Configurar (30 minutos)

```bash
# 1. Ir a carpeta backend
cd backend

# 2. Instalar dependencias
npm install

# 3. Copiar archivo de entorno
cp .env.example .env

# 4. Editar .env con tus datos:
#    - PostgreSQL credentials
#    - JWT_SECRET (copia algo como: "ehs_super_secret_key_abc123xyz789!@#")
```

### PASO 2️⃣: Crear Base de Datos PostgreSQL (15 minutos)

**Si tienes PostgreSQL instalado:**

```bash
# Terminal/PowerShell
psql -U postgres

# Dentro de psql:
CREATE DATABASE ehs_solutions;
\c ehs_solutions
\i 'C:/Users/dtruj/EHS-SOLUTIONS/database/schema.sql'
\dt  # Ver tablas creadas
\q  # Salir
```

**Si NO tienes PostgreSQL:**
- Descargar: https://www.postgresql.org/download/
- Instalar con los valores por defecto
- Luego correr comandos arriba

### PASO 3️⃣: Probar Backend (5 minutos)

```bash
# Dentro de backend/
npm run dev

# Deberías ver:
# 🚀 Backend EHS Solutions corriendo en puerto 5000
# 📍 Ambiente: development
```

### PASO 4️⃣: Probar Endpoints (10 minutos)

**Opción A: Con Postman**
1. Descargar Postman: https://www.postman.com/downloads/
2. Crear nueva colección "EHS Solutions"
3. Agregar requests:

**POST** `http://localhost:5000/api/auth/register`
```json
{
  "first_name": "Juan",
  "last_name": "Pérez",
  "email": "juan@example.com",
  "password": "Password123!"
}
```

**POST** `http://localhost:5000/api/auth/login`
```json
{
  "email": "juan@example.com",
  "password": "Password123!"
}
```

**GET** `http://localhost:5000/api/auth/profile`
Header: `Authorization: Bearer <TOKEN_DEL_LOGIN>`

**Opción B: Con cURL**
```bash
# Registro
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Juan","last_name":"Pérez","email":"juan@test.com","password":"Pass123!"}'

# Login
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"juan@test.com","password":"Pass123!"}'
```

---

## 🎓 FASE 2: Próximos Pasos (No ahora)

- [ ] Frontend React + Vite
- [ ] Catálogo de cursos
- [ ] Dashboard estudiante
- [ ] Visor de lecciones
- [ ] Sistema de progreso

---

## 📊 Estado Actual

```
FASE 1: FUNDACIÓN ✅ COMPLETADA
├── ✅ Estructura directorios
├── ✅ Backend Express.js
├── ✅ Autenticación JWT
├── ✅ Base de datos PostgreSQL
└── ✅ Documentación

FASE 2: PLATAFORMA BASE ⏳ PRÓXIMA (4-6 semanas)
└── Frontend React LMS

FASE 3: EVALUACIONES ⏳ DESPUÉS
└── Quizzes + Certificados

FASE 4: ADMINISTRACIÓN ⏳ FINAL
└── Reportes + Dashboard Admin
```

---

## ⚠️ Troubleshooting

### Error: "Cannot find module pg"
```bash
npm install
```

### Error: "Connection refused" (PostgreSQL)
- Verificar que PostgreSQL está corriendo
- Windows: Services → PostgreSQL should be running
- Mac: `brew services start postgresql`
- Linux: `sudo service postgresql start`

### Error: "EADDRINUSE: port 5000 already in use"
```bash
# Cambiar puerto en .env
PORT=5001
```

### Error: "JWT_SECRET not found"
- Asegurar que JWT_SECRET está en .env
- Debe tener mínimo 32 caracteres

---

## 📚 Documentación Completa

- **Backend:** [backend/README.md](../backend/README.md)
- **Arquitectura:** [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md)
- **Base de Datos:** [database/schema.sql](../database/schema.sql)
- **Proyecto:** [README.md](../README.md)

---

## 🎯 Checklist Para Comenzar

- [ ] Node.js instalado (verificar: `node -v`)
- [ ] PostgreSQL instalado y corriendo
- [ ] Clonar/descargar este proyecto
- [ ] `npm install` en `/backend`
- [ ] Crear `.env` con configuración
- [ ] Crear base de datos PostgreSQL
- [ ] Ejecutar `schema.sql`
- [ ] `npm run dev` para iniciar backend
- [ ] Probar endpoints con Postman

---

## 🚀 Cuando Hayas Completado Todo

¡Felicidades! 🎉 Tienes:
- ✅ Backend funcional
- ✅ Base de datos con 13 tablas
- ✅ Sistema de autenticación seguro
- ✅ API REST lista para frontend

**Próximo paso:** Esperar por FASE 2 con frontend React

---

**¿Preguntas?** Revisar los README de cada carpeta o contactar al equipo.

**Versión:** 1.0 FASE 1  
**Fecha:** 2024-08-26
