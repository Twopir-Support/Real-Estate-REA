// Master build: Real_Estate_Applications_Reverse_Engineering.pptx
const fs = require("fs");
const path = require("path");
const L = require("./lib");
const S = require("./slides");
const X = require("./sections");
const C = require("./cross");
const PR = require("./proposed");
const { P, W, txt, rect } = L;

const OUT = process.argv[2] || "Real_Estate_Applications_Reverse_Engineering.pptx";
const pres = L.createDeck();

// ---------- Section 1: Executive overview ----------
const S1 = "Executive overview";
pres.addSection({ title: S1 });
X.cover(pres, {
  section: S1, title: "Real estate applications on Salesforce", sub: "Reverse-engineering eight products from public sources: functions, data model, processes and a proposed architecture",
  meta: "Twopir Consulting · Research date 12 November 2026 · Public material only: no product was installed",
  apps: [
    { n: "Propertybase", t: "Residential" }, { n: "Apto", t: "CRE brokerage" }, { n: "AscendixRE", t: "CRE brokerage" }, { n: "REthink CRM", t: "CRE brokerage" },
    { n: "Left Main REI", t: "Investors" }, { n: "improveit 360", t: "Home improvement" }, { n: "Real Properties", t: "Property mgmt" }, { n: "Booker25", t: "Booking" },
  ],
});

let s = L.contentSlide(pres, S1, "Project objective and scope", "Understand what each product does, how it is built on Salesforce, and how its processes run, so we can design our own application", "scope");
X.cards(s, [
  { tag: "Objective", h: "Understand eight products end to end", d: "What each product does, its modules, its Salesforce objects, its automation, and how a record moves from first contact to final outcome." },
  { tag: "Constraint", h: "No installs, public sources only", d: "Vendor sites, help centers, AppExchange, release notes, review sites and demo pages. Internal code was never seen, so internals are labelled as verified, observed, inferred or unknown." },
  { tag: "Outcome", h: "A design for our own application", d: "A common data model, module map, Flow/Apex/LWC split, integrations and a phased roadmap, built independently from documented behaviour." },
  { tag: "Covered", h: "Eight products, four segments", d: "Residential (Propertybase), commercial brokerage (Apto, AscendixRE, REthink), investors (Left Main), plus three adjacent tools: improveit 360, Real Properties, Booker25." },
  { tag: "Per product", h: "Thirteen to fifteen slides each", d: "Overview, architecture, modules, objects, ERD, two to four process flows, automation, integrations, UI flow, reporting and limitations." },
  { tag: "Companion files", h: "Two workbooks and three documents", d: "Functional comparison and object inventory (Excel); process flows, sources and proposed architecture (Markdown)." },
], { cols: 3 });

s = L.contentSlide(pres, S1, "Research method and evidence labels", "Every architecture statement carries a label and a source id. Unknowns are stated, never filled in", "method");
L.drawProcess(s, {
  compact: true, minH: 2.4,
  sections: [
    { label: "Collect", tone: "beige", cols: [[{ id: "m1", kind: "start", cap: "Step 1", title: "Vendor sites, help centers, AppExchange, release notes", text: "Zendesk JSON endpoints used where help pages blocked bots" }]] },
    { label: "Extract", tone: "blue", cols: [[{ id: "m2", kind: "action", num: 2, title: "Objects, fields, stages, automation, integrations", text: "Exact API names only where the vendor prints them" }]] },
    { label: "Classify", tone: "blue", cols: [[{ id: "m3", kind: "status", num: 3, title: "Evidence label", items: ["Verified: vendor states it", "Observed: seen in official demo", "Inferred: reasoned, not confirmed", "Unknown: nothing reliable"] }]] },
    { label: "Synthesise", tone: "orange", cols: [[{ id: "m4", kind: "auto", num: 4, title: "Diagrams, comparison, proposed design", text: "Inferred models are marked 'inferred reference architecture'" }]] },
  ],
  links: [["m1", "m2"], ["m2", "m3"], ["m3", "m4"]],
});
X.cards(s, [
  { h: "Blocked pages", d: "G2, Capterra and some vendor sites returned HTTP 403. Their figures come from search-engine snippets and are marked as such.", ev: "V" },
  { h: "No video watched for most products", d: "'Observed' is used only for Left Main, where step-by-step vendor walkthroughs were read in a browser.", ev: "O" },
  { h: "Names", d: "Where a vendor does not publish an API name we write 'Unknown' and, if useful, a 'Proposed: TC_…' name of our own.", ev: "U" },
], { cols: 3, y: 4.3, h: 1.75, fs: 11 });

