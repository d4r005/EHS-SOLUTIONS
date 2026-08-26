// ============================================
// Cloudflare Pages Function
// POST /api/send-email
// Envía notificaciones transaccionales usando Resend.
// Si RESEND_API_KEY no está configurada, responde 200 sin enviar
// nada (para no romper el flujo del frontend mientras se configura).
// ============================================

const TEMPLATES = {
  welcome: ({ firstName }) => ({
    subject: '¡Bienvenido a EHS Solutions! 🎉',
    html: `<p>Hola ${firstName || ''},</p><p>Gracias por registrarte en EHS Solutions. Ya puedes explorar el catálogo de cursos de seguridad, salud y medio ambiente.</p><p>El equipo de EHS Solutions</p>`,
  }),
  enrollment_confirmed: ({ firstName, courseTitle }) => ({
    subject: `Inscripción confirmada: ${courseTitle}`,
    html: `<p>Hola ${firstName || ''},</p><p>Tu inscripción al curso <strong>${courseTitle}</strong> fue confirmada. ¡Empieza cuando quieras desde tu dashboard!</p>`,
  }),
  course_completed: ({ firstName, courseTitle }) => ({
    subject: `¡Completaste ${courseTitle}! 🎓`,
    html: `<p>Felicidades ${firstName || ''},</p><p>Completaste el 100% del curso <strong>${courseTitle}</strong>. Tu certificado ya está disponible en tu perfil.</p>`,
  }),
  certificate_ready: ({ firstName, courseTitle, certificateNumber }) => ({
    subject: 'Tu certificado está listo 🏆',
    html: `<p>Hola ${firstName || ''},</p><p>Tu constancia del curso <strong>${courseTitle}</strong> está lista. Folio: <strong>${certificateNumber}</strong>. Descárgala desde tu perfil en la plataforma.</p>`,
  }),
};

export async function onRequestPost({ request, env }) {
  try {
    const { type, to, data } = await request.json();
    const template = TEMPLATES[type];
    if (!template || !to) {
      return new Response(JSON.stringify({ message: 'type y to son requeridos' }), { status: 400 });
    }

    if (!env.RESEND_API_KEY) {
      // No configurado todavía: no romper el flujo del frontend
      return new Response(JSON.stringify({ skipped: true, reason: 'RESEND_API_KEY no configurada' }), { status: 200 });
    }

    const { subject, html } = template(data || {});
    const fromEmail = env.RESEND_FROM_EMAIL || 'EHS Solutions <notificaciones@ehs-solutions.com>';

    const res = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: { Authorization: `Bearer ${env.RESEND_API_KEY}`, 'Content-Type': 'application/json' },
      body: JSON.stringify({ from: fromEmail, to: [to], subject, html }),
    });

    if (!res.ok) {
      const err = await res.text();
      return new Response(JSON.stringify({ message: 'Error al enviar email', detail: err }), { status: 500 });
    }

    return new Response(JSON.stringify({ sent: true }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ message: err.message }), { status: 500 });
  }
}
