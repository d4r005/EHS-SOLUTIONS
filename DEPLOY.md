# EHS Solutions - Guía de Deploy

## Stack
- **Frontend**: React + Vite → Cloudflare Pages
- **Backend**: Supabase Edge Functions (Deno)
- **Base de Datos**: Supabase PostgreSQL

---

## 1. Deploy del Backend (Supabase Edge Function)

### Requisitos
- Supabase CLI instalado: `npm i -g supabase`
- Tu proyecto de Supabase: `tsqlpjliqslgzookdqvg`

### Pasos

```bash
# 1. Login en Supabase
supabase login

# 2. Vincular el proyecto
supabase link --project-ref tsqlpjliqslgzookdqvg

# 3. (Opcional) Setear JWT_SECRET custom
# Si no lo seteas, usa el SUPABASE_SERVICE_ROLE_KEY por defecto
supabase secrets set JWT_SECRET=tu_secreto_super_largo_y_seguro

# 4. Desplegar la Edge Function
supabase functions deploy api --no-verify-jwt
```

La API quedará disponible en:
```
https://tsqlpjliqslgzookdqvg.supabase.co/functions/v1/api
```

### Verificar
```bash
curl https://tsqlpjliqslgzookdqvg.supabase.co/functions/v1/api/health
# Debe responder: {"success":true,"message":"EHS Solutions API en línea",...}
```

---

## 2. Deploy del Frontend (Cloudflare Pages)

### Opción A: Deploy desde GitHub (recomendado)

1. Ve a [Cloudflare Pages](https://pages.cloudflare.com)
2. Create a project → Connect to Git
3. Selecciona el repo `d4r005/EHS-SOLUTIONS`
4. Configuración:
   - **Framework preset**: Vite
   - **Build command**: `cd frontend/lms && npm install && npm run build`
   - **Build output directory**: `frontend/lms/dist`
   - **Environment variables**:
     - `VITE_API_URL` = `https://tsqlpjliqslgzookdqvg.supabase.co/functions/v1/api`
5. Deploy

### Opción B: Deploy con Wrangler CLI

```bash
# Instalar wrangler
npm i -g wrangler

# Login
wrangler login

# Build
cd frontend/lms
npm install
npm run build

# Deploy
wrangler pages deploy dist --project-name ehs-solutions
```

---

## 3. Usuarios de Prueba

| Usuario | Email | Contraseña | Rol |
|---------|-------|------------|-----|
| Instructor | instructor@ehs-solutions.com | Password123! | instructor |
| Admin | admin@ehs-solutions.com | Password123! | admin |
| Estudiante | estudiante@ehs-solutions.com | Password123! | student |

---

## Estructura del Proyecto

```
EHS-SOLUTIONS/
├── supabase/
│   ├── config.toml
│   └── functions/
│       └── api/
│           └── index.ts          ← Edge Function (backend)
├── frontend/
│   └── lms/
│       ├── src/
│       │   ├── context/AuthContext.jsx
│       │   ├── services/courseService.js
│       │   ├── pages/
│       │   └── components/
│       ├── .env.example
│       └── package.json
├── database/
│   └── schema_with_seed.sql
└── DEPLOY.md                     ← Este archivo
```
