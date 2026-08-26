#!/bin/bash
# EHS Solutions - Script de inicio rápido
# Instala dependencias y levanta backend + frontend

echo "🚀 EHS Solutions - Inicio rápido"
echo "================================"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar .env del backend
if [ ! -f backend/.env ]; then
  echo "${YELLOW}⚠️  No encuentro backend/.env${NC}"
  echo "Copia backend/.env.example a backend/.env y configura tus credenciales de Supabase"
  exit 1
fi

# Instalar dependencias backend
echo "${GREEN}📦 Instalando dependencias del backend...${NC}"
cd backend
npm install
if [ $? -ne 0 ]; then
  echo "❌ Error instalando dependencias del backend"
  exit 1
fi
echo "${GREEN}✅ Backend listo${NC}"
cd ..

# Instalar dependencias frontend
echo "${GREEN}📦 Instalando dependencias del frontend...${NC}"
cd frontend/lms
npm install
if [ $? -ne 0 ]; then
  echo "❌ Error instalando dependencias del frontend"
  exit 1
fi
echo "${GREEN}✅ Frontend listo${NC}"
cd ../..

echo ""
echo "${GREEN}🎉 Todo instalado correctamente!${NC}"
echo ""
echo "Para levantar el proyecto abre dos terminales:"
echo ""
echo "  Terminal 1 (Backend):  cd backend && npm run dev"
echo "  Terminal 2 (Frontend): cd frontend/lms && npm run dev"
echo ""
echo "Backend:  http://localhost:5000/api"
echo "Frontend: http://localhost:5173"
echo ""
echo "Usuarios de prueba:"
echo "  instructor@ehs-solutions.com / Password123!"
echo "  admin@ehs-solutions.com      / Password123!"
echo "  estudiante@ehs-solutions.com / Password123!"
