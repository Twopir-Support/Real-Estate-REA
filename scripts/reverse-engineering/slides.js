// Per-application chapter renderers. Each takes (pres, app) and the shared toolkit.
const L = require("./lib");
const { P, W, txt, rect, badge, seg, poly, legend, laneLabel, sourceLine, textH, check } = L;

function srcLine(s, app, ids) {
  const list = (ids || []).map((id) => `[${id}]`).join(" ");
  sourceLine(s, `Sources: ${list || "see Sources section"} · ${app.name} · public material only, accessed 2026-11-12`);
}

// 1. Chapter divider with identity facts
function divider(pres, app, idx) {
  const s = L.dividerSlide(pres, app.name, `2.${idx}  ${app.name}`, app.tagline);
  const facts = app.facts; // [[label, value, ev]]
  const n = facts.length; const gw = 0.2; const cw = (11.7 - gw * (n - 1)) / n;
  facts.forEach(([k, v, ev], i) => {
    const x = 0.8 + i * (cw + gw), y = 4.35;
    rect(s, x, y, cw, 1.55, { fill: "24384B", line: "3A5268" });
    txt(s, k.toUpperCase(), { x: x + 0.14, y: y + 0.12, w: cw - 0.5, h: 0.2, fontSize: 9, bold: true, color: "F2A27A", charSpacing: 1 });
    badge(s, x + cw - 0.32, y + 0.12, ev);
    txt(s, v, { x: x + 0.14, y: y + 0.4, w: cw - 0.28, h: 1.08, fontSize: 12, color: P.white });
    check(`divider fact ${k}`, textH(v, cw - 0.28, 12), 1.08);
  });
  if (app.statusWarn) {
    rect(s, 0.8, 6.15, 11.7, 0.5, { fill: P.orange, line: null });
    txt(s, app.statusWarn, { x: 0.95, y: 6.15, w: 11.4, h: 0.5, fontSize: 12, bold: true, color: P.white, valign: "middle" });
  }
  return s;
}

// 2. Overview: 12 questions in a grid
function overview(pres, app) {
  const s = L.contentSlide(pres, app.name, `${app.name}: application overview`, "The twelve overview questions, answered from public sources only", "overview");
  const items = app.overview; const cols = 4, rows = Math.ceil(items.length / cols);
  const gx = 0.18, gy = 0.16, x0 = 0.35, y0 = 1.12, cw = (W - 0.7 - gx * (cols - 1)) / cols, ch = (5.85 - gy * (rows - 1)) / rows;
  items.forEach((it, i) => {
    const x = x0 + (i % cols) * (cw + gx), y = y0 + Math.floor(i / cols) * (ch + gy);
    rect(s, x, y, cw, ch, { fill: P.white, line: P.line });
    L.numDot(s, x + 0.1, y + 0.1, i + 1);
    txt(s, it.q, { x: x + 0.4, y: y + 0.1, w: cw - 0.75, h: 0.24, fontSize: 10, bold: true, color: P.navy });
    badge(s, x + cw - 0.3, y + 0.11, it.ev);
    txt(s, it.a, { x: x + 0.12, y: y + 0.42, w: cw - 0.24, h: ch - 0.48, fontSize: 11.5, color: P.text });
    check(`overview ${it.q}`, textH(it.a, cw - 0.24, 11.5), ch - 0.48);
  });
  legend(s, 0.35, 7.13); srcLine2(s, app, app.overviewSrc);
  return s;
}
function srcLine2(s, app, ids) {
  if (!ids || !ids.length) return; txt(s, `Sources: ${(ids || []).map((i) => `[${i}]`).join(" ")}`, { x: 5.45, y: 7.13, w: 6.95, h: 0.2, fontSize: 8, color: P.muted }); }

