// ============================================
// Cloudflare Pages Function
// POST /api/create-checkout-session
// Crea una sesión de Stripe Checkout para comprar un curso.
// La Secret Key de Stripe vive solo en el servidor (variable de entorno).
// ============================================

export async function onRequestPost({ request, env }) {
  try {
    const { course_id, student_id, student_email } = await request.json();

    if (!course_id || !student_id || !student_email) {
      return json({ message: 'course_id, student_id y student_email son requeridos' }, 400);
    }

    if (!env.STRIPE_SECRET_KEY) {
      return json({ message: 'Pagos no configurados: falta STRIPE_SECRET_KEY en el servidor' }, 500);
    }

    const supabaseUrl = env.VITE_SUPABASE_URL || env.SUPABASE_URL;
    const supabaseKey = env.SUPABASE_SERVICE_ROLE_KEY || env.VITE_SUPABASE_KEY;

    // Obtener el curso real desde Supabase (nunca confiar en un precio enviado por el cliente)
    const courseRes = await fetch(
      `${supabaseUrl}/rest/v1/courses?id=eq.${course_id}&is_published=eq.true&select=id,title,price`,
      { headers: { apikey: supabaseKey, Authorization: `Bearer ${supabaseKey}` } }
    );
    const courses = await courseRes.json();
    const course = courses[0];
    if (!course) return json({ message: 'Curso no encontrado' }, 404);
    if (!course.price || course.price <= 0) return json({ message: 'Este curso es gratuito, inscríbete directamente' }, 400);

    const origin = new URL(request.url).origin;
    const amountCents = Math.round(parseFloat(course.price) * 100);

    const params = new URLSearchParams();
    params.append('mode', 'payment');
    params.append('success_url', `${origin}/app/courses/${course_id}?payment=success`);
    params.append('cancel_url', `${origin}/app/courses/${course_id}?payment=cancelled`);
    params.append('customer_email', student_email);
    params.append('line_items[0][price_data][currency]', 'mxn');
    params.append('line_items[0][price_data][product_data][name]', course.title);
    params.append('line_items[0][price_data][unit_amount]', String(amountCents));
    params.append('line_items[0][quantity]', '1');
    params.append('metadata[course_id]', String(course_id));
    params.append('metadata[student_id]', String(student_id));
    params.append('metadata[student_email]', student_email);

    const stripeRes = await fetch('https://api.stripe.com/v1/checkout/sessions', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${env.STRIPE_SECRET_KEY}`,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: params.toString(),
    });

    const session = await stripeRes.json();
    if (!stripeRes.ok) {
      return json({ message: session.error?.message || 'Error al crear la sesión de pago' }, 500);
    }

    return json({ url: session.url, session_id: session.id });
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
