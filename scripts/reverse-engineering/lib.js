// Diagram + slide toolkit modelled on the "Proposed Architecture" reference deck:
// navy title bar, cream canvas, white process blocks, navy automation blocks,
// slate status chips, orange step numbers, dotted callouts, coloured lane labels.
const pptxgen = require("pptxgenjs");

const W = 13.333, H = 7.5;
const P = {
  navy: "1B2A3A", navy2: "2C4257", cream: "F4F1EA", beige: "E7E0CF", blue: "D6E2EC", blueDeep: "AFC6D8",
  orange: "E2601F", orangeLt: "F6C9B0", peach: "FCEBE1", slate: "5E6A73", slateLt: "8B959D",
  white: "FFFFFF", text: "1E2933", muted: "5F6B75", line: "9AA4AC", grid: "D9D4C7",
  green: "2E7D4F", greenLt: "DCEFE3", blueEv: "2F6EA5", amber: "B9801A", amberLt: "FBEFD6", grey: "8A9096", red: "B23A2E",
};
const EV = {
  V: { name: "Verified", color: P.green }, O: { name: "Observed", color: P.blueEv },
  I: { name: "Inferred", color: P.amber }, U: { name: "Unknown", color: P.grey }, P: { name: "Proposed", color: P.orange },
};
const FONT = "Calibri";
const warnings = [];
let curSlideNo = 0;

// ---------- text fitting (Calibri ~0.5em average glyph width, bold ~0.53) ----------
function linesFor(text, wIn, pt, bold) {
  const cpl = Math.max(4, Math.floor((wIn * 72) / (pt * (bold ? 0.48 : 0.455))));
  let n = 0;
  for (const para of String(text).split("\n")) {
    const words = para.split(/\s+/); let line = 0; let ln = 1;
    for (const w of words) {
      const L = w.length + (line ? 1 : 0);
      if (line + L > cpl && line > 0) { ln++; line = w.length; } else line += L;
      while (line > cpl) { ln++; line -= cpl; }
    }
    n += ln;
  }
  return n;
}
const lh = (pt) => (pt * 1.2) / 72;
function textH(text, wIn, pt, bold) { return linesFor(text, wIn, pt, bold) * lh(pt); }
function check(name, needH, haveH) {
  if (needH > haveH + 0.02) warnings.push(`slide ${curSlideNo}: "${String(name).slice(0, 50)}" needs ${needH.toFixed(2)}in, has ${haveH.toFixed(2)}in`);
}

// ---------- deck ----------
function createDeck() {
  const pres = new pptxgen();
  pres.layout = "LAYOUT_WIDE";
  pres.author = "Twopir Consulting";
  pres.company = "Twopir Consulting";
  pres.title = "Real Estate Applications on Salesforce: Reverse Engineering";
  pres.theme = { headFontFace: FONT, bodyFontFace: FONT };
  pres.defineSlideMaster({
    title: "CONTENT", background: { color: P.cream },
    objects: [
      { rect: { x: 0, y: 0, w: W, h: 0.92, fill: { color: P.navy } } },
      { placeholder: { options: { name: "title", type: "title", x: 0.35, y: 0.1, w: 10.6, h: 0.46, fontSize: 22, bold: true, color: P.white, fontFace: FONT, valign: "middle", align: "left", margin: 0 }, text: "" } },
      { placeholder: { options: { name: "sub", type: "body", x: 0.35, y: 0.55, w: 10.6, h: 0.3, fontSize: 11, color: "C9D3DC", fontFace: FONT, valign: "middle", margin: 0 }, text: "" } },
    ],
    slideNumber: { x: 12.55, y: 7.12, w: 0.5, h: 0.25, fontSize: 9, color: P.muted, fontFace: FONT, align: "right" },
  });
  pres.defineSlideMaster({
    title: "DIVIDER", background: { color: P.navy },
    objects: [
      { placeholder: { options: { name: "title", type: "title", x: 0.8, y: 2.3, w: 11.5, h: 1.0, fontSize: 40, bold: true, color: P.white, fontFace: FONT, align: "left", margin: 0 }, text: "" } },
      { placeholder: { options: { name: "sub", type: "body", x: 0.8, y: 3.35, w: 11.5, h: 0.6, fontSize: 16, color: "C9D3DC", fontFace: FONT, margin: 0 }, text: "" } },
    ],
    slideNumber: { x: 12.55, y: 7.12, w: 0.5, h: 0.25, fontSize: 9, color: "8FA0B0", fontFace: FONT, align: "right" },
  });
  return pres;
}