s = L.contentSlide(pres, S1, "Application landscape at a glance", "Who makes each product, who it serves, how it sits on Salesforce, and its status today", "comparison summary");
L.table(s, ["Application", "Publisher", "Segment", "Salesforce footprint", "Status (Nov 2026)", "Stand-out capability"],
  C.landscape.map((r) => [{ text: r[0], options: { bold: true } }, r[1], r[2], r[3], r[4], r[5]]), { colW: [1.45, 2.05, 1.75, 2.0, 2.85, 2.53], fontSize: 11, rowH: 0.66 });
L.sourceLine(s, "Sources: per-product chapters and the Sources section; status labels are Verified unless the chapter says otherwise");

X.ratings(pres, S1, C.ratings);

s = L.contentSlide(pres, S1, "Key findings", "What the research shows, and what it means for our build", "summary");
X.cards(s, [
  { tag: "Status", h: "Two of eight are not what they seem", d: "Apto is closed to new customers (Buildout now sells Rethink). Booker25 is now GoMeddo. Propertybase GO is not on Salesforce; only the Salesforce Edition is analysed.", ev: "V" },
  { tag: "Data model", h: "Property hub plus a custom demand object", d: "The CRE products put Property at the centre and capture demand in a custom Inquiry/Request, avoiding standard Lead and Opportunity, often because users hold Platform licences.", ev: "I" },
  { tag: "Process", h: "Close creates the outcome record", d: "AscendixRE, REthink and Left Main all create the next record on close (Lease/Sale, comp, Transaction). This is the pattern to copy.", ev: "V" },
  { tag: "Differentiators", h: "Matching, routing, booking", d: "Propertybase's field-name matching and lead routing, and Booker25's conflict-checked bookings, fill the gaps in our current enquiry-to-close process.", ev: "V" },
  { tag: "Evidence", h: "API names are rarely public", d: "Only Propertybase and Booker25 publish many API names. Elsewhere the object model is documented by label only; we mark the rest Unknown.", ev: "V" },
  { tag: "Recommendation", h: "Extend the TC app in phases", d: "Keep the commercial core already built; add Preferences and matching, routing, showings, offers and closing, then portals and investor features.", ev: "P" },
], { cols: 3 });
L.legend(s, 0.35, 7.13, ["V", "I", "P"]);

// ---------- Section 2: chapters ----------
pres.addSection({ title: "Individual analysis" });
L.dividerSlide(pres, "Individual analysis", "2. Individual application analysis", "One chapter per product, in the order supplied. Each opens with identity, status and ratings");
C.KEYS.forEach((k, i) => {
  if (!fs.existsSync(path.join(__dirname, "apps", k + ".js"))) { console.log("MISSING app", k); return; }
  const app = require(`./apps/${k}`);
  S.chapter(pres, app, i + 1);
});

// ---------- Section 3: comparison ----------
const S3 = "Cross-application comparison";
pres.addSection({ title: S3 });
L.dividerSlide(pres, S3, "3. Cross-application comparison", "Features, architecture, objects, processes, integrations and market position side by side");

s = L.contentSlide(pres, S3, "Functional comparison", "○ means outside the product's documented scope, not merely undocumented. ? means we could not verify it either way", "feature matrix");
X.matrix(s, ["Capability", ...C.APPS], C.features, { colW: [2.23, 1.3, 1.3, 1.3, 1.3, 1.3, 1.3, 1.3, 1.3], rowH: 0.36, fontSize: 10 });
X.symLegend(s, 0.35, 7.13);

