// Usar pdf-lib para extraer info de posicionamiento y verificar visualmente
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';
import { writeFileSync } from 'fs';

// En lugar de renderizar el PDF, generamos un PNG directo con canvas
// usando la misma logica para verificar posiciones

async function genConstanciaPreview() {
  // Crear un canvas simple con pdf-lib
  const pdfDoc = await PDFDocument.create();
  const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const fontBold = await pdfDoc.embedFont(StandardFonts.HelveticaBold);
  const PAGE_W = 595, PAGE_H = 842;
  const page = pdfDoc.addPage([PAGE_W, PAGE_H]);
  
  // Simular contenido basico para contexto
  page.drawRectangle({ x: 0, y: 0, width: PAGE_W, height: PAGE_H, color: rgb(1, 1, 1) });
  
  const folio = 'EHS-2026-0001';
  
  // QR
  const qrUrl = `http://localhost:5173/app/verify?f=${folio}`;
  const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200, color: { dark: '#002855' } });
  const qrImage = await pdfDoc.embedPng(qrDataUrl);
  
  // Linea guía para mostrar el centro del QR
  const qrX = PAGE_W - 160;
  const qrW = 90;
  const qrCenterX = qrX + qrW / 2;
  
  page.drawImage(qrImage, { x: qrX, y: 60, width: qrW, height: qrW });
  
  // Folio centrado
  const displayFolio = folio.replace('EHS-', 'EHS-CON-');
  const folioText = `Folio: ${displayFolio}`;
  const folioWidth = fontRegular.widthOfTextAtSize(folioText, 9);
  const folioX = qrCenterX - (folioWidth / 2);
  
  page.drawText(folioText, {
    x: folioX,
    y: 45,
    size: 9,
    font: fontRegular,
    color: rgb(0.5, 0.5, 0.5),
  });
  
  // Mostrar info de debug
  console.log('=== CONSTANCIA ===');
  console.log(`QR: x=${qrX}, w=${qrW}, center=${qrCenterX}`);
  console.log(`Folio text: "${folioText}"`);
  console.log(`Folio width: ${folioWidth.toFixed(2)}pt`);
  console.log(`Folio x: ${folioX.toFixed(2)} (centered at ${qrCenterX})`);
  console.log(`Folio right edge: ${(folioX + folioWidth).toFixed(2)} vs QR right: ${qrX + qrW}`);
  console.log(`Offset from QR left: ${(folioX - qrX).toFixed(2)}pt`);
  console.log(`Offset from QR right: ${(qrX + qrW - folioX - folioWidth).toFixed(2)}pt`);
  console.log(`Symmetric: ${Math.abs((folioX - qrX) - (qrX + qrW - folioX - folioWidth)) < 0.01}`);
  console.log('');
  
  writeFileSync('/tmp/test_constancia.pdf', await pdfDoc.save());
}

async function genDC3Preview() {
  const pdfDoc = await PDFDocument.create();
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const page = pdfDoc.addPage([595, 842]);
  
  const folio = 'EHS-2026-0001';
  const qrUrl = `http://localhost:5173/app/verify?f=${folio}`;
  const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200 });
  const qrImage = await pdfDoc.embedPng(qrDataUrl);
  
  const qrX = 30, qrW = 50;
  const qrCenterX = qrX + qrW / 2;
  
  page.drawImage(qrImage, { x: qrX, y: 45, width: qrW, height: qrW });
  
  const displayFolio = folio.replace('EHS-', 'EHS-DC3-');
  const folioText = `Folio: ${displayFolio}`;
  const folioWidth = font.widthOfTextAtSize(folioText, 7);
  const folioX = qrCenterX - (folioWidth / 2);
  
  page.drawText(folioText, {
    x: folioX,
    y: 35,
    size: 7,
    font,
    color: rgb(0, 0, 0),
  });
  
  console.log('=== DC3 ===');
  console.log(`QR: x=${qrX}, w=${qrW}, center=${qrCenterX}`);
  console.log(`Folio text: "${folioText}"`);
  console.log(`Folio width: ${folioWidth.toFixed(2)}pt`);
  console.log(`Folio x: ${folioX.toFixed(2)} (centered at ${qrCenterX})`);
  console.log(`Folio right edge: ${(folioX + folioWidth).toFixed(2)} vs QR right: ${qrX + qrW}`);
  console.log(`Offset from QR left: ${(folioX - qrX).toFixed(2)}pt`);
  console.log(`Offset from QR right: ${(qrX + qrW - folioX - folioWidth).toFixed(2)}pt`);
  console.log(`Symmetric: ${Math.abs((folioX - qrX) - (qrX + qrW - folioX - folioWidth)) < 0.01}`);
  
  writeFileSync('/tmp/test_dc3.pdf', await pdfDoc.save());
}

await genConstanciaPreview();
await genDC3Preview();
