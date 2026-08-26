// ============================================
// Cloudflare Pages Function
// POST /api/mercadopago-webhook
// Recibe notificaciones de MercadoPago (ipn/webhook).
// Cuando el pago se aprueba, crea la inscripción (enrollment)
// y el registro de la orden en Supabase usando la Service Role Key.
//
// Configura esta URL en MercadoPago → Tu aplicación → Notificaciones:
//   https://tu-dominio.com/api/mercadopago-webhook
// Evento: payment
// ============================================

export async function onRequestPost({ request, env }) {
  try {
    const body = await request.json();

    // MercadoPago envía { type: "payment", data: { id: "123456789" } }
    if (body.type !== 'payment' || !body.data?.id) {
      return new Response('ok', { status: 200 });
    }

    const paymentId = body.data.id;

    if (!env.MERCADOPAGO_ACCESS_TOKEN) {
      return new Response('Falta MERCADOPAGO_ACCESS_TOKEN', { status: 500 });
    }

    // Obtener los detalles del pago desde la API de MercadoPago
    const payRes = await fetch(`https://api.mercadopago.com/v1/payments/${paymentId}`, {
      headers: { Authorization: `Bearer ${env.MERCADOPAGO_ACCESS_TOKEN}` },
    });
    const payment = await payRes.json();

    // Solo procesar pagos aprobados
    if (payment.status !== 'approved') {
      return new Response('ok', { status: 200 });
    }

    const courseId = parseInt(payment.metadata?.course_id);
    const studentId = parseInt(payment.metadata?.student_id);
    const studentEmail = payment.metadata?.student_email || payment.payer?.email;

    if (!courseId || !studentId) {
      return new Response('Metadata incompleta', { status: 200 });
    }

    const supabaseUrl = env.VITE_SUPABASE_URL || env.SUPABASE_URL;
    const serviceKey = env.SUPABASE_SERVICE_ROLE_KEY;

    if (serviceKey) {
      // Crear inscripción (idempotente por UNIQUE(student_id, course_id))
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
  } catch (err) {
    console.error('MercadoPago webhook error:', err);
    return new Response('error', { status: 500 });
  }
}
