// ============================================
// EHS Solutions - Envío de notificaciones por email
// Llama a la Cloudflare Pages Function /api/send-email
// (usa Resend en el servidor; si no está configurada la
// API key, la función responde sin error para no romper el flujo)
// ============================================

async function send(payload) {
  try {
    await fetch('/api/send-email', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
  } catch (err) {
    console.warn('No se pudo enviar el email:', err);
  }
}

export const emailService = {
  sendWelcomeEmail: (email, firstName) =>
    send({ type: 'welcome', to: email, data: { firstName } }),

  sendCourseCompletedEmail: (email, firstName, courseTitle) =>
    send({ type: 'course_completed', to: email, data: { firstName, courseTitle } }),

  sendCertificateReadyEmail: (email, firstName, courseTitle, certificateNumber) =>
    send({ type: 'certificate_ready', to: email, data: { firstName, courseTitle, certificateNumber } }),

  sendEnrollmentConfirmedEmail: (email, firstName, courseTitle) =>
    send({ type: 'enrollment_confirmed', to: email, data: { firstName, courseTitle } }),
};
