// Section 4 (proposed architecture) and Section 5 (roadmap). Independent design: our own TC_ names, no vendor code.
const L = require("./lib");
const S = require("./slides");
const X = require("./sections");
const { P, W, txt, rect, badge } = L;
const SEC4 = "Proposed architecture", SEC5 = "Implementation roadmap";
const TAG = "proposed (ours)";

const pseudo = { name: SEC4, key: "tc" };
const pseudo5 = { name: SEC5, key: "tc5" };

function build(pres) {
  pres.addSection({ title: SEC4 });
  L.dividerSlide(pres, SEC4, "4. Proposed Salesforce architecture", "An independent design for our own application, built from documented functionality, not vendor code. It extends the TC Commercial Real Estate app already in this repo");

  // Common vs unique
  let s = L.contentSlide(pres, SEC4, "What is common, what is unique", "Common capabilities become the core; unique ones are optional modules ranked by value to our target market", TAG);
  X.cards(s, [
    { tag: "Common · core", h: "People and companies", d: "Every product uses Account and Contact; most add role or relationship records (Deal parties, Transaction Members, Reservation Contacts).", ev: "V" },
    { tag: "Common · core", h: "Inventory", d: "Property with units or spaces below it: AscendixRE, Propertybase, Apto, REthink, Real Properties. Booker25 generalises it as Resource.", ev: "V" },
    { tag: "Common · core", h: "Demand capture", d: "A lead-like record outside standard Lead: Inquiry (AscendixRE), Request (Propertybase), eLead / Inquiry (improveit 360), seller lead (Left Main).", ev: "V" },
    { tag: "Common · core", h: "Pipeline with stages", d: "Deal or Opportunity-like object with stages, close status and a structured close step that creates the outcome record.", ev: "V" },
    { tag: "Common · core", h: "Follow-up automation", d: "Task sequences, drips, action plans and expiration reminders appear in every product.", ev: "V" },
    { tag: "Unique · optional", h: "Matching, booking, money", d: "Criteria matching (Propertybase), stacking plan and capital markets (AscendixRE), conflict-checked booking (Booker25), investor dispositions (Left Main), production scheduling (improveit 360).", ev: "V" },
  ], { cols: 3 });
  L.legend(s, 0.35, 7.13);

  // Proposed ERD
  S.erd(pres, pseudo, {
    title: "common data model (ERD)", tag: TAG, sub: "Navy = objects already built in this repo (P2–P7). Grey dashed = proposed new objects. All names are ours (TC_ convention)",
    cols: 5, rows: 3, gx: 0.4, gy: 0.5,
    nodes: [
      { id: "acc", label: "Account", api: "Account", type: "std", c: 0, r: 0, fields: ["Owner, tenant, buyer, lender"] },
      { id: "con", label: "Contact", api: "Contact", type: "std", c: 0, r: 1, fields: ["Relationship type"] },
      { id: "inq", label: "Inquiry", api: "TC_Inquiry__c", type: "custom", c: 0, r: 2, fields: ["Source, type, status"] },
      { id: "pref", label: "Preference", api: "Proposed: TC_Preference__c", type: "proposed", c: 1, r: 2, fields: ["Criteria min / max", "for automatching"] },
      { id: "prop", label: "Property", api: "TC_Property__c", type: "custom", c: 2, r: 0, fields: ["Hub; class, market"] },
      { id: "unit", label: "Unit / Availability", api: "TC_Unit__c / TC_Availability__c", type: "custom", c: 1, r: 0, fields: ["Space, status, rate"] },
      { id: "lst", label: "Listing", api: "TC_Listing__c", type: "custom", c: 1, r: 1, fields: ["Lease / Sale"] },
      { id: "deal", label: "Deal", api: "TC_Deal__c", type: "custom", c: 2, r: 1, fields: ["Record types, stage"] },
      { id: "show", label: "Showing / Booking", api: "Proposed: TC_Showing__c", type: "proposed", c: 2, r: 2, fields: ["Start, end, conflict check"] },
      { id: "off", label: "Offer", api: "TC_Offer__c", type: "custom", c: 3, r: 1, fields: ["Amount, status, counter"] },
      { id: "lease", label: "Lease / Sale", api: "TC_Lease__c / TC_Sale__c", type: "custom", c: 3, r: 0, fields: ["Outcome records (comps)"] },
      { id: "com", label: "Commission", api: "TC_Commission__c", type: "custom", c: 3, r: 2, fields: ["Splits, privacy"] },
      { id: "pub", label: "Portal Publication", api: "Proposed: TC_Portal_Publication__c", type: "proposed", c: 4, r: 0, fields: ["Child of Listing (MD)", "Portal, status, last sync"] },
      { id: "ms", label: "Closing Milestone", api: "Proposed: TC_Closing_Milestone__c", type: "proposed", c: 4, r: 2, fields: ["Checklist, due date"] },
      { id: "cfg", label: "Settings (CMDT)", api: "TC_*_Setting__mdt", type: "config", c: 4, r: 1, fields: ["Mappings, toggles, routing rules"] },
    ],
    edges: [
      { from: "acc", to: "con", kind: "lookup", label: "1:N" },
      { from: "con", to: "inq", kind: "lookup", label: "1:N" },
      { from: "inq", to: "pref", kind: "md", label: "1:N" },
      { from: "prop", to: "unit", kind: "md", label: "1:N" },
      { from: "prop", to: "deal", kind: "lookup", label: "1:N" },
      { from: "prop", to: "lease", kind: "lookup", label: "1:N" },
      { from: "unit", to: "lst", kind: "lookup", label: "1:N" },
      { from: "deal", to: "off", kind: "md", label: "1:N" },
      { from: "deal", to: "show", kind: "lookup", label: "1:N" },
      { from: "off", to: "com", kind: "ref", label: "via Deal" },
      { from: "off", to: "ms", kind: "lookup", label: "1:N", aox: 0.6, box: -0.6 },
    ],
  });

  // Layered architecture (reuse renderer)
  S.architecture(pres, Object.assign({}, pseudo, { arch: {
    tag: TAG, sub: "Users, layers and external systems for the proposed platform. Navy chips are logic that needs Apex",
    users: [
      { n: "Brokers and agents", d: "Pipeline, matching, showings" },
      { n: "Listing coordinators", d: "Listings, media, portals" },
      { n: "Managers", d: "Dashboards, approvals" },
      { n: "Accounting", d: "Commissions, payouts" },
      { n: "Admins", d: "Settings in CMDT" },
      { n: "Prospects", d: "Web forms, booking page" },
    ],
    layers: [
      { name: "Experience (LWC)", items: [{ n: "tcPropertySearch + map", ev: "V" }, { n: "tcStackingPlan", ev: "V" }, { n: "tcDealPipeline", ev: "V" }, { n: "tcCloseDeal", ev: "V" }, { n: "tcInquiryMatches", ev: "V" }, { n: "tcShowingScheduler", ev: "P" }, { n: "tcPortalPublisher", ev: "P" }] },
      { name: "Logic (Apex + Flow)", items: [{ n: "TC_DealService", ev: "V", dark: true }, { n: "TC_CommissionService", ev: "V", dark: true }, { n: "TC_FieldMappingService", ev: "V", dark: true }, { n: "TC_MatchingService", ev: "P", dark: true }, { n: "TC_BookingService", ev: "P", dark: true }, { n: "Record-triggered Flows", ev: "V" }, { n: "Scheduled Flows", ev: "V" }] },
      { name: "Data", items: [{ n: "Property / Unit / Availability", ev: "V" }, { n: "Inquiry + Preference", ev: "P" }, { n: "Deal / Offer", ev: "V" }, { n: "Lease / Sale", ev: "V" }, { n: "Commission", ev: "V" }, { n: "Showing", ev: "P" }, { n: "Portal Publication", ev: "P" }] },
      { name: "Config + security", items: [{ n: "TC_*__mdt settings", ev: "V" }, { n: "TC_Bypass_Settings__c", ev: "V" }, { n: "Permission set groups", ev: "P" }, { n: "Commission privacy sharing", ev: "P" }] },
    ],
    external: [
      { n: "Web forms / site", d: "Inquiry REST endpoint", ev: "P" },
      { n: "Listing portals", d: "Outbound feeds", ev: "P" },
      { n: "Outlook / Google", d: "Showing calendar sync", ev: "P" },
      { n: "E-signature", d: "LOI, lease, offer docs", ev: "P" },
      { n: "Maps / geocoding", d: "Search and map", ev: "P" },
      { n: "Email / SMS", d: "Notifications", ev: "P" },
    ],
  } }));

  // Module architecture with priorities
  S.modules(pres, Object.assign({}, pseudo, { modules: {
    tag: TAG, sub: "Module map. P1 = built in this repo; P2 and P3 = proposed next, ordered by dependency", src: [],
    sections: [
      { label: "Core (built, P1)", tone: "beige", cols: [[
        { kind: "action", title: "Property, Unit, Availability", text: "Hub, stacking plan, map search", ev: "V" },
        { kind: "action", title: "Inquiry and conversion", text: "Capture, convert to Account/Contact/Deal", ev: "V" },
        { kind: "auto", title: "Deal pipeline and close", text: "Record types, stages, close mapping", ev: "V" },
        { kind: "action", title: "Lease, Sale, rent tables", text: "Outcome records and periods", ev: "V" },
        { kind: "auto", title: "Commissions", text: "Splits, validation, payout order", ev: "V" },
      ]] },
      { label: "Next (P2)", tone: "blue", cols: [[
        { kind: "start", cap: "Priority 2a", title: "Preferences and automatching", text: "Criteria on Inquiry matched to Availability and Listing", ev: "P" },
        { kind: "action", title: "Lead routing", text: "Round robin and claim, from CMDT rules", ev: "P" },
        { kind: "action", title: "Showings and booking", text: "Conflict-checked viewings with calendar sync", ev: "P" },
        { kind: "action", title: "Offers and closing milestones", text: "Counter chain, checklist, Listing status", ev: "P" },
      ]] },
      { label: "Later (P3)", tone: "orange", cols: [[
        { kind: "action", title: "Portal publication", text: "Feeds per portal with mapping and sync status", ev: "P" },
        { kind: "action", title: "Drips and cadences", text: "Email/SMS sequences for nurture", ev: "P" },
        { kind: "action", title: "Investor acquisitions", text: "Seller leads, offers, dispositions, profit", ev: "P" },
        { kind: "action", title: "Invoicing and payments", text: "Commission invoices and receipts", ev: "P" },
        { kind: "auto", title: "AI assist", text: "Email-to-record drafts with human review", ev: "P" },
      ]] },
    ],
  } }));

  // End-to-end proposed process
  S.process(pres, pseudo, {
    title: "Proposed end-to-end process: enquiry to close", sub: "Combines the strongest documented patterns: Propertybase routing and matching, Booker25 conflict checks, AscendixRE close mapping", tag: TAG, src: [],
    sections: [
      { label: "Enquiry in", tone: "beige", cols: [[
        { id: "a1", kind: "start", cap: "Start points", title: "Web form, portal email, call, walk-in", ev: "P" },
        { id: "a2", kind: "auto", num: 1, title: "REST endpoint creates Inquiry + Preference", text: "Duplicate check on email and phone", ev: "P" },
        { id: "a3", kind: "auto", num: 2, title: "Routing rule assigns owner", text: "Round robin or claim; SLA timer starts", ev: "P" },
        { id: "a4", kind: "note", title: "Fixes the gap in the reference process: every enquiry is routed and its wait time measured.", noLink: true },
      ]] },
      { label: "Match and show", tone: "blue", weight: 2, cols: [[
        { id: "b1", kind: "auto", num: 3, title: "Automatching", text: "Preference criteria → Availabilities and Listings", ev: "P" },
        { id: "b2", kind: "action", num: 4, title: "Shortlist sent to client", ev: "P" },
        { id: "b3", kind: "auto", num: 5, title: "Showing booked", text: "Conflict check on agent and unit; calendar invite", ev: "P" },
      ], [
        { id: "b4", kind: "gate", cap: "Decision", num: 6, title: "Qualify: convert or disqualify", text: "Convert creates Account, Contact, Deal", ev: "P" },
        { id: "b5", kind: "status", num: 7, title: "Deal stage", items: ["Qualified", "Touring", "Proposal / LOI", { t: "Negotiation", hl: true }, "Contract", "Closed Won / Lost"], ev: "P" },
      ]] },
      { label: "Offer and close", tone: "orange", cols: [[
        { id: "c1", kind: "action", num: 8, title: "Offer and counters", text: "Accept updates Listing and Availability", ev: "P" },
        { id: "c2", kind: "auto", num: 9, title: "Close Deal maps to Lease or Sale", text: "Rent table and commissions carried", ev: "P" },
        { id: "c3", kind: "auto", num: 10, title: "Post-close", text: "Expiry reminders, review request, portal unpublish", ev: "P" },
      ]] },
    ],
    links: [["a3", "b1"], ["b3", "b4"], ["b5", "c1"]],
    notes: [
      { h: "Borrowed patterns", d: "Routing and field-name matching (Propertybase), None/Soft/Hard conflict rules (Booker25), close-time object mapping and expiry reminders (AscendixRE).", ev: "V" },
      { h: "Alternate paths", d: "Disqualify closes the Inquiry with a reason. Lost deals keep the history and release held Availabilities. A cancelled showing frees the slot.", ev: "P" },
      { h: "Measures", d: "Time to first contact, match-to-showing rate, showing-to-offer rate, stage ageing and win rate by source.", ev: "P" },
      { h: "Built vs new", d: "Steps 6, 7, 9 and 10 run today in the TC app. Steps 1–5 and 8 need the P2 modules.", ev: "V" },
    ],
  });

  // LWC / Apex / Flow / Integration architecture tables
  s = L.contentSlide(pres, SEC4, "LWC architecture", "Lightning Web Components: what exists in this repo and what the next modules need", TAG);
  L.table(s, ["Component", "Purpose", "Objects", "Apex controller", "Status"], [
    ["tcPropertySearch", "Filtered search with map pins", "Property, Availability", "TC_PropertyUIController", "Built"],
    ["tcStackingPlan", "Floor-by-floor occupancy view", "Property, Lease, Availability", "TC_PropertyUIController", "Built"],
    ["tcDealPipeline", "Kanban by stage with totals", "Deal", "TC_DealUIController", "Built"],
    ["tcCloseDeal", "Won/Lost dialog with mapping preview", "Deal → Lease / Sale / Listing", "TC_DealUIController", "Built"],
    ["tcConvertInquiry", "Convert with listing choice", "Inquiry", "TC_RecordUIController", "Built"],
    ["tcInquiryMatches", "Matching availabilities for an inquiry", "Inquiry, Availability", "TC_RecordUIController", "Built (extend to Preference)"],
    ["tcCommissionGrid / Dashboard", "Split entry and payout view", "Commission", "TC_DealUIController", "Built"],
    ["tcRentTable, tcTermSheetCompare", "Rent periods; lender quote comparison", "Deal/Lease Period, Term Sheet", "TC_RecordUIController", "Built"],
    [{ text: "tcShowingScheduler", options: { bold: true } }, "Calendar of agents and units; drag to book", "Proposed: TC_Showing__c", "Proposed: TC_BookingService", "Proposed"],
    [{ text: "tcPortalPublisher", options: { bold: true } }, "Publish, pause, see sync errors per portal", "Proposed: TC_Portal_Publication__c", "Proposed: TC_PortalService", "Proposed"],
    [{ text: "tcLeadInbox", options: { bold: true } }, "Claim queue with SLA timer", "Inquiry", "Proposed: TC_RoutingService", "Proposed"],
  ], { colW: [2.4, 3.3, 2.6, 2.5, 1.83], fontSize: 9.5 });
  L.sourceLine(s, "Built = present in force-app/main/default/lwc of this repository. Proposed = recommended, not built");

  s = L.contentSlide(pres, SEC4, "Apex architecture", "Trigger → handler → service layering already used in this repo; new services slot into the same pattern", TAG);
  S_apex(s);

  s = L.contentSlide(pres, SEC4, "Flow vs Apex: where each piece of automation belongs", "Rule of thumb: Flow for single-record, admin-owned logic; Apex for bulk, cross-object, callouts and calculations", TAG);
  L.table(s, ["Automation", "Trigger", "Recommended", "Why", "Status"], [
    ["Inquiry follow-up task", "Inquiry created", "Record-triggered Flow", "Single record, admin may change wording", "Built (TC_Inquiry_New_Follow_Up)"],
    ["Deal stage tasks", "Stage change", "Record-triggered Flow + CMDT", "Per-stage task lists in TC_Deal_Stage_Setting__mdt", "Built (TC_Deal_Stage_Tasks)"],
    ["Lease expiration reminders", "Days before expiry", "Scheduled-path Flow", "Time-based, no code", "Built"],
    ["Listing expiration", "Expiry date", "Scheduled Flow", "Batch of records, simple update", "Built"],
    ["Close Deal mapping", "Close Won", "Apex (TC_FieldMappingService)", "Cross-object, metadata-driven, bulk-safe", "Built"],
    ["Commission split + validation", "Commission save / close", "Apex (TC_CommissionService)", "Calculation, ordering, 100% rules", "Built"],
    ["Automatching", "Preference or Availability change", "Apex queueable", "Dynamic SOQL from criteria; volume", "Proposed"],
    ["Lead routing", "Inquiry created", "Apex + CMDT rules", "Round-robin state needs locking", "Proposed"],
    ["Showing conflict check", "Showing insert / update", "Apex trigger", "Overlap queries must be bulk-safe", "Proposed"],
    ["Portal feed", "Listing published", "Apex queueable callout", "Named Credential, retries, logging", "Proposed"],
    ["Notifications", "Showing booked / offer accepted", "Flow (email / custom notification)", "Admin-owned content", "Proposed"],
  ], { colW: [2.3, 2.0, 2.4, 3.6, 2.33], fontSize: 9.5 });

  // Integration hub (reuse renderer)
  S.integrations(pres, Object.assign({}, pseudo, {
    coreName: "Proposed TC platform", intSub: "Proposed integrations. Each callout uses a Named Credential and logs to an integration log object",
    coreText: "Inbound: Apex REST for inquiries. Outbound: queueable callouts with retry. Calendar sync via standard Einstein Activity Capture or a sync service.",
    integrations: [
      { sys: "Website / web forms", dir: "→", purpose: "Enquiries into Inquiry + Preference", data: "Apex REST, token on a guest Site", ev: "P" },
      { sys: "Listing portals", dir: "←", purpose: "Publish listings and media", data: "Feed or API per portal · Named Credential", ev: "P" },
      { sys: "Portal lead emails", dir: "→", purpose: "Leads parsed into Inquiry", data: "Email Service + parser per portal", ev: "P" },
      { sys: "Outlook / Google Calendar", dir: "↔", purpose: "Showings on agent calendars", data: "Event sync; ICS invites to clients", ev: "P" },
      { sys: "E-signature", dir: "↔", purpose: "LOI, offer and lease signing", data: "Envelope status back to Deal / Offer", ev: "P" },
      { sys: "Maps / geocoding", dir: "←", purpose: "Coordinates for search and map", data: "Address → lat/long on Property", ev: "P" },
      { sys: "Email / SMS provider", dir: "←", purpose: "Drips, alerts, reminders", data: "Templates, opt-out sync", ev: "P" },
      { sys: "Accounting", dir: "←", purpose: "Commission invoices and payouts", data: "Invoice and payment status", ev: "P" },
    ],
  }));

  // ---------- Section 5 ----------
  pres.addSection({ title: SEC5 });
  L.dividerSlide(pres, SEC5, "5. Implementation roadmap", "Phases, priorities, dependencies and risks for the proposed platform");
  s = L.contentSlide(pres, SEC5, "Development phases", "Indicative sequence. Durations assume one admin, two developers and a part-time architect", TAG);
  X.roadmap(s, [
    { n: "0 · Baseline", when: "done (P1–P7 in repo)", items: ["Property, Unit, Availability, Listing", "Inquiry and conversion", "Deal pipeline, close mapping", "Lease, Sale, rent tables", "Commissions, capital markets", "Reports, dashboard, sample data"] },
    { n: "1 · Demand", when: "weeks 1–4", items: ["TC_Preference__c and criteria UI", "TC_MatchingService (queueable)", "Lead routing rules in CMDT", "tcLeadInbox with SLA timer", "Inquiry REST endpoint"] },
    { n: "2 · Showings", when: "weeks 5–8", items: ["TC_Showing__c, conflict trigger", "tcShowingScheduler", "Calendar sync and ICS invites", "Feedback captured on Showing", "Notification Flows"] },
    { n: "3 · Offer and close", when: "weeks 9–12", items: ["Offer counter chain, status rules", "Closing milestones checklist", "E-signature integration", "Listing and Availability status sync"] },
    { n: "4 · Market", when: "weeks 13–16", items: ["TC_Portal_Publication__c", "Portal feed callouts and logs", "Drip and cadence engine", "Portal lead email parsing"] },
    { n: "5 · Extend", when: "weeks 17+", items: ["Investor acquisitions module", "Invoicing and payments", "AI email-to-record drafts", "Mobile layouts and actions"] },
  ]);

  s = L.contentSlide(pres, SEC5, "Module priorities and technical dependencies", "What each module needs first, and which products show it working", TAG);
  L.table(s, ["Module", "Priority", "Depends on", "Main build effort", "Seen in"], [
    ["Preferences and automatching", "P2a", "Inquiry, Availability, Listing", "Apex dynamic SOQL, LWC results", "Propertybase, AscendixRE"],
    ["Lead routing", "P2a", "Inquiry REST endpoint", "CMDT rules, round-robin state, notifications", "Propertybase, Left Main"],
    ["Showings and booking", "P2b", "Deal or Inquiry, Unit", "Conflict trigger, scheduler LWC, calendar sync", "Booker25, Propertybase, improveit 360"],
    ["Offers and closing milestones", "P2c", "Deal, Listing", "Status rules, checklist, e-signature", "Propertybase, Apto, Left Main"],
    ["Portal publication", "P3", "Listing, media", "Callouts per portal, mapping, retries", "Propertybase, AscendixRE"],
    ["Drips and cadences", "P3", "Contact, templates", "Scheduler, opt-out, SMS provider", "Propertybase, Left Main, improveit 360"],
    ["Investor acquisitions", "P3", "Inquiry, Offer", "Deal analysis fields, disposition pipeline", "Left Main"],
    ["Invoicing and payments", "P3", "Commission", "Invoice objects, accounting sync", "Apto, Propertybase, improveit 360"],
    ["AI assist", "P3", "All core objects", "Email service, LLM call, review queue", "AscendixRE"],
  ], { colW: [2.6, 0.9, 2.6, 3.6, 2.93], fontSize: 10 });

  s = L.contentSlide(pres, SEC5, "Risks and limitations", "What could go wrong, and how the plan contains it", TAG);
  X.cards(s, [
    { tag: "Evidence", h: "Public sources only", d: "No product was installed. API names, stage values and automation names are mostly unpublished, so our model is designed, not copied. Each design choice is labelled.", ev: "V" },
    { tag: "Licensing", h: "Platform vs Sales Cloud", d: "Two vendors bundle Platform licences and avoid Lead/Opportunity. If our users hold Platform licences, the custom Inquiry/Deal design is required, not optional.", ev: "I" },
    { tag: "Integration", h: "Portal and calendar APIs", d: "Each portal has its own feed format and terms. Calendar sync needs either Einstein Activity Capture or a service; both have limits.", ev: "I" },
    { tag: "Scale", h: "Matching and conflicts at volume", d: "Automatching and conflict checks run queries per record. They must be bulk-safe and asynchronous to stay within governor limits.", ev: "I" },
    { tag: "Data", h: "Migration from existing CRMs", d: "Clients moving from these products bring namespaced data (pba__, McLabs2__, ascendix__). Mapping tables per source are needed.", ev: "I" },
    { tag: "IP", h: "Independent build", d: "No vendor code, trademarks or confidential material is used. Names are ours; features are re-designed from public descriptions.", ev: "V" },
  ], { cols: 3 });
  L.legend(s, 0.35, 7.13);

  S.process(pres, pseudo5, {
    title: "Recommended implementation sequence", sub: "Each step ends with tests, a deployable package and a demo", tag: TAG, src: [],
    sections: [
      { label: "Design", tone: "beige", cols: [[
        { id: "x1", kind: "start", cap: "Start", title: "Confirm target segment and licences", ev: "P" },
        { id: "x2", kind: "action", num: 1, title: "Freeze data model for P2 objects", ev: "P" },
      ]] },
      { label: "Build", tone: "blue", cols: [[
        { id: "x3", kind: "auto", num: 2, title: "Objects, CMDT, permission sets", ev: "P" },
        { id: "x4", kind: "auto", num: 3, title: "Apex services + tests (≥85%)", ev: "P" },
        { id: "x5", kind: "action", num: 4, title: "LWC screens and Flows", ev: "P" },
      ]] },
      { label: "Prove", tone: "orange", cols: [[
        { id: "x6", kind: "gate", cap: "Gate", num: 5, title: "End-to-end test with sample data", ev: "P" },
        { id: "x7", kind: "action", num: 6, title: "Demo, feedback, next phase", ev: "P" },
      ]] },
    ],
    links: [["x2", "x3"], ["x5", "x6"]],
    notes: [
      { h: "Start here", d: "Phase 1 (Demand) first: matching and routing touch every later module and are the most-cited gaps in the reference process.", ev: "P" },
      { h: "Keep configurable", d: "Stages, routing rules, mappings and task lists live in custom metadata so admins change behaviour without code.", ev: "P" },
      { h: "Definition of done", d: "Bulk tests at 200 records, permission tests per persona, and an updated field inventory workbook.", ev: "P" },
    ],
  });
}

