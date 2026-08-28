#!/usr/bin/env bash
# Build combinado: marketing (raíz) + LMS React (bajo /app)
set -e

echo "== Limpiando dist =="
rm -rf dist
mkdir -p dist

echo "== Copiando sitio de marketing =="
cp index.html dist/
cp logo.png dist/

echo "== Instalando y compilando LMS =="
cd frontend/lms
npm install
npm run build
cd ../..

echo "== Copiando build de LMS a dist/app =="
mkdir -p dist/app
cp -r frontend/lms/dist/* dist/app/

echo "== Creando 200.html para SPA fallback =="
cp dist/app/index.html dist/app/200.html

echo "== Copiando reglas de rutas (_redirects) =="
cp _redirects dist/

echo "== Build combinado listo en /dist =="
