# Left Main REI — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [L3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

Research note: Left Main runs a public documentation site at `docs.leftmainrei.co` (index at `/llms.txt`, ~140 articles) [L8]. Many "how-to" articles are embedded Scribe walkthroughs (scribehow.com, published by Left Main); their step text and screenshots were viewed in a browser (no files downloaded) and are labelled **Observed** — they show Left Main's own demo/training org, so picklist values seen there are Left Main's shipped/default configuration as of the screenshot date, not guaranteed in every customer org. G2 blocked direct fetch (403); ratings come from search snippets.

---

## 0. Identity and status

| Item | Finding | Label | Source |
|---|---|---|---|
| Product name | "Left Main REI"; core product "Left Main® Core" / "Left Main® CRM"; AI suite "Left Main Genius" (Property Sales AI®, DealSignals®, DispoSignals); "Left Main Exchange" / "LMX Investor Portal"; app label in org "Left Main+" | Verified / Observed | [L1][L2][L3][L38][L11] |
| Publisher | Left Main REI, Inc., Charlotte, North Carolina; CEO/founder Stephanie Betters (real-estate investor; "building and flipping 200+ homes per year") | Verified | [L1][L51] |
| Year | Launched on the Salesforce AppExchange in 2020 (Scale-to-Sale podcast snippet); third-party directories give 2019. | Inferred (secondary sources only) | [L50] |
| Funding | Seed / strategic investment from Cofounders Capital announced May 2025 to expand "Left Main Genius" AI suite; earlier Nov-2024 funding release ("Secures new funding, launches suite of AI-powered real estate applications"). | Verified (press releases via search snippets) | [L51] |
| Status | **Active, actively developed.** Release notes v1.630 dated 2026-10-15 [L32]; pricing checked by vendor 2026-10-18 [L6]. Not acquired or renamed. | Verified | [L32][L6] |
| Native vs integrated | **Native on Salesforce.** "Built on Salesforce", "Powered by Salesforce", Salesforce Consulting Partner badge [L1]; installed package "Left Main" visible under Setup → Installed Packages [L30]; every plan includes Salesforce Enterprise Edition licensing, can install into an existing org or provision a new one [L3][L6]. | Verified | [L1][L3][L30] |
| Package / namespace | Installed package name "Left Main"; version series v1.5xx–v1.630 [L30][L32]. Namespace **`Left_Main__`** evidenced by published Lightning page API name `Left_Main__Property_Sales_AI_Sign_Up` [L37][L38]. | Verified | [L30][L37] |
| AppExchange listing | Not located in searches; listing id Unknown. | Unknown | — |
| Scale | "Over 300 clients", "20+ team members", "15+ Real Estate Solutions Included with Built-In Package", "100+ SMS and task sequence templates", "400+ stock reports" (Copado case study 2024-04-11) [L46]; "used by over 3,000 real estate professionals" (funding coverage snippet) [L51]. | Verified (vendor-endorsed case study) | [L46][L51] |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| G2 — Left Main | 4.8/5, 12 reviews | 4.8/5 (search snippets, 2026-11-12) | **8** (product reviews page) / **10** (seller page: nine 5★, one 4★) | https://www.g2.com/products/left-main/reviews ; https://www.g2.com/sellers/left-main-rei | Direct fetch HTTP 403. Rating matches supplied value; **review count does not** — snippets show 8 or 10, not 12 (G2 page may have grown since snippet indexed; cannot confirm). |
| Trustpilot | — | TrustScore 0 / no reviews shown (snippet) | 0 | https://www.trustpilot.com/review/leftmainrei.co | — |
| Google reviews | — | "100+ Google reviews" claimed on vendor homepage | — | https://leftmainrei.co/ | Vendor claim, not checked. |
| Slashdot/SourceForge | — | No user reviews | 0 | https://slashdot.org/software/p/Left-Main/ | — |

## 2. Overview (12 questions)

