// ============================================
// EHS Solutions - Checkout con Stripe
// Llama a la Cloudflare Pages Function /api/create-checkout-session
// que crea la sesión de Stripe Checkout en el servidor (la Secret Key
// nunca se expone en el navegador)
// ============================================

export const paymentService = {
  startCheckout: async (courseId, user) => {
    const res = await fetch('/api/create-checkout-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        course_id: courseId,
        student_id: user.id,
        student_email: user.email,
      }),
    });

    if (!res.ok) {
      const err = await res.json().catch(() => ({}));
      throw { message: err.message || 'No se pudo iniciar el pago' };
    }

    const data = await res.json();
    if (data.url) {
      window.location.href = data.url; // redirige a Stripe Checkout
    } else {
      throw { message: 'Respuesta de pago inválida' };
    }
  },
};
