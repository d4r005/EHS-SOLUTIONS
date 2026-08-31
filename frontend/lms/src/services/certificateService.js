import { jsPDF } from 'jspdf';
import { rest } from './api';

function formatFolioNumber(id) {
  return String(id).padStart(4, '0');
}

export const certificateService = {
  // Obtiene el certificado existente o lo crea si el curso está al 100%
  getOrCreateCertificate: async (courseId) => {
    const userId = parseInt(localStorage.getItem('userId'));
    if (!userId) throw { message: 'No autenticado' };

    const { data: existing } = await rest.get(
      `/certificates?student_id=eq.${userId}&course_id=eq.${courseId}&select=*`
    );
    if (existing.length) return existing[0];

    const { data: enr } = await rest.get(
      `/enrollments?student_id=eq.${userId}&course_id=eq.${courseId}&select=progress_percentage,status`
    );
    if (!enr.length || enr[0].progress_percentage < 100) {
      throw { message: 'Debes completar el 100% del curso para obtener el certificado' };
    }

    // 1) Crear el registro. El folio se genera automáticamente vía Trigger en la BD.
    // Usamos Prefer: return=representation para obtener el objeto insertado con su nuevo ID y Folio.
    const payload = {
      student_id: userId,
      course_id: parseInt(courseId),
      issued_date: new Date().toISOString(),
      is_valid: true,
    };

    const { data: inserted } = await rest.post('/certificates', payload, {
      headers: { 'Prefer': 'return=representation' }
    });

    if (!inserted?.[0]) throw { message: 'No se pudo crear el registro del certificado' };

    return inserted[0];
  },

  // Certificados del alumno actual con datos de curso
  getMyCertificates: async () => {
    const userId = localStorage.getItem('userId');
    if (!userId || userId === '0') return [];
    const { data } = await rest.get(
      `/certificates?student_id=eq.${userId}&select=*,course:courses(id,title,duration_hours)&order=issued_date.desc`
    );
    return data;
  },

  // Genera y descarga el PDF del certificado (estilo constancia DC-3 STPS)
  downloadCertificatePDF: (certificate, studentName, courseTitle, durationHours) => {
    const doc = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });
    const pageW = doc.internal.pageSize.getWidth();
    const pageH = doc.internal.pageSize.getHeight();

    // Borde decorativo
    doc.setDrawColor(0, 40, 85);
    doc.setLineWidth(2);
    doc.rect(8, 8, pageW - 16, pageH - 16);
    doc.setLineWidth(0.5);
    doc.rect(12, 12, pageW - 24, pageH - 24);

    // Encabezado
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(12);
    doc.setTextColor(0, 40, 85);
    doc.text('EHS SOLUTIONS', pageW / 2, 28, { align: 'center' });
    doc.setFontSize(10);
    doc.setFont('helvetica', 'normal');
    doc.text('Constancia de Habilidades Laborales (formato DC-3)', pageW / 2, 34, { align: 'center' });

    doc.setFontSize(26);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(118, 184, 42);
    doc.text('CONSTANCIA DE CAPACITACIÓN', pageW / 2, 55, { align: 'center' });

    doc.setFontSize(12);
    doc.setTextColor(60, 60, 60);
    doc.setFont('helvetica', 'normal');
    doc.text('Se otorga la presente constancia a:', pageW / 2, 72, { align: 'center' });

    doc.setFontSize(22);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(0, 40, 85);
    doc.text(studentName, pageW / 2, 85, { align: 'center' });

    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(60, 60, 60);
    doc.text('por haber concluido satisfactoriamente el curso:', pageW / 2, 97, { align: 'center' });

    doc.setFontSize(16);
    doc.setFont('helvetica', 'bold');
    doc.setTextColor(0, 40, 85);
    doc.text(courseTitle, pageW / 2, 107, { align: 'center', maxWidth: pageW - 60 });

    doc.setFontSize(11);
    doc.setFont('helvetica', 'normal');
    doc.setTextColor(60, 60, 60);
    doc.text(`Duración: ${durationHours || 0} horas`, pageW / 2, 118, { align: 'center' });

    const issuedDate = new Date(certificate.issued_date).toLocaleDateString('es-MX', {
      year: 'numeric', month: 'long', day: 'numeric',
    });
    doc.text(`Fecha de emisión: ${issuedDate}`, pageW / 2, 125, { align: 'center' });

    // Folio
    doc.setFontSize(9);
    doc.setTextColor(120, 120, 120);
    doc.text(`Folio: ${certificate.certificate_number}`, pageW / 2, pageH - 18, { align: 'center' });
    doc.text('Este documento es válido como constancia interna de capacitación EHS Solutions.', pageW / 2, pageH - 13, { align: 'center' });

    // Firma
    doc.setDrawColor(150, 150, 150);
    doc.line(pageW / 2 - 35, pageH - 35, pageW / 2 + 35, pageH - 35);
    doc.setFontSize(10);
    doc.setTextColor(60, 60, 60);
    doc.text('EHS Solutions - Dirección de Capacitación', pageW / 2, pageH - 30, { align: 'center' });

    doc.save(`Constancia_${certificate.certificate_number}.pdf`);
  },
};