1. **What it is** — Salesforce-native CRM for real-estate investment companies (wholesalers, fix-and-flip, BRRRR, rental, also commercial investors): leads → opportunities → transactions, buyer management/dispositions, multichannel cadences, dashboards, plus AI/data add-ons. **Verified** [L1][L2][L9]
2. **Developer** — Left Main REI, Charlotte NC. **Verified** [L1]
3. **Industry** — Residential (and commercial) real-estate investing. **Verified** [L1]
4. **Target users** — Lead managers, acquisition reps, inside sales agents (ISAs), disposition teams, transaction coordinators, marketing, leadership (L10). **Verified** [L5][L9][L26]
5. **Problems solved** — Speed to lead, consistent follow-up, pipeline visibility from marketing spend to revenue, buyer matching, stale-lead revival, closing out leads already sold. **Verified** [L2][L5][L22]
6. **Major functions** — Lead management, acquisition appointments, offers, transaction management (Kanban), interested buyers, Cadence Library (SMS/email/task/direct mail), click-to-dial CTI, dashboards (Leadership/L10, Marketing, Lead Management, Acquisitions, Dispositions, Transactions), property data (ATTOM), mobile "drive for dollars", QuickBooks expense sync, Investor Portal, DealSignals, DispoSignals, Property Sales AI, Next Best Action, Retail App, Claude connector. **Verified** [L2][L3][L6][L8]
7. **Differentiators** — Investor-specific objects (Transactions, Interested Buyers), Cadence Library with automations/chaining/after-hours response, Property Sales AI auto-closing sold leads, DealSignals distress data, DispoSignals buyer intelligence, Salesforce licences bundled. **Verified** [L3][L16][L22][L24][L27]
8. **Native/integrated** — Native Salesforce package "Left Main" (namespace `Left_Main__`). **Verified** [L30][L37]
9. **Editions/licences required** — Salesforce Enterprise Edition licensing included in all plans [L3][L6]; Salesforce Maps optional ($45/user/mo per competitor) [L8][L48]. **Verified**
10. **Pricing & licensing** — Starter $500/mo + $3,000 implementation (5 users); Launch $1,200/mo (implementation included; DealSignals *or* DispoSignals, Property Sales AI, 5 PS hours; 10 users per vendor guide); Enterprise $2,000/mo (DealSignals *and* DispoSignals, LMX Investor Portals, 10 users, 60 PS hours, cadence configuration); extra users $80/user/mo; Investor Portal add-on $250/mo; annual contract billed monthly; phone/SMS usage billed by provider. **Verified** [L3][L6]
11. **Managed/unmanaged** — Installed package with versioned push rollouts in batches ("your org may still be in the rollout process") [L30][L34]. Namespace prefix present. **Inferred managed** (namespace + push upgrades).
12. **Limitations & dependencies** — Requires a CTI partner for SMS (five supported: Vonage, Dialpad, CallRail, smrtPhone, RingCentral) [L33]; Direct Mail cadences only on Leads/Opportunities [L42]; competitor-reported contract terms (≤75 employees warranty, seat reductions only at anniversary) [L48]; Salesforce security/MFA constraints [L8]; Notes export limitations [L8]. **Verified** [L33][L42]; competitor claims [L48] as third-party.

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Lead management | Intake (manual, web/Carrot, PPL, Launch Control push, Mail Parser), status path, unqualified reasons, routing to cadences | Lead managers, ISAs | Lead Source, Status, Unqualified Reason, Reason for Selling, Contacted, Next Step, Mobile, address, Do Not Mail, Allow Mail to Closed/Lost Opp Or Leads, Allow More Than 1 Mail Piece Every 30 Days | Campaigns, Cadences, DealSignals, Property Sales AI | Speed-to-lead automation | Verified/Observed | [L9][L13][L10][L16][L45] |
| Acquisitions (Opportunities) | Converted lead → Account + Opportunity; appointment scheduling, deal analysis (rehab, MAO), negotiation, offers, contract | Acquisition reps | Stage, Appointment Date/Time, Last Offer Made, Rehab Level, Estimated Rehab $, Estimated Rehab Costs, MAO, Closed/Lost Reason, Number_Outbound_Calls__c | Account, Contact Roles, Events, Cadences, NBA, DispoSignals | — | Verified/Observed | [L10][L11][L12][L19][L38] |
| Transaction management | Created when Opportunity closes as Contract Signed; path through closing; assigned buyer; profits; expenses; commission | Transaction coordinators, dispo | Transaction Name, Opportunity, Contract Purchase Price, Contract Assignment Price, Projected Wholesale Profit, Projected Flip Profit, Assigned Buyer, Assigned Buyer Contact, Closing Date, Closing Attorney, Path, Acquisition Rep | Interested Buyers, Transaction Expenses, Investor Portal, QuickBooks | Kanban "Disposition & Transaction Management" | Verified/Observed | [L9][L11][L2] |
| Dispositions / buyers | Buyers list on Contacts (buy box), Interested Buyers on Transactions, offers, buyer matching, DispoSignals buyer search | Dispo team | Preferred location, property types, typical financing; Offer, Offer Type, Asking Price Offer, Offer Notes | Transaction, Contact, Investor Portal | — | Verified/Observed | [L7][L9][L14][L27] |
| Cadences / Cadence Library | Multichannel sequences (SMS, email, tasks, direct mail) with timeline, automations, chaining, after-hours | Everyone | Cadence, scheduled email/SMS/task records, status, Stopped Reason | Leads, Opportunities, Contacts, Transactions, Interested Buyers | Consistent follow-up | Verified | [L15][L16][L42] |
| Direct mail (PostcardMania) | Mail pieces as cadence steps; designed in PostcardMania app in Salesforce (released 2026-04-29); legacy direct mail end-of-life | Marketing | Mail templates, "Direct Mail Last Offer Made" (used for Check Letter 8A) | Leads, Opportunities, Campaigns | — | Verified/Observed | [L43][L11] |
| Calling / SMS (CTI) | Click-to-dial, softphone, SMS via partner CTI | Reps | Call/SMS logs (provider-dependent) | All cadence objects | — | Verified | [L44][L33] |
| Campaigns | Salesforce Campaigns for marketing (direct mail), Campaign Members with status | Marketing | Member Status (e.g. "Sent"), Lead Source | Leads | Lead-source ROI | Verified | [L52b] |
| Dashboards & reports | Department dashboards with reference ranges; 400+ stock reports | Leadership | KPIs | All | — | Verified | [L5][L6][L46] |
| DealSignals | Distress-signal enrichment, Prospect lead creation, Hot List, Intent Score, Contacted/Snooze | Acquisitions | Signals, Intent Score, enrichment fields, Verified Ownership, DNC indicator | Leads, Opportunities | Revives stale leads | Verified | [L24][L25][L26][L34][L40] |
| Property Sales AI | Weekly county sold-data match; auto-close sold Leads/Opps; market insights | Leadership, acquisitions | Property Sales records, matches, history | Leads, Opportunities, Subscriptions | Stops spend on sold properties | Verified | [L22][L23][L39] |
| DispoSignals | Investor activity/summary, investor/retail/CRM comps, buyer search (≤30 buyers) | Acquisitions (pricing), dispo | Analysis runs, buyer contacts | Opportunity, Transaction, Contact, Interested Buyer | Pre-contract buyer validation | Verified | [L27][L53b][L32][L34] |
| Investor Portal (Left Main Exchange) | Branded private buyer marketplace; publish from Transaction; registrations → Contacts; offers → Interested Buyers; funding partners | Dispo team, buyers | Views, saves, inquiries, offers | Transaction, Contact, Account, Interested Buyer | Replaces email blasts | Verified | [L4][L7][L29][L28] |
| Next Best Action | Salesforce NBA strategy/recommendations, incl. a "Set Appointment" flow and Opportunity Strategy Builder; "Deal Analysis" recommendation seen on Opportunity | Acquisition reps | — | Opportunity | Guided selling | Verified (titles) / Observed | [L53][L11] |
| Retail App | Retail (listing/retail exit) leads and opportunities; convert lead/opp to retail | Retail/agent team | Retail lead status/stage, Retail Opportunity Process | Lead, Opportunity | — | Verified (titles) / Observed | [L8][L12][L13] |
| QuickBooks Online | One-way QBO → Left Main vendor expenses for marketing ROI | Leadership/finance | Vendor expenses | Quarterly Marketing dashboard | — | Verified | [L41] |
| Claude connector | Claude via Salesforce-hosted MCP server (External Client App, mcp_api scope) | All | Records/metadata | All | — | Verified | [L31][L6] |
| Support tab | "Left Main Support" tab to submit cases; Ticket Type incl. "Professional Services" | Admins | Case | Left Main support | — | Verified | [L37] |

