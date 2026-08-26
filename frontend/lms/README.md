# 🎓 Frontend - LMS Platform

## Descripción

Frontend moderno en React 18 + Vite para la plataforma LMS de EHS Solutions.

**Estado:** 🚀 FASE 2 - En Desarrollo (Autenticación + Dashboard)

## 🚀 Quick Start

### 1. Instalar Dependencias
```bash
cd frontend/lms
npm install
```

### 2. Iniciar Servidor de Desarrollo
```bash
npm run dev
```

El frontend estará disponible en `http://localhost:3000`

---

## 📁 Estructura

```
frontend/lms/
├── src/
│   ├── components/
│   │   └── Navbar.jsx              # ✅ Barra de navegación
│   ├── pages/
│   │   ├── HomePage.jsx            # ✅ Página principal
│   │   ├── LoginPage.jsx           # ✅ Login
│   │   ├── RegisterPage.jsx        # ✅ Registro
│   │   └── DashboardPage.jsx       # ✅ Dashboard estudiante
│   ├── context/
│   │   ├── AuthContext.jsx         # ✅ Context de autenticación
│   │   └── ProtectedRoute.jsx      # ✅ Rutas protegidas
│   ├── services/
│   │   └── courseService.js        # ✅ API de cursos
│   ├── styles/
│   │   └── index.css               # ✅ Estilos globales
│   ├── App.jsx                     # ✅ App principal
│   └── main.jsx                    # ✅ Entry point
├── public/
├── index.html                      # ✅ HTML template
├── package.json                    # ✅ Dependencias
├── vite.config.js                  # ✅ Configuración Vite
├── tailwind.config.js              # ✅ TailwindCSS
└── postcss.config.js               # ✅ PostCSS
```

## ✅ Características Implementadas

### Autenticación ✅
- [x] Página de login con validación
- [x] Página de registro con validación
- [x] AuthContext para gestionar sesiones
- [x] JWT token en localStorage
- [x] Rutas protegidas con ProtectedRoute
- [x] Auto-logout en token inválido
- [x] Navbar con user info

### Dashboard ✅
- [x] Mostrar cursos inscritos
- [x] Estadísticas (total, completados, en progreso)
- [x] Tarjetas de curso con progreso visual
- [x] Responsive design

### UI/UX ✅
- [x] TailwindCSS integrado
- [x] Diseño responsive
- [x] Colores EHS (navy, green)
- [x] Componentes modernos
- [x] Página de inicio con CTA

## 📡 API Integration

### Axios Service Setup
- Interceptor automático para JWT
- Manejo centralizado de errores
- BaseURL configurado

### Endpoints Utilizados
```
POST   /api/auth/register      (✅)
POST   /api/auth/login         (✅)
GET    /api/auth/profile       (✅)
GET    /api/courses            (📝)
GET    /api/courses/:id        (📝)
POST   /api/enrollments        (📝)
GET    /api/enrollments        (📝)
```

---

## 🔄 Próximos Pasos (FASE 2 Continuación)

### Semana 2 (Próxima):
- [ ] Página de Catálogo de Cursos
- [ ] Detalles del curso
- [ ] Botón de inscripción
- [ ] Búsqueda y filtros
- [ ] Endpoints CRUD en backend

### Semana 3:
- [ ] Visor de lecciones
- [ ] Reproductor de video
- [ ] Visor de PDF
- [ ] Marcar como completado
- [ ] Navegación entre lecciones

### Semana 4:
- [ ] Testing completo
- [ ] Optimización performance
- [ ] PWA setup

---

## 🛠️ Stack Tecnológico

- **React 18** - UI Framework
- **Vite 5** - Bundler rápido
- **React Router 6** - Routing
- **Axios** - HTTP Client
- **TailwindCSS 3** - Utility CSS

---

## 📝 Comandos

```bash
npm run dev      # Desarrollo en puerto 3000
npm run build    # Build producción
npm run preview  # Preview del build
npm run lint     # Linting
```

---

## 🔐 Seguridad

- JWT tokens en localStorage
- Axios interceptor automático
- ProtectedRoute para rutas privadas
- Validación de formularios
- CORS configurado en backend

---

**Versión:** 0.1.0 FASE 2 - En Desarrollo  
**Última actualización:** 2024-08-26  
**Siguiente:** Catálogo de Cursos
