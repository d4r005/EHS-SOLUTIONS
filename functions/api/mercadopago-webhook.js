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
// ============================================

async function processPayment(paymentId, env) {
  if (!paymentId) {
    return new Response('ok', { status: 200 });
  }

  const MP_TOKEN = env.MERCADOPAGO_ACCESS_TOKEN;
  if (!MP_TOKEN) {
    return new Response('Falta MERCADOPAGO_ACCESS_TOKEN', { status: 500 });
  }

  // Obtener los detalles del pago desde la API de MercadoPago
  const payRes = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
    headers: { Authorization: `Bearer ${MP_TOKEN}` },
  });

  if (!payRes.ok) {
    // El id puede ser ficticio (pruebas de MP tipo id=123456) -> respondemos ok
    // para que MercadoPago valide la URL sin marcarla como error.
    return new Response('ok', { status: 200 });
  }

  const payment = await payRes.json();

  // Solo procesar pagos aprobados
  if (payment.status !== 'approved') {
    return new Response('ok', { status: 200 });
  }

  const courseId = parseInt(payment.metadata?.course_id);
  const studentId = parseInt(payment.metadata?.student_id);
  const studentEmail = payment.metadata?.student_email || payment.payer?.email;

  if (!courseId || !studentId) {
    return new Response('ok', { status: 200 });
  }

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

  return new Response('ok', { status: 200 });
}

// IPN "legacy": MercadoPago manda GET con ?topic=payment&id=123
// (también usa ?topic=merchant_order, que ignoramos).
export async function onRequestGet({ request, env }) {
  try {
    const url = new URL(request.url);
    const topic = url.searchParams.get('topic') || url.searchParams.get('type');
    const id = url.searchParams.get('id') || url.searchParams.get('data.id');

    if (topic !== 'payment' || !id) {
      // Responder 200 para cualquier otro topic (merchant_order, etc.)
      // o para el test de validación de URL de MercadoPago.
      return new Response('ok', { status: 200 });
    }

    return await processPayment(id, env);
  } catch (err) {
    console.error('MercadoPago webhook (GET) error:', err);
    // Nunca devolver error al validador de URL de MercadoPago.
    return new Response('ok', { status: 200 });
  }
}

// Webhooks nuevos: MercadoPago manda POST con { type: "payment", data: { id } }
export async function onRequestPost({ request, env }) {
  try {
    const body = await request.json().catch(() => null);

    if (!body || body.type !== 'payment' || !body.data?.id) {
      return new Response('ok', { status: 200 });
    }

    return await processPayment(body.data.id, env);
  } catch (err) {
    console.error('MercadoPago webhook (POST) error:', err);
    return new Response('ok', { status: 200 });
  }
}