## 4. Data model

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields (labels) | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Lead | `Lead` | Standard (extended with RE fields/layouts) | Seller lead workspace for acquisitions | Status (Lead Status), Unqualified Reason (dependent on Status), Lead Source, Reason for Selling, Contacted, Next Step, Mobile, Description, Fax, Company Name, address, Do Not Mail, Allow Mail to Closed/Lost Opp Or Leads, Allow More Than 1 Mail Piece Every 30 Days; DealSignals: First Enrichment, Date/Time Contacted After Enrichment, Enrich Event, Last Enrichment Date; record type **Prospect** | — | Cadences, Tasks, Campaign Members, PSAI matches | Verified/Observed | [L9][L13][L10][L25][L37][L16] |
| Account | `Account` | Standard | Seller household / company; buyers, investors, vendors | Standard; Person Account in use for Transactions' "Mobile Phone" | — | Opportunity, Contact | Verified | [L9][L15] |
| Contact | `Contact` | Standard | People incl. **buyers list** (buy box, history) | Mobile, preferred location, property types, typical financing, Generated From Opportunity/Transaction | Account | Interested Buyers, Cadences | Verified | [L9][L7][L33] |
| Person Account | `Account` (IsPersonAccount) | Standard | Contact data on Transactions ("Mobile Phone (via Person Account)") | Mobile Phone | — | — | Verified (mentioned) / Inferred (org has Person Accounts enabled) | [L15] |
| Opportunity | `Opportunity` | Standard | Acquisition deal after lead conversion | Stage, Closed/Lost Reason (dependent on Stage), Appointment Date/Time, Last Offer Made, Direct Mail Last Offer Made, Rehab Level, Estimated Rehab $, Estimated Rehab Costs, MAO, `Number_Outbound_Calls__c`, DealSignals enrichment fields; sales processes **"Opportunity Process"**, **"Retail Opportunity Process"** | Account | Transaction, Events, Contact Roles, Cadences, Stage History, Opportunity Field History | Verified/Observed | [L11][L12][L19][L38][L25] |
| Transaction | Unknown. `Proposed:` `Left_Main__Transaction__c` | Custom | Under-contract deal for TC/dispo | Transaction Name (address), Opportunity (lookup), Phone, Email, Closing Date, Closing Attorney, Path (picklist), "…e Closing?" (truncated), Acquisition Rep, Contract Purchase Price (= last offer), Contract Assignment Price, Projected Wholesale Profit, Projected Flip Profit, Assigned Buyer, Assigned Buyer Contact; commission details (Left Main Commission permission set) | Opportunity | Interested Buyers, Transaction Expenses, Transactions History, Notes, Files, Cadence scheduled items | Verified (object, rules) / Observed (fields) | [L9][L11][L37] |
| Interested Buyer | Unknown. `Proposed:` `Left_Main__Interested_Buyer__c` | Custom (junction Transaction↔Contact) | Buyer interest and offers on a transaction | Interested Buyers Name (req), Transactions (lookup, req), Contact (lookup), Offer (currency), Offer Type (picklist), Asking Price Offer (checkbox), Offer Notes, SMS Opt out - obsolete, Mobile Phone | Transaction | Cadence items | Verified/Observed | [L9][L14] |
| Transaction Expense | Unknown | Custom | Costs on a transaction | Unknown | Transaction | — | Observed (related list "Transaction Expenses") | [L11] |
| Transactions History | Unknown (likely field history) | Standard history | Field history on Transaction | — | Transaction | — | Observed | [L11] |
| Cadence | Unknown label "Cadence" (Object Manager) | Custom | A cadence applied to a record | Cadences Name, Stop Cadences, Folder Email Template, Folder SMS Template, Folder Task Template, Stopped Reason (values incl. "Completed"), Stopped Timestamp; record flags "has cadence", "stop cadence" | Lead/Opportunity/Contact/Transaction/Interested Buyer | Scheduled Email/SMS/Task | Verified | [L15][L17][L40] |
| Cadence Scheduled Email | Unknown | Custom | Queued cadence email | Time to be dispatched, Email, Frequency, Sequence, Status | Cadence | — | Verified | [L15] |
| Cadence Scheduled SMS | Unknown | Custom | Queued cadence SMS | SMS Follow Up Sequence, Status, Folder, Object, Type of Schedule, # Schedule, SMS Body | Cadence | — | Verified | [L15] |
| Cadence Scheduled Task | Unknown | Custom | Queued cadence task | Cadence Scheduled Task Name, Cadence, Frequency to Flow, Status, Related Record ID | Cadence | Task | Verified | [L15] |
| Cadence Direct Mail | Unknown | Custom | Leads/Opps on a direct-mail cadence | — | Lead/Opportunity | — | Verified | [L15] |
| Email Follow Up Sequence | Unknown | Custom (template) | Email step templates | Lead Follow Up Sequence Name, Email Template Name, From Email | — | — | Verified | [L15] |
| SMS Template Follow Up Sequence | Unknown | Custom (template) | SMS step templates | (as SMS scheduled) | — | — | Verified | [L15] |
| Task Follow Up Sequence | Unknown | Custom (template) | Task step templates | Task Follow Up Sequence Name, Task Cadence Folder, Task Subject, Owner First Name | — | — | Verified | [L15] |
| Direct Mail Follow-Up Sequence | Unknown | Custom (template) | Mail step templates | — | — | — | Verified | [L32] |
| Cadence Library | Unknown | Custom (config) | Container of multichannel steps on a timeline | Status (Draft, Active; Archived mentioned), steps, days between | — | steps | Verified | [L42][L18] |
| Property | Unknown (label "Properties") | Custom | Sold-property hub tracking multiple sale events per address | custom roll-up of unique sales (admin article) | — | Property Sales | Verified | [L22][L8] |
| Property Sales | Unknown | Custom | County sold-transaction feed | Property Address, County, Recording Date, Sales Price, Estimated Value, Tax Assessed Value, Seller/Buyer names, Buyer Mailing Address, Owner Occupant (formula), LFID | Property | — | Verified | [L22][L23][L39] |
| Property Sales AI Matches | Unknown | Custom | Confirmed Lead/Opp ↔ sold property matches | — | Lead/Opportunity, Property Sales | — | Verified | [L22] |
| Property Sales AI History | Unknown | Custom | Match history; confirm/reject | — | — | — | Verified | [L22] |
| Property Sales AI Administration Panel | Unknown (setup wizard) | Config | Lead/Opp preferences, address matching | record types, lead statuses, opp stages, address fields, auto-update toggle | — | — | Verified | [L22][L21] |
| Subscription | Unknown | Custom | County data subscriptions | Property Sale Duration (days) | — | — | Verified | [L22][L39] |
| DispoSignals runs | Unknown ("DispoSignals runs object") | Custom | Stored analysis runs | — | Opportunity/Transaction (Inferred) | — | Verified (mention) | [L53b] |
| Campaign / Campaign Member | `Campaign`, `CampaignMember` | Standard | Marketing/direct mail | Member Status ("Sent") | — | — | Verified | [L52b] |
| Task / Event | `Task`, `Event` | Standard | Activities; Event subject "Acquisition Appointment…" drives Appointment Date/Time | Subject, Related To | Opportunity | — | Verified | [L19][L20] |
| Case | `Case` | Standard | Left Main Support tab tickets (Ticket Type) | Ticket Type ("Professional Services") | — | — | Verified | [L37] |

**Relationships (found)**
- Lead → converts to Account + Opportunity (+ Contact implicit in standard convert); conversion only via Convert button or Status Path "Converted" → "Mark Status as Complete". Observed [L10]
- Account 1—* Opportunity; Account 1—* Contact. Verified [L9]
- Opportunity 1—* Transaction (created when Opportunity closed as "Contract Signed"; Transaction shows Opportunity lookup; reached via "Transactions" related quick link). Verified/Observed [L9][L11]
- Transaction 1—* Interested Buyer; Interested Buyer → Contact (lookup); also shown on Contact. Verified/Observed [L9][L14]
- Transaction → Assigned Buyer / Assigned Buyer Contact (lookups). Observed [L11]
- Cadence → generates Tasks (and scheduled email/SMS records). Verified [L9][L15]
- Property 1—* Property Sales; Property Sales AI Matches link Lead/Opportunity ↔ Property Sales. Verified [L22]
- Investor Portal registration → Contact (create/match), Account sync, Interested Buyer, offers. Verified [L29]

**Record types / sales processes (found)**
- Lead record type **Prospect** (DealSignals-created). Verified [L24][L25]
- Opportunity sales processes **"Opportunity Process"** and **"Retail Opportunity Process"**. Observed [L12]
- Retail leads/opportunities (Retail App; "Convert a Lead or Opportunity to a Retail Lead or Opportunity"). Verified (title) [L8]
- Transaction record types: Unknown (buttons "Renovation Project", "New Build Project" observed — may create related project records). Observed [L11]

**Picklist values (found)**
- **Lead Status** (Left Main training org, picklist modified 2024-08-13, screenshot 2025): New (default) · Working · Follow Up · Qualified (Converted = true) · Unqualified · Retail; inactive: Contacted (+1 other). Observed [L13]
- **Lead path** (older 2023 screenshot): New → Working → Marketing test → Unqualified → Retail → Converted. Observed [L10] ("Marketing test" looks like a demo value).
- **Opportunity Stage** (Left Main training org, 2025): Pending Appointment (Open, 10%, Pipeline) · Appointment Set (Open, 20%, Pipeline) · Follow-up (Open, 30%, Pipeline) · Long Term Followup (Open, 25%, Pipeline) · Negotiation (Open, 90%, Commit) · Retail (Closed/Won, 100%, Closed) · Contract Signed (Closed/Won, 100%, Closed) · Closed Lost (Closed/Lost, 0%, Omitted) · Sold - PSAI (Closed/Lost, 0%, Omitted — added in the tutorial for Property Sales AI). Observed [L12]
- **Unqualified Reason** (dependent on Lead Status) value "Already sold (Property Sales AI)". Verified [L22]
- **Closed/Lost Reason** (dependent on Stage) value "Already sold (Property Sales AI)". Verified [L22][L12]
- **Transaction Path** (2023 screenshot; labels truncated in UI): New Con[tract] · Docs Sen[t] · Title Issu[e…] · Need Dis[…] · Awaiting … · Pending … · Pending … · Clear to … · Clear to … · Closed/… · Contract …; field "Path" value "New Contract". Observed [L11]. Full labels **Unknown**; `Proposed` reading (ours): New Contract, Docs Sent, Title Issues, Need Dispo, Awaiting …, Pending …, Pending …, Clear to Close …, Clear to Fund/Close …, Closed/Won-type, Contract Cancelled — **Inferred only**.
- **Cadence Library status**: Draft, Active (Archived referenced). Verified [L42][L18]
- **Cadence Stopped Reason**: includes "Completed" (others: manual action, automation). Verified [L17][L40]
- **Scheduled step status**: "COMPLETED", "Canceled"; timeline shows completed/failed/pending. Verified [L15][L40][L42]
- **Campaign Member Status**: "Sent". Verified [L52b]
- **DealSignals Lead Source** value: "DealSignals". Verified [L24][L25]
- **DealSignals signals**: First Up (Death Notices), Probate, Tax Default, Eviction, Pre-Foreclosure, Vacant, Expired Listing, Absentee Owner, Default/Lis Pendens, Divorce, Utility Lien. Verified [L26]
- **Launch Control push statuses**: warm, hot, nurture (partner page). Verified (partner) [L45]
- **Offer Type** values: Unknown.