// 3. Overall application architecture: users → experience → logic → data → external
function architecture(pres, app) {
  const a = app.arch;
  const s = L.contentSlide(pres, app.name, `${app.name}: overall application architecture`, a.sub || "Who uses it, which layer does what, and what it connects to", a.tag || "verified + inferred");
  const x0 = 0.35, y0 = 1.12; const uw = 1.85, xw = 2.25, gap = 0.3; const cx = x0 + uw + gap, cw = W - 0.7 - uw - xw - 2 * gap;
  // users column
  txt(s, "USERS", { x: x0, y: y0, w: uw, h: 0.2, fontSize: 9, bold: true, color: P.orange, charSpacing: 1 });
  let uy = y0 + 0.26;
  for (const u of a.users) {
    const h = Math.max(0.5, textH(u.d || "", uw - 0.16, 8.5) + 0.32);
    rect(s, x0, uy, uw, h, { fill: P.white, line: P.orange, lw: 1 });
    txt(s, u.n, { x: x0 + 0.08, y: uy + 0.05, w: uw - 0.16, h: 0.2, fontSize: 9.5, bold: true });
    if (u.d) txt(s, u.d, { x: x0 + 0.08, y: uy + 0.26, w: uw - 0.16, h: h - 0.28, fontSize: 8.5, color: P.muted });
    uy += h + 0.12;
  }
  check("arch users", uy - y0, 5.75);
  // layers
  const layers = a.layers; const lg = 0.14; const lh = (5.72 - lg * (layers.length - 1)) / layers.length;
  layers.forEach((ly, i) => {
    const y = y0 + i * (lh + lg);
    rect(s, cx, y, cw, lh, { fill: i % 2 ? P.beige : P.blue, line: null });
    txt(s, ly.name.toUpperCase(), { x: cx + 0.1, y: y + 0.06, w: 1.45, h: lh - 0.12, fontSize: 9, bold: true, color: P.navy, valign: "middle", charSpacing: 0.5 });
    // chips flow
    let px = cx + 1.6, py = y + 0.1; const right = cx + cw - 0.1; const chH = 0.32;
    for (const it of ly.items) {
      const w = Math.min(right - cx - 1.6, Math.max(1.2, it.n.length * 0.068 + 0.42));
      if (px + w > right) { px = cx + 1.6; py += chH + 0.07; }
      rect(s, px, py, w, chH, { fill: it.dark ? P.navy2 : P.white, line: it.dark ? null : P.line });
      txt(s, it.n, { x: px + 0.07, y: py, w: w - 0.32, h: chH, fontSize: 8.5, color: it.dark ? P.white : P.text, valign: "middle" });
      badge(s, px + w - 0.25, py + 0.075, it.ev);
      px += w + 0.08;
    }
    check(`layer ${ly.name}`, py + chH - y + 0.05, lh);
  });
  // external column
  const ex = cx + cw + gap;
  txt(s, "EXTERNAL SYSTEMS", { x: ex, y: y0, w: xw, h: 0.2, fontSize: 9, bold: true, color: P.orange, charSpacing: 1 });
  let ey = y0 + 0.26;
  for (const e of a.external) {
    const th = textH(e.n, xw - 0.4, 9.5, true);
    const h = Math.max(0.42, textH(e.d || "", xw - 0.16, 8.5) + th + 0.12);
    rect(s, ex, ey, xw, h, { fill: P.white, line: P.blueEv, lw: 1, dash: e.ev === "I" || e.ev === "U" ? "dash" : "solid" });
    txt(s, e.n, { x: ex + 0.08, y: ey + 0.05, w: xw - 0.4, h: th, fontSize: 9.5, bold: true });
    badge(s, ex + xw - 0.27, ey + 0.06, e.ev);
    if (e.d) txt(s, e.d, { x: ex + 0.08, y: ey + 0.06 + th, w: xw - 0.16, h: h - th - 0.08, fontSize: 8.5, color: P.muted });
    ey += h + 0.1;
  }
  check("arch external", ey - y0, 5.75);
  // connectors
  seg(s, x0 + uw, y0 + 0.6, cx, y0 + 0.6, { end: "triangle", color: P.orange, width: 1.25 });
  const dataY = y0 + (layers.length - 1) * (lh + lg) + lh / 2;
  seg(s, cx + cw, y0 + 0.6, ex, y0 + 0.6, { end: "triangle", begin: "triangle", color: P.blueEv, width: 1.25 });
  if (a.note) { /* note shown in subtitle tag */ }
  legend(s, 0.35, 7.13); srcLine2(s, app, a.src);
  return s;
}

