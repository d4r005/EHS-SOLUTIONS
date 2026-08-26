# EHS Solutions - Guía de Deploy

## Arquitectura (simplificada)
- **Frontend**: React + Vite → Cloudflare Pages (static)
- **Backend**: Supabase REST API (PostgREST) + Supabase Auth — directo desde el navegador
- **Base de Datos**: Supabase PostgreSQL
- **Sin servidor backend**: No necesitas Express, ni Edge Functions, ni Render

---

## Único paso: Conectar repo a Cloudflare Pages

1. Ve a [Cloudflare Pages](https://pages.cloudflare.com)
2. **Create a project** → **Connect to Git**
3. Selecciona el repo `d4r005/EHS-SOLUTIONS`
4. Configuración:
   - **Framework preset**: Vite
   - **Build command**: `cd frontend/lms && npm install && npm run build`
   - **Build output directory**: `frontend/lms/dist`
   - **Environment variables** (Settings → Environment variables):
     - `VITE_SUPABASE_URL` = `https://tsqlpjliqslgzookdqvg.supabase.co`
     - `VITE_SUPABASE_KEY` = tu anon key de Supabase (Dashboard → Settings → API → Project API keys → anon public)
5. Click **Deploy**

¡Listo! Tu sitio estará en `https://ehs-solutions.pages.dev` (o similar).

---

## Usuarios de Prueba

| Email | Contraseña | Rol |
|-------|------------|-----|
| instructor@ehs-solutions.com | Password123! | instructor |
| admin@ehs-solutions.com | Password123! | admin |
| estudiante@ehs-solutions.com | Password123! | student |

---

## Estructura

```
EHS-SOLUTIONS/
├── frontend/lms/          ← Frontend (deploy a Cloudflare Pages)
│   ├── src/
│   │   ├── context/AuthContext.jsx    ← Supabase Auth
│   │   ├── services/courseService.js  ← Supabase REST API
│   │   └── pages/
│   ├── .env.example
│   └── package.json
├── database/schema_with_seed.sql
└── DEPLOY.md
```