s = L.contentSlide(pres, S3, "Technical architecture comparison", "How each product sits on Salesforce, from public evidence. 'Unknown' means not published, not absent", "architecture");
L.table(s, ["Dimension", ...C.APPS], C.tech.map((r) => r.map((c, j) => (j === 0 ? { text: c, options: { bold: true } } : c))), { colW: [1.75, 1.36, 1.36, 1.36, 1.36, 1.36, 1.36, 1.36, 1.36], fontSize: 10.5, rowH: 0.6 });

s = L.contentSlide(pres, S3, "Object architecture comparison", "The same business concept, and the object each product uses for it", "objects");
L.table(s, ["Concept", ...C.APPS], C.objectMap.map((r) => r.map((c, j) => (j === 0 ? { text: c, options: { bold: true } } : c))), { colW: [1.55, 1.39, 1.39, 1.39, 1.39, 1.39, 1.39, 1.39, 1.39], fontSize: 9, rowH: 0.6 });

s = L.contentSlide(pres, S3, "Business process comparison", "The nine common steps from first contact to after completion, and how each product handles them", "process");
L.table(s, ["Step", ...C.APPS], C.processCmp.map((r) => r.map((c, j) => (j === 0 ? { text: c, options: { bold: true } } : c))), { colW: [1.35, 1.41, 1.41, 1.41, 1.41, 1.41, 1.41, 1.41, 1.41], fontSize: 9.5, rowH: 0.6 });

s = L.contentSlide(pres, S3, "Integration comparison", "Direction is from the Salesforce org's point of view", "integrations");
L.table(s, ["Application", "Inbound", "Outbound", "Two-way", "AI"], C.integrationCmp.map((r) => [{ text: r[0], options: { bold: true } }, r[1], r[2], r[3], r[4]]), { colW: [1.6, 3.0, 2.6, 3.2, 2.23], fontSize: 11.5, rowH: 0.6 });

// Market positioning lanes
s = L.contentSlide(pres, S3, "Market position and target audience", "Where each product competes. Ratings shown as supplied / verified", "market");
const J = (...l) => l.join("\n");
const lanes = [
  ["Residential", [["Propertybase", J("Agents, teams, brokerages", "From $89 per user per month", "Routing, matching, portal feeds", "3.8 Capterra (51)")]]],
  ["Commercial brokerage", [["AscendixRE", J("Brokers, capital markets", "$79–$99 per user per month", "Close mapping, stacking plan, AI", "4.3 G2 (9)")], ["REthink CRM", J("Brokers by representation type", "$129, or $299 for Rethink+", "Four pipelines, Showcase sync", "3.3 G2 (13)")], ["Apto", J("Existing customers only", "Price not published", "Comps, Over-the-Term invoicing", "3.3 G2 (37)")]]],
  ["Investors", [["Left Main REI", J("Wholesalers and flippers", "$500–$2,000 per month + setup", "Cadences, dispositions, signals", "4.8 G2")]]],
  ["Adjacent tools", [["improveit 360", J("Home-improvement contractors", "Price not published", "Dispatch, in-home sale, production", "4.6 G2 (13)")], ["Real Properties", J("Property, events, assisted living", "Per user per year, amount unpublished", "CAD floor plans with live status", "5.0 AppExchange (2)")], ["Booker25 / GoMeddo", J("Any organisation that books resources", "Renamed GoMeddo, Feb 2023", "Conflict-checked reservations", "4.96 AppExchange (57)")]]],
];
const lg = 0.25, lw = (W - 0.7 - lg * 3) / 4;
lanes.forEach(([n, apps], i) => {
  const x = 0.35 + i * (lw + lg);
  rect(s, x, 1.12, lw, 5.5, { fill: i % 2 ? P.beige : P.blue, line: null });
  apps.forEach(([a, d], j) => {
    const y = 1.27 + j * 1.75;
    rect(s, x + 0.15, y, lw - 0.3, 1.6, { fill: P.white, line: j === 0 ? P.orange : P.line, lw: j === 0 ? 1.25 : 0.75 });
    txt(s, a, { x: x + 0.27, y: y + 0.1, w: lw - 0.55, h: 0.3, fontSize: 12, bold: true, color: P.navy });
    txt(s, d, { x: x + 0.27, y: y + 0.42, w: lw - 0.55, h: 1.12, fontSize: 10.5, color: P.text, paraSpaceAfter: 2 });
  });
  L.laneLabel(s, x, 6.7, lw, n, ["beige", "blue", "orange", "navy"][i]);
});
L.sourceLine(s, "Orange outline = segment leader by documented breadth (our judgement). Ratings from the ratings slide");

