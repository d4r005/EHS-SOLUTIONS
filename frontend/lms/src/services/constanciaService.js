import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';

// ============================================
// EHS Solutions - Generador de Constancia/Diploma OFICIAL
// ============================================

const NAVY = rgb(0 / 255, 40 / 255, 85 / 255);
const PAGE_W = 1152;
const PAGE_H = 768;
const CENTER_X = 576;

const MESES = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

function formatFechaLarga(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return '';
  return `el día ${d.getDate()} de ${MESES[d.getMonth()]} del ${d.getFullYear()}`;
}

function formatPeriodo(fechaInicio, fechaFin) {
  const ini = fechaInicio ? new Date(fechaInicio) : null;
  const fin = fechaFin ? new Date(fechaFin) : null;
  if (!ini && !fin) return '';

  // Caso: Mismo día exacto
  if (ini && fin && ini.toDateString() === fin.toDateString()) {
    return formatFechaLarga(fechaFin);
  }

  if (ini && fin) {
    const mismoMes = ini.getMonth() === fin.getMonth() && ini.getFullYear() === fin.getFullYear();
    if (mismoMes) {
      return `del ${ini.getDate()} al ${fin.getDate()} de ${MESES[fin.getMonth()]} del ${fin.getFullYear()}`;
    }
    // Diferente mes o año
    const f1 = formatFechaLarga(fechaInicio).replace('el día ', '');
    const f2 = formatFechaLarga(fechaFin).replace('el día ', '');
    return `del ${f1} al ${f2}`;
  }
  return formatFechaLarga(fechaFin || fechaInicio);
}

function drawCentered(page, font, text, { centerX, baselineY, size, color, maxWidth, lineGap = 14 }) {
  if (!text) return;
  let fontSize = size;
  let width = font.widthOfTextAtSize(text, fontSize);

  const minSize = Math.max(9, size - 6);
  while (width > maxWidth && fontSize > minSize) {
    fontSize -= 0.5;
    width = font.widthOfTextAtSize(text, fontSize);
  }

  if (width <= maxWidth) {
    page.drawText(text, { x: centerX - width / 2, y: baselineY, size: fontSize, font, color });
    return;
  }

  const words = text.split(' ');
  let line1 = '';
  let line2 = '';
  for (let i = 0; i < words.length; i++) {
    const tentative = line1 ? `${line1} ${words[i]}` : words[i];
    if (font.widthOfTextAtSize(tentative, fontSize) <= maxWidth || !line1) {
      line1 = tentative;
    } else {
      line2 = words.slice(i).join(' ');
      break;
    }
  }
  const w1 = font.widthOfTextAtSize(line1, fontSize);
  const w2 = font.widthOfTextAtSize(line2, fontSize);
  page.drawText(line1, { x: centerX - w1 / 2, y: baselineY + lineGap / 2, size: fontSize, font, color });
  if (line2) {
    page.drawText(line2, { x: centerX - w2 / 2, y: baselineY - lineGap / 2, size: fontSize, font, color });
  }
}

export const constanciaService = {
  /**
   * Genera el PDF de la Constancia/Diploma oficial rellenado y lo descarga.
   */
  generateAndDownload: async ({
    nombreAlumno,
    nombreCurso,
    duracionHoras,
    fechaInicio,
    fechaFin,
    folio,
  }) => {
    const templateUrl = `${import.meta.env.BASE_URL}constancia-template.pdf`;
    const templateBytes = await fetch(templateUrl).then((r) => r.arrayBuffer());

    const pdfDoc = await PDFDocument.load(templateBytes);
    const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
    const page = pdfDoc.getPage(0);

    // --- Datos variables ---
    drawCentered(page, fontBold, (nombreAlumno || '').toUpperCase(), {
      centerX: CENTER_X,
      baselineY: PAGE_H - 424,
      size: 24,
      color: NAVY,
      maxWidth: 700,
    });

    drawCentered(page, fontBold, nombreCurso || '', {
      centerX: CENTER_X,
      baselineY: PAGE_H - 486,
      size: 18,
      color: NAVY,
      maxWidth: 750,
      lineGap: 18,
    });

    const duracionTexto = duracionHoras ? `${duracionHoras} horas` : '';
    if (duracionTexto) {
      page.drawText(duracionTexto, {
        x: 636,
        y: PAGE_H - 516,
        size: 15,
        font: fontRegular,
        color: NAVY,
      });
    }

    const periodoTexto = formatPeriodo(fechaInicio, fechaFin);
    if (periodoTexto) {
      page.drawText(periodoTexto, {
        x: 545,
        y: PAGE_H - 540,
        size: 16,
        font: fontRegular,
        color: NAVY,
      });
    }

    // --- QR Y FOLIO DE VALIDACIÓN ---
    if (folio) {
      try {
        const qrUrl = `${window.location.origin}/app/verify?f=${folio}`;
        const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200, color: { dark: '#002855' } });
        const qrImage = await pdfDoc.embedPng(qrDataUrl);

        // Posicionamiento en esquina inferior derecha (basado en DiplomaGenerator.kt)
        page.drawImage(qrImage, {
          x: PAGE_W - 160,
          y: 60,
          width: 90,
          height: 90,
        });

        // Folio centrado debajo del QR
        const displayFolio = folio.replace('EHS-', 'EHS-CON-');
        const folioText = `Folio: ${displayFolio}`;
        const folioWidth = fontRegular.widthOfTextAtSize(folioText, 9);
        const qrCenterX = (PAGE_W - 160) + 45; // x del QR + mitad de su ancho (90)
        page.drawText(folioText, {
          x: qrCenterX - (folioWidth / 2),
          y: 45,
          size: 9,
          font: fontRegular,
          color: rgb(0.5, 0.5, 0.5),
        });
      } catch (e) {
        console.error('Error QR Constancia:', e);
      }
    }

    const pdfBytes = await pdfDoc.save();
    const blob = new Blob([pdfBytes], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `Constancia_${(nombreAlumno || 'alumno').replace(/\s+/g, '_')}.pdf`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  },
};
