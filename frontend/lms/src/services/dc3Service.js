import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';

// ============================================
// EHS Solutions - Generador de Formato DC-3 OFICIAL
// Usa la plantilla real proporcionada (dc3-template.pdf, en /public)
// que ya trae impresos el logo, el agente capacitador STPS y la firma
// del instructor (JESUS DARIO ROBLES TRUJILLO STPS-ROTJ920320-IP4-0005).
// Coordenadas re-calibradas midiendo con precisión cada etiqueta y su
// renglón/celda en blanco correspondiente dentro del PDF original.
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
   * @param {Object} params
   * @param {string} params.nombreTrabajador - Apellido paterno, materno y nombre(s)
   * @param {string} params.curp
   * @param {string} params.ocupacion
   * @param {string} params.puesto
   * @param {string} params.empresa - Nombre o razón social (o "Persona física / Independiente")
   * @param {string} params.rfc
   * @param {string} params.nombreCurso
   * @param {number} params.duracionHoras
   * @param {string} params.fechaInicio - ISO date (inscripción)
   * @param {string} params.fechaFin - ISO date (fecha de emisión del certificado)
   * @param {string} params.categoria - categoría del curso, para inferir área temática
   * @param {string} params.folio - folio interno del certificado (se imprime pequeño abajo)
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
    // "Nombre del curso": etiqueta top=343.9-353.9, renglón en blanco top=357.2-366.2
    draw(nombreCurso, 30, 364, 10);

    // "Duración en horas": etiqueta top=368.6-378.6, renglón en blanco top=381.4-391.5
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

    // "Área temática del curso": etiqueta top=394.9-404.9, renglón en blanco top=407.7-417.8
    draw(getAreaTematica(categoria), 30, 416, 9);

    // Folio interno (referencia EHS Solutions, no forma parte oficial del DC-3)
    if (folio) {
      page.drawText(`Folio interno EHS Solutions: ${folio}`, {
        x: 30,
        y: pageHeight - 452,
        size: 6.5,
        font,
        color: rgb(0.5, 0.5, 0.5),
      });
    }

    const pdfBytes = await pdfDoc.save();
    const blob = new Blob([pdfBytes], { type: 'application/pdf' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `DC3_${(nombreTrabajador || 'constancia').replace(/\s+/g, '_')}.pdf`;
    document.body.appendChild(a);
    a.click();
    a.remove();
    URL.revokeObjectURL(url);
  },
};