// ---------- Section 4–5 ----------
PR.build(pres);

// ---------- Section 6: sources ----------
const S6 = "Sources";
pres.addSection({ title: S6 });
L.dividerSlide(pres, S6, "6. Sources and references", "Key sources per product. The full list with access dates is in Research_Sources_and_References.md");
const RES = process.env.RE_RESEARCH || path.join(__dirname, "..", "..", "docs", "reverse-engineering", "research");
C.KEYS.forEach((k, i) => {
  const md = fs.readFileSync(path.join(RES, `${k}.md`), "utf8");
  const rows = parseSources(md).filter((r) => /^https?:/.test(r.url));
  const pick = rows.slice(0, 15);
  const sl = L.contentSlide(pres, S6, `Sources: ${C.APPS[i]}`, `${pick.length} of ${rows.length} sources shown; all accessed 12 Nov 2026`, "sources");
  L.table(sl, ["Id", "Title", "URL", "Type"], pick.map((r) => [r.id, r.title, { text: r.url, options: { hyperlink: { url: r.url }, color: P.blueEv } }, r.type]), { colW: [0.8, 4.2, 5.6, 2.03], fontSize: 8.5, maxH: 5.9 });
});
s = L.contentSlide(pres, S6, "Research limitations", "Read the deck with these in mind", "limitations");
X.cards(s, [
  { h: "No installations", d: "Internals (Apex, Flows, LWC) are known only where vendors publish names. Everything else is inferred or unknown.", ev: "V" },
  { h: "Blocked review sites", d: "G2 and Capterra returned HTTP 403; ratings are from search snippets and may lag the live pages.", ev: "V" },
  { h: "Documentation age", d: "Propertybase help is largely 2017–2021; Real Properties material dates from 2008–2019.", ev: "V" },
  { h: "Customer orgs differ", d: "Stage and status values are vendor defaults or examples; customers often customise them.", ev: "I" },
  { h: "Screenshots not embedded", d: "Vendor screenshots are copyrighted. The deck links to them instead; diagrams are our own editable drawings.", ev: "V" },
  { h: "Real Properties identity", d: "Matched on the only exact AppExchange name; functional detail is very thin.", ev: "V" },
], { cols: 3 });
L.legend(s, 0.35, 7.13, ["V", "I"]);

function parseSources(md) {
  const i = md.search(/^## 12\. Sources/m); if (i < 0) return [];
  const out = [];
  for (const line of md.slice(i).split("\n")) {
    if (!line.startsWith("|") || /^\|\s*-/.test(line) || /^\|\s*id\s*\|/i.test(line)) continue;
    const c = line.split("|").slice(1, -1).map((x) => x.trim());
    if (c.length < 4) continue;
    const url = (c[2].match(/https?:\/\/[^\s;)]+/) || [c[2]])[0];
    out.push({ id: c[0].replace(/\*/g, ""), title: ((t) => (t.length > 90 ? t.slice(0, t.lastIndexOf(" ", 88)) + " …" : t))(c[1].replace(/\*/g, "")), url, type: c[3] });
  }
  return out;
}

pres.writeFile({ fileName: OUT }).then(() => {
  console.log("slides:", L.getSlideNo());
  console.log(L.warnings.join("\n") || "no warnings");
});
module.exports = { parseSources };
