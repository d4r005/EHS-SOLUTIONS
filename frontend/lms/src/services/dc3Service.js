import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';

// ============================================
// EHS Solutions - Generador de Formato DC-3 OFICIAL
// ============================================

// Mapeo simple de categoría de curso -> clave de área temática (catálogo STPS)
function getAreaTematica(category) {
  const cat = (category || '').toLowerCase();
  if (cat.includes('segur')) return '6000  SEGURIDAD';
  if (cat.includes('ambient')) return '6000  SEGURIDAD'; // cursos ambientales también son de seguridad/higiene
  if (cat.includes('calidad')) return '3000  ADMINISTRACIÓN, CONTABILIDAD Y ECONOMÍA';
  return '6000  SEGURIDAD';
}

function formatFecha(dateStr) {
  if (!dateStr) return { anio: '', mes: '', dia: '' };
  const d = new Date(dateStr);
  return {
    anio: String(d.getFullYear()),
    mes: String(d.getMonth() + 1).padStart(2, '0'),
    dia: String(d.getDate()).padStart(2, '0'),
  };
}

export const dc3Service = {
  /**
   * Genera el PDF del Formato DC-3 oficial rellenado y lo descarga.
   */
  generateAndDownload: async ({
    nombreTrabajador,
    curp = '',
    ocupacion = '',
    puesto = '',
    empresa = '',
    rfc = '',
    nombreCurso,
    duracionHoras,
    fechaInicio,
    fechaFin,
    categoria,
    folio,
  }) => {
    const templateUrl = `${import.meta.env.BASE_URL}dc3-template.pdf`;
    const templateBytes = await fetch(templateUrl).then((r) => r.arrayBuffer());

    const pdfDoc = await PDFDocument.load(templateBytes);
    const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
    const page = pdfDoc.getPage(0);
    const pageHeight = page.getHeight(); // 792

    const draw = (text, x, top, size = 9) => {
      if (!text) return;
      page.drawText(String(text), {
        x,
        y: pageHeight - top,
        size,
        font,
        color: rgb(0, 0, 0), // NEGRO según solicitud
      });
    };

    // --- DATOS DEL TRABAJADOR ---
    // Nombre: Apellido Paterno, Materno y Nombres
    draw(nombreTrabajador, 30, 171, 10);

    // CURP CALIBRADO: Fila en blanco top=191.2 bot=201.2
    // Ajuste de X (+5) y Y (subir a 198)
    const curpCells = [35.8, 52.8, 68.5, 83.4, 96.9, 114.9, 130.3, 145.0, 160.3, 176.4, 189.1, 206.8, 221.8, 234.6, 252.9, 268.6, 283.6, 296.6];
    const curpChars = (curp || '').toUpperCase().split('');
    curpChars.forEach((ch, i) => {
      if (i < curpCells.length) draw(ch, curpCells[i] + 4, 198, 9);
    });

    draw(ocupacion, 306, 198, 8);
    draw(puesto, 65, 221.5, 9); // Subido de 223.5 a 221.5

    // --- DATOS DE LA EMPRESA ---
    draw(empresa || 'Independiente / Persona física', 30, 286, 9);

    // RFC CALIBRADO: fila en blanco top=303.8 bot=313.8
    // Ajuste de X (+6) y Y (subir a 310)
    const rfcCells = [58.6, 72.5, 87.1, 101.8, 116.1, 130.3, 144.9, 159.0, 173.3, 187.6, 201.9, 216.2, 233.7, 251.3];
    const rfcChars = (rfc || '').toUpperCase().split('');
    rfcChars.forEach((ch, i) => {
      if (i < rfcCells.length) draw(ch, rfcCells[i] + 4, 310, 9);
    });

    // --- DATOS DEL PROGRAMA DE CAPACITACIÓN ---
    draw(nombreCurso, 30, 364, 10);
    draw(String(duracionHoras || ''), 30, 389, 9);

    // Periodo de ejecución calibrado (X +4, Y 391)
    const fechaIniCells = [264.1, 279.9, 296.2, 312.3, 330.7, 352.2, 373.5, 394.7];
    const fechaFinCells = [436.8, 456.4, 475.9, 495.5, 515.8, 536.8, 558.1, 579.6];
    const ini = formatFecha(fechaInicio);
    const fin = formatFecha(fechaFin);
    const iniDigits = `${ini.anio}${ini.mes}${ini.dia}`.split('');
    const finDigits = `${fin.anio}${fin.mes}${fin.dia}`.split('');
    iniDigits.forEach((ch, i) => { if (i < fechaIniCells.length) draw(ch, fechaIniCells[i] + 3, 391, 9); });
    finDigits.forEach((ch, i) => { if (i < fechaFinCells.length) draw(ch, fechaFinCells[i] + 3, 391, 9); });

    draw(getAreaTematica(categoria), 30, 416, 9);

    // --- QR DE VALIDACIÓN ---
    if (folio) {
      try {
        const qrUrl = `https://ehs-solutions.pages.dev/app/verify?f=${folio}`;
        const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200 });
        const qrImage = await pdfDoc.embedPng(qrDataUrl);
        page.drawImage(qrImage, {
          x: 480,
          y: pageHeight - 75,
          width: 55,
          height: 55,
        });

        page.drawText(`Folio: ${folio}`, {
          x: 30,
          y: pageHeight - 452,
          size: 7,
          font,
          color: rgb(0.3, 0.3, 0.3),
        });
      } catch (e) {
        console.error('Error QR:', e);
      }
    }

    const pdfBytes = await pdfDoc.save();
    const blob = new Blob([pdfBytes], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `DC3_${(nombreTrabajador || 'documento').replace(/\s+/g, '_')}.pdf`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  },
};