function contentSlide(pres, section, title, sub, tag) {
  const s = pres.addSlide({ masterName: "CONTENT", sectionTitle: section });
  curSlideNo++;
  s.addText(title, { placeholder: "title" });
  s.addText(sub || " ", { placeholder: "sub" });
  if (tag) s.addText(tag, { x: 11.05, y: 0.32, w: 1.95, h: 0.28, fontSize: 9, color: "C9D3DC", align: "right", fontFace: FONT, margin: 0, isTextBox: true });
  check(title, textH(title, 10.6, 22, true), 0.46);
  return s;
}
function dividerSlide(pres, section, title, sub) {
  const s = pres.addSlide({ masterName: "DIVIDER", sectionTitle: section });
  curSlideNo++;
  s.addText(title, { placeholder: "title" });
  s.addText(sub || " ", { placeholder: "sub" });
  return s;
}

// ---------- primitives ----------
function txt(s, text, o) {
  const opt = Object.assign({ fontFace: FONT, fontSize: 10, color: P.text, margin: 0, valign: "top", isTextBox: true, fit: "none" }, o);
  s.addText(text, opt);
}
function rect(s, x, y, w, h, o = {}) {
  s.addShape(o.round ? "roundRect" : "rect", {
    x, y, w, h, rectRadius: o.round ? 0.06 : undefined,
    fill: o.fill ? { color: o.fill, transparency: o.transparency || 0 } : { type: "none" },
    line: o.line === null ? { type: "none" } : { color: o.line || P.line, width: o.lw || 0.75, dashType: o.dash || "solid" },
  });
}
function badge(s, x, y, ev) {
  if (!ev || !EV[ev]) return;
  s.addShape("roundRect", { x, y, w: 0.2, h: 0.17, rectRadius: 0.03, fill: { color: EV[ev].color }, line: { color: "FFFFFF", width: 0.75 } });
  txt(s, ev, { x, y, w: 0.2, h: 0.17, fontSize: 8, bold: true, color: P.white, align: "center", valign: "middle" });
}
function numDot(s, x, y, n, color) {
  s.addShape("ellipse", { x, y, w: 0.22, h: 0.22, fill: { color: color || P.orange }, line: { type: "none" } });
  txt(s, String(n), { x, y, w: 0.22, h: 0.22, fontSize: 9, bold: true, color: P.white, align: "center", valign: "middle" });
}
function seg(s, x1, y1, x2, y2, o = {}) {
  const line = { color: o.color || P.slateLt, width: o.width || 1, dashType: o.dash || "solid" };
  if (o.end) line.endArrowType = o.end;
  if (o.begin) line.beginArrowType = o.begin;
  s.addShape("line", { x: Math.min(x1, x2), y: Math.min(y1, y2), w: Math.max(Math.abs(x2 - x1), 0.001), h: Math.max(Math.abs(y2 - y1), 0.001), flipH: x2 < x1, flipV: y2 < y1, line });
}
function poly(s, pts, o = {}) {
  for (let i = 0; i < pts.length - 1; i++) {
    const last = i === pts.length - 2, first = i === 0;
    seg(s, pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1], { ...o, end: last ? (o.end === undefined ? "triangle" : o.end) : undefined, begin: first ? o.begin : undefined });
  }
}
function legend(s, x, y, kinds) {
  // evidence legend as a compact row
  let cx = x;
  txt(s, "EVIDENCE", { x: cx, y: y + 0.01, w: 0.62, h: 0.17, fontSize: 8, bold: true, color: P.muted });
  cx += 0.62;
  for (const k of kinds || ["V", "O", "I", "U", "P"]) {
    badge(s, cx, y, k); txt(s, EV[k].name, { x: cx + 0.24, y: y + 0.01, w: 0.62, h: 0.17, fontSize: 8, color: P.muted }); cx += 0.86;
  }
}
function laneLabel(s, x, y, w, text, tone) {
  const fills = { beige: P.beige, blue: P.blue, orange: P.orange, navy: P.navy, slate: P.slate };
  const dark = tone === "orange" || tone === "navy" || tone === "slate";
  rect(s, x, y, w, 0.26, { fill: fills[tone] || P.beige, line: null });
  txt(s, text.toUpperCase(), { x, y, w, h: 0.26, fontSize: 9, bold: true, charSpacing: 1, color: dark ? P.white : P.navy, align: "center", valign: "middle" });
}
function sourceLine(s, text) {
  txt(s, text, { x: 0.35, y: 7.12, w: 11.9, h: 0.25, fontSize: 8, color: P.muted, valign: "middle" });
}

