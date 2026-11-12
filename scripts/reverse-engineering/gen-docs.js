// Generates the two Excel workbooks and two of the markdown deliverables from the same data as the deck.
const fs = require("fs");
const path = require("path");
const ExcelJS = require("exceljs");
const C = require("./cross");
const OUT = process.argv[2];
const RES = process.env.RE_RESEARCH || path.join(__dirname, "..", "..", "docs", "reverse-engineering", "research");
const EVN = { V: "Verified", O: "Observed", I: "Inferred", U: "Unknown", P: "Proposed" };
const SYMN = { F: "Fully supported", P: "Partially supported", N: "Not supported (outside scope)", U: "Not publicly verified" };
const apps = C.KEYS.map((k) => require(`./apps/${k}`));
const NAVY = "FF1B2A3A", CREAM = "FFF4F1EA";

function sheet(wb, name, header, rows, widths) {
  const ws = wb.addWorksheet(name, { views: [{ state: "frozen", ySplit: 1 }] });
  ws.addRow(header);
  rows.forEach((r) => ws.addRow(r));
  ws.getRow(1).eachCell((c) => { c.font = { bold: true, color: { argb: "FFFFFFFF" } }; c.fill = { type: "pattern", pattern: "solid", fgColor: { argb: NAVY } }; c.alignment = { vertical: "middle", wrapText: true }; });
  ws.columns.forEach((col, i) => { col.width = (widths && widths[i]) || 22; col.alignment = { vertical: "top", wrapText: true }; });
  ws.autoFilter = { from: { row: 1, column: 1 }, to: { row: 1, column: header.length } };
  return ws;
}
function colourEvidence(ws, colIdx) {
  const fill = { Verified: "FFDCEFE3", Observed: "FFD6E4F2", Inferred: "FFFBEFD6", Unknown: "FFE8E8E8", Proposed: "FFFCEBE1" };
  ws.eachRow((row, i) => { if (i === 1) return; const c = row.getCell(colIdx); if (fill[c.value]) c.fill = { type: "pattern", pattern: "solid", fgColor: { argb: fill[c.value] } }; });
}
function readme(wb, title, lines) {
  const ws = wb.addWorksheet("README");
  ws.getColumn(1).width = 120;
  ws.addRow([title]).font = { bold: true, size: 14, color: { argb: NAVY } };
  ws.addRow([]);
  lines.forEach((l) => ws.addRow([l]).alignment = { wrapText: true });
}

async function comparison() {
  const wb = new ExcelJS.Workbook(); wb.creator = "Twopir Consulting";
  readme(wb, "Application functional comparison: eight Salesforce applications", [
    "Research date: 12 November 2026. Public sources only; no product was installed.",
    "Feature codes: Fully supported / Partially supported / Not supported (outside the product's documented scope) / Not publicly verified.",
    "'Not supported' is used only where the product's scope clearly excludes the capability (e.g. listings in a home-improvement CRM). Lack of documentation is 'Not publicly verified'.",
    "Ratings: supplied values are kept as given; verified values are shown beside them with platform and date. G2 and Capterra returned HTTP 403, so their values come from search-engine snippets.",
    "Companion files: Real_Estate_Applications_Reverse_Engineering.pptx, Salesforce_Object_Architecture.xlsx, Application_Process_Flows.md, Research_Sources_and_References.md, Proposed_Salesforce_Architecture.md.",
  ]);
  sheet(wb, "Landscape", ["Application", "Publisher", "Segment", "Salesforce footprint", "Status (Nov 2026)", "Stand-out capability"], C.landscape, [18, 30, 26, 30, 44, 44]);
  sheet(wb, "Ratings", ["Application", "Supplied rating", "Supplied (as given)", "Verified on same platform", "Other platforms", "Note", "Verified on"],
    C.ratings.map((r) => [r.app, r.sup || null, r.supplied, r.verified, r.other, r.note, "2026-11-12"]), [18, 14, 26, 28, 36, 30, 14]);
  const fw = sheet(wb, "Features", ["Capability", ...C.APPS], C.features.map((r) => [r[0], ...r.slice(1).map((c) => SYMN[c])]), [26, 20, 20, 20, 20, 20, 20, 20, 20]);
  const ff = { "Fully supported": "FFDCEFE3", "Partially supported": "FFFBEFD6", "Not supported (outside scope)": "FFF6D5D1", "Not publicly verified": "FFE8E8E8" };
  fw.eachRow((row, i) => { if (i > 1) row.eachCell((c, j) => { if (j > 1 && ff[c.value]) c.fill = { type: "pattern", pattern: "solid", fgColor: { argb: ff[c.value] } }; }); });
  sheet(wb, "Technical", ["Dimension", ...C.APPS], C.tech, [24, 22, 22, 22, 22, 22, 22, 22, 22]);
  sheet(wb, "Object map", ["Concept", ...C.APPS], C.objectMap, [20, 24, 24, 24, 24, 24, 24, 24, 24]);
  sheet(wb, "Process steps", ["Step", ...C.APPS], C.processCmp, [20, 26, 26, 26, 26, 26, 26, 26, 26]);
  sheet(wb, "Integrations", ["Application", "Inbound", "Outbound", "Two-way", "AI"], C.integrationCmp, [18, 44, 40, 48, 36]);
  const mods = [];
  apps.forEach((a) => a.modules.sections.forEach((sec) => sec.cols.forEach((col) => (Array.isArray(col) ? col : col.blocks).forEach((b) => mods.push([a.name, sec.label, b.title, b.text || "", EVN[b.ev] || ""])))));
  colourEvidence(sheet(wb, "Modules", ["Application", "Lifecycle group", "Module", "What it does", "Evidence"], mods, [20, 26, 32, 60, 12]), 5);
  const ints = [];
  apps.forEach((a) => (a.integrations || []).forEach((i) => ints.push([a.name, i.sys, i.dir === "→" ? "Into Salesforce" : i.dir === "←" ? "Out of Salesforce" : "Both ways", i.purpose, i.data, EVN[i.ev]])));
  colourEvidence(sheet(wb, "Integration detail", ["Application", "External system", "Direction", "Purpose", "Data / technology", "Evidence"], ints, [20, 30, 16, 44, 56, 12]), 6);
  const autos = [];
  apps.forEach((a) => (a.automation || []).forEach((r) => autos.push([a.name, ...r.slice(0, 6), EVN[r[6]] || r[6]])));
  colourEvidence(sheet(wb, "Automation", ["Application", "Automation", "Trigger", "Object", "Action", "Outcome", "Likely technology", "Evidence"], autos, [18, 30, 24, 22, 36, 26, 28, 12]), 8);
  await wb.xlsx.writeFile(path.join(OUT, "Application_Functional_Comparison.xlsx"));
}

