// Pages Function: sirve el React app para cualquier ruta /app/* que no sea un asset estático
// Cloudflare sirve archivos estáticos PRIMERO, así que esto solo se ejecuta para rutas virtuales (dashboard, login, etc.)
export async function onRequest(context) {
  const { request, env } = context;
  
  // Intentar servir como asset estático primero
  try {
    const assetResponse = await env.ASSETS.fetch(request);
    if (assetResponse.status !== 404) {
      return assetResponse;
    }
  } catch (e) {
    // Continuar al fallback
  }
  
  // Fallback: servir el React index.html
  const htmlResponse = await env.ASSETS.fetch(new Request(new URL('/app/index.html', request.url)));
  const html = await htmlResponse.text();
  
  return new Response(html, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
  });
}