// ---------- process blocks ----------
// block: {id, kind:start|action|auto|status|gate|note|end, num, cap, title, items[], text, ev}
const CHIP_H = 0.21, CHIP_GAP = 0.045, PAD = 0.08;
function blockHeight(b, w) {
  const inner = w - 2 * PAD;
  const tIndent = b.num != null ? 0.3 : 0;
  let h = PAD;
  if (b.cap) h += 0.17;
  if (b.title) h += textH(b.title, inner - tIndent - (b.ev ? 0.24 : 0), b.kind === "note" ? 9 : 10, b.kind !== "note");
  if (b.text) h += 0.03 + textH(b.text, inner, 9, false);
  if (b.items && b.items.length) {
    h += 0.06;
    for (const it of b.items) h += chipH(it, inner) + CHIP_GAP;
  }
  return Math.max(h + PAD - (b.items && b.items.length ? CHIP_GAP : 0), 0.36);
}
function chipH(it, w) { const t = typeof it === "string" ? it : it.t; return Math.max(CHIP_H, textH(t, w - 0.12, 9, false) + 0.06); }
function drawBlock(s, b, x, y, w, h) {
  const k = b.kind || "action";
  const st = {
    start: { fill: P.white, line: P.orange, lw: 1.25 }, action: { fill: P.white, line: P.line },
    auto: { fill: P.navy2, line: null }, status: { fill: P.white, line: P.line },
    gate: { fill: P.white, line: P.orange, dash: "dash", lw: 1 }, note: { fill: P.peach, line: P.orange, dash: "sysDot", lw: 0.75 },
    end: { fill: P.white, line: P.navy, lw: 1.5 }, ok: { fill: P.greenLt, line: P.green, lw: 1 },
  }[k];
  rect(s, x, y, w, h, st);
  const dark = k === "auto";
  let cy = y + PAD; const inner = w - 2 * PAD;
  if (b.cap) {
    txt(s, b.cap.toUpperCase(), { x: x + PAD, y: cy, w: inner, h: 0.16, fontSize: 7.5, bold: true, color: P.orange, charSpacing: 0.5 });
    cy += 0.17;
  }
  if (b.title) {
    let tx = x + PAD;
    if (b.num != null) { numDot(s, tx, cy - 0.02, b.num, dark ? P.orange : P.orange); tx += 0.3; }
    const tw = x + w - PAD - tx - (b.ev ? 0.24 : 0);
    const fs = k === "note" ? 9 : 10;
    const th = textH(b.title, tw, fs, k !== "note");
    txt(s, b.title, { x: tx, y: cy, w: tw, h: th, fontSize: fs, bold: k !== "note", color: dark ? P.white : P.text });
    cy += th;
  }
  if (b.ev) badge(s, x + w - PAD - 0.2, y + PAD - 0.01, b.ev);
  if (b.text) {
    const th = textH(b.text, inner, 9, false);
    txt(s, b.text, { x: x + PAD, y: cy + 0.03, w: inner, h: th, fontSize: 9, color: dark ? "DCE4EA" : P.muted });
    cy += th + 0.03;
  }
  if (b.items && b.items.length) {
    cy += 0.06;
    for (const it of b.items) {
      const t = typeof it === "string" ? it : it.t; const ch = chipH(it, inner);
      const hl = typeof it === "object" && it.hl;
      rect(s, x + PAD, cy, inner, ch, { fill: hl ? P.orange : (dark ? "3E5870" : P.slate), line: null });
      txt(s, t, { x: x + PAD + 0.06, y: cy, w: inner - 0.12, h: ch, fontSize: 9, color: P.white, valign: "middle" });
      cy += ch + CHIP_GAP;
    }
  }
}