async function objects() {
  const wb = new ExcelJS.Workbook(); wb.creator = "Twopir Consulting";
  readme(wb, "Salesforce object architecture: object and field inventory with confidence", [
    "One row per object or object group named in public material. 'API name' is shown exactly as the vendor publishes it; 'Unknown' where unpublished; 'Proposed: …' marks a name of our own.",
    "Confidence: Verified (vendor states it), Observed (seen in an official walkthrough), Inferred (reasoned, not confirmed), Unknown.",
    "Sheet 'Relationships' lists ERD edges drawn in the deck. Lookup vs master-detail is rarely published; 'md' edges are inferred unless the chapter says otherwise.",
    "Sheet 'Published API names' lists only names quoted from vendor material, for quick verification.",
    "Real Properties: every object is an inferred reference model; no API names are published.",
  ]);
  const rows = [];
  apps.forEach((a) => a.objects.forEach((o) => rows.push([a.name, o[0], o[1] || "Unknown", o[2], o[3], o[4] || "", EVN[o[5]] || o[5] || "Unknown"])));
  colourEvidence(sheet(wb, "Objects", ["Application", "Object", "API name", "Type", "Purpose", "Key fields / relationships", "Confidence"], rows, [18, 26, 34, 14, 40, 60, 12]), 7);
  const rels = [];
  apps.forEach((a) => (a.erds || [a.erd]).forEach((e) => {
    const lab = Object.fromEntries(e.nodes.map((n) => [n.id, n]));
    e.edges.forEach((ed) => rels.push([a.name, lab[ed.from]?.label, lab[ed.from]?.api || "Unknown", { md: "Master-detail (inferred unless stated)", lookup: "Lookup", junction: "Junction", ref: "Reference" }[ed.kind || "lookup"], lab[ed.to]?.label, lab[ed.to]?.api || "Unknown", ed.label || "", e.tag === "inferred reference architecture" ? "Inferred" : "As drawn in deck"]));
  }));
  sheet(wb, "Relationships", ["Application", "Parent", "Parent API", "Relationship", "Child", "Child API", "Cardinality / note", "Basis"], rels, [18, 24, 30, 30, 24, 30, 16, 20]);
  const api = [];
  apps.forEach((a) => a.objects.forEach((o) => { if (o[1] && !/^Proposed|Unknown|^Standard$/.test(o[1])) api.push([a.name, o[0], o[1], EVN[o[5]] || o[5]]); }));
  sheet(wb, "Published API names", ["Application", "Object", "API name(s) as published", "Confidence"], api, [18, 30, 60, 12]);
  // Field-level detail: from ERD node field lists
  const fields = [];
  apps.forEach((a) => (a.erds || [a.erd]).forEach((e) => e.nodes.forEach((n) => (n.fields || []).forEach((f) => fields.push([a.name, n.label, n.api || "Unknown", f, EVN[n.ev] || "Unknown"])))));
  colourEvidence(sheet(wb, "Fields (ERD)", ["Application", "Object", "Object API", "Field / note", "Confidence"], fields, [18, 26, 32, 50, 12]), 5);
  await wb.xlsx.writeFile(path.join(OUT, "Salesforce_Object_Architecture.xlsx"));
}

