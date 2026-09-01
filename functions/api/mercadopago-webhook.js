// ============================================
// Cloudflare Pages Function
// GET & POST /api/mercadopago-webhook
// Recibe notificaciones de MercadoPago (IPN legacy por GET
// y Webhooks nuevos por POST).
// Cuando el pago se aprueba, crea la inscripción (enrollment)
// y el registro de la orden en Supabase usando la Service Role Key.
//
// Configura esta URL en MercadoPago → Tu aplicación → Notificaciones:
//   https://tu-dominio.com/api/mercadopago-webhook
// Evento: payment
//
// Variable de entorno requerida:
//   MERCADOPAGO_WEBHOOK_SECRET — clave secreta del webhook (panel de MP)
// ============================================

const OK = new Response('ok', { status: 200, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
const FORBIDDEN = new Response('forbidden', { status: 403, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
const ERROR = new Response('error', { status: 500, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });

/**
 * Valida la firma x-signature de MercadoPago.
 * MP envía un header con formato: "ts=<timestamp>,v1=<hash>"
 * El hash es HMAC-SHA256 del string: "<data.id><timestamp><secret>"
 * (usando la parte de query string o el body crudo).
 */
function verifySignature(request, body, env) {
  const secret = env.MERCADOPAGO_WEBHOOK_SECRET;
  if (!secret) return true; // Si no hay secreto configurado, permitir (modo dev)

  const sigHeader = request.headers.get('x-signature') || request.headers.get('X-Signature');
  if (!sigHeader) return false;

  // Parsear el header: "ts=1234567890,v1=abcdef..."
  const parts = {};
  sigHeader.split(',').forEach(part => {
    const [key, val] = part.split('=');
    if (key && val) parts[key.trim()] = val.trim();
  });

  const ts = parts['ts'];
  const v1 = parts['v1'];
  if (!ts || !v1) return false;

  // Construir el manifest: data.id + timestamp + secret
  // MP usa la query string (para GET) o el body (para POST)
  const url = new URL(request.url);
  const dataId = url.searchParams.get('data.id') || url.searchParams.get('id') || '';
  const manifest = `${dataId}${ts}${secret}`;

  // Calcular HMAC-SHA256
  const encoder = new TextEncoder();
  const keyPromise = crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  // Usar sync validation via a simpler method
  // Cloudflare Workers support crypto.subtle, but it's async
  // We'll do the async version in the caller
  return { ts, v1, manifest, dataId };
}

async function verifySignatureAsync(request, env) {
  const secret = env.MERCADOPAGO_WEBHOOK_SECRET;
  if (!secret) return true; // Si no hay secreto configurado, permitir (modo dev)

  const sigHeader = request.headers.get('x-signature') || request.headers.get('X-Signature');
  if (!sigHeader) return false;

  // Parsear el header: "ts=1234567890,v1=abcdef..."
  const parts = {};
  sigHeader.split(',').forEach(part => {
    const idx = part.indexOf('=');
    if (idx > 0) {
      const key = part.slice(0, idx).trim();
      const val = part.slice(idx + 1).trim();
      parts[key] = val;
    }
  });

  const ts = parts['ts'];
  const v1 = parts['v1'];
  if (!ts || !v1) return false;

  // Construir el manifest: data.id + timestamp + secret
  const url = new URL(request.url);
  const dataId = url.searchParams.get('data.id') || url.searchParams.get('id') || '';

  // Si no hay data.id en query, intentar del body
  let bodyDataId = dataId;
  if (!bodyDataId) {
    try {
      const body = await request.clone().json();
      bodyDataId = body?.data?.id || '';
    } catch {}
  }

  const manifest = `${bodyDataId}${ts}${secret}`;
  const encoder = new TextEncoder();

  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const signature = await crypto.subtle.sign('HMAC', key, encoder.encode(manifest));
  const hashHex = [...new Uint8Array(signature)]
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  return hashHex === v1;
}

async function processPayment(paymentId, env) {
  if (!paymentId) return OK;

  const MP_TOKEN = env.MERCADOPAGO_ACCESS_TOKEN;
  if (!MP_TOKEN) return ERROR;

  // Obtener los detalles del pago desde la API de MercadoPago
  const payRes = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
    headers: { Authorization: `Bearer ${MP_TOKEN}` },
  });

  if (!payRes.ok) {
    // El id puede ser ficticio (pruebas de MP tipo id=123456) -> respondemos ok
    return OK;
  }

  const payment = await payRes.json();

  // Solo procesar pagos aprobados
  if (payment.status !== 'approved') return OK;

  const courseId = parseInt(payment.metadata?.course_id);
  const studentId = parseInt(payment.metadata?.student_id);
  const studentEmail = payment.metadata?.student_email || payment.payer?.email;

  if (!courseId || !studentId) return OK;

  const SUPABASE_URL = env.SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
  const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;

  if (serviceKey) {
    // Crear inscripción (idempotente por UNIQUE(student_id, course_id))
    await fetch(`${SUPABASE_URL}/rest/v1/enrollments`, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
        Prefer: 'resolution=ignore-duplicates',
      },
      body: JSON.stringify({
        student_id: studentId,
        course_id: courseId,
        status: 'enrolled',
        progress_percentage: 0,
      }),
    });

    // Registrar la orden de pago
    await fetch(`${SUPABASE_URL}/rest/v1/orders`, {
      method: 'POST',
      headers: {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
        Prefer: 'resolution=ignore-duplicates',
      },
      body: JSON.stringify({
        student_id: studentId,
        course_id: courseId,
        mercadopago_payment_id: String(paymentId),
        amount: payment.transaction_amount,
        currency: 'MXN',
        status: 'paid',
        payer_email: studentEmail,
      }),
    });
  }

  return OK;
}

// IPN "legacy": MercadoPago manda GET con ?topic=payment&id=123
export async function onRequestGet({ request, env }) {
  try {
    // Validar firma x-signature (si hay secreto configurado)
    const valid = await verifySignatureAsync(request, env);
    if (!valid) return FORBIDDEN;

    const url = new URL(request.url);
    const topic = url.searchParams.get('topic') || url.searchParams.get('type');
    const id = url.searchParams.get('id') || url.searchParams.get('data.id');

    if (topic !== 'payment' || !id) {
      // Responder 200 para cualquier otro topic o para el test de validación de URL.
      return OK;
    }

    return await processPayment(id, env);
  } catch (err) {
    console.error('MercadoPago webhook (GET) error:', err);
    return OK; // Nunca devolver error al validador de URL de MercadoPago.
  }
}

// Webhooks nuevos: MercadoPago manda POST con { type: "payment", data: { id } }
export async function onRequestPost({ request, env }) {
  try {
    // Validar firma x-signature (si hay secreto configurado)
    const valid = await verifySignatureAsync(request, env);
    if (!valid) return FORBIDDEN;

    const body = await request.json().catch(() => null);

    if (!body || body.type !== 'payment' || !body.data?.id) {
      return OK;
    }

    return await processPayment(body.data.id, env);
  } catch (err) {
    console.error('MercadoPago webhook (POST) error:', err);
    return OK;
  }
}