// 4. Functional modules: reuse process layout, modules as blocks per lane
function modules(pres, app) {
  const m = app.modules;
  const s = L.contentSlide(pres, app.name, `${app.name}: functional module architecture`, m.sub, m.tag || "modules");
  L.drawProcess(s, { sections: m.sections, links: m.links, noAuto: true });
  legend(s, 0.35, 7.13); srcLine2(s, app, m.src);
  return s;
}

// 5. Object inventory table
function objects(pres, app) {
  const rows = app.objects; const per = 13; const pages = Math.ceil(rows.length / per);
  for (let p = 0; p < pages; p++) {
    const s = L.contentSlide(pres, app.name, `${app.name}: Salesforce object architecture${pages > 1 ? ` (${p + 1}/${pages})` : ""}`, app.objectsSub || "Objects named in public material. API names are shown only where the vendor publishes them", "data model");
    const slice = rows.slice(p * per, (p + 1) * per).map((r) => [
      { text: r[0], options: { bold: true } }, { text: r[1] || "Unknown", options: { italic: !r[1] || /^Proposed/.test(r[1]), color: !r[1] ? P.grey : P.text } }, r[2], r[3], r[4] || "", L.evCell(r[5] || "U"),
    ]);
    L.table(s, ["Object", "API name", "Type", "Purpose", "Key fields / relationships", "Ev."], slice, { colW: [1.75, 2.45, 1.05, 3.25, 3.84, 0.29], fontSize: slice.length <= 8 ? 11 : 9, rowH: slice.length <= 8 ? 0.55 : undefined, maxH: 5.9 });
    legend(s, 0.35, 7.13); srcLine2(s, app, app.objectsSrc);
  }
}

// 6. ERD
function erd(pres, app, e, i) {
  const s = L.contentSlide(pres, app.name, `${app.name}: ${e.title || "object relationship diagram (ERD)"}`, e.sub, e.tag || "documented vs inferred");
  L.drawERD(s, e);
  L.erdLegend(s, 0.35, 7.13);
  if (e.src) txt(s, e.src.map((x) => `[${x}]`).join(" "), { x: 9.5, y: 7.14, w: 2.95, h: 0.2, fontSize: 6.5, color: P.muted, align: "right" });
  return s;
}

// 7. Process
function process(pres, app, pr) {
  const s = L.contentSlide(pres, app.name, pr.title, pr.sub, pr.tag || "as documented");
  if (pr.notes && pr.notes.length) pr.compact = true;
  L.drawProcess(s, pr, pr.area);
  if (pr.notes && pr.notes.length) callouts(s, pr.notes, pr._bottom + 0.2);
  legend(s, 0.35, 7.13); srcLine2(s, app, pr.src);
  return s;
}

function callouts(s, notes, y0) {
  const n = notes.length, g = 0.25, cw = (W - 0.7 - g * (n - 1)) / n; const h = 6.98 - y0;
  notes.forEach((nt, i) => {
    const x = 0.35 + i * (cw + g);
    const need = 0.42 + textH(nt.d, cw - 0.3, 10);
    const bh = Math.min(h, Math.max(need + 0.1, 0.9));
    rect(s, x, y0, cw, bh, { fill: P.peach, line: P.orange, dash: "sysDot", lw: 0.75 });
    txt(s, nt.h.toUpperCase(), { x: x + 0.15, y: y0 + 0.1, w: cw - 0.55, h: 0.22, fontSize: 9, bold: true, color: P.orange, charSpacing: 0.5 });
    badge(s, x + cw - 0.32, y0 + 0.1, nt.ev);
    txt(s, nt.d, { x: x + 0.15, y: y0 + 0.36, w: cw - 0.3, h: bh - 0.42, fontSize: 10, color: P.text });
    check("callout " + nt.h, need, h);
  });
}