function section(md, n) {
  const re = new RegExp(`^## ${n}\\.[^\\n]*\\n`, "m"); const m = md.match(re); if (!m) return "";
  const start = m.index; const rest = md.slice(start + m[0].length); const next = rest.search(/^## \d+\./m);
  return md.slice(start, start + m[0].length + (next < 0 ? rest.length : next));
}
function processDoc() {
  let out = `# Application process flows\n\nDetailed business processes for the eight applications, start to finish. Researched 12 November 2026 from public sources only; no product was installed.\n\n**Labels.** Verified = stated by the vendor. Observed = seen in an official walkthrough. Inferred = reasoned, not confirmed. Unknown = no reliable information. Source ids refer to each product's table in \`Research_Sources_and_References.md\`.\n\nEach process follows six stages: initiation, data processing, business operations, decision/approval, completion, post-completion, with alternate paths. The matching diagrams are in \`Real_Estate_Applications_Reverse_Engineering.pptx\`.\n\n## Contents\n\n`;
  C.APPS.forEach((n, i) => (out += `${i + 1}. [${n}](#${i + 1}-${n.toLowerCase().replace(/[^a-z0-9]+/g, "-")})\n`));
  C.KEYS.forEach((k, i) => {
    const md = fs.readFileSync(path.join(RES, `${k}.md`), "utf8");
    let p = section(md, 6), a = section(md, 7);
    p = p.replace(/^## 6\.[^\n]*\n/, ""); a = a.replace(/^## 7\.[^\n]*\n/, "");
    p = p.replace(/^### /gm, "#### ").replace(/^## /gm, "### ");
    out += `\n---\n\n## ${i + 1}. ${C.APPS[i]}\n\n### Business processes\n${p.trim()}\n\n### Automation in these processes\n${a.trim()}\n`;
  });
  return out;
}
function sourcesDoc() {
  const { parseSources } = { parseSources: require("./parse-sources") };
  let out = `# Research sources and references\n\nAll sources used for the eight applications, with links and access dates. Accessed 12 November 2026 unless stated. Ids match the citations in the deck, the workbooks and \`Application_Process_Flows.md\`.\n\n## How to read this\n\n- **Vendor site / help / AppExchange / release notes**: primary evidence (Verified).\n- **Snippet**: the page returned HTTP 403 to direct fetches (G2, Capterra, some vendor sites); the fact comes from a search-engine snippet of that page.\n- **Third party**: directories, press and competitor pages; used for context and marked as such.\n- Screenshots and demo videos are linked, not copied.\n\n## Research limitations\n\n- No product was installed; internals are known only where vendors publish names.\n- Help content for some products is old (Propertybase 2017–2021, Real Properties 2008–2019).\n- Picklist and stage values are vendor defaults or examples and may differ in customer orgs.\n- Real Properties was identified as the only exact-name AppExchange match (Real Intelligence, Inc.); its functional detail is thin.\n`;
  C.KEYS.forEach((k, i) => {
    const md = fs.readFileSync(path.join(RES, `${k}.md`), "utf8");
    const rows = parseSources(md);
    out += `\n## ${i + 1}. ${C.APPS[i]}\n\n| Id | Title | URL | Type | Accessed |\n|---|---|---|---|---|\n`;
    rows.forEach((r) => (out += `| ${r.id} | ${r.title.replace(/\|/g, "/")} | ${r.urlRaw.replace(/\|/g, "/")} | ${r.type} | ${r.accessed || "2026-11-12"} |\n`));
    if (k === "ascendixre") out += `\nThe AscendixRE ids not listed above (H-*, S-*) come from the earlier research pass and are listed with URLs in \`docs/research/AscendixRE_Public_Research_Notes.md\`.\n`;
  });
  return out;
}

(async () => {
  await comparison();
  await objects();
  fs.writeFileSync(path.join(OUT, "Application_Process_Flows.md"), processDoc());
  fs.writeFileSync(path.join(OUT, "Research_Sources_and_References.md"), sourcesDoc());
  console.log("docs written");
})();
