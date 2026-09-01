// ============================================
// Cloudflare Pages Function
// POST /api/create-checkout-session
// Crea una Stripe Checkout Session para comprar un curso.
// El STRIPE_SECRET_KEY vive solo en el servidor (variable de entorno).
// ============================================

export async function onRequestPost({ request, env }) {
  try {
    const { course_id, student_id, student_email } = await request.json();

    if (!course_id || !student_id || !student_email) {
      return json({ message: 'course_id, student_id y student_email son requeridos' }, 400);
    }

    const STRIPE_SECRET = env.STRIPE_SECRET_KEY;
    if (!STRIPE_SECRET) {
      return json({ message: 'Pagos no configurados: falta STRIPE_SECRET_KEY en el servidor' }, 500);
    }

    const SUPABASE_URL = env.SUPABASE_URL || 'https://tsqlpjliqslgzookdqvg.supabase.co';
    const SUPABASE_KEY = env.SUPABASE_SERVICE_ROLE_KEY;

    if (!SUPABASE_KEY) {
      return json({ message: 'Configuración incompleta: falta SUPABASE_SERVICE_ROLE_KEY en el servidor' }, 500);
    }

    // Obtener el curso desde Supabase (nunca confiar en un precio enviado por el cliente)
    const courseRes = await fetch(
      `${SUPABASE_URL}/rest/v1/courses?id=eq.${course_id}&is_published=eq.true&select=id,title,price`,
      { headers: { apikey: SUPABASE_KEY, Authorization: `Bearer ${SUPABASE_KEY}` } }
    );

    if (!courseRes.ok) {
      const errBody = await courseRes.text().catch(() => 'sin detalles');
      return json({ message: `Error al consultar el curso (${courseRes.status}): ${errBody}` }, 500);
    }

    const courses = await courseRes.json();
    const course = courses[0];
    if (!course) return json({ message: 'Curso no encontrado o no publicado' }, 404);
    if (!course.price || course.price <= 0) return json({ message: 'Este curso es gratuito, inscríbete directamente' }, 400);

    const origin = new URL(request.url).origin;

    // Crear Stripe Checkout Session
    // Usamos la API de Stripe directamente (sin SDK, porque Cloudflare Pages
    // no soporta el SDK de Stripe que depende de Node streams)
    const stripePayload = new URLSearchParams();
    stripePayload.append('mode', 'payment');
    stripePayload.append('payment_method_types[]', 'card');
    stripePayload.append('payment_method_types[]', 'oxxo'); // OXXO es popular en México (pagos en efectivo)
    stripePayload.append('customer_email', student_email);
    stripePayload.append(
      'line_items[0][price_data][currency]',
      'mxn'
    );
    stripePayload.append(
      'line_items[0][price_data][unit_amount]',
      String(Math.round(parseFloat(course.price) * 100)) // Stripe usa centavos
    );
    stripePayload.append(
      'line_items[0][price_data][product_data][name]',
      course.title
    );
    stripePayload.append(
      'line_items[0][price_data][product_data][description]',
      `Curso: ${course.title}`
    );
    stripePayload.append('line_items[0][quantity]', '1');

    // URLs de retorno
    stripePayload.append('success_url', `${origin}/app/courses/${course_id}?payment=success`);
    stripePayload.append('cancel_url', `${origin}/app/courses/${course_id}?payment=cancelled`);

    // Metadata para que el webhook sepa a quién inscribir
    stripePayload.append('metadata[course_id]', String(course_id));
    stripePayload.append('metadata[student_id]', String(student_id));
    stripePayload.append('metadata[student_email]', student_email);

    const stripeRes = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${STRIPE_SECRET}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: stripePayload.toString(),
    });

    const stripeData = await stripeRes.json();
    if (!stripeRes.ok) {
      return json({
        message: stripeData.error?.message || 'Error al crear la sesión de pago en Stripe',
      }, 500);
    }

    // url = URL de Checkout hosted (Stripe-hosted page)
    return json({ url: stripeData.url, session_id: stripeData.id });
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