// 8. Automation table
function automation(pres, app) {
  const s = L.contentSlide(pres, app.name, `${app.name}: automation inventory`, "What runs automatically, what starts it and the likely technology. Names are unknown unless stated", "automation");
  const rows = app.automation.map((r) => [{ text: r[0], options: { bold: true } }, r[1], r[2], r[3], r[4], r[5], L.evCell(r[6])]);
  L.table(s, ["Automation", "Trigger", "Object", "Action", "Outcome", "Likely technology (our inference)", "Ev."], rows, { colW: [2.2, 1.85, 1.45, 2.55, 2.0, 2.3, 0.28], fontSize: 9, maxH: 5.9 });
  legend(s, 0.35, 7.13); srcLine2(s, app, app.automationSrc);
  return s;
}

// 9. Integration hub
function integrations(pres, app) {
  const s = L.contentSlide(pres, app.name, `${app.name}: automation and integration flow`, app.intSub || "External systems around the core, with direction of data flow and what moves", "integrations");
  const ints = app.integrations; const cxw = 3.0, cxh = 2.0; const cx = (W - cxw) / 2, cy = 1.12 + (5.75 - cxh) / 2;
  rect(s, cx, cy, cxw, cxh, { fill: P.navy2, line: null });
  const cth = textH(app.coreName || app.name, cxw - 0.3, 12, true);
  txt(s, app.coreName || app.name, { x: cx + 0.15, y: cy + 0.12, w: cxw - 0.3, h: cth, fontSize: 12, bold: true, color: P.white });
  txt(s, app.coreText || "", { x: cx + 0.15, y: cy + 0.2 + cth, w: cxw - 0.3, h: cxh - 0.3 - cth, fontSize: 10, color: "DCE4EA" });
  check("int core", textH(app.coreText || "", cxw - 0.3, 10) + cth, cxh - 0.3);
  const left = ints.filter((_, i) => i % 2 === 0), right = ints.filter((_, i) => i % 2 === 1);
  const bw = 3.55, gapY = 0.12;
  [[left, 0.35, true], [right, W - 0.35 - bw, false]].forEach(([arr, x, isLeft]) => {
    const hs = arr.map((it) => Math.max(0.62, textH(it.data, bw - 0.16, 8.5) + textH(it.purpose, bw - 0.16, 8.5) + 0.34));
    const tot = hs.reduce((a, b) => a + b, 0) + gapY * (arr.length - 1); let y = 1.12 + Math.max(0, (5.75 - tot) / 2);
    check("int column", tot, 5.75);
    arr.forEach((it, i) => {
      const h = hs[i];
      rect(s, x, y, bw, h, { fill: P.white, line: P.blueEv, lw: 1, dash: it.ev === "I" || it.ev === "U" ? "dash" : "solid" });
      txt(s, it.sys, { x: x + 0.08, y: y + 0.05, w: bw - 0.75, h: 0.22, fontSize: 10, bold: true, color: P.navy });
      txt(s, it.dir, { x: x + bw - 0.62, y: y + 0.06, w: 0.32, h: 0.2, fontSize: 9, bold: true, color: P.orange, align: "center" });
      badge(s, x + bw - 0.27, y + 0.07, it.ev);
      const ph = textH(it.purpose, bw - 0.16, 8.5);
      txt(s, it.purpose, { x: x + 0.08, y: y + 0.28, w: bw - 0.16, h: ph, fontSize: 8.5, color: P.text });
      txt(s, it.data, { x: x + 0.08, y: y + 0.3 + ph, w: bw - 0.16, h: h - ph - 0.32, fontSize: 8.5, color: P.muted, italic: true });
      const my = y + h / 2; const ty = Math.min(Math.max(my, cy + 0.15), cy + cxh - 0.15);
      const sx = isLeft ? x + bw : x, ex = isLeft ? cx : cx + cxw; const mx = (sx + ex) / 2;
      const inbound = it.dir === "→" ? true : it.dir === "←" ? false : null;
      const o = { color: it.ev === "I" || it.ev === "U" ? P.slateLt : P.blueEv, width: 1, dash: it.ev === "I" || it.ev === "U" ? "dash" : "solid" };
      const pts = [[sx, my], [mx, my], [mx, ty], [ex, ty]];
      if (inbound === true || inbound === null) poly(s, pts, { ...o, end: "triangle", begin: inbound === null ? "triangle" : undefined });
      else poly(s, pts.slice().reverse(), { ...o, end: "triangle" });
      y += h + gapY;
    });
  });
  txt(s, "→ into Salesforce   ← out of Salesforce   ↔ both ways   (direction as seen from the Salesforce org)", { x: 5.45, y: 7.13, w: 6.5, h: 0.2, fontSize: 8, color: P.muted });
  legend(s, 0.35, 7.13);
  return s;
}

