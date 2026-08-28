import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';

// ============================================
// EHS Solutions - Generador de Constancia/Diploma OFICIAL
// Usa la plantilla real proporcionada (constancia-template.pdf, en /public)
// que ya trae impresos el logo, el sello, los iconos SST y la firma
// del instructor (JESUS DARIO ROBLES TRUJILLO STPS-ROTJ920320-IP4-0005).
// Aquí solo sobreponemos: nombre del alumno, nombre del curso, duración
// y periodo, en las coordenadas exactas del diseño (1152x768 pt).
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
  return `${d.getDate()} de ${MESES[d.getMonth()]} de ${d.getFullYear()}`;
}

function formatPeriodo(fechaInicio, fechaFin) {
  const ini = fechaInicio ? new Date(fechaInicio) : null;
  const fin = fechaFin ? new Date(fechaFin) : null;
  if (!ini && !fin) return '';
  if (ini && fin) {
    const mismoMes = ini.getMonth() === fin.getMonth() && ini.getFullYear() === fin.getFullYear();
    if (mismoMes) {
      return `${ini.getDate()} al ${fin.getDate()} de ${MESES[fin.getMonth()]} de ${fin.getFullYear()}`;
    }
    return `${formatFechaLarga(fechaInicio)} al ${formatFechaLarga(fechaFin)}`;
  }
  return formatFechaLarga(fechaFin || fechaInicio);
}

// Dibuja texto centrado horizontalmente en centerX; si no cabe en maxWidth,
// reduce el tamaño de fuente progresivamente y, si aun así no cabe,
// envuelve en 2 líneas.
function drawCentered(page, font, text, { centerX, baselineY, size, color, maxWidth, lineGap = 14 }) {
  if (!text) return;
  let fontSize = size;
  let width = font.widthOfTextAtSize(text, fontSize);

  // Reducir tamaño hasta un mínimo razonable
  const minSize = Math.max(9, size - 6);
  while (width > maxWidth && fontSize > minSize) {
    fontSize -= 0.5;
    width = font.widthOfTextAtSize(text, fontSize);
  }

  if (width <= maxWidth) {
    page.drawText(text, { x: centerX - width / 2, y: baselineY, size: fontSize, font, color });
    return;
  }

  // No cabe en una línea: envolver en 2 líneas por palabras
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
   * @param {Object} params
   * @param {string} params.nombreAlumno - Nombre completo del estudiante
   * @param {string} params.nombreCurso
   * @param {number} params.duracionHoras
   * @param {string} params.fechaInicio - ISO date (inscripción)
   * @param {string} params.fechaFin - ISO date (fecha de emisión del certificado)
   * @param {string} params.folio - folio interno del certificado
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

    // --- Nombre del alumno (línea bajo "A", arriba de la regla en y≈436) ---
    drawCentered(page, fontBold, (nombreAlumno || '').toUpperCase(), {
      centerX: CENTER_X,
      baselineY: PAGE_H - 424,
      size: 22,
      color: NAVY,
      maxWidth: 620,
    });

    // --- Nombre del curso (entre "el curso de" y "Con duración de") ---
    drawCentered(page, fontBold, nombreCurso || '', {
      centerX: CENTER_X,
      baselineY: PAGE_H - 496,
      size: 15,
      color: NAVY,
      maxWidth: 640,
      lineGap: 15,
    });

    // --- Duración (después de "Con duración de") ---
    const duracionTexto = duracionHoras ? `${duracionHoras} horas` : '';
    if (duracionTexto) {
      page.drawText(duracionTexto, {
        x: 636,
        y: PAGE_H - 517,
        size: 11,
        font: fontRegular,
        color: NAVY,
      });
    }

    // --- Periodo (después de "Del") ---
    const periodoTexto = formatPeriodo(fechaInicio, fechaFin);
    if (periodoTexto) {
      page.drawText(periodoTexto, {
        x: 545,
        y: PAGE_H - 541,
        size: 11,
        font: fontRegular,
        color: NAVY,
      });
    }

    // Folio interno (referencia EHS Solutions, discreto en la esquina inferior)
    if (folio) {
      page.drawText(`Folio: ${folio}`, {
        x: 30,
        y: 14,
        size: 7,
        font: fontRegular,
        color: rgb(0.5, 0.5, 0.5),
      });
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