**Formulas / roll-ups / validation / IDs (found)**
- Owner Occupant (formula on Property Sales) → Investor Sales report. Verified [L22]
- Opportunity: "Last Offer Made" must be populated or save errors when closing to Contract Signed (validation rule or trigger). Observed [L11]
- Transaction Contract Purchase Price = last offer (automation). Verified [L9]
- Custom roll-up of unique Property Sales per Property (admin how-to). Verified (title) [L8]
- Projected Wholesale Profit / Projected Flip Profit — likely formulas. Inferred [L11]
- LFID unique identifier on Property Sales (duplicate logic with Property Sale Duration). Verified [L39]

**ERD edge list**
```
Lead -> Account (convert) [Observed]
Lead -> Opportunity (convert) [Observed]
Account -> Contact (lookup) [Verified]
Account -> Opportunity (lookup) [Verified]
Opportunity -> Transaction (lookup on Transaction; created at Contract Signed) [Verified]
Opportunity -> Event (Acquisition Appointment) [Verified]
Opportunity -> OpportunityContactRole [Observed]
Transaction -> Interested Buyer (child, lookup required) [Observed]
Contact -> Interested Buyer (lookup) [Observed]
Transaction -> Contact (Assigned Buyer Contact) [Observed]
Transaction -> Transaction Expense (child) [Observed]
Lead|Opportunity|Contact|Transaction|Interested Buyer -> Cadence (child) [Verified]
Cadence -> Cadence Scheduled Email|SMS|Task (child) [Verified]
Cadence Scheduled Task -> Task [Verified]
Cadence Library -> (steps referencing Email/SMS/Task/Direct Mail Follow Up Sequences) [Verified/Inferred]
Lead|Opportunity -> Cadence Direct Mail [Verified]
Property -> Property Sales (child) [Verified]
Lead|Opportunity <-> Property Sales via Property Sales AI Matches (junction) [Verified]
Subscription (county) -> Property Sales (feed) [Inferred]
Campaign -> CampaignMember <- Lead [Verified]
Opportunity|Transaction -> DispoSignals runs [Inferred]
```

## 5. Technical components

| Area | Verified | Inferred | Unknown |
|---|---|---|---|
| Package | Installed package "Left Main"; versions e.g. v1.529, v1.534, v1.535, v1.541, v1.569, v1.587, v1.594, v1.606, v1.611, v1.615, v1.616, v1.620, v1.624, v1.625, v1.630 [L30][L32–L40]; batch rollouts [L34]; namespace `Left_Main__` [L37] | Managed package | Package id |
| Apex | — | Cadence scheduler/dispatcher, CTI SMS callouts (credentials in "protected, private storage" — likely protected custom settings/metadata or named credentials) [L32][L33]; PSAI weekly matcher; DealSignals enrichment | Class names |
| LWC / Aura / VF | "Enriched Property Data Lightning Web Component" (DealSignals) [L40]; "DealSignals component" on page layout [L25]; DispoSignals tab with list/map views [L27][L34]; Lightning page `Left_Main__Property_Sales_AI_Sign_Up` [L37]; "Left Main Support" tab [L37]; record timeline of cadence steps [L42]; "Past Date Cadence Steps" section [L33] | LWC for Cadence Library builder | Component API names |
| Flows | "Enrichment Flow" (DealSignals) [L40]; NBA "Set Appointment" flow (article: "Modify Opportunity Stage Verbiage in the NBA - Set Appointment Flow") [L53]; customers use record-triggered flows that Cadence Automation Readiness Check scans [L17]; "Frequency to Flow" field [L15] | — | Flow API names |
| Next Best Action | NBA strategies/recommendations; "Opportunity Strategy Builder" [L53]; recommendation "Deal Analysis for <address>" Observed [L11] | Einstein NBA (Strategy Builder) | Strategy names |
| Approval | "Submit for Approval" button on Lead (Observed) [L10] | Standard approval process | Process names |
| Security | Permission sets: **Left Main User**, **Left Main User (Salesforce Required)**, **Left Main Extra**, **Left Main Cadences**, **Left Main Cases**, **Left Main Commission**, **Left Main Dispo**, **Left Main Direct Mail Mapping Access**, **Left Main DispoSignals Admin**, **Left Main DispoSignals User**, **Left Main Dispo User**, **Property Sales AI Admin**, **Property Sales AI Full User**, **Property Sales AI User** [L37][L35][L53b][L22]; "Left Main User Permission Set" label in 1.587 [L36]; Salesforce MFA/passkeys/VPN freeze guidance [L8] | — | Profiles |
| Trusted sites / remote | Trusted Site `GoogleMaps_StreetView` must be activated (v1.630) [L32] | Remote site settings for CTI providers | — |
| Integrations | External Client App + Salesforce-hosted MCP (mcp_api scope) for Claude [L31]; QuickBooks Online one-way [L41]; PostcardMania in-org app [L43]; CTI packages per provider [L44] | — | Named credentials |
| Mobile | "Mobile CRM" with route optimisation / drive for dollars [L2]; Salesforce Maps optional licence [L8] | Salesforce mobile app + Salesforce Maps | — |
| DevOps | Copado pipeline + GitHub, per-developer sandboxes (vendor engineering) [L46] | — | — |

## 6. Business processes

### 6.1 Seller lead intake → qualification → conversion (acquisitions front end)
**Start trigger:** a seller lead arrives (web form/Carrot, PPL, Launch Control push, DealSignals Prospect, manual entry, inbound call). [L2][L45][L25]
1. **Initiation**
   - Lead record created; Lead Source set (e.g. "DealSignals"; Google Ads); Status = **New** (default). Verified/Observed [L13][L25][L52b]
   - DealSignals path: new Lead with Record Type **Prospect**, skip-traced contacts; or existing Lead/Opportunity enriched. Verified [L25]
2. **Data processing**
   - Cadence Automations route new Lead to a Cadence Library by Lead Source / Status / Reason for Selling. Verified [L16]
   - After-hours: one acknowledgment message, cadence resumes in business hours. Verified [L18]
   - Speed-to-lead tasks/SMS/email/call tasks; click-to-dial via CTI. Verified [L2][L44]
3. **Business operations**
   - Lead manager works lead: Status **Working** → **Follow Up**; "Contacted" checkbox; Next Step; DealSignals "Contacted"/"Snooze" (30-day follow-up task). Observed/Verified [L13][L10][L24]
   - Direct mail via Campaigns/Direct Mail cadence ("Create Direct Mail Cadences" action on Lead). Observed/Verified [L10][L43]
4. **Decision**
   - Qualified → **Convert** (Convert button or Status path "Converted"/"Qualified" → Mark Status as Complete; editing the Status field on the layout does NOT convert) → New Account + New Opportunity; record type changed only if needed. Observed [L10]
   - Not qualified → Status **Unqualified** + Unqualified Reason (incl. "Already sold (Property Sales AI)"). Verified/Observed [L13][L22]
   - Retail exit → Status **Retail** / convert to Retail lead (Retail App). Observed/Verified [L13][L8]
