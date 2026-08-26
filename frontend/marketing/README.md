# 📱 Frontend - Marketing

## Descripción

Página de marketing existente de EHS Solutions que mantiene toda la información corporativa, servicios y presencia en línea.

## 📁 Estructura

```
frontend/marketing/
├── index.html              # Página principal (tu archivo actual)
├── logo.png                # Logo EHS Solutions
└── assets/
    ├── images/
    ├── icons/
    └── styles/             # Estilos globales (opcional)
```

## 🎯 Funcionalidades Actuales

- Landing page con hero section
- Información de servicios EHS
- Testimonios y certificaciones
- Formulario de contacto (próximamente conectado)
- Diseño responsive

## 🔗 Integración Futura (FASE 2)

Se agregará:
- Botón "Ir a Plataforma de Cursos"
- Link de login a LMS
- Descripción de cursos disponibles

## 📝 Notas

Esta sección de marketing es **independiente** de la plataforma LMS en `/frontend/lms/`

El flujo será:
1. Usuario llega a marketing (`/index.html`)
2. Hace click en "Cursos" o "Ir a Plataforma"
3. Se redirige a LMS en dominio/puerto diferente o ruta `/cursos`
