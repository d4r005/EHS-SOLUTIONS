#!/usr/bin/env bash
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

echo "== Copiando 200.html para SPA fallback =="
# Cloudflare Pages sirve 200.html automaticamente cuando no encuentra
# un archivo estatico para la ruta solicitada (SPA fallback)
cp dist/app/index.html dist/app/200.html

echo "== Copiando _routes.json (solo /api/* va a Functions) =="
cp _routes.json dist/

echo "== Build combinado listo en /dist =="
