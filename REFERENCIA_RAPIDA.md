# 🎯 REFERENCIA RÁPIDA - EHS Solutions LMS

## 📁 Archivos Importantes

| Archivo | Propósito | Acción |
|---------|-----------|--------|
| `QUICKSTART.md` | Guía paso a paso | ⭐ **LEER PRIMERO** |
| `backend/README.md` | API documentation | Referencia endpoints |
| `docs/ARCHITECTURE.md` | Diseño técnico | Entender estructura |
| `database/schema.sql` | BD schema | Ver tablas |
| `backend/.env.example` | Config template | Copiar a .env |

## 🚀 Comandos Esenciales

```bash
# 1. Instalar dependencias
cd backend && npm install

# 2. Configurar
cp .env.example .env
# Editar .env con PostgreSQL credentials

# 3. Base de datos
createdb ehs_solutions
psql -d ehs_solutions -f ../database/schema.sql

# 4. Ejecutar
npm run dev

# 5. Probar
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"first_name":"Test","last_name":"User","email":"test@test.com","password":"Pass123!"}'
```

## 🔑 Credenciales de Ejemplo

**Registro:**
```json
{
  "first_name": "Juan",
  "last_name": "Pérez",
  "email": "juan@test.com",
  "password": "SecurePass123!",
  "role": "student"
}
```

**Login:**
```json
{
  "email": "juan@test.com",
  "password": "SecurePass123!"
}
```

## 📊 Estado de Tareas

- [x] Estructura backend
- [x] Autenticación JWT
- [x] Base de datos (13 tablas)
- [x] 5 endpoints API
- [x] Documentación
- [ ] **SIGUIENTE:** Testing endpoints
- [ ] **DESPUÉS:** Frontend FASE 2

## 💡 Información Clave

**Backend URL:** `http://localhost:5000`  
**Frontend (futura):** `http://localhost:3000`  
**Database:** PostgreSQL on `localhost:5432`  
**JWT Duration:** 7 días

---

**Más información:** Ver `QUICKSTART.md` para instrucciones completas.