function S_apex(s) {
  const cols = [
    { h: "Entry points", items: ["Triggers (one per object) → TC_TriggerHandler", "Apex REST: inquiry intake (proposed)", "@AuraEnabled UI controllers", "Schedulable: TC_DailyScheduler", "Email service: portal leads (proposed)"] },
    { h: "Services (built)", items: ["TC_DealService", "TC_InquiryService", "TC_LeaseService, TC_RentTableService", "TC_CommissionService", "TC_FieldMappingService, TC_NamingService", "TC_PropertyRollupService"] },
    { h: "Services (proposed)", items: ["TC_MatchingService (queueable)", "TC_RoutingService", "TC_BookingService (conflicts)", "TC_PortalService (callouts)", "TC_IntegrationLog writer"] },
    { h: "Cross-cutting", items: ["TC_Settings reads CMDT", "TC_Bypass_Settings__c switches", "TC_Exception, error logging", "with sharing by default; FLS via WITH USER_MODE", "TC_TestDataFactory for tests"] },
  ];
  const g = 0.3, cw = (W - 0.7 - g * 3) / 4;
  cols.forEach((c, i) => {
    const x = 0.35 + i * (cw + g), y = 1.12;
    rect(s, x, y, cw, 5.75, { fill: i === 2 ? P.peach : i === 1 ? P.blue : P.beige, line: i === 2 ? P.orange : null, dash: i === 2 ? "dash" : undefined });
    txt(s, c.h.toUpperCase(), { x: x + 0.15, y: y + 0.12, w: cw - 0.3, h: 0.25, fontSize: 10, bold: true, color: P.navy, charSpacing: 1 });
    let cy = y + 0.5;
    for (const it of c.items) {
      const h = L.textH(it, cw - 0.44, 10.5) + 0.2;
      rect(s, x + 0.12, cy, cw - 0.24, h, { fill: i === 1 ? P.navy2 : P.white, line: null });
      txt(s, it, { x: x + 0.22, y: cy + 0.1, w: cw - 0.44, h: h - 0.2, fontSize: 10.5, color: i === 1 ? P.white : P.text });
      cy += h + 0.1;
    }
    if (i < 3) L.seg(s, x + cw, y + 2.9, x + cw + g, y + 2.9, { end: "triangle", color: P.orange, width: 1.5 });
  });
  L.sourceLine(s, "Built class names are from force-app/main/default/classes in this repository; proposed names are recommendations");
}

module.exports = { build };
