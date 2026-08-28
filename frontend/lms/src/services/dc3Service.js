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
        color: rgb(0.05, 0.1, 0.3),
      });
    };

    // --- DATOS DEL TRABAJADOR ---
    draw(nombreTrabajador, 30, 171, 10);

    // CURP: 18 celdas (fila en blanco top=191.2 bot=201.2)
    const curpCells = [32.8, 49.8, 65.5, 80.4, 93.9, 111.9, 127.3, 142.0, 157.3, 173.4, 186.1, 203.8, 218.8, 231.6, 249.9, 265.6, 280.6, 293.6];
    const curpChars = (curp || '').toUpperCase().split('');
    curpChars.forEach((ch, i) => {
      if (i < curpCells.length) draw(ch, curpCells[i] + 4, 200, 9);
    });

    draw(ocupacion, 306, 198, 8);
    draw(puesto, 65, 223.5, 9);

    // --- DATOS DE LA EMPRESA ---
    draw(empresa || 'Independiente / Persona física', 30, 286, 9);

    // RFC: 14 celdas (fila en blanco top=303.8 bot=313.8)
    const rfcCells = [52.6, 66.5, 81.1, 95.8, 110.1, 124.3, 138.9, 153.0, 167.3, 181.6, 195.9, 210.2, 227.7, 245.3];
    const rfcChars = (rfc || '').toUpperCase().split('');
    rfcChars.forEach((ch, i) => {
      if (i < rfcCells.length) draw(ch, rfcCells[i] + 4, 312, 9);
    });

    // --- DATOS DEL PROGRAMA DE CAPACITACIÓN ---
    draw(nombreCurso, 30, 364, 10);
    draw(String(duracionHoras || ''), 30, 389, 9);

    // Periodo de ejecución: celdas individuales por dígito (renglón top=383.8-393.9)
    const fechaIniCells = [260.1, 275.9, 292.2, 308.3, 326.7, 348.2, 369.5, 390.7]; // Año(4) Mes(2) Día(2)
    const fechaFinCells = [432.8, 452.4, 471.9, 491.5, 511.8, 532.8, 554.1, 575.6];
    const ini = formatFecha(fechaInicio);
    const fin = formatFecha(fechaFin);
    const iniDigits = `${ini.anio}${ini.mes}${ini.dia}`.split('');
    const finDigits = `${fin.anio}${fin.mes}${fin.dia}`.split('');
    iniDigits.forEach((ch, i) => { if (i < fechaIniCells.length) draw(ch, fechaIniCells[i] + 3, 392, 9); });
    finDigits.forEach((ch, i) => { if (i < fechaFinCells.length) draw(ch, fechaFinCells[i] + 3, 392, 9); });

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
