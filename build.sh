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

echo "== Copiando 200.html, _routes.json y _redirects =="
cp dist/app/index.html dist/app/200.html
cp _routes.json dist/
cp _redirects dist/

echo "== Generando functions/app/[[catchall]].js con el HTML actual (evita hashes desincronizados) =="
mkdir -p functions/app
HTML_CONTENT=$(cat dist/app/index.html)
cat > 'functions/app/[[catchall]].js' << FUNCEOF
// GENERADO AUTOMÁTICAMENTE por build.sh — no editar a mano.
// Sirve el React app para rutas virtuales bajo /app/*.
// Los assets estáticos (JS, CSS) los sirve Cloudflare directamente (ver _routes.json).
const REACT_HTML = \`${HTML_CONTENT}\`;

export async function onRequest() {
  return new Response(REACT_HTML, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-cache',
    },
  });
}
FUNCEOF

echo "== Build combinado listo en /dist =="
