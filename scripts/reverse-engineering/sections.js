// Renderers for the executive, comparison, proposed-architecture, roadmap and sources sections.
const L = require("./lib");
const { P, W, txt, rect, badge, seg, poly, legend, laneLabel, sourceLine, textH, check } = L;

function cover(pres, d) {
  const s = L.dividerSlide(pres, d.section, d.title, d.sub);
  txt(s, d.meta, { x: 0.8, y: 4.2, w: 11.5, h: 0.9, fontSize: 13, color: "C9D3DC" });
  // eight app chips
  const n = d.apps.length, g = 0.15, cw = (11.7 - g * (n - 1)) / n;
  d.apps.forEach((a, i) => {
    const x = 0.8 + i * (cw + g);
    rect(s, x, 5.45, cw, 0.95, { fill: "24384B", line: "3A5268" });
    txt(s, a.n, { x: x + 0.08, y: 5.52, w: cw - 0.16, h: 0.42, fontSize: 11, bold: true, color: P.white });
    txt(s, a.t, { x: x + 0.08, y: 5.95, w: cw - 0.16, h: 0.4, fontSize: 9, color: "F2A27A" });
  });
  return s;
}

// generic card grid: items [{h, d, ev, tag}]
function cards(s, items, o = {}) {
  const cols = o.cols || 3, x0 = o.x || 0.35, y0 = o.y || 1.12, w = o.w || W - 0.7, h = o.h || 5.85;
  const rows = Math.ceil(items.length / cols), gx = 0.2, gy = 0.18;
  const cw = (w - gx * (cols - 1)) / cols, ch = (h - gy * (rows - 1)) / rows; const fs = o.fs || 11;
  items.forEach((it, i) => {
    const x = x0 + (i % cols) * (cw + gx), y = y0 + Math.floor(i / cols) * (ch + gy);
    rect(s, x, y, cw, ch, { fill: it.fill || P.white, line: it.line || P.line, dash: it.dash });
    let ty = y + 0.12;
    if (it.tag) { txt(s, it.tag.toUpperCase(), { x: x + 0.14, y: ty, w: cw - 0.5, h: 0.18, fontSize: 8.5, bold: true, color: P.orange, charSpacing: 0.5 }); ty += 0.2; }
    const hh = textH(it.h, cw - 0.55, 12, true);
    txt(s, it.h, { x: x + 0.14, y: ty, w: cw - 0.55, h: hh, fontSize: 12, bold: true, color: P.navy });
    if (it.ev) badge(s, x + cw - 0.32, y + 0.12, it.ev);
    const dy = ty + hh + 0.06;
    txt(s, it.d, { x: x + 0.14, y: dy, w: cw - 0.28, h: y + ch - dy - 0.08, fontSize: fs, color: P.text });
    check("card " + it.h, dy - y + textH(it.d, cw - 0.28, fs), ch);
  });
}

// matrix with symbol cells. rows: [label, ...cells] cell codes F P N U or text
const SYM = { F: { t: "●", c: P.green, n: "Fully supported" }, P: { t: "◐", c: P.amber, n: "Partially supported" }, N: { t: "○", c: P.red, n: "Not supported" }, U: { t: "?", c: P.grey, n: "Not publicly verified" } };
function matrix(s, header, rows, o = {}) {
  const fs = o.fontSize || 9.5;
  const data = rows.map((r, i) => r.map((c, j) => {
    if (j === 0) return { text: c, options: { bold: true } };
    const sy = SYM[c];
    if (sy) return { text: sy.t, options: { color: sy.c, align: "center", fontSize: 16, bold: true, valign: "middle" } };
    return { text: c, options: { fontSize: fs } };
  }));
  L.table(s, header, data, { colW: o.colW, fontSize: fs, y: o.y || 1.12, maxH: o.maxH || 5.85, rowH: o.rowH });
}
function symLegend(s, x, y) {
  let cx = x;
  for (const k of ["F", "P", "N", "U"]) {
    txt(s, SYM[k].t, { x: cx, y: y - 0.03, w: 0.2, h: 0.22, fontSize: 12, bold: true, color: SYM[k].c });
    txt(s, SYM[k].n, { x: cx + 0.22, y, w: 1.6, h: 0.18, fontSize: 8.5, color: P.muted }); cx += 1.75;
  }
}

