import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import QRCode from 'qrcode';
import { writeFileSync } from 'fs';

async function genConstancia() {
  const pdfDoc = await PDFDocument.create();
  const fontRegular = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const PAGE_W = 595, PAGE_H = 842;
  const page = pdfDoc.addPage([PAGE_W, PAGE_H]);
  const folio = 'EHS-2026-0001';

  const qrUrl = `http://localhost:5173/app/verify?f=${folio}`;
  const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200, color: { dark: '#002855' } });
  const qrImage = await pdfDoc.embedPng(qrDataUrl);

  page.drawImage(qrImage, { x: PAGE_W - 160, y: 60, width: 90, height: 90 });

  const displayFolio = folio.replace('EHS-', 'EHS-CON-');
  const folioText = `Folio: ${displayFolio}`;
  const folioWidth = fontRegular.widthOfTextAtSize(folioText, 9);
  const qrCenterX = (PAGE_W - 160) + 45;
  page.drawText(folioText, {
    x: qrCenterX - (folioWidth / 2),
    y: 45,
    size: 9,
    font: fontRegular,
    color: rgb(0.5, 0.5, 0.5),
  });

  writeFileSync('/tmp/test_constancia.pdf', await pdfDoc.save());
  console.log('Constancia OK');
}

async function genDC3() {
  const pdfDoc = await PDFDocument.create();
  const font = await pdfDoc.embedFont(StandardFonts.Helvetica);
  const page = pdfDoc.addPage([595, 842]);
  const folio = 'EHS-2026-0001';

  const qrUrl = `http://localhost:5173/app/verify?f=${folio}`;
  const qrDataUrl = await QRCode.toDataURL(qrUrl, { margin: 1, width: 200 });
  const qrImage = await pdfDoc.embedPng(qrDataUrl);

  page.drawImage(qrImage, { x: 30, y: 45, width: 50, height: 50 });

  const displayFolio = folio.replace('EHS-', 'EHS-DC3-');
  const folioText = `Folio: ${displayFolio}`;
  const folioWidth = font.widthOfTextAtSize(folioText, 7);
  const qrCenterX = 30 + 25;
  page.drawText(folioText, {
    x: qrCenterX - (folioWidth / 2),
    y: 35,
    size: 7,
    font,
    color: rgb(0, 0, 0),
  });

  writeFileSync('/tmp/test_dc3.pdf', await pdfDoc.save());
  console.log('DC3 OK');
}

await genConstancia();
await genDC3();
