// Shared cross-application data used by the deck, the Excel workbooks and the markdown files.
const APPS = ["Propertybase", "Apto", "AscendixRE", "REthink CRM", "Left Main REI", "improveit 360", "Real Properties", "Booker25"];
const KEYS = ["propertybase", "apto", "ascendixre", "rethink", "leftmain", "improveit360", "realproperties", "booker25"];

const landscape = [
  ["Propertybase", "Propertybase by Lone Wolf Technologies", "Residential brokerage", "Native, managed (pba)", "Active; Salesforce Edition sold, GO is a separate non-Salesforce product", "Lead routing, inquiry matching, portal syndication"],
  ["Apto", "Buildout (acquired Jan 2022)", "CRE brokerage", "Native, managed (McLabs2__)", "Maintained for existing customers only; not sold to new buyers", "Prospecting console, comps, Over-the-Term invoicing"],
  ["AscendixRE", "Ascendix Technologies, Dallas", "CRE brokerage, capital markets", "Native, managed (ascendix)", "Active; v1.43 Sep 2026; AI Suite 2026", "Deal-close mapping, stacking plan, commissions, AI Suite"],
  ["REthink CRM", "Buildout (acquired Feb 2021)", "CRE brokerage", "Native (TTL_Core__)", "Active as 'Rethink by Buildout'; v3.56 Fall 2026", "Four rep-type pipelines, close → comp, Showcase sync"],
  ["Left Main REI", "Left Main, Charlotte NC", "Real estate investors (wholesale, flip)", "Installed package (Left_Main__), EE licences bundled", "Active; v1.630 Oct 2026", "Cadences, dispositions, Investor Portal, DealSignals"],
  ["improveit 360", "improveit 360 (EverCommerce)", "Home improvement contractors", "Native, managed OEM (i360core__)", "Active; v1.43 Summer 2026", "Appointment dispatch, in-home sale, production projects"],
  ["Real Properties", "Real Intelligence, Inc.", "Property, facility and event management", "Native, unmanaged", "Listing live (2008, edited 2022); appears legacy", "CAD floor plans coloured by live status"],
  ["Booker25 / GoMeddo", "Group25 (renamed GoMeddo Feb 2023)", "Generic resource booking", "Native, managed (B25)", "Active; listing updated Sep 2026", "Conflict-checked reservations, availability, booking widget"],
];

// rating rows: sup = supplied, ver = verified on same platform, ax = AppExchange
const ratings = [
  { app: "Propertybase", sup: 3.8, ver: 3.8, ax: 4.78, supplied: "3.8 · 51 · Capterra", verified: "3.8 · 51 (snippet)", other: "G2 2.7 (33); AppExchange 4.78 (369)", note: "Matches supplied" },
  { app: "Apto", sup: 3.3, ver: 3.3, ax: 0, supplied: "3.3 · 37 · G2", verified: "3.3 · 37 (snippet)", other: "No AppExchange listing found", note: "Matches; product no longer sold" },
  { app: "AscendixRE", sup: 4.3, ver: 4.3, ax: 4.98, supplied: "4.3 · 9 · G2", verified: "4.3 · 9 (snippet)", other: "AppExchange 4.98 (91)", note: "Matches supplied" },
  { app: "REthink CRM", sup: 3.3, ver: 3.3, ax: 0, supplied: "3.3 · 13 · G2", verified: "3.3 · 13 (snippet)", other: "Capterra 4.1 (7)", note: "Matches; G2 profile looks stale" },
  { app: "Left Main REI", sup: 4.8, ver: 4.8, ax: 0, supplied: "4.8 · 12 · G2", verified: "4.8 · 8–10 (snippet)", other: "No AppExchange listing found", note: "Rating matches; count differs" },
  { app: "improveit 360", sup: 4.6, ver: 4.6, ax: 0, supplied: "4.6 · 13 · G2", verified: "4.6 · 13 (snippet)", other: "Capterra / GetApp 3.7 (19)", note: "Matches supplied" },
  { app: "Real Properties", sup: 0, ver: 0, ax: 5.0, supplied: "Not publicly verified", verified: "No G2 / Capterra page", other: "AppExchange 5.00 (2)", note: "Only 2 reviews" },
  { app: "Booker25", sup: 0, ver: 4.8, ax: 4.96, supplied: "Not publicly verified", verified: "G2 ~4.8 (14–15, snippet)", other: "AppExchange 4.96 (57)", note: "Now GoMeddo" },
];

