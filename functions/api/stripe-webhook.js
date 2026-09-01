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

function ok(body = 'ok') {
  return new Response(body, { status: 200, headers: { 'Content-Type': 'text/plain' } });
}

function error(msg = 'error') {
  console.error('[stripe-webhook] ERROR:', msg);
  return new Response(msg, { status: 500, headers: { 'Content-Type': 'text/plain' } });
}

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
        console.error('[stripe-webhook] Firma invalida');
        return new Response('invalid signature', { status: 403 });
      }
    } else {
      console.error('[stripe-webhook] ADVERTENCIA: STRIPE_WEBHOOK_SECRET no configurado, saltando verificacion de firma');
    }

    const event = JSON.parse(rawBody);
    console.log('[stripe-webhook] Evento recibido:', event.type, event.id);

    // Solo nos interesa checkout.session.completed (pago exitoso)
    if (event.type !== 'checkout.session.completed') {
      return ok();
    }

    const session = event.data?.object;
    if (!session) {
      console.error('[stripe-webhook] Evento sin session object');
      return ok();
    }

    // Si el pago no fue exitoso, ignorar
    if (session.payment_status !== 'paid') {
      console.log('[stripe-webhook] payment_status no es paid:', session.payment_status);
      return ok();
    }

    const courseId = parseInt(session.metadata?.course_id);
    const studentId = parseInt(session.metadata?.student_id);
    const studentEmail = session.metadata?.student_email || session.customer_email || '';
    const paymentIntent = session.payment_intent || '';
    const amountTotal = session.amount_total ? session.amount_total / 100 : 0;

    console.log('[stripe-webhook] metadata:', JSON.stringify(session.metadata));

    if (!courseId || !studentId) {
      console.error('[stripe-webhook] Metadata incompleta en session:', session.id, JSON.stringify(session.metadata));
      return error('metadata incompleta: course_id o student_id faltante/invalido');
    }

    const SUPABASE_URL = env.SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
    const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;

    if (!serviceKey) {
      console.error('[stripe-webhook] Falta SUPABASE_SERVICE_ROLE_KEY');
      return error('falta SUPABASE_SERVICE_ROLE_KEY en el servidor');
    }

    const headers = {
      apikey: serviceKey,
      Authorization: `Bearer ${serviceKey}`,
      'Content-Type': 'application/json',
    };

    // Crear inscripción (idempotente por UNIQUE(student_id, course_id))
    const enrollRes = await fetch(`${SUPABASE_URL}/rest/v1/enrollments`, {
      method: 'POST',
      headers: { ...headers, Prefer: 'resolution=ignore-duplicates,return=representation' },
      body: JSON.stringify({
        student_id: studentId,
        course_id: courseId,
        status: 'enrolled',
        progress_percentage: 0,
      }),
    });

    if (!enrollRes.ok) {
      const errBody = await enrollRes.text().catch(() => 'sin detalles');
      console.error('[stripe-webhook] Error creando enrollment:', enrollRes.status, errBody);
      return error(`fallo al crear enrollment (${enrollRes.status}): ${errBody}`);
    }
    console.log('[stripe-webhook] Enrollment creado/existente OK');

    // Registrar la orden de pago
    // NOTA: la tabla `orders` real en Supabase solo tiene la columna
    // `stripe_payment_id` (varchar 100) -- no existen `stripe_payment_intent`
    // ni `stripe_session_id` como columnas separadas. Antes esto hacia que
    // el insert fallara silenciosamente (PGRST204: columna no encontrada) y
    // el pago nunca quedaba registrado, aunque la inscripcion si se creaba.
    const orderRes = await fetch(`${SUPABASE_URL}/rest/v1/orders`, {
      method: 'POST',
      headers: { ...headers, Prefer: 'resolution=ignore-duplicates,return=representation' },
      body: JSON.stringify({
        student_id: studentId,
        course_id: courseId,
        stripe_payment_id: String(paymentIntent || session.id),
        amount: amountTotal,
        currency: 'MXN',
        status: 'paid',
        payer_email: studentEmail,
      }),
    });

    if (!orderRes.ok) {
      const errBody = await orderRes.text().catch(() => 'sin detalles');
      console.error('[stripe-webhook] Error creando order:', orderRes.status, errBody);
      return error(`fallo al crear order (${orderRes.status}): ${errBody}`);
    }
    console.log('[stripe-webhook] Order creada OK');

    return ok();
  } catch (err) {
    console.error('[stripe-webhook] Excepcion:', err.message, err.stack);
    return error(err.message || 'error inesperado');
  }
}

// Stripe también puede enviar GET ocasionalmente
export async function onRequestGet() {
  return ok();
}