// process: {sections:[{label, tone, weight, cols:[[block...]]}], links:[[from,to,opts]], callouts}
function drawProcess(s, proc, area) {
  const A = Object.assign({ x: 0.35, y: 1.12, w: W - 0.7, h: 5.52 }, area);
  const gapS = 0.32, gapC = 0.2, gapB = 0.2;
  const totalW = proc.sections.reduce((a, sec) => a + (sec.weight || sec.cols.length), 0);
  const avail = A.w - gapS * (proc.sections.length - 1);
  const pos = {}; let sx = A.x; const autoLinks = []; let maxB = A.y; const crossLinks = [];
  proc.sections.forEach((sec, si) => {
    const sw = (avail * (sec.weight || sec.cols.length)) / totalW;
    const cw = (sw - gapC * (sec.cols.length - 1)) / sec.cols.length;
    sec.cols.forEach((col, ci) => {
      const cx = sx + ci * (cw + gapC); let cy = A.y + (col.offset || 0);
      const list = Array.isArray(col) ? col : col.blocks;
      list.forEach((b, bi) => {
        const bw = b.w ? b.w * cw : cw;
        const h = b.h || blockHeight(b, bw);
        pos[b.id || `${si}.${ci}.${bi}`] = { x: cx, y: cy, w: bw, h };
        b._p = pos[b.id || `${si}.${ci}.${bi}`];
        if (bi > 0 && !proc.noAuto && !b.noLink && b.kind !== "note" && !list[bi - 1].noNext) autoLinks.push([list[bi - 1]._p, b._p]);
        cy += h + (b.gapAfter != null ? b.gapAfter : gapB);
      });
      check(`process column ${si}.${ci}`, cy - gapB - A.y, A.h); maxB = Math.max(maxB, cy - gapB);
      if (ci > 0 && !proc.noAuto && !sec.noColLink) {
        const prev = (Array.isArray(sec.cols[ci - 1]) ? sec.cols[ci - 1] : sec.cols[ci - 1].blocks).filter((b) => b.kind !== "note" && !b.noNext);
        const first = list.find((b) => b.kind !== "note");
        const targeted = (proc.links || []).some((l) => first && l[1] === first.id);
        if (prev.length && first && !targeted && !first.noLink) crossLinks.push([prev[prev.length - 1], first]);
      }
    });
    // section divider + lane label
    sec._x = sx; sec._w = sw;
    sx += sw + gapS;
  });
  if (proc.compact) A.h = Math.max(maxB - A.y + 0.12, proc.minH || 2.5);
  proc._bottom = A.y + A.h + 0.32;
  proc.sections.forEach((sec, si) => {
    laneLabel(s, sec._x, A.y + A.h + 0.06, sec._w, sec.label, sec.tone || ["beige", "blue", "orange"][si % 3]);
    if (si < proc.sections.length - 1) seg(s, sec._x + sec._w + gapS / 2, A.y, sec._x + sec._w + gapS / 2, A.y + A.h, { color: P.grid, width: 0.75 });
  });
  // draw blocks
  proc.sections.forEach((sec) => sec.cols.forEach((col) => (Array.isArray(col) ? col : col.blocks).forEach((b) => drawBlock(s, b, b._p.x, b._p.y, b._p.w, b._p.h))));
  for (const [a, b] of autoLinks) seg(s, a.x + a.w / 2, a.y + a.h, b.x + a.w / 2 > b.x + b.w ? b.x + b.w / 2 : a.x + a.w / 2, b.y, { end: "triangle", color: P.slateLt });
  for (const L of proc.links || []) link(s, pos[L[0]], pos[L[1]], L[2] || {}, L);
  for (const [a, b] of crossLinks) link(s, a._p, b._p, {}, ["auto"]);
  return pos;
}
function link(s, a, b, o, L) {
  if (!a || !b) { warnings.push(`slide ${curSlideNo}: bad link ${L}`); return; }
  const col = o.color || P.slateLt, dash = o.dash;
  if (o.route === "down" || (Math.abs(a.x - b.x) < 0.05 && b.y > a.y)) {
    const x = o.ax != null ? o.ax : Math.max(a.x, b.x) + Math.min(a.w, b.w) / 2;
    return seg(s, x, a.y + a.h, x, b.y, { end: "triangle", color: col, dash });
  }
  if (o.route === "under") { // go down from a, across, down into b top
    const ya = o.y; const x1 = a.x + a.w / 2, x2 = b.x + b.w / 2;
    return poly(s, [[x1, a.y + a.h], [x1, ya], [x2, ya], [x2, b.y]], { color: col, dash });
  }
  if (o.route === "up") { const x1 = a.x + a.w / 2, x2 = b.x + b.w / 2, ya = o.y; return poly(s, [[x1, a.y], [x1, ya], [x2, ya], [x2, b.y + b.h]], { color: col, dash }); }
  if (b.x >= a.x + a.w - 0.01) { // rightwards
    const y1 = o.y1 != null ? o.y1 : a.y + Math.min(0.22, a.h / 2), y2 = o.y2 != null ? o.y2 : b.y + Math.min(0.22, b.h / 2);
    const mx = o.mx != null ? o.mx : (a.x + a.w + b.x) / 2;
    if (Math.abs(y1 - y2) < 0.01) return seg(s, a.x + a.w, y1, b.x, y2, { end: "triangle", color: col, dash });
    return poly(s, [[a.x + a.w, y1], [mx, y1], [mx, y2], [b.x, y2]], { color: col, dash });
  }
  if (b.x + b.w <= a.x + 0.01) { // leftwards
    const y1 = a.y + Math.min(0.22, a.h / 2), y2 = b.y + Math.min(0.22, b.h / 2); const mx = (b.x + b.w + a.x) / 2;
    return poly(s, [[a.x, y1], [mx, y1], [mx, y2], [b.x + b.w, y2]], { color: col, dash });
  }
  // overlapping columns: vertical
  const x = (Math.max(a.x, b.x) + Math.min(a.x + a.w, b.x + b.w)) / 2;
  if (b.y > a.y) seg(s, x, a.y + a.h, x, b.y, { end: "triangle", color: col, dash }); else seg(s, x, a.y, x, b.y + b.h, { end: "triangle", color: col, dash });
}

