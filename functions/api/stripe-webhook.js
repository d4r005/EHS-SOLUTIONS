// ============================================
// Cloudflare Pages Function
// POST /api/stripe-webhook
// Recibe el evento checkout.session.completed de Stripe,
// verifica la firma y crea la inscripción (enrollment) + el
// registro de la orden en Supabase usando la Service Role Key
// (nunca expuesta al navegador).
//
// Configura esta URL en Stripe Dashboard → Developers → Webhooks:
//   https://tu-dominio.com/api/stripe-webhook
// Evento a escuchar: checkout.session.completed
// ============================================

export async function onRequestPost({ request, env }) {
  const signatureHeader = request.headers.get('stripe-signature');
  const rawBody = await request.text();

  if (!env.STRIPE_WEBHOOK_SECRET) {
    return new Response('Falta STRIPE_WEBHOOK_SECRET', { status: 500 });
  }

  const isValid = await verifyStripeSignature(rawBody, signatureHeader, env.STRIPE_WEBHOOK_SECRET);
  if (!isValid) {
    return new Response('Firma inválida', { status: 400 });
  }

  const event = JSON.parse(rawBody);

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    const courseId = parseInt(session.metadata?.course_id);
    const studentId = parseInt(session.metadata?.student_id);

    if (courseId && studentId) {
      const supabaseUrl = env.VITE_SUPABASE_URL || env.SUPABASE_URL;
      const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;

      if (serviceKey) {
        // Crear inscripción (idempotente por el UNIQUE(student_id, course_id))
        await fetch(`${supabaseUrl}/rest/v1/enrollments`, {
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
        await fetch(`${supabaseUrl}/rest/v1/orders`, {
          method: 'POST',
          headers: { apikey: serviceKey, Authorization: `Bearer ${serviceKey}`, 'Content-Type': 'application/json' },
          body: JSON.stringify({
            student_id: studentId,
            course_id: courseId,
            stripe_session_id: session.id,
            amount: (session.amount_total || 0) / 100,
            currency: session.currency || 'mxn',
            status: 'paid',
          }),
        });
      }
    }
  }

  return new Response('ok', { status: 200 });
}

// Verificación de firma de Stripe usando Web Crypto (compatible con Cloudflare Workers)
async function verifyStripeSignature(payload, signatureHeader, secret) {
  if (!signatureHeader) return false;
  const parts = Object.fromEntries(signatureHeader.split(',').map((p) => p.split('=')));
  const timestamp = parts.t;
  const signature = parts.v1;
  if (!timestamp || !signature) return false;

  const signedPayload = `${timestamp}.${payload}`;
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const sigBuffer = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(signedPayload));
  const expected = [...new Uint8Array(sigBuffer)].map((b) => b.toString(16).padStart(2, '0')).join('');

  return expected === signature;
}