// 10. UI flow
function ui(pres, app) {
  const u = app.ui;
  const s = L.contentSlide(pres, app.name, `${app.name}: user interaction flow`, u.sub || "Screen by screen: what the user does and which record it writes", u.tag || "UI");
  const pr = { sections: u.sections, links: u.links, compact: !!(u.notes && u.notes.length) };
  L.drawProcess(s, pr);
  if (pr.compact) callouts(s, u.notes, pr._bottom + 0.2);
  legend(s, 0.35, 7.13); srcLine2(s, app, u.src);
  return s;
}

// 11. Reporting + limitations
function reportsLimits(pres, app) {
  const s = L.contentSlide(pres, app.name, `${app.name}: reporting, limitations and rebuild difficulty`, "What it measures, where it falls short, and what would be hard to recreate in a new org", "assessment");
  const cols = [["Reports and dashboards", app.reports, P.blue], ["Limitations", app.limits, P.beige], ["Hard to recreate", app.hard, P.peach]];
  const gw = 0.25, cw = (W - 0.7 - gw * 2) / 3;
  cols.forEach(([h, arr, fill], i) => {
    const x = 0.35 + i * (cw + gw), y = 1.12;
    rect(s, x, y, cw, 5.75, { fill, line: null });
    txt(s, h.toUpperCase(), { x: x + 0.15, y: y + 0.12, w: cw - 0.3, h: 0.24, fontSize: 10, bold: true, color: P.navy, charSpacing: 1 });
    let cy = y + 0.48;
    for (const it of arr || []) {
      const dh = textH(it.d, cw - 0.5, 10.5);
      const bh = dh + 0.4;
      rect(s, x + 0.12, cy, cw - 0.24, bh, { fill: P.white, line: null });
      txt(s, it.n, { x: x + 0.22, y: cy + 0.06, w: cw - 0.75, h: 0.24, fontSize: 11, bold: true });
      badge(s, x + cw - 0.4, cy + 0.06, it.ev);
      txt(s, it.d, { x: x + 0.22, y: cy + 0.32, w: cw - 0.44, h: dh, fontSize: 10.5, color: P.muted });
      cy += bh + 0.1;
    }
    check(`col ${h}`, cy - y, 5.75);
  });
  legend(s, 0.35, 7.13); srcLine2(s, app, app.reportsSrc);
  return s;
}

function chapter(pres, app, idx) {
  pres.addSection({ title: app.name });
  divider(pres, app, idx);
  overview(pres, app);
  architecture(pres, app);
  modules(pres, app);
  objects(pres, app);
  (app.erds || [app.erd]).forEach((e, i) => erd(pres, app, e, i));
  for (const pr of app.processes) process(pres, app, pr);
  automation(pres, app);
  integrations(pres, app);
  ui(pres, app);
  reportsLimits(pres, app);
}

module.exports = { chapter, divider, overview, architecture, modules, objects, erd, process, automation, integrations, ui, reportsLimits };
