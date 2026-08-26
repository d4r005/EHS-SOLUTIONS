// ============================================
// Cloudflare Pages Function
// POST /api/create-checkout-session
// Crea una preferencia de pago en MercadoPago.
// El ACCESS_TOKEN vive solo en el servidor (variable de entorno).
// ============================================

export async function onRequestPost({ request, env }) {
  try {
    const { course_id, student_id, student_email } = await request.json();

    if (!course_id || !student_id || !student_email) {
      return json({ message: 'course_id, student_id y student_email son requeridos' }, 400);
    }

    const MP_TOKEN = env.MERCADOPAGO_ACCESS_TOKEN;
    if (!MP_TOKEN) {
      return json({ message: 'Pagos no configurados: falta MERCADOPAGO_ACCESS_TOKEN en el servidor' }, 500);
    }

    const SUPABASE_URL = env.SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
    const SUPABASE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

    // Obtener el curso desde Supabase (nunca confiar en un precio enviado por el cliente)
    const courseRes = await fetch(
      `${SUPABASE_URL}/rest/v1/courses?id=eq.${course_id}&is_published=eq.true&select=id,title,price`,
      { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` } }
    );
    const courses = await courseRes.json();
    const course = courses[0];
    if (!course) return json({ message: 'Curso no encontrado' }, 404);
    if (!course.price || course.price <= 0) return json({ message: 'Este curso es gratuito, inscríbete directamente' }, 400);

    const origin = new URL(request.url).origin;

    // Crear preferencia en MercadoPago
    const preference = {
      items: [
        {
          id: String(course.id),
          title: course.title,
          description: `Curso: ${course.title}`,
          quantity: 1,
          currency_id: 'MXN',
          unit_price: parseFloat(course.price),
        },
      ],
      payer: {
        email: student_email,
      },
      back_urls: {
        success: `${origin}/app/courses/${course_id}?payment=success`,
        pending: `${origin}/app/courses/${course_id}?payment=pending`,
        failure: `${origin}/app/courses/${course_id}?payment=failure`,
      },
      auto_return: 'approved',
      notification_url: `${origin}/api/mercadopago-webhook`,
      metadata: {
        course_id: String(course_id),
        student_id: String(student_id),
        student_email,
      },
      statement_descriptor: 'EHS SOLUTIONS',
    };

    const mpRes = await fetch('https://api.mercadopago.com/checkout/preferences', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${MP_TOKEN}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(preference),
    });

    const mpData = await mpRes.json();
    if (!mpRes.ok) {
      return json({ message: mpData.message || 'Error al crear la preferencia de pago' }, 500);
    }

    // init_point = URL de pago en producción, sandbox_init_point = pruebas
    const checkoutUrl = mpData.init_point || mpData.sandbox_init_point;

    return json({ url: checkoutUrl, preference_id: mpData.id });
  } catch (err) {
    return json({ message: err.message || 'Error inesperado' }, 500);
  }
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