// Feature matrix: F full, P partial, N not in product scope, U not publicly verified
const features = [
  ["Property management", "F", "F", "F", "F", "P", "N", "F", "P"],
  ["Lead management", "F", "P", "F", "P", "F", "F", "P", "N"],
  ["Contact management", "F", "F", "F", "F", "F", "F", "F", "P"],
  ["Listing management", "F", "F", "F", "F", "P", "N", "P", "N"],
  ["Deal management", "F", "F", "F", "F", "F", "F", "U", "N"],
  ["Lease management", "P", "F", "F", "F", "N", "N", "P", "N"],
  ["Commission management", "P", "F", "F", "P", "U", "F", "U", "N"],
  ["Investor management", "N", "N", "P", "P", "F", "N", "N", "N"],
  ["Appointment scheduling", "P", "U", "P", "P", "P", "F", "P", "F"],
  ["Document generation", "P", "P", "F", "U", "U", "P", "P", "U"],
  ["Workflow automation", "F", "P", "F", "P", "F", "F", "P", "F"],
  ["Marketing automation", "F", "P", "P", "P", "F", "F", "P", "N"],
  ["Dashboards", "F", "F", "F", "F", "F", "F", "P", "P"],
  ["Integrations", "F", "P", "F", "P", "F", "F", "P", "F"],
  ["AI capabilities", "P", "U", "F", "P", "F", "U", "N", "P"],
];

const tech = [
  ["Namespace", "pba", "McLabs2__", "ascendix", "TTL_Core__", "Left_Main__", "i360__ / i360core__", "none", "B25"],
  ["Package", "Managed", "Managed", "Managed", "Managed (inferred)", "Installed pkg", "Managed OEM", "Unmanaged", "Managed"],
  ["Licence", "Platform bundled", "Platform + 'Apto x7'", "EE/UE + Platform", "Rethink org, Platform users", "EE licences bundled", "OEM licence", "PE and up", "Not stated"],
  ["API names published", "Many", "2 objects", "Some", "2 objects", "1 field", "Several + triggers", "None", "Many + Apex API"],
  ["Standard objects reused", "Contact, Account, Event", "Account, Contact", "Account, Contact, Task", "Account, Contact", "Lead, Opportunity, Campaign", "Account, Contact (no Lead/Opp)", "Account, Contact, Lead", "Contact, Account"],
  ["Apex evidence", "Triggers on 7 objects, REST", "Unknown", "REST, email service, jobs", "Unknown", "Unknown", "27 named triggers, REST", "Unknown", "Public Apex API"],
  ["UI tech evidence", "VF + Lightning SPA", "Unknown", "LWC (agentChat), grids", "Unknown", "Lightning, Scribe-observed", "LWC + Aura named", "VF / Flash (inferred)", "Scheduler component"],
  ["Flow / automation", "Process Builder named", "Nightly sync", "2 Flows named", "Scheduled alerts, approval", "Cadence engine", "2 Flows named", "Action plans", "10 Flow templates"],
  ["Data model complexity", "High", "Medium-high", "High", "Medium-high", "Medium", "High", "Low (inferred)", "Medium"],
];

const objectMap = [
  ["People / company", "Contact + shadow Account", "Account, Contact", "Account, Contact", "Company, Contact", "Lead → Account, Contact", "Account, Contact, Address", "Account, Contact", "Reservation Contact"],
  ["Demand", "pba__Request__c", "Prospect, Pursuit", "Inquiry, Preference", "Inquiry / Requirement", "Lead (Prospect RT)", "eLead, Inquiry", "Lead (inferred)", "—"],
  ["Inventory", "pba__Property__c", "McLabs2__Property__c", "Property", "Property", "Property (PSAI)", "Address", "Property, Building (inf.)", "B25__Resource__c"],
  ["Unit / space", "Child Property", "Space", "Availability, Unit", "Space / Unit", "—", "—", "Unit (inferred)", "Resource hierarchy"],
  ["Listing", "pba__Listing__c", "McLabs2__Listing__c", "Listing", "Listing stage", "Investor Portal listing", "—", "Website availability", "—"],
  ["Pipeline", "Offer chain", "Deal / Pursuit → Project", "Deal (12 RT)", "TTL_Core__Deal__c", "Opportunity", "Sales Opportunity", "Opportunity (inf.)", "—"],
  ["Outcome", "pba__Closing__c, Transaction", "Closed Deal, Comp", "Lease, Sale", "Comp", "Transaction", "Sale, Project", "Lease (inferred)", "B25__Reservation__c"],
  ["Money", "Closing fields, Payments", "Commission, Invoice", "Commission", "Invoice", "Transaction Expense", "Payment, Commission", "Unknown", "Pricing plugin"],
  ["Scheduling", "Event (Showing)", "Activities", "Task / Event", "Action Plan", "Event, Cadence", "Sales Appointment, Time Block", "Reservation (inf.)", "Reservation, Availability"],
];

