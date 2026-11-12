#!/usr/bin/env node
// Builds docs/Object_Field_Inventory.xlsx from docs/generated/inventory.json (written by generate.js).
// Usage: npm run inventory
const path = require('path');
const ExcelJS = require('exceljs');
const inv = require('../docs/generated/inventory.json');

(async () => {
  const wb = new ExcelJS.Workbook();
  wb.creator = 'Twopir Consulting';
  wb.created = new Date();
  const header = { font: { bold: true, color: { argb: 'FFFFFFFF' } }, fill: { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0F5F74' } } };

  // Summary sheet
  const sum = wb.addWorksheet('Objects', { views: [{ state: 'frozen', ySplit: 1 }] });
  sum.columns = [
    { header: 'Object', key: 'label', width: 24 }, { header: 'API Name', key: 'api', width: 30 },
    { header: 'Fields', key: 'fields', width: 9 }, { header: 'AscendixRE-documented', key: 'a', width: 22 },
    { header: '% documented', key: 'pct', width: 14 }, { header: 'Record Types', key: 'rts', width: 50 },
    { header: 'Validation Rules', key: 'vrs', width: 16 }, { header: 'Purpose', key: 'desc', width: 80 },
  ];
  for (const o of inv.objects) {
    const rows = inv.rows.filter(r => r.object === o.api);
    const a = rows.filter(r => r.source === 'AscendixRE documented').length;
    sum.addRow({ label: o.label, api: o.api, fields: rows.length, a, pct: rows.length ? a / rows.length : 0, rts: o.recordTypes.join(', '), vrs: o.vrs.length, desc: o.desc });
  }
  sum.getColumn('pct').numFmt = '0%';
  sum.getRow(1).eachCell(c => Object.assign(c, header));
  sum.autoFilter = { from: 'A1', to: 'H1' };

  // Field sheet
  const fs = wb.addWorksheet('Fields', { views: [{ state: 'frozen', ySplit: 1 }] });
  fs.columns = [
    { header: 'Object API', key: 'object', width: 28 }, { header: 'Object', key: 'objectLabel', width: 20 },
    { header: 'Field API', key: 'field', width: 34 }, { header: 'Field Label', key: 'label', width: 30 },
    { header: 'Type', key: 'type', width: 30 }, { header: 'Required', key: 'required', width: 10 },
    { header: 'Values / Formula / Help', key: 'details', width: 70 }, { header: 'Source', key: 'source', width: 22 },
    { header: 'Maintained By', key: 'maintainedBy', width: 14 },
  ];
  inv.rows.forEach(r => fs.addRow(r));
  fs.getRow(1).eachCell(c => Object.assign(c, header));
  fs.autoFilter = { from: 'A1', to: 'I1' };
  fs.getColumn('details').alignment = { wrapText: true, vertical: 'top' };

  // Validation rules sheet
  const vs = wb.addWorksheet('Validation Rules', { views: [{ state: 'frozen', ySplit: 1 }] });
  vs.columns = [{ header: 'Object', key: 'object', width: 28 }, { header: 'Rule', key: 'name', width: 40 }, { header: 'Error message', key: 'msg', width: 80 }, { header: 'Source', key: 'src', width: 22 }];
  inv.objects.forEach(o => o.vrs.forEach(v => vs.addRow({ object: o.api, name: v.name, msg: v.msg, src: v.src === 'A' ? 'AscendixRE documented' : 'TC design' })));
  vs.getRow(1).eachCell(c => Object.assign(c, header));

  const file = path.join(__dirname, '..', 'docs', 'Object_Field_Inventory.xlsx');
  await wb.xlsx.writeFile(file);
  console.log(`Wrote ${file}: ${inv.objects.length} objects, ${inv.rows.length} fields.`);
})();