// ---------- ERD ----------
// nodes:[{id,label,api,type:std|custom|junction|config|external|proposed,c,r,fields[],ev}], edges:[{from,to,kind:md|lookup|junction|ref,label}]
function drawERD(s, erd, area) {
  const A = Object.assign({ x: 0.35, y: 1.12, w: W - 0.7, h: 5.62 }, area);
  const cols = erd.cols, rows = erd.rows; const gx = erd.gx || 0.5, gy = erd.gy || 0.4;
  const nw = (A.w - gx * (cols - 1)) / cols;
  const rowH = (A.h - gy * (rows - 1)) / rows;
  const fill = { std: P.slate, custom: P.navy2, junction: P.orange, config: "7A6A4F", external: P.blueEv, proposed: "6F8191", unknown: P.grey };
  const pos = {};
  for (const n of erd.nodes) {
    const x = A.x + n.c * (nw + gx) + (n.dx || 0) * (nw + gx); const y = A.y + n.r * (rowH + gy) + (n.dy || 0);
    const w = (n.span || 1) * nw + ((n.span || 1) - 1) * gx;
    const fl = (n.fields || []).join("\n");
    const hh = 0.46; const bh = n.fields && n.fields.length ? textH(fl, w - 0.16, 8.5, false) + 0.1 : 0;
    const h = n.h || Math.min(rowH, hh + bh);
    check(`ERD node ${n.label}`, hh + bh, Math.max(h, rowH));
    pos[n.id] = { x, y, w, h };
    rect(s, x, y, w, h, { fill: P.white, line: fill[n.type] || P.slate, lw: 1, dash: n.type === "proposed" || n.type === "unknown" ? "dash" : "solid" });
    rect(s, x, y, w, hh, { fill: fill[n.type] || P.slate, line: null });
    txt(s, n.label, { x: x + 0.08, y: y + 0.03, w: w - 0.36, h: 0.22, fontSize: 10, bold: true, color: P.white });
    txt(s, n.api || "API name unknown", { x: x + 0.08, y: y + 0.24, w: w - 0.14, h: 0.19, fontSize: 8, color: "E3E8EC", italic: !n.api });
    if (n.ev) badge(s, x + w - 0.26, y + 0.05, n.ev);
    if (bh) txt(s, fl, { x: x + 0.08, y: y + hh + 0.05, w: w - 0.16, h: bh, fontSize: 8.5, color: P.text });
  }
  for (const e of erd.edges) {
    const a = pos[e.from], b = pos[e.to]; if (!a || !b) { warnings.push(`slide ${curSlideNo}: ERD edge ${e.from}->${e.to} missing node`); continue; }
    const st = { md: { color: P.navy, width: 1.5 }, lookup: { color: P.slate, width: 1, dash: "dash" }, junction: { color: P.orange, width: 1.5 }, ref: { color: P.slateLt, width: 1, dash: "sysDot" } }[e.kind || "lookup"];
    const o = { ...st, begin: "oval", end: e.kind === "ref" ? "triangle" : "triangle" };
    let pts;
    const acx = a.x + a.w / 2, bcx = b.x + b.w / 2;
    if (e.via === "v" || (Math.abs(acx - bcx) < 0.05)) {
      const x = e.x != null ? e.x : (Math.max(a.x, b.x) + Math.min(a.x + a.w, b.x + b.w)) / 2;
      pts = b.y > a.y ? [[x, a.y + a.h], [x, b.y]] : [[x, a.y], [x, b.y + b.h]];
    } else if (b.y >= a.y + a.h - 0.01 && e.via !== "h") {
      const ym = (a.y + a.h + b.y) / 2 + (e.ymo || 0); const ax = acx + (e.aox || 0), bx = bcx + (e.box || 0);
      pts = [[ax, a.y + a.h], [ax, ym], [bx, ym], [bx, b.y]];
    } else if (a.y >= b.y + b.h - 0.01 && e.via !== "h") {
      const ym = (b.y + b.h + a.y) / 2 + (e.ymo || 0); const ax = acx + (e.aox || 0), bx = bcx + (e.box || 0);
      pts = [[ax, a.y], [ax, ym], [bx, ym], [bx, b.y + b.h]];
    } else {
      const right = b.x > a.x; const ya = a.y + 0.23 + (e.oya || 0), yb = b.y + 0.23 + (e.oyb || 0);
      const x1 = right ? a.x + a.w : a.x, x2 = right ? b.x : b.x + b.w; const mx = (x1 + x2) / 2 + (e.mxo || 0);
      pts = Math.abs(ya - yb) < 0.01 ? [[x1, ya], [x2, yb]] : [[x1, ya], [mx, ya], [mx, yb], [x2, yb]];
    }
    poly(s, pts, o);
    if (e.label) {
      const [px, py] = pts[pts.length - 1]; const [qx, qy] = pts[pts.length - 2];
      const vert = Math.abs(px - qx) < 0.01;
      const lx = vert ? px + 0.05 : (px + qx) / 2 - 0.15; const ly = vert ? (py + qy) / 2 - 0.09 : py + 0.03;
      txt(s, e.label, { x: lx, y: ly, w: 0.36, h: 0.17, fontSize: 8, color: o.color, bold: true, align: vert ? "left" : "center" });
    }
  }
  return pos;
}
function erdLegend(s, x, y) {
  const items = [["Standard", P.slate], ["Custom", P.navy2], ["Junction", P.orange], ["Config / CMDT", "7A6A4F"], ["External", P.blueEv], ["Proposed (ours)", "6F8191"]];
  let cx = x;
  for (const [n, c] of items) { rect(s, cx, y + 0.02, 0.16, 0.14, { fill: c, line: null }); txt(s, n, { x: cx + 0.2, y, w: 0.95, h: 0.18, fontSize: 8, color: P.muted }); cx += 0.93; }
  cx += 0.22;
  seg(s, cx, y + 0.09, cx + 0.38, y + 0.09, { color: P.navy, width: 1.5, end: "triangle", begin: "oval" }); txt(s, "Master-detail", { x: cx + 0.43, y, w: 0.8, h: 0.18, fontSize: 8, color: P.muted }); cx += 1.25;
  seg(s, cx, y + 0.09, cx + 0.38, y + 0.09, { color: P.slate, width: 1, dash: "dash", end: "triangle", begin: "oval" }); txt(s, "Lookup  (● parent → child)", { x: cx + 0.43, y, w: 1.6, h: 0.18, fontSize: 8, color: P.muted });
}