const processCmp = [
  ["1 Initial lead", "Front Desk / WebToProspect", "Prospecting console", "Inquiry: web, portal, Harvest", "Prospect and call lists", "Lead: marketing, dialer, DealSignals", "eLead / Quick Lead", "Lead (inferred)", "Widget, API or internal booking"],
  ["2 Customer created", "Contact (dedupe, enrich)", "Account / Contact", "Convert → Account, Contact, Deal", "Company / Contact", "Convert → Account, Contact, Opp", "Account + Contact + Address", "Account / Contact", "Contact linked to reservation"],
  ["3 Property / service", "Matching → Linked Listings", "Property, Space, Assignment", "Prospective Listings, automatch", "Inquiry, Site Selection", "Property on lead; PSAI match", "Territory, Time Block, Dispatcher", "Unit on floor plan", "Resource + Staff availability"],
  ["4 Deal created", "Offer on Listing", "Pursuit or Deal", "Deal by record type", "Deal in 1 of 4 pipelines", "Opportunity", "Sales Opportunity + Appointment", "Opportunity (inferred)", "Reservation"],
  ["5 Activities", "Showings, drips, action plans", "Tours, Buildout marketing", "Rent tables, Composer, tasks", "Tours, RFP, action plans", "Appointment, cadences, SMS", "In-home demo, quote", "Tours, action plans", "—"],
  ["6 Negotiation / approval", "Counter, reserve, accept", "Offers, stages", "Stages incl. LOI", "LOI / Offers stage", "Negotiation, Last Offer Made", "Result wizard; Sale In Review", "Unknown", "Conflict check, status"],
  ["7 Contract", "Closing from Offer", "Project (Escrow)", "Close Deal dialog", "Escrow / Lease Execution", "Contract Signed → Transaction", "Sale Approved → Net", "Lease (inferred)", "Reservation confirmed"],
  ["8 Completion", "Closing Closed; Listing Sold", "Closed Deal + Comp", "Lease / Sale created; Availability Closed", "Closed → comp auto-created", "Transaction path to close", "Project complete", "Unit Occupied / Sold", "Reservation completed"],
  ["9 After", "Transaction sync, payments", "Book Lease Wizard, invoices", "Expiry reminders 18/12/6", "Invoice approval, prior tenant", "Dispositions, Investor Portal", "Payments, commission, survey", "Occupancy reports", "Notifications, calendar sync"],
];

const integrationCmp = [
  ["Propertybase", "Front Desk portal emails, WebToProspect, Workspace / BackAgent", "Portal feeds, Mailservice, SMS", "Boston Logic sites, Dotloop", "Agentforce lead scoring (claim)"],
  ["Apto", "—", "—", "Buildout (one-way, button + nightly)", "Not documented"],
  ["AscendixRE", "LoopNet / Crexi, Web-to-Inquiry, Harvest email", "Google Maps, Composer", "MarketSpace, Mailchimp, Claude / ChatGPT Connector", "AI Suite (Harvest, Agent, Composer AI)"],
  ["REthink CRM", "Owner data (Rethink+)", "Email alerts", "Buildout Showcase, Mailchimp, Constant Contact, Outlook / Gmail", "Claude via third-party MCP"],
  ["Left Main REI", "DealSignals, Property Sales AI, web leads", "PostcardMania, QuickBooks (expenses)", "Vonage, Dialpad, CallRail, smrtPhone, RingCentral; Investor Portal", "Next Best Action, Claude MCP connector"],
  ["improveit 360", "Lead vendors, Five9, Hatch", "PaySimple, QuickBooks via DBSync, GuildQuality", "Vendo, OneClick, SalesPro / Leap, Twilio", "Not documented"],
  ["Real Properties", "AutoCAD drawings", "Websites, email marketing", "Outlook, Word, Excel; Google Maps", "None"],
  ["Booker25", "Booking widget, REST API", "Notification Flows, ICS invites", "Outlook / Google calendar sync", "Agentforce / MCP tools (GMCopilot__)"],
];

module.exports = { APPS, KEYS, landscape, ratings, features, tech, objectMap, processCmp, integrationCmp };