5. **Completion**
   - Account + Opportunity created; cadence-stop automation on convert (Cadence Setup → Automations "stop Cadences when leads convert or receive inbound communication"). Verified [L40]
6. **Post-completion**
   - Unconverted leads: long-term nurture libraries; chaining to next library when complete. Verified [L18]
   - Property Sales AI weekly match may auto-set Unqualified when county records a sale. Verified [L22][L23]
   - DealSignals revives inactive leads on new distress signal. Verified [L24]
- **Alternate paths:** duplicate handling (custom duplicate data report) [L8]; Launch Control push (one-click, one-way) [L45]; cancellation = Unqualified.

### 6.2 Acquisition opportunity → appointment → offer → contract (Opportunity pipeline)
**Start trigger:** Lead conversion creates Opportunity (Stage typically **Pending Appointment**). [L12][L10]
1. **Initiation**
   - Opportunity Stage **Pending Appointment**; NBA "Set Appointment" recommendation/flow (stage verbiage editable). Observed/Verified [L12][L53]
2. **Data processing**
   - Rep creates Event with Subject starting "Acquisition Appointment" related to the Opportunity → automation fills **Appointment Date/Time** (most recently created event wins; edits to Event don't update). Stage → **Appointment Set**. Verified [L19][L20]; stage move Inferred from stage list.
   - Cadence Automations transition record into appointment-reminder/confirmation library when appointment scheduled. Verified [L16][L19]
3. **Business operations**
   - Deal analysis: Rehab Level, Estimated Rehab $, MAO; NBA "Deal Analysis" card; DispoSignals Full Property Analysis (Investor Activity, Investor Summary, Investor Comps, Retail Comps) and CRM Comps for pricing/exit. Observed/Verified [L11][L53b]
   - Offers: "Last Offer Made" recorded; stages **Follow-up**, **Long Term Followup**, **Negotiation** (90%). Observed [L11][L12]
4. **Decision**
   - Accepted → click "Closed" on Stage Path → "Select Closed Stage" → **Contract Signed** (Closed/Won). "Last Offer Made" required. Observed [L11]
   - Retail exit → **Retail** (Closed/Won) via Retail Opportunity Process. Observed [L12]
   - Lost → **Closed Lost** + Closed/Lost Reason; or **Sold - PSAI** / "Already sold (Property Sales AI)" when county shows sale. Observed/Verified [L12][L22]
5. **Completion**
   - Transaction auto-created; Contract Purchase Price = last offer; accessed via "Transactions" related quick link. Verified/Observed [L9][L11]
6. **Post-completion**
   - Cadences stopped/transitioned by stage rules ("An Opportunity reaching a selected stage"). Verified [L16]
   - Reporting: L10 funnel "Lead to Opportunity" → "Opportunities with Attended Appointments" → "Attended Appointments with Offers" → "Offers to Accepted" → "Contract to Revenue"; "Lost Opps by Offer Difference". Verified [L5]
- **Alternate / reopen:** Closed Lost opps can be revived by DealSignals signals [L24]; PSAI may wrongly close own won deals — exclude via admin panel preferences [L21].

### 6.3 Transaction management & disposition (contract → assignment/sale → close)
**Start trigger:** Transaction created from Opportunity at Contract Signed. [L9][L11]
1. **Initiation**
   - Transaction Path **New Contract**; Acquisition Rep, Closing Date, Closing Attorney, Contract Purchase Price set. Observed [L11]
   - Left Main Dispo / Commission permission sets govern access. Verified [L37]
2. **Data processing**
   - Path through docs/title stages ("Docs Sen…", "Title Issu…"); Transaction Expenses logged; QuickBooks expense sync for marketing ROI. Observed [L11]; Verified [L41]
   - Cadences on Transactions (email uses record email or custom field). Verified [L36]
3. **Business operations (dispo)**
   - DispoSignals Buyer Search on Transaction → up to 30 verified buyers with skip-trace → create Buyer Contacts and Interested Buyers; Internal Buyer List with ZIP filter. Verified [L27][L32]
   - Publish to Investor Portal in one click; buyers self-register/are invited; views, saves, inquiries, offers tracked; real-time alerts and weekly digests. Verified [L4][L7][L29]
   - Interested Buyer records with Offer, Offer Type, Asking Price Offer, Offer Notes; Bulk Add/Stop Cadence to buyers. Observed [L14]
4. **Decision**
   - Choose buyer → Assigned Buyer / Assigned Buyer Contact; Contract Assignment Price; Projected Wholesale or Flip Profit. Observed [L11]
   - Funding option via Left Main Exchange partners (e.g. Renovo Financial: intro sent → specialist outreach within 1 business day → term sheet; Coast 2 Coast Capital underwriting tracked). Verified [L7]
   - Alternate: "Renovation Project" / "New Build Project" buttons for flip/build path. Observed [L11]
5. **Completion**
   - Path reaches "Clear to …" then "Closed/…". Observed (truncated) [L11]
6. **Post-completion**
   - Dispo KPIs: interested buyers per deal, offer ratio, marketing vs assignment price, days to assign, fall-through rate. Verified [L5]
   - CRM Comps from own closed deals feed future DispoSignals analyses. Verified [L27]
- **Cancellation:** path value "Contract …" (likely contract cancelled/terminated) — Observed truncated; fall-through rate KPI implies cancellation tracking [L5].

### 6.4 Cadence lifecycle (cross-object follow-up engine)
**Start trigger:** manual apply (record picker), Bulk Add Cadence from list view, Salesforce Flow, or native Cadence Automation. [L42][L16]
1. **Initiation** — Admin builds Cadence Library (Draft → Active) with SMS/email/task/direct-mail steps and day offsets; Cadence Setup Wizard sets SMS From number (Record Owner, User Profile, Org-Wide), default email sender, working hours, timezone fallback. Verified [L42][L40]
2. **Data processing** — Applying creates Cadence + Cadence Scheduled Email/SMS/Task records (Status pending); "has cadence" checked; recipient-timezone scheduling. Verified [L15][L40]
3. **Business operations** — Dispatcher sends via CTI provider (SMS), email (Lightning templates/Org-Wide address), creates Tasks; timeline shows completed (green)/failed (red)/pending. Verified [L42][L44]
4. **Decision** — Stop rules: lead converts, inbound communication, record reaches status/stage; new cadence stops previous; transition to another library on lifecycle event. Verified [L15][L16][L40]
5. **Completion** — All steps done → "stop cadence" checked, "has cadence" unchecked; Stopped Reason "Completed"; pending items marked **Canceled** on manual stop. Verified [L15][L17][L40]
6. **Post-completion** — Chaining into next Active library; Error SMS report; Cadence troubleshooting. Verified [L18][L8]

**Ordered status/stage lists for key objects**
- Lead Status (Observed, 2025 demo org): 1 New · 2 Working · 3 Follow Up · 4 Qualified (converted) · 5 Unqualified · 6 Retail [L13]
- Opportunity Stage (Observed, 2025 demo org): 1 Pending Appointment · 2 Appointment Set · 3 Follow-up · 4 Long Term Followup · 5 Negotiation · 6 Retail (Won) · 7 Contract Signed (Won) · 8 Sold - PSAI (Lost) · 9 Closed Lost (Lost) [L12]
- Transaction Path (Observed, 2023 demo org, truncated): New Contract · Docs Sen… · Title Issu… · Need Dis… · Awaiting … · Pending … · Pending … · Clear to … · Clear to … · Closed/… · Contract … [L11]
- Cadence Library: Draft · Active · (Archived) [L42][L18]

## 7. Automation table

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Transaction on contract | Opportunity Stage → Contract Signed | Opportunity → Transaction | Create Transaction; Contract Purchase Price = last offer | TC/dispo record | Apex trigger or Flow (package) | Verified [L9][L11] |
| Last Offer required | Close Opportunity | Opportunity | Error if "Last Offer Made" blank | Data quality | Validation rule/trigger | Observed [L11] |
| Appointment Date/Time fill | Event created, Related To = Opportunity, Subject starts "Acquisition Appointment" | Event → Opportunity | Set Appointment Date/Time | Drives reminder cadences, NBA | Record-triggered Flow/Apex | Verified [L19] |
| Cadence enrollment / routing | New record; Lead Source / Status / Reason for Selling | Lead, Opportunity, Contact, Transaction, Interested Buyer | Enroll in Cadence Library | Follow-up starts | Package automation (configured in Cadence Setup) | Verified [L16][L18] |
| Cadence transition | Appointment scheduled; stage/status change | Opportunity, others | Move to another library | Reminder/confirmation sequences | Package automation | Verified [L16] |
| Cadence stop | Convert, inbound communication, status/stage criteria, manual | All cadence objects | Stop; pending → Canceled; Stopped Reason/Timestamp | Avoids over-contact | Package automation | Verified [L16][L40] |
| After-hours response | New lead outside business hours | Lead | Single acknowledgment; resume in hours | — | Package | Verified [L18] |
| Cadence chaining | Library completes | All | Enroll in next Active library | Long-term nurture | Package | Verified [L18] |
| Cadence dispatch | Scheduled time (recipient timezone) | Scheduled Email/SMS/Task | Send via CTI / email / create Task | Touchpoints | Scheduled Apex + callouts | Verified [L15][L40] |
| Automation Readiness Check | First enablement | Org | List overlapping active Flows | Avoid duplicates | Apex/Tooling query | Verified [L17] |
| DealSignals enrichment | Hourly/daily county feeds | Lead, Opportunity | Enrich signals; create Prospect lead if no match; revive inactive; notify; Hot List | Motivated-seller pipeline | External data + "Enrichment Flow" | Verified [L24][L40] |
| DealSignals Snooze | User clicks Snooze | Lead/Opportunity | Remove from Hot List; 30-day follow-up task; resurface on new signal | — | Package | Verified [L24][L25] |
| Prospect conversion contact carry-over | Prospect → Opportunity | Lead/Opportunity | Carry related contacts (Probate, First Up, Eviction) | No duplicates | Package | Verified [L33] |
| Property Sales AI matching | Weekly run (7 days) | Property Sales vs Lead/Opportunity | Address match; auto-set Unqualified / Closed Lost ("Already sold (Property Sales AI)") if enabled, else manual confirm/reject | Stops spend on sold properties | Scheduled Apex + external feed | Verified [L22][L23] |
| PSAI duplicate suppression | Same LFID within Property Sale Duration days | Property Sales | Treat as duplicate | Cleaner insights | Apex | Verified [L39] |
| Investor Portal sync | Publish / registration / offer | Transaction, Contact, Account, Interested Buyer | Create/match records; sync offers & status | Buyer activity in CRM | External portal (lmx-dns.com) + API | Verified [L29][L28] |
| DispoSignals buyer creation | Buyer Search results | Contact, Interested Buyer | Create Buyer Contacts and Interested Buyers; store "Generated From Opportunity/Transaction" | Buyer list growth | Package + external API | Verified [L27][L33] |
| QuickBooks sync | Scheduled (frequency Unknown) | Expenses | QBO → Left Main vendor expenses | Marketing ROI dashboard | External integration | Verified [L41] |
| Launch Control push | One-click in Launch Control | Lead (Inferred) | Push tags, statuses, notes, campaign names | Leads in CRM | Partner API | Verified (partner) [L45] |

## 8. UI / UX

- **App**: Lightning app "Left Main+" (nav: Home, Chatter, Leads, Opportunities, Calendar, Tasks, Transactions, Dashboards, Reports, Campaigns, Accounts, Contacts, Interested Buyers). Observed [L10][L11][L14]
- **Home**: "Left Main+ default homepage" with Property Sales AI banner. Verified [L38]
- **Lead page**: status path (New … Converted), highlights (Address, Phone, Email, Contacted, Lead Source, Next Step), "Company Information" section, actions: Check for New Data, Create Direct Mail Cadences, Convert, Change Record Type, Submit for Approval, New Case, Follow. Observed [L10]
- **Opportunity page**: stage path with "Select Closed Stage" modal; related quick links Files, Cadences, Opportunity Field History, Contact Roles, Post Appointment…, Stage History, Transactions; Next Best Action panel ("Deal Analysis for <address>"); fields Rehab Level, Estimated Rehab $, MAO. Observed [L11]
- **Transaction page**: path (11 steps), buttons Edit, Renovation Project, New Build Project, Call, Printable View, "Mark Path as Complete"; tabs Details / Interested Buyers / Related; related quick links Notes, Files, Transactions History, Transaction Expenses, Interested Buyers; Activity / SMS / Chatter tabs. Observed [L11]
- **Interested Buyers list view**: columns Interested Buyers Name, Transactions, Contact, Mobile Phone, Offer, Offer Notes, Offer Type, Created Date; buttons New, Import, Bulk Add Cadence, Bulk Stop Cadence. Observed [L14]
- **Kanban**: "Kanban view" for disposition & transaction management. Verified [L2]
- **Cadence App Configuration** app with tabs incl. Cadence Setup, Direct Mail. Verified [L15][L36][L40]
- **DealSignals** app/dashboard, Today's Hot List, DealSignals component on records. Verified [L25]
- **DispoSignals tab** on Opportunity/Transaction with list/map views, Street View images. Verified [L53b][L34][L32]
- **Mobile**: Mobile CRM, drive for dollars, Salesforce Maps. Verified [L2][L8]
- **Portal**: Investor Portal (branded external site, custom domain; staging on `lmx-dns.com`). Verified [L4][L28]
- **Public screenshot/demo URLs (viewed, not downloaded)**:
  - https://scribehow.com/shared/Convert_a_Lead_to_an_Opportunity_and_Account__oQ2yNQJtS2WBZ_sJILDBBA — Lead record, status path, Convert menu (2023).
  - https://scribehow.com/shared/Convert_an_Opportunity_to_a_Transaction__wH-XJZmaS9mALSVlTGB92g — Opportunity close to Contract Signed and resulting Transaction record with path/fields (2023).
  - https://scribehow.com/shared/Add_a_New_Opportunity_Stage_and_Update_the_ClosedLost_Reason_Field_Dependency__86o5LSu9RoGo1diM2otmKA — Opportunity Stage picklist table with types/probabilities; sales processes (2025).
  - https://scribehow.com/shared/Add_a_New_Lead_Status_and_Update_the_Unqualified_Reason_Field_Dependency__YvtK2a07S4mq2cpg5tXvSQ — Lead Status picklist table (2025).
  - https://scribehow.com/shared/Use_the_Interested_Buyers_Object_for_Buyers_Who_Made_an_Offer__CM6qqvqDR3qNKeXH1ji45g — Interested Buyers list view and New form (2024).
  - https://scribehow.com/embed/Create_an_Acquisition_Appointment__QYtYuxtmQpSTTaiPkxxTXQ — creating appointment Event (not viewed).
  - https://scribehow.com/embed/Add_a_Buyer__xlm8E424Q_eX2yswdKojdQ — adding a buyer contact (not viewed).
  - docs.leftmainrei.co "Intro to Next Best Action" and "Intro to the Retail App" embed Loom videos (not viewed).
  - https://www.smrtphone.io/blog/crm-showcase-left-main/ — 2023 webinar announcement with illustration.
  - YouTube channel: not located in searches; vendor footer links Vimeo. Unknown.

## 9. Reporting

- Department dashboards: Leadership/L10, Marketing, Lead Management, Acquisitions, Dispositions, Transactions (with "industry-standard reference ranges"); also Acquisitions scorecard, Marketing ROI, ARV accuracy, Quarterly Marketing (QuickBooks), Market Insights (Property Sales AI), DealSignals Dashboard / Today's Hot List, Investor Sales report. Verified [L5][L6][L54][L41][L22][L25]
- KPIs: cost per lead / qualified lead / acquisition by source; speed to lead; contact rate; lead→appointment, appointment→offer, offer→contract conversion; follow-up compliance; lost-deal reasons; interested buyers per deal; marketing vs assignment price; days to assign; assignment fee/spread; fall-through rate; deal velocity; ARV accuracy; revenue per team member; avg profit per deal. Verified [L5]
- L10 funnel report names: "Lead to Opportunity", "Opportunities with Attended Appointments", "Attended Appointments with Offers", "Offers to Accepted", "Contract to Revenue", "Lost Leads by Source", "Lost Opps by Offer Difference". Verified [L5]
- Objects driving: Lead, Opportunity (stage, appointment fields, Number_Outbound_Calls__c), Transaction (prices, profits), Interested Buyer, Campaign, Property Sales, QBO expenses. Verified/Inferred
- 400+ stock reports in package. Verified [L46]
- Admin how-tos: Error SMS report, duplicate data report, modified Property Sales report, Market Insights subscriptions. Verified [L8]

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| smrtPhone | Calling, SMS, softphone, campaign tracking | Bi-directional | Calls, SMS logs | Click-to-dial, cadence | smrtPhone package (CTI) | Verified | [L44][L47] |
| RingCentral | Calling, SMS | Bi-directional | Call/SMS logs | Click-to-dial, cadence | RingCentral package | Verified | [L44][L37] |
| Dialpad | Calling, SMS (E.164 numbers) | Bi-directional | Calls, SMS | Click-to-dial, cadence | Dialpad package | Verified | [L44] |
| CallRail | Cadence SMS only | Out | SMS | Cadence | API credentials in Cadence Setup | Verified | [L44] |
| Vonage | Cadence SMS | Out | SMS | Cadence | API key/secret | Verified | [L33] |
| PostcardMania | Direct mail | Out | Mail pieces | Cadence step | In-Salesforce app | Verified | [L43] |
| Gmail / Outlook (EAC) | Email | Bi-directional | Email activity | — | Gmail integration; Einstein Activity Capture | Verified | [L1][L34] |
| Launch Control (Smarter Contact) | SMS marketing lead push | In | Tags, statuses, phone verification, notes, campaign names | One-click push | Partner integration | Verified (partner) | [L45] |
| Carrot / WordPress / Mail Parser / PPL | Web lead capture | In | Leads | Form submit | Web-to-lead / Zapier / parser | Verified (listed) | [L1][L54] |
| BatchLeads/BatchDialer, InvestorBase, InvestorLift | Lists, buyer data, dispo marketplace | In/Out | Leads, buyers | — | Partner | Verified (listed) | [L1][L6] |
| ATTOM | Property data (appraisals, mortgage, sales history, comps, street view) | In | Property data | On record | Data API | Verified | [L2] |
| DealSignals feed | Distress signals, skip trace | In | Signals, contacts | Hourly/daily | Left Main data service | Verified | [L24][L6] |
| Property Sales AI feed | County sold records | In | Property Sales | Weekly | Left Main data service | Verified | [L23] |
| DispoSignals | Investor/retail comps, buyers | In | Comps, buyers | On demand | External API + Google Street View | Verified | [L27][L32] |
| QuickBooks Online | Vendor expenses for ROI | In (one-way) | Expenses | Scheduled | Integration (QBO minor versions ≥75) | Verified | [L41][L8] |
| Investor Portal (LMX) | Buyer marketplace | Bi-directional | Listings, registrations, offers, status | Publish, buyer actions | External site + sync engine | Verified | [L29] |
| Funding partners (Renovo Financial, Coast 2 Coast Capital) | Transactional funding | Out/In | Funding requests, status | From Transaction | Left Main Exchange | Verified | [L7][L8] |
| Mailchimp, Calendly, Slack, Zapier | Marketing, scheduling, alerts, glue | Various | — | — | Connectors | Verified (listed) | [L1] |
| Claude | AI assistant | Read/write | Records, metadata | User prompt | Salesforce-hosted MCP server via External Client App (OAuth, mcp_api, PKCE) | Verified | [L31] |
| Salesforce Maps | Routing/drive for dollars | — | — | — | Salesforce Maps licence | Verified | [L8] |

## 11. Limitations & what would be hard to recreate

- **Hard to recreate**: licensed data products (DealSignals distress feeds + skip trace, Property Sales AI county feed with LFID dedupe, DispoSignals investor/retail comps and verified buyers) [L24][L23][L27]; Investor Portal external marketplace with funding partners [L29][L7]; multi-CTI SMS dispatch with protected credential storage [L32][L33]; Cadence Library builder with timeline, chaining, readiness check [L42][L17].
- **Easy to recreate**: Lead statuses/Opportunity stages with dependent reason picklists; Transaction custom object created on Contract Signed; Interested Buyer junction; Appointment Date/Time flow from Event subject; department dashboards.
- **Vendor limitations**: SMS only through five CTI providers [L33]; CallRail lacks call/SMS history [L44]; Direct Mail only on Leads/Opps [L42]; Appointment field updates only on Event creation and subject prefix [L19]; PSAI can mark own won deals Closed/Lost if misconfigured [L21]; address fields in PSAI immutable after save [L22]; competitor-reported: cadence automations ship disabled, 219-step NBA post-install, ≤75 employee clause [L48] (third-party, unverified).
- **Gaps (Unknown)**: API names of all custom objects/fields except `Number_Outbound_Calls__c` and namespace `Left_Main__`; full Transaction path labels; Offer Type values; Interested Buyer status values; Contact buyer-criteria field names; NBA strategy content; AppExchange listing; Retail App process detail.

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| L1 | Left Main REI homepage | https://leftmainrei.co/ | vendor site | 2026-11-12 |
| L2 | Left Main Core features | https://leftmainrei.co/real-estate-crm-features-2/ | vendor site | 2026-11-12 |
| L3 | Pricing Plans | https://leftmainrei.co/pricing/ | vendor site | 2026-11-12 |
| L4 | Investor Portal | https://leftmainrei.co/investor-portal/ | vendor site | 2026-11-12 |
| L5 | Real Estate Investor CRM Reporting: KPIs and Dashboards | https://leftmainrei.co/real-estate-investor-crm-reporting/ | vendor blog | 2026-11-12 |
| L6 | Best CRM for Real Estate Investors: 2026 Buyer's Guide | https://leftmainrei.co/best-crm-for-real-estate-investors/ | vendor blog | 2026-11-12 |
| L7 | How to Market Wholesale Deals: Your Own Buyer Marketplace | https://leftmainrei.co/market-wholesale-deals-buyer-marketplace/ | vendor blog | 2026-11-12 |
| L8 | Left Main docs index (llms.txt) | https://docs.leftmainrei.co/llms.txt | help | 2026-11-12 |
| L9 | What are Objects? | https://docs.leftmainrei.co/docs/what-are-objects | help | 2026-11-12 |
| L10 | Convert a Lead to an Opportunity and Account (doc + Scribe) | https://docs.leftmainrei.co/docs/convert-a-lead-to-an-opportunity-and-account | help / walkthrough | 2026-11-12 |
| L11 | Convert an Opportunity to a Transaction (doc + Scribe) | https://docs.leftmainrei.co/docs/convert-an-opportunity-to-a-transaction | help / walkthrough | 2026-11-12 |
| L12 | Add a New Opportunity Stage and Update the Closed/Lost Reason Field Dependency (Scribe) | https://docs.leftmainrei.co/docs/add-a-new-opportunity-stage-and-update-the-closedlost-reason-field-dependency | help / walkthrough | 2026-11-12 |
| L13 | Add a New Lead Status and Update the Unqualified Reason Field Dependency (Scribe) | https://docs.leftmainrei.co/docs/add-a-new-lead-status-and-update-the-unqualified-reason-field-dependency | help / walkthrough | 2026-11-12 |
| L14 | Use the Interested Buyers Object for Buyers Who Made an Offer (Scribe) | https://docs.leftmainrei.co/docs/use-the-interested-buyers-object-for-buyers-who-made-an-offer | help / walkthrough | 2026-11-12 |
| L15 | Cadences Desk Reference | https://docs.leftmainrei.co/docs/cadences-desk-reference | help | 2026-11-12 |
| L16 | Cadence Automations Feature Overview | https://docs.leftmainrei.co/docs/cadence-automations-feature-overview | help | 2026-11-12 |
| L17 | Getting Started with Cadence Automations | https://docs.leftmainrei.co/docs/getting-started-with-cadence-automations | help | 2026-11-12 |
| L18 | Release Notes v1.615: Cadence Automations | https://docs.leftmainrei.co/docs/release-notes-cadence-automations | release notes | 2026-11-12 |
| L19 | Opportunity Appointment Date/Time | https://docs.leftmainrei.co/docs/opportunity-appointment-date-time | help | 2026-11-12 |
| L20 | Create an Acquisition Appointment | https://docs.leftmainrei.co/docs/create-an-acquisition-appointment | help | 2026-11-12 |
| L21 | Why are my own won deals getting marked Closed/Lost? | https://docs.leftmainrei.co/docs/why-are-my-own-won-deals-getting-marked-closedlost | help | 2026-11-12 |
| L22 | Property Sales AI Desk Reference | https://docs.leftmainrei.co/docs/property-sales-ai-desk-reference | help | 2026-11-12 |
| L23 | User Guide to Property Sales AI Data | https://docs.leftmainrei.co/docs/user-guide-to-property-sales-ai-data | help | 2026-11-12 |
| L24 | DealSignals Feature Overview | https://docs.leftmainrei.co/docs/dealsignals-feature-overview | help | 2026-11-12 |
| L25 | Getting Started with DealSignals | https://docs.leftmainrei.co/docs/getting-started-with-dealsignals | help | 2026-11-12 |
| L26 | Frequently Asked Questions for DealSignals | https://docs.leftmainrei.co/docs/frequently-asked-questions-dealsignals | help | 2026-11-12 |
| L27 | Feature Overview: DispoSignals | https://docs.leftmainrei.co/docs/feature-overview-disposignals | help | 2026-11-12 |
| L28 | Investor Portal Admin Documentation | https://docs.leftmainrei.co/docs/investor-portal-admin-documentation | help | 2026-11-12 |
| L29 | Feature Overview: Investor Portal | https://docs.leftmainrei.co/docs/feature-overview-investor-portal | help | 2026-11-12 |
| L30 | How to Check Your Left Main Package Version | https://docs.leftmainrei.co/docs/how-to-check-your-left-main-package-version | help | 2026-11-12 |
| L31 | How to Connect Claude to Left Main | https://docs.leftmainrei.co/docs/how-to-connect-claude-to-leftmain | help | 2026-11-12 |
| L32 | Release Notes v1.630 (2026-10-15) | https://docs.leftmainrei.co/docs/release-notes-v1630 | release notes | 2026-11-12 |
| L33 | Release Notes v1.624 (2026-09-13) | https://docs.leftmainrei.co/docs/releasenotesv1624-dealsignals-disposignals-core-updates | release notes | 2026-11-12 |
| L34 | Release Notes v1.611 (2026-07-05) | https://docs.leftmainrei.co/docs/release-notes-disposignals-dealsignals-and-platform-updates | release notes | 2026-11-12 |
| L35 | 1.594 Release Notes (2026-04-14) | https://docs.leftmainrei.co/docs/1-593-release-notes-4-14-26 | release notes | 2026-11-12 |
| L36 | 1.587 (March 2026) | https://docs.leftmainrei.co/docs/1-587-march | release notes | 2026-11-12 |
| L37 | January 2025 release notes | https://docs.leftmainrei.co/docs/january-2025-core | release notes | 2026-11-12 |
| L38 | March 2025 release notes | https://docs.leftmainrei.co/docs/march-2025-core | release notes | 2026-11-12 |
| L39 | May 2025 release notes (v1.541) | https://docs.leftmainrei.co/docs/may-2025 | release notes | 2026-11-12 |
| L40 | November 2025 release notes (v1.569) | https://docs.leftmainrei.co/docs/november-2025 | release notes | 2026-11-12 |
| L41 | QuickBooks Online Integration Overview | https://docs.leftmainrei.co/docs/quickbooks-online-integration-overview | help | 2026-11-12 |
| L42 | Cadence Library Feature Overview | https://docs.leftmainrei.co/docs/cadence-library-feature-overview | help | 2026-11-12 |
| L43 | Direct Mail Cadences and PostcardMania Feature Overview | https://docs.leftmainrei.co/docs/direct-mail-cadences-postcardmania-feature-overview | help | 2026-11-12 |
| L44 | CTI Functionality Overview | https://docs.leftmainrei.co/docs/cti-functionality-overview | help | 2026-11-12 |
| L45 | Launch Control: Left Main REI integration | https://launchcontrol.us/partners-integrations/left-main-rei/ | third party (partner) | 2026-11-12 |
| L46 | Copado customer story: Left Main REI (2024-04-11) | https://www.copado.com/resources/customer-stories/rapid-fire-releases-and-less-stress-for-left-main-rei | third party (vendor-endorsed) | 2026-11-12 |
| L47 | smrtPhone CRM Showcase: Left Main REI | https://www.smrtphone.io/blog/crm-showcase-left-main/ | third party (partner) | 2026-11-12 |
| L48 | REsimpli vs Left Main (competitor) | https://resimpli.com/blog/resimpli-vs-left-main/ | third party (competitor) | 2026-11-12 |
| L49 | G2 Left Main reviews / seller page (403; search snippets) | https://www.g2.com/products/left-main/reviews | review | 2026-11-12 |
| L50 | Scale to Sale podcast: Building a real estate solution on Salesforce (snippet) | https://scaletosale.buzzsprout.com/2277525/episodes/15546207-building-a-real-estate-solution-on-salesforce | third party (podcast) | 2026-11-12 |
| L51 | Funding coverage (Crowdfund Insider May 2025; PRWeb Nov 2024) (snippets) | https://www.crowdfundinsider.com/2025/05/239731-left-main-rei-secures-funding-to-expand-ai-powered-crm-suite-for-real-estate-investors/ | press | 2026-11-12 |
| L52 | February 2025 release notes (v1.529) | https://docs.leftmainrei.co/docs/february-2025 | release notes | 2026-11-12 |
| L52b | Best Practices: Add Leads to a Campaign with Minimal Clicks | https://docs.leftmainrei.co/docs/best-practices-add-leads-to-a-campaign-with-minimal-clicks | help | 2026-11-12 |
| L53 | Next Best Action docs (titles: Intro, Post-Install Steps, Modify Opportunity Stage Verbiage in the NBA - Set Appointment Flow, Opportunity Strategy Builder) | https://docs.leftmainrei.co/docs/next-best-action | help | 2026-11-12 |
| L53b | Getting Started with DispoSignals | https://docs.leftmainrei.co/docs/getting-started-with-disposignals | help | 2026-11-12 |
| L54 | Out of the Box CRM for Real Estate Investors | https://leftmainrei.co/out-of-the-box-crm-real-estate-investors/ | vendor blog | 2026-11-12 |