// ---------- tables ----------
function table(s, header, rows, o = {}) {
  const fs = o.fontSize || 9;
  const head = header.map((h) => ({ text: h, options: { bold: true, color: P.white, fill: { color: P.navy }, fontSize: fs, fontFace: FONT, valign: "middle" } }));
  const body = rows.map((r, i) => r.map((c) => {
    const cell = typeof c === "object" && c !== null && c.text !== undefined ? c : { text: String(c ?? "") };
    return { text: cell.text, options: Object.assign({ fontSize: fs, fontFace: FONT, color: P.text, fill: { color: i % 2 ? "F8F6F1" : P.white }, valign: "top" }, cell.options || {}) };
  }));
  s.addTable([head, ...body], { x: o.x || 0.35, y: o.y || 1.12, w: o.w || W - 0.7, colW: o.colW, border: { type: "solid", pt: 0.5, color: P.grid }, margin: [0.03, 0.06, 0.03, 0.06], rowH: o.rowH, autoPage: false });
  // estimate height
  const colW = o.colW; let total = 0.3;
  for (const r of rows) { let mh = 0; r.forEach((c, j) => { const t = typeof c === "object" && c !== null && c.text !== undefined ? c.text : String(c ?? ""); mh = Math.max(mh, textH(Array.isArray(t) ? t.map((x) => x.text).join("") : t, colW[j] - 0.12, fs, false) + 0.06); }); total += Math.max(mh, o.rowH || 0); }
  check(`table ${header[0]}`, total, (o.maxH || 5.9));
  return total;
}
function evCell(ev) { return { text: ev, options: { bold: true, color: P.white, fill: { color: (EV[ev] || EV.U).color }, align: "center" } }; }

module.exports = { pptxgen, W, H, P, EV, FONT, warnings, createDeck, contentSlide, dividerSlide, txt, rect, badge, numDot, seg, poly, legend, laneLabel, sourceLine, blockHeight, drawBlock, drawProcess, link, drawERD, erdLegend, table, evCell, textH, check, getSlideNo: () => curSlideNo };
