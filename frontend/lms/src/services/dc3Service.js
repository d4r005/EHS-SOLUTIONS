import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';

// ============================================
// EHS Solutions - Generador de Formato DC-3 OFICIAL
// Usa la plantilla real proporcionada (dc3-template.pdf, en /public)
// que ya trae impresos el logo, el agente capacitador STPS y la firma
// del instructor (JESUS DARIO ROBLES TRUJILLO STPS-ROTJ920320-IP4-0005).
// Aquí solo sobreponemos los datos variables del trabajador y del curso
// en las coordenadas exactas de cada casilla del formato oficial.
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

    // CURP: 18 celdas entre x=24.4 y x=301.0 (~15.35pt cada una)
    const curpCells = [25.1, 40.4, 55.8, 71.2, 86.5, 101.9, 117.3, 132.5, 148.1, 163.3, 178.7, 194.2, 209.6, 224.9, 240.3, 255.7, 271.0, 286.4];
    const curpChars = (curp || '').toUpperCase().split('');
    curpChars.forEach((ch, i) => {
      if (i < curpCells.length) draw(ch, curpCells[i] + 4, 198.5, 9);
    });

    draw(ocupacion, 306, 198, 8);
    draw(puesto, 65, 223.5, 9);

    // --- DATOS DE LA EMPRESA ---
    draw(empresa || 'Independiente / Persona física', 30, 286, 9);

    // RFC: celdas entre x=25.1 y x~237.9
    const rfcCells = [25.1, 46.1, 59.6, 73.9, 89.1, 103.3, 117.6, 131.8, 146.3, 160.6, 174.9, 189.1, 203.3, 217.6];
    const rfcChars = (rfc || '').toUpperCase().split('');
    rfcChars.forEach((ch, i) => {
      if (i < rfcCells.length) draw(ch, rfcCells[i] + 4, 312.5, 9);
    });

    // --- DATOS DEL PROGRAMA DE CAPACITACIÓN ---
    draw(nombreCurso, 30, 424, 10);
    draw(String(duracionHoras || ''), 95, 412, 9);

    const ini = formatFecha(fechaInicio);
    const fin = formatFecha(fechaFin);
    // Fecha inicio: Año (x~252.7-315.9), Mes (316.6-358.8), Día (359.5-400.9)
    draw(ini.anio, 274, 399, 9);
    draw(ini.mes, 328, 399, 9);
    draw(ini.dia, 372, 399, 9);
    // Fecha fin: Año (423.4-500.9), Mes (501.6-543.0), Día (543.7-585.8)
    draw(fin.anio, 452, 399, 9);
    draw(fin.mes, 512, 399, 9);
    draw(fin.dia, 556, 399, 9);

    draw(getAreaTematica(categoria), 30, 413, 9);

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
