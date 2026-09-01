// ============================================
// Cloudflare Pages Function
// POST /api/stripe-webhook
// Recibe notificaciones (webhooks) de Stripe.
// Cuando un pago de Checkout se completa (checkout.session.completed),
// crea la inscripción (enrollment) y el registro de la orden en Supabase
// usando la Service Role Key.
//
// Configura esta URL en Stripe → Developers → Webhooks:
//   https://tu-dominio.com/api/stripe-webhook
// Evento: checkout.session.completed
//
// Variable de entorno requerida:
//   STRIPE_WEBHOOK_SECRET — signing secret del webhook (whsec_...)
// ============================================

const OK = new Response('ok', { status: 200, headers: { 'Content-Type': 'text/plain' } });
const ERROR = new Response('error', { status: 500, headers: { 'Content-Type': 'text/plain' } });

/**
 * Verifica la firma del webhook de Stripe usando HMAC-SHA256.
 * Stripe envía header "stripe-signature": "t=<timestamp>,v1=<hash>"
 * El hash es HMAC-SHA256 del string "<timestamp>.<body_raw>" con el webhook secret.
 */
async function verifyStripeSignature(request, rawBody, secret) {
  const sigHeader = request.headers.get('stripe-signature') || '';
  if (!sigHeader) return false;

  const parts = {};
  sigHeader.split(',').forEach(part => {
    const idx = part.indexOf('=');
    if (idx > 0) parts[part.slice(0, idx).trim()] = part.slice(idx + 1).trim();
  });

  const ts = parts['t'];
  const v1 = parts['v1'];
  if (!ts || !v1) return false;

  const payload = `${ts}.${rawBody}`;

  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );

  const sig = await crypto.subtle.sign('HMAC', key, encoder.encode(payload));
  const expected = Array.from(new Uint8Array(sig))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  return expected === v1;
}

export async function onRequestPost({ request, env }) {
  try {
    const rawBody = await request.text();

    // Verificar firma si hay secret configurado
    const webhookSecret = env.STRIPE_WEBHOOK_SECRET;
    if (webhookSecret) {
      const valid = await verifyStripeSignature(request, rawBody, webhookSecret);
      if (!valid) {
        return new Response('invalid signature', { status: 403 });
      }
    }

    const event = JSON.parse(rawBody);

    // Solo nos interesa checkout.session.completed (pago exitoso)
    if (event.type !== 'checkout.session.completed') {
      return OK;
    }

    const session = event.data?.object;
    if (!session) return OK;

    // Si el pago no fue exitoso, ignorar
    if (session.payment_status !== 'paid') return OK;

    const courseId = parseInt(session.metadata?.course_id);
    const studentId = parseInt(session.metadata?.student_id);
    const studentEmail = session.metadata?.student_email || session.customer_email || '';
    const paymentIntent = session.payment_intent || '';
    const amountTotal = session.amount_total ? session.amount_total / 100 : 0;

    if (!courseId || !studentId) {
      console.error('Metadata incompleta en session de Stripe:', session.id);
      return OK;
    }

    const SUPABASE_URL = env.SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
    const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;

    if (serviceKey) {
      const headers = {
        apikey: serviceKey,
        Authorization: `Bearer ${serviceKey}`,
        'Content-Type': 'application/json',
      };

      // Crear inscripción (idempotente por UNIQUE(student_id, course_id))
      await fetch(`${SUPABASE_URL}/rest/v1/enrollments`, {
        method: 'POST',
        headers: { ...headers, Prefer: 'resolution=ignore-duplicates' },
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
        headers: { ...headers, Prefer: 'resolution=ignore-duplicates' },
        body: JSON.stringify({
          student_id: studentId,
          course_id: courseId,
          stripe_payment_intent: String(paymentIntent),
          stripe_session_id: String(session.id),
          amount: amountTotal,
          currency: 'MXN',
          status: 'paid',
          payer_email: studentEmail,
        }),
      });
    }

    return OK;
  } catch (err) {
    console.error('Stripe webhook error:', err);
    return ERROR;
  }
}

// Stripe también envía GET偶尔, respondemos ok para que no falle
export async function onRequestGet() {
  return OK;
}
