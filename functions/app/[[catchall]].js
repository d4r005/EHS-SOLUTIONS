// GENERADO AUTOMÁTICAMENTE por build.sh — no editar a mano.
// Sirve el React app para rutas virtuales bajo /app/*.
// Los assets estáticos (JS, CSS) los sirve Cloudflare directamente (ver _routes.json).
const REACT_HTML = `<!doctype html>
<html lang="es">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="/vite.svg" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="description" content="EHS Solutions - Plataforma de Capacitación en Seguridad, Salud y Medio Ambiente" />
    <title>EHS Solutions | Plataforma LMS</title>
    <script type="module" crossorigin src="/app/assets/app-LGNsei3p.js"></script>
    <link rel="stylesheet" crossorigin href="/app/assets/asset-B0LHfdhK.css">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>`;

export async function onRequest() {
  return new Response(REACT_HTML, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-cache',
    },
  });
}
