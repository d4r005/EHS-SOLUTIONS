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
    // Nombre: Apellidos y Nombres (Orden STPS)
    draw(nombreTrabajador, 30, 171, 10);

    // CURP RE-CALIBRADO: Iniciar en el PRIMER CUADRO (X=25.8) y centrar (+4.2)
    const curpCells = [25.8, 41.1, 56.5, 71.9, 87.2, 102.6, 118.0, 133.2, 148.8, 164.0, 179.4, 194.9, 210.3, 225.6, 241.0, 256.4, 271.7, 287.1];
    const curpChars = (curp || '').toUpperCase().split('');
    curpChars.forEach((ch, i) => {
      if (i < curpCells.length) draw(ch, curpCells[i] + 4.2, 198, 9);
    });

    draw(ocupacion, 306, 198, 8);
    draw(puesto, 30, 221.5, 9); // Izquierda

    // --- DATOS DE LA EMPRESA ---
    draw(empresa || 'Independiente / Persona física', 30, 286, 9);

    // RFC RE-CALIBRADO: Iniciar en el PRIMER CUADRO (X=25.8)
    const rfcCells = [25.8, 43.1, 57.5, 72.3, 87.1, 101.3, 115.9, 130.0, 144.3, 158.6, 172.9, 187.2, 204.7, 222.3];
    const rfcChars = (rfc || '').toUpperCase().split('');
    rfcChars.forEach((ch, i) => {
      if (i < rfcCells.length) draw(ch, rfcCells[i] + 4.5, 310, 9);
    });

    // --- DATOS DEL PROGRAMA DE CAPACITACIÓN ---
    draw(nombreCurso, 30, 364, 10);
    draw(String(duracionHoras || ''), 30, 389, 9);

    // Periodo de ejecución RE-CALIBRADO: Desplazado un espacio a la derecha
    const fechaIniCells = [254.1, 269.9, 286.2, 302.3, 320.7, 342.2, 363.5, 384.7];
    const fechaFinCells = [427.8, 447.4, 466.9, 486.5, 506.8, 527.8, 549.1, 570.6];
    const ini = formatFecha(fechaInicio);
    const fin = formatFecha(fechaFin);
    const iniDigits = `${ini.anio}${ini.mes}${ini.dia}`.split('');
    const finDigits = `${fin.anio}${fin.mes}${fin.dia}`.split('');
    iniDigits.forEach((ch, i) => { if (i < fechaIniCells.length) draw(ch, fechaIniCells[i] + 4.0, 391, 9); });
    finDigits.forEach((ch, i) => { if (i < fechaFinCells.length) draw(ch, fechaFinCells[i] + 4.0, 391, 9); });

    draw(getAreaTematica(categoria), 30, 416, 9);

    // --- QR Y FOLIO DE VALIDACIÓN (Esquina Inferior Izquierda) ---
    if (folio) {
      try {
        const qrUrl = `${window.location.origin}/app/verify?f=${folio}`;
        const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 400, errorCorrectionLevel: 'M', color: { dark: '#000000', light: '#FFFFFFFF' } });
        const qrImage = await pdfDoc.embedPng(qrDataUrl);

        // Posicionamiento abajo a la izquierda
        page.drawImage(qrImage, {
          x: 25,
          y: 40, // Ajustado para que quepa bien abajo
          width: 60,
          height: 60,
        });

        // Folio centrado debajo del QR
        const displayFolio = folio.replace('EHS-', 'EHS-DC3-');
        const folioText = `Folio: ${displayFolio}`;
        const folioWidth = font.widthOfTextAtSize(folioText, 7);
        const qrCenterX = 25 + 30; // x del QR + mitad de su ancho (60)
        page.drawText(folioText, {
          x: qrCenterX - (folioWidth / 2),
          y: 35,
          size: 7,
          font,
          color: rgb(0, 0, 0),
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