// ratings chart + table
function ratings(pres, sec, d) {
  const s = L.contentSlide(pres, sec, "Ratings and reviews: supplied vs verified", "Supplied values kept as given. Verified values were checked on 12 Nov 2026 and are shown beside them, never in place of them", "verified 2026-11-12");
  const labels = d.map((r) => r.app);
  s.addChart("bar", [
    { name: "Supplied rating", labels, values: d.map((r) => r.sup || 0) },
    { name: "Verified, same platform", labels, values: d.map((r) => r.ver || 0) },
    { name: "AppExchange", labels, values: d.map((r) => r.ax || 0) },
  ], {
    x: 0.35, y: 1.12, w: 5.6, h: 5.85, barDir: "bar", barGrouping: "clustered", chartColors: [P.slateLt, P.navy2, P.orange],
    valAxisMinVal: 0, valAxisMaxVal: 5.5, valAxisMajorUnit: 1, catAxisLabelFontSize: 9, valAxisLabelFontSize: 8, catAxisLabelFontFace: "+mn-lt", valAxisLabelFontFace: "+mn-lt",
    catAxisLabelColor: P.text, valAxisLabelColor: P.muted, valGridLine: { color: "D9D4C7", size: 0.5 }, catGridLine: { style: "none" }, catAxisOrientation: "maxMin",
    showValue: true, dataLabelFontSize: 7.5, dataLabelColor: P.text, dataLabelPosition: "outEnd", dataLabelFormatCode: "0.0#;;;", dataLabelFontFace: "+mn-lt",
    showLegend: true, legendPos: "b", legendFontSize: 8.5, legendFontFace: "+mn-lt", showTitle: true, title: "Rating out of 5 (0 = none found)", titleFontSize: 10, titleColor: P.navy, titleFontFace: "+mn-lt",
  });
  const rows = d.map((r) => [{ text: r.app, options: { bold: true } }, r.supplied, r.verified, r.other, r.note]);
  L.table(s, ["Application", "Supplied", "Verified (same platform)", "Other platforms", "Note"], rows, { x: 6.15, w: 6.83, colW: [1.25, 1.05, 1.45, 1.55, 1.53], fontSize: 8.5, maxH: 5.85 });
  rect(s, 6.15, 4.75, 6.83, 2.1, { fill: P.peach, line: P.orange, dash: "sysDot" });
  txt(s, "WHAT DIFFERS FROM THE SUPPLIED TABLE", { x: 6.3, y: 4.85, w: 6.5, h: 0.22, fontSize: 9, bold: true, color: P.orange, charSpacing: 0.5 });
  txt(s, "All six supplied ratings match the same platform today. One review count differs: Left Main shows 8–10 G2 reviews, not 12. Real Properties and Booker25 now have verifiable ratings, on AppExchange (5.00 from 2; 4.96 from 57). AppExchange scores run higher than G2 and Capterra for every product listed there.", { x: 6.3, y: 5.12, w: 6.55, h: 1.65, fontSize: 10.5, color: P.text });
  sourceLine(s, "Sources: G2, Capterra and AppExchange listing pages; G2 and Capterra returned HTTP 403, so their values come from search-engine snippets of those pages");
  return s;
}

// horizontal timeline / roadmap: phases [{n, when, items[], tone}]
function roadmap(s, phases, o = {}) {
  const x0 = 0.35, y0 = o.y || 1.12, w = W - 0.7, n = phases.length, g = 0.18; const cw = (w - g * (n - 1)) / n; const h = o.h || 5.8;
  phases.forEach((p, i) => {
    const x = x0 + i * (cw + g);
    s.addShape("chevron", { x, y: y0, w: cw + 0.1, h: 0.62, fill: { color: p.tone || [P.navy, P.navy2, P.slate, P.orange, P.green, P.blueEv][i % 6] }, line: { type: "none" } });
    txt(s, p.n, { x: x + 0.25, y: y0 + 0.04, w: cw - 0.4, h: 0.32, fontSize: 11, bold: true, color: P.white, valign: "middle" });
    txt(s, p.when, { x: x + 0.25, y: y0 + 0.34, w: cw - 0.4, h: 0.22, fontSize: 8.5, color: "E3E8EC" });
    rect(s, x, y0 + 0.75, cw, h - 0.75, { fill: P.white, line: P.line });
    let cy = y0 + 0.85;
    for (const it of p.items) {
      const th = textH(it, cw - 0.3, 9.5);
      s.addShape("ellipse", { x: x + 0.1, y: cy + 0.06, w: 0.07, h: 0.07, fill: { color: P.orange }, line: { type: "none" } });
      txt(s, it, { x: x + 0.22, y: cy, w: cw - 0.3, h: th, fontSize: 9.5, color: P.text });
      cy += th + 0.07;
    }
    check("phase " + p.n, cy - y0, h);
  });
}

module.exports = { cover, cards, matrix, symLegend, ratings, roadmap, SYM };
