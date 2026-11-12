# REthink CRM (now "Rethink by Buildout") — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

Research note: the single richest public source is Buildout's Intercom help center for Rethink (`rethink.help.buildout.com`, 19 collections, ~225 articles) [S5]. It exposes object labels, stage values, field labels, setup paths and two published API names. G2, Capterra and Ascendix pages returned HTTP 403 to direct fetch; their data below comes from search-engine snippets and is labelled as such.

---

## 0. Identity and status

| Item | Finding | Label | Source |
|---|---|---|---|
| Current product name | "Rethink by Buildout" (also "Rethink CRM"; vendor uses lower-case "rethink" in branding). Historic name "REthink CRM" / "REthink CRE" / "REthink Commercial". | Verified | [S3][S4][S1] |
| Original publisher | Think Tech Labs (Austin, TX). G2 still lists seller "Think Tech Labs". | Verified (G2 seller page via search snippet; press releases) | [S51][S48] |
| Current publisher | Buildout, Inc. (Chicago), backed by The Riverside Company. | Verified | [S1] |
| Acquisition | Buildout announced acquisition of Rethink on **2021-02-23**; terms undisclosed. Buildout said Rethink and Buildout would "remain separate products" initially and Rethink's team would be folded in. | Verified | [S1][S2][S52] |
| 2019 rebrand | PR Newswire (2019) "rethink reveals new branding and direction to power commercial real estate transactions from prospecting to closing". | Verified (title from search result only; body not fetched) | [S56] |
| Related Buildout CRMs | Buildout also sells "Buildout CRM" (out-of-the-box, broker-native, not described as Salesforce) and refers to a "Lite CRM". Buildout also acquired Apto (another Salesforce-based CRE CRM); help articles refer jointly to "Rethink and Apto". | Verified | [S2][S3][S22] |
| Status today | **Active and sold.** Buildout markets "Rethink by Buildout" with published pricing ($129/user/mo Rethink, $299/user/mo Rethink+) [S4]; release notes run through "Rethink Fall 2026 Release Notes - v3.56" [S41][S15]. Not sunset, not renamed away. | Verified | [S4][S15][S41] |
| Native vs integrated | **Native on Salesforce.** Buildout: "A highly customizable, AI-powered CRM built on the Salesforce platform" and "Choose Rethink when customization matters; choose Buildout CRM when speed-to-value matters." [S3]. Help center articles are Salesforce Setup / Object Manager / Lightning App Builder instructions throughout [S40]. | Verified | [S3][S40] |
| Delivery model | Customer gets a Salesforce org licensed through Rethink (OEM-style): admins hold "Salesforce" licences, users hold "Salesforce Platform" licences; "Salesforce plus Salesforce Platform licenses together equal the total licenses purchased from Rethink" [S24]. Updates arrive as Salesforce package upgrades that overwrite Compact Layouts [S25]. | Verified | [S24][S25] |
| Package namespace | **`TTL_Core__`** (custom objects with the `TTL_Core__` prefix, e.g. `TTL_Core__Deal__c` = Deal Pipeline, `TTL_Core__Associate__c` = Colleague). TTL presumably = Think Tech Labs. | Verified (namespace + 2 API names); Inferred (TTL meaning) | [S33] |
| AppExchange listing | Not found. No appexchange.salesforce.com result surfaced in two searches; Ascendix (competitor) says REthink is among the "most popular Salesforce-based CRE CRMs presented on the AppExchange" (snippet). Listing id Unknown. | Unknown | [S54] |
| Package version | Release notes versioned v3.18.4 (Spring 2022) to v3.56 (Fall 2026) [S41]. Managed vs unlocked not stated; "do not upgrade" list and push-upgrade behaviour imply a managed package. | Verified (versions); Inferred (managed) | [S41][S25] |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| G2 — "REthink CRM" (seller Think Tech Labs) | 3.3/5, 13 reviews | 3.3/5 (search snippet, 2026-11-12) | 13 | https://www.g2.com/products/rethink-crm/reviews | Direct fetch returned HTTP 403; figure taken from WebSearch snippet. Snippet also says the G2 profile "hasn't been active for over a year" and lists a vendor-supplied starting price of $99/user/mo (stale). **Supplied value matches snippet.** |
| G2 — "Rethink" (Buildout-era profile) | — | 4.0/5 from 1 review (search snippet) | 1 | https://www.g2.com/products/rethink/reviews | Internally inconsistent page ("not reviewed yet"). Buildout seller page: 4.2 across 16 reviews (all Buildout products). |
| Capterra — "Rethink CRM" (id 133963) | — | 4.1/5 (search snippet, 2026-11-12); ease of use 4.1, customer service 4.3, value 4.2, functionality 3.9 (Software Advice) | 7 | https://www.capterra.com/p/133963/REthink/reviews/ | Direct fetch HTTP 403. Distribution 4×5★, 2×4★, 1×1★. Capterra pricing snippets conflict ($159 flat/mo vs $35/user/mo) — treat as stale. |
| AppExchange | — | Not found | — | — | Listing not located. |

## 2. Overview (12 questions)

1. **What it is** — CRE brokerage CRM and deal-management app on Salesforce: contacts/companies, properties, spaces/units, deal pipeline by representation type, comps, prospecting lists, GEOsearch, stacking plan, invoices. **Verified** [S3][S4][S5]
2. **Developer** — Built by Think Tech Labs (Austin), owned by Buildout since Feb 2021. **Verified** [S1][S51]
3. **Industry** — Commercial real estate brokerage (sales and leasing); historically also residential ("REthink Residential", 2015). **Verified** [S51]
4. **Target users** — Seller rep, buyer rep, landlord rep and tenant rep brokers, investment-sales teams, brokerage admins; Buildout positions it for "larger teams or enterprises that already use Salesforce". **Verified** [S3][S6–S9]
5. **Problems solved** — Single source of truth for contacts, property data and deal pipeline; comp generation from closed deals; prospecting with owner data (Rethink+); listing-marketing sync with Buildout Showcase. **Verified** [S1][S10][S21][S30]
6. **Major functions** — Contact management, activity tracking, property & listing database, comps, Kanban deal pipeline, branded client activity reports, map-based search (GEOsearch), dashboards, Showcase marketing integration; Rethink+ adds ownership data, AI owner research, predictive analytics, property records. **Verified** [S4]
7. **Differentiators** — Four representation-specific pipelines with CRE stage sets; auto comp on close; GEOsearch; stacking plan; Showcase bi-directional sync; Rethink+ owner unlock. **Verified** [S6–S10][S21][S30][S31]
8. **Native/integrated** — Native Salesforce managed package (`TTL_Core__`) in a Rethink-licensed org. **Verified** [S33][S24]
9. **Editions/licences required** — Salesforce licence for admins, Salesforce Platform licence for users; Chatter Free/External available; Prospecting Console requires Lightning Console licence/permission. Salesforce edition (Enterprise vs other) Unknown. **Verified** (licence types) [S24][S38]; **Unknown** (edition)
10. **Pricing & licensing** — Rethink $129/user/month; Rethink+ $299/user/month (Buildout tour page) [S4]. Buildout site-wide "plans start at $125/user/month" [S3][S55]. Enterprise (100+ users) custom. **Verified**
11. **Managed/unmanaged** — Delivered as package upgrades; customers can be placed on a "do not upgrade" list; Compact Layouts overwritten each upgrade. Package type not named. **Verified** (behaviour) [S25]; **Inferred** managed (namespace + push upgrades)
12. **Limitations & dependencies** — Salesforce platform dependency; Compact Layout customisations lost on upgrade [S25]; stage "Closed" tied to automation [S9]; competitor claims: no native VoIP dialer or built-in mass-email platform, property data only in Rethink+ [S47]. **Verified** [S25][S9]; competitor claims labelled **Inferred/third-party** [S47]

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Companies & Contacts | Company (parent) → Contacts (child); Contact cannot exist without Company; Contact Groups, Property Types tagging | Brokers, assistants | Company Name; First/Last Name, Email, Phone, Contact Groups, Property Types, List Membership | Properties (owner), Deals (associated parties), Activities, Lists | Before: Excel/Outlook contacts; after: linked relationship graph | Verified | [S35][S36][S26] |
| Properties | Property records by record type (Office, Industrial, Land, Multifamily, Portfolio, Retail); ownership section; map location | Brokers, researchers | Property Name, address, lat/long, class, size, year built, price, cap rate, zoning, etc. | Spaces/Units, Comps, Deals, GEOsearch, Showcase | Property database replaces spreadsheets | Verified | [S19][S20] |
| Spaces/Units | Child of Property; record types Space and Unit Mix; lease details and tenant | Leasing brokers | Floor #, Suite, Space Type/Subtype, RSF, Status (leased/vacant), Tenant, lease dates, rent, escalations, lease structure, TI | Property, Comps, Stacking Plan, Showcase Lease Space | — | Verified | [S18] |
| Portfolio | Portfolio property record type; Parent Property lookup groups properties | Investment-sales brokers | Parent Property | Property | — | Verified | [S17] |
| Deal Pipeline | Deals by representation type (Seller/Buyer/Landlord/Tenant Rep); Table and Kanban views; stage path; commission and splits | Brokers, managers | Deal Name, Property, Stage, Status, Lead Broker, Client Company, commission, client requirements, DD/escrow, loan info, lease execution | Associated Parties, Offers, Inquiries, Site Selections, Activities, Invoices, Comps, Deal Stage Tracker | Pipeline visibility; Kanban summarised by Gross Commission | Verified | [S6–S9] |
| Associated Parties | Internal Colleagues (co-broker, commission split, access level) and External Contacts (role) on a deal; also on Property/Space for owner/tenant history (v3.56) | Brokers | Role (picklist), Access Level (Read, Read/Write), commission split | Deal, Contact, Property, Space/Unit | — | Verified | [S11][S15] |
| Inquiries/Requirements | Inbound listing inquiries and client requirements; matching to on-market properties | Brokers | Min/Max price, Min cap rate, property class, date space needed, min/max SF, max rent, lease structure | Deal, Property, Showcase Leads | — | Verified | [S6][S37][S20] |
| Offers | "New Offer" captures offer details and status on a deal; side-by-side comparison | Brokers | Offer details, status | Deal | — | Verified | [S6][S34] |
| Site Selections | Candidate sites for buyer/tenant rep deals incl. tour data; scoring | Tenant/buyer reps | Size, TI, location, rent scores, tour data | Deal, GEOsearch | — | Verified | [S7][S8][S34] |
| Comps | Sale Comp and Lease Comp record types; auto-created on Closed; manual external comps | Researchers, brokers | Address, buyer/seller company, cap rates, close date, price total/PSF, size, market, etc. | Deal, Property, Space, GEOsearch, Showcase | Comps captured as by-product of closing | Verified | [S10][S16] |
| Invoices | Invoices related list on deal; line items with receipts; approval; send | Brokers, accounting | Deal Commission (Gross), Status (Draft…), line items, Approver, To, payment terms, total, issue date | Deal, Files, Approval history | — | Verified | [S12] |
| Deal Stage Tracker | Related list tracking days in each stage | Managers | Name, Number of Days In Stage, Start Date, End Date | Deal | — | Verified | [S13] |
| Prospecting Lists & List widget | Call lists from list views / GEOsearch / Rethink+; Play/Next/Skip To; bulk Add Action Plan, New Task | Brokers | List, List Membership (contact picklist), Owner | Contacts, Companies, Properties, Spaces, Inquiries | Systematic call blocks | Verified | [S26] |
| Prospects | Prospect records (incl. Property Owner record type from Rethink+); convert to Company/Contact/Deal; client requirement fields carry to Tenant/Buyer Rep deal on convert | Brokers | Owner contact data, client requirements | Property, Deal, Contact | — | Verified | [S30][S15][S29] |
| Action Plans | Templated task sets applied to records or lists | Brokers, admins | Action Plan Template, tasks, owners, due dates | Deals, Properties, Contacts, Lists | — | Verified | [S28][S34] |
| Rethink Alerts | Scheduled email alerts off date fields | Brokers | Object, record type, date field, before/after offset, template, recipients | Contact, Prospect, Property, Space/Unit, Deal Pipeline, Offer | Replaces manual lease-expiry tracking | Verified | [S29] |
| GEOsearch | Map search (radius, polygon) across Properties, Spaces, Deals, Comps, Companies, Contacts; PDF, CSV, tour map, add to list, create site selections | Brokers | Saved searches, map marker settings | All core objects | — | Verified | [S32] |
| Stacking Plan | Lightning component on Office property page showing floors/spaces | Leasing brokers | Floors/spaces (fields Unknown) | Property, Space/Unit | Replaced older Visualforce version | Verified | [S31] |
| Rethink+ | Property/owner data search, owner unlock (credits), Enrich List, External Data merge, Financials (Debt/Tax), Save Comp/Tenant | Prospecting brokers | Property attributes, APN, owner contacts, financials | Property, Prospect, Comp, Contact, Company, Space, List | Replaces data-source switching | Verified | [S30] |
| Prospecting Console | Lightning console app (added April 2025) | Prospecting brokers | Leads, contacts, opportunities | — | — | Verified | [S38] |
| Showcase integration | Bi-directional sync with Buildout Showcase (listing marketing) | Brokers, marketing | Property, Deal, Space, Comps, Leads→Inquiries | Buildout Showcase | Re-keying eliminated | Verified | [S20][S21] |
| Reports & Dashboards | Salesforce reports, dashboards, joined reports, activity reports, branded client activity report | Managers | All | — | — | Verified | [S42][S4] |

## 4. Data model

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields (labels) | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Company | Unknown (label "Companies"; help never says "Account"). `Proposed:` standard `Account` relabelled | Standard? | Organisation | Company Name (required), phone, address | — | Contact, Property (owner), Deal (client company) | Verified (label); Inferred (Account) — Contact described as "a standard object in Salesforce" and Company is its required parent, consistent with Account | [S35][S36] |
| Contact | `Contact` (standard; vendor says "a standard object in Salesforce") | Standard | Person | First Name, Last Name, Company Name (required), Email, Phone, Contact Groups, Property Types, List Membership (picklist, ≤1,000 active values) | Company | Activities, Associated Parties, Inquiries, Files | Verified | [S36][S26] |
| Property | Unknown. `Proposed:` `TTL_Core__Property__c` (pattern only) | Custom | Building/land/portfolio | Property Name (req), Address, City, State, County, Postal/Zip, Market, Submarket, Location (Latitude/Longitude), Zoning, Land Size (Acres), Building Size (SF), Property Class, Usable SF, Occupancy (%), Ceiling Height (ft), # of Floors, Year Built, Year Renovated, # of Parking Spaces, # of Dock Doors, Price (total), Last Cap Rate (%), Anchor Tenant(s), Listing Status ("For Sale"), Date Available, Available SF, Is Proposal, Buildout Id, Sync With Showcase, Parent Property | Parent Property (self) | Space/Unit, Comp, Deal, Prospect, Financials | Verified (labels) | [S19][S20][S37][S17][S15] |
| Space/Unit | Unknown. `Proposed:` `TTL_Core__Space__c` | Custom | Leasable space or multifamily unit mix | Space/Unit Name (req), Property (req), Floor #, Suite, Space Type, Space Subtype, Space Size (RSF), Space/Unit Status, Tenant, Lease Commencement Date, Lease Expiration Date, Lease Term (months), Rent (Amount), Rent (Unit of Measure), Rent Escalations, Renewal Option(s), Lease Structure, Landlord Work, Tenant Improvement, Lease Comments, Date Available, Lease Rate Type, Max Contiguous SF, Min. Divisible SF, Gross Rate/SF ($); Unit Mix: Floor Plan, # Bedrooms, # Bathrooms, Total # of Units, Avg Unit SF | Property (deleting Property deletes Spaces → behaves like master-detail) | Comps (lease), Associated Parties (tenant history) | Verified | [S18][S20] |
| Deal Pipeline (Deal) | **`TTL_Core__Deal__c`** | Custom | Brokerage deal / mandate | Deal Name, Property, Stage ("Deal Stage" picklist), Status, Lead Broker, Client Company, client contact, Gross Commission, commission split with house, Client Requirements (min/max price, type, class, rent, availability), Listing & Marketing (sites, duration, listed price), DD/Escrow/PSA (buyer/seller, price, PSF, DD), Loan Information (loan value, LTV, Loan Rate), Lease Execution (actual rent, term, landlord work), Close Deal Date, Sync With Showcase, Buildout Id | Property, Company | Associated Party, Inquiry, Offer, Site Selection, Invoice, Deal Stage Tracker, Activities, Comp (link) | Verified (API name [S33]; fields [S6–S9][S20]) | [S33][S6–S9] |
| Associated Party | Unknown. Related list label "Associated Parties". Colleague object is **`TTL_Core__Associate__c`** ("Colleague") — relationship to Associated Party not stated | Custom (junction-like) | Internal colleague or external contact on a Deal / Property / Space | Type (Internal Colleague / External Contact), Role (picklist, e.g. "Landlord"), Access Level (Read, Read/Write), commission split | Deal (and Property, Space/Unit since v3.56) | — | Verified (labels, Colleague API); Unknown (junction API) | [S11][S33][S15] |
| Colleague | **`TTL_Core__Associate__c`** | Custom | Internal broker/colleague reference | Unknown | Unknown | Unknown | Verified | [S33] |
| Inquiry/Requirement | Unknown. `Proposed:` `TTL_Core__Inquiry__c` | Custom | Inbound listing inquiry or client requirement | Property Class, Min/Max Purchase Price, Min Cap Rate, Date Space Needed, Min/Max Square Footage, Max Rent (amount, unit), Lease Structure; from Showcase: Contact first/last, Company Name, Phone, Cell, Email, Company address, Lead Status, Source of Interest, Added By, Web Status | Property or Deal | — | Verified | [S6][S37][S20] |
| Offer | Unknown. `Proposed:` `TTL_Core__Offer__c` | Custom | Offer/LOI on a deal | Offer details, status (values Unknown) | Deal | — | Verified (existence); Unknown (fields) | [S6][S29][S34] |
| Site Selection | Unknown | Custom | Candidate site for buyer/tenant rep deal | tour data, scoring (size, TI, location, rent) | Deal | — | Verified | [S7][S8][S34] |
| Comp | Unknown. Record types **Sale Comp**, **Lease Comp** | Custom | Market comparable | Comp Name (req), Address, City, State, Buyer (Company), Seller (Company), Cap Rate (Stabilized), Cap Rate (YR 1), Close Deal Date, Comp RT Hidden, Comp Source, Deal Name, Building Size (SF), Market, Submarket, Price (PSF), Price (Total), Property Class, Property Name, Property Type, Contact, Year Built, Description, Lease Commencement, Lease Term (Months), Rent (Amount), Rent (Unit of Measure), Buildout Id | Property, Deal, Space/Unit | — | Verified | [S10][S16][S20] |
| Invoice | Unknown | Custom | Commission/expense invoice | Deal Commission (Gross), Status ("Draft"), To, Approver, payment terms, invoice total, issue date | Deal | Invoice line item | Verified | [S12] |
| Invoice line item | Unknown | Custom | Line on invoice | Item Description, receipt file | Invoice | — | Verified | [S12] |
| Deal Stage Tracker | Unknown | Custom | Stage-duration history | Deal Stage Tracker Name, Number of Days In Stage, Start Date, End Date | Deal | — | Verified | [S13] |
| List | Unknown | Custom | Prospecting/call list | Owner, members, archived flag | — | (members) | Verified | [S26] |
| List Display Fields | Unknown (a Custom Metadata Type) | Config (CMDT) | Fields shown in List widget | field API names | — | — | Verified | [S26] |
| Prospect | Unknown. Record type **Property Owner** | Custom | Prospective owner/client prior to conversion | first/last name, email, phone, cell, up to five alternate phones; client requirement fields | Property | converts to Company, Contact, Deal | Verified | [S30][S15][S29] |
| Financials | Unknown. Labels "Financials (Debt)", "Financials (Tax)" (possibly record types) | Custom | Loan and tax data | Unknown | Property | — | Verified (labels) | [S30] |
| Action Plan / Action Plan Template | Unknown | Custom (likely Action Plans package) | Templated task sequences | template, tasks, owners, due dates | Any record | Task | Verified | [S28][S34][S43] |
| Task / Event / EmailMessage | standard | Standard | Activities | Subject, due date, assignee; call outcome (connected, voicemail, no answer) | WhatId | — | Verified | [S28][S39][S42] |
| Rethink Settings / Rethink Alerts | Unknown (App Launcher item "Rethink Settings") | Config | Alerts schedule, From address, Showcase webhooks | — | — | — | Verified | [S29][S15] |
| Leads / Opportunities | Standard `Lead`, `Opportunity` (Prospecting Console references leads, contacts, opportunities) | Standard | Used by Prospecting Console | — | — | — | Verified (mentioned); Unknown (how used vs Deal) | [S38] |

**Relationships (found)**
- Company 1—* Contact; contact requires company; ≤10,000 contacts per company. Verified [S36]
- Property 1—* Space/Unit; deleting Property deletes its Spaces/Units (master-detail-like cascade). Verified [S18]
- Property —(Parent Property lookup)→ Portfolio property. Verified [S17]
- Deal → Property (lookup), Deal → Client Company (lookup). Verified [S6][S8]
- Deal 1—* Associated Parties, Inquiries, Offers, Site Selections, Invoices, Deal Stage Tracker, Activities. Verified [S6–S13]
- Closed Deal → creates Comp (Sale or Lease) linked back ("Comp" link on deal). Verified [S10]
- Inquiry/Requirement → Deal (Existing Deal / Create New Deal from matching component). Verified [S37]
- Showcase Lead → Inquiry under a Property or Deal. Verified [S21]
- Prospect → Property; converts to Company/Contact/Deal. Verified [S30]
- Associated Party also on Property and Space/Unit (ownership/tenancy history, v3.56). Verified [S15]

**Record types (found)**
- Property: Office, Industrial, Land, Multifamily, Portfolio, Retail. Verified [S19]
- Space/Unit: Space, Unit Mix. Verified [S18]
- Comp: Sale Comp, Lease Comp. Verified [S16]
- Deal Pipeline: Seller Rep, Buyer Rep, Landlord Rep, Tenant Rep (articles call them pipelines/list views; stage values are assigned per record type) — Inferred record types because the Deal Stage picklist values must be enabled per Record Type [S14]; four deal types Verified [S6–S9].
- Prospect: Property Owner. Verified [S30]

**Picklists (found)**
- Deal Stage — Seller Rep: Prospect → Proposal → Listing → LOI/Offers → Escrow/Due Diligence → Closed (+ "Testing" shown in the article) [S6]
- Deal Stage — Buyer Rep: Prospect → Identify Acquisition → Underwrite → LOI/Offers → Escrow/Due Diligence → Closed (+ "Testing") [S8]
- Deal Stage — Landlord Rep: Prospect → Proposal → Listing → RFP → Lease Execution → Closed [S9]
- Deal Stage — Tenant Rep: Prospect → Pursuit → Assignment → Survey/Tours → RFP → Lease Execution → Closed [S7]
- Invoice Status: "Draft" (others Unknown) [S12]
- Associated Party Access Level: Read, Read/Write [S11]; Role: customizable, example "Landlord" [S11]; article examples also "Buyer Rep", "Seller Rep", "Landlord Broker", "secondary owner", "property manager" [S6–S8]
- Space/Unit Status: leased, vacant [S18]; Rent (Unit of Measure): Amount/Month, $/SF/Year, $/SF/Month [S18]; Space Type: Retail, Industrial, Office, Multifamily (among others) [S18]; Office subtypes: traditional, tech/creative, executive suite, coworking space [S18]; Lease Structure: Absolute Net, Triple Net, Modified Gross (examples) [S18]
- Market → Sub Market dependent picklist. Verified [S40]
- Contact Group values (admin-maintained). Verified [S40]
- Call outcome examples: connected, voicemail, no answer. Verified [S39]
- Deal "Status" field values: Unknown.

**Roll-ups / formulas / validation / external IDs (found)**
- "Gross Commission" used as Kanban summary (likely currency field). Verified [S6]
- "Buildout Id" on Property, Space/Unit, Comps, Inquiries — external ID used for Showcase matching. Verified [S20][S21]
- "Comp RT Hidden" field on Comp (likely record-type helper). Verified [S10]
- Deal Commission (Gross) auto-populates on invoice. Verified [S12]
- Validation rules / formulas shipped by vendor: Unknown (help explains how admins create them [S40]).

**ERD edge list**
```
Company -> Contact (lookup, required) [Verified]
Company -> Deal Pipeline (lookup: Client Company) [Verified]
Company -> Property (owner, Ownership section) [Verified label; field Unknown]
Property -> Property (lookup: Parent Property, Portfolio) [Verified]
Property -> Space/Unit (MD-like cascade delete) [Verified]
Property -> Deal Pipeline (lookup: Property) [Verified]
Property -> Comp (lookup: Property) [Verified]
Property -> Prospect (Prospects tab) [Verified]
Property -> Financials (Debt/Tax) [Verified]
Property -> Inquiry/Requirement (Property or Deal) [Verified]
Space/Unit -> Comp (required for lease comps on Landlord/Tenant Rep close) [Verified]
Deal Pipeline -> Associated Party (child) [Verified]
Contact -> Associated Party (lookup) [Verified]
Colleague(TTL_Core__Associate__c) -> Associated Party (internal) [Inferred]
Deal Pipeline -> Inquiry/Requirement (child) [Verified]
Deal Pipeline -> Offer (child) [Verified]
Deal Pipeline -> Site Selection (child) [Verified]
Deal Pipeline -> Invoice (child) -> Invoice Line Item (child) [Verified]
Deal Pipeline -> Deal Stage Tracker (child) [Verified]
Deal Pipeline -> Comp (auto-created on Closed) [Verified]
Prospect -> Company/Contact/Deal (convert) [Verified]
List -> Contact/Company/Property/Space/Inquiry (membership, mechanism Unknown) [Verified]
Action Plan Template -> Action Plan -> Task [Verified/Inferred]
```

## 5. Technical components

| Area | Verified | Inferred | Unknown |
|---|---|---|---|
| Package | Namespace `TTL_Core__`; objects `TTL_Core__Deal__c`, `TTL_Core__Associate__c` [S33]; version series v3.x [S41]; upgrades overwrite Compact Layouts; "do not upgrade" list [S25] | Managed 1GP/2GP package published by Buildout/Think Tech Labs | Package name, install key, AppExchange id |
| Apex | — | Comp-on-close, invoice auto-populate, Showcase sync, matching component, Alerts scheduler imply Apex/batch jobs | All class names |
| LWC / Aura / Visualforce | Components named in UI: "Stacking Plan" (Lightning component; replaced a Visualforce page) [S31]; "Requirements/Inquiries Match Properties" (Lightning component) [S37]; "Lists" widget (lower-left utility) [S26]; Kanban tile customisation [S40] | GEOsearch is a custom map component (likely LWC) | API names of components |
| Flows | Help teaches admins to build Flows [S40]; Showcase sync "scheduled sync" every 15 min–daily [S21]; Rethink Alerts daily schedule [S29] | Comp creation and Deal Stage Tracker may be Flow or Apex trigger | Vendor flow names |
| Approval | Invoice "Submit for Approval" → approver emailed → "Approve" → approval history [S12] | Standard Salesforce Approval Process on Invoice | Process name |
| Custom Metadata | "List Display Fields" CMDT [S26] | — | — |
| Security | Profiles: "System Administrator", "Rethink Advanced User", "Rethink Standard User" [S23]; also "REthink Standard User", "REthink Advanced User" casing [S24]; Chatter Free/Moderator/External profiles [S24]; Permission set "Rethink Advanced Features" (required for Alerts) [S29]; "Prospecting Console" custom permission set + "Salesforce Console User" [S38]; MFA, passkeys, sharing rules, field-level security articles [S40] | OWD Private on Deal (Associated Party access level grants Read / Read-Write — suggests Apex-managed sharing) | Full permission set list |
| Integrations | Showcase (webhooks mentioned in v3.56: "disabling Showcase webhooks in Rethink Settings") [S15]; ProspectNow [S45]; Einstein Activity Capture; Cirrus Insight; Nintex Drawloop DocGen; Google Docs; SmartCloud; Slack; Claude Desktop via 3rd-party MCP server [S22][S33][S45] | — | Named credentials, endpoints |
| Mobile | "Creating a Rethink App for Mobile Devices" (Salesforce mobile app) [S5] | — | — |

## 6. Business processes

### 6.1 Prospecting → qualified prospect → deal
**Start trigger:** broker builds a "prospect universe" (Rethink+ search, import, or manual entry) [S27].
1. **Initiation**
   - Broker runs Rethink+ Search (filters incl. "Likely to Sell") or GEOsearch; saves Property and up to 10 highest-confidence owner Prospects (record type Property Owner). Verified [S30]
   - Alternative path: import spreadsheet (Data Import Wizard / Data Loader) or New Property / New Contact/Company/Prospect. Verified [S27][S43]
2. **Data processing**
   - Owner unlock consumes a pooled credit (property-only saves are free). Verified [S30]
   - Enrich List / External Data → Merge wizard; Get Financials (Debt/Tax). Verified [S30]
   - Duplicate rules / Property Duplicate Detection & Merge. Verified [S40][S5]
3. **Business operations**
   - Records added to a List (≤200 per select from list view; ≤500 GEOsearch results shown); contact List Membership auto-updated. Verified [S26]
   - Broker works list: List widget → Play → call/email → log outcome (connected/voicemail/no answer) → Next; no auto-save of position ("Skip To"). Verified [S26][S39]
   - Bulk "Add Action Plan" / "New Task" on list members. Verified [S26][S28]
4. **Decision/approval**
   - Broker decides prospect is qualified → Convert (creates Company, Contact, Deal); links new contact as property owner (v3.56 one-step). Verified [S30][S15]
   - Not ready → follow-up Task / Action Plan, Rethink Alert on a date field (e.g. lease expiration). Verified [S28][S29]
5. **Completion**
   - Deal created (or converted into an existing deal — only blank fields filled); client requirement fields copied to Tenant Rep / Buyer Rep deals. Verified [S15]
6. **Post-completion**
   - List archived ("Archive List" hides but keeps). Verified [S26]
   - Adoption / activity reports. Verified [S42]
- Alternate: "Remove From List"; record ownership transfer (Mass Transfer). Verified [S26][S40]

### 6.2 Seller Rep / Landlord Rep listing deal (listing → close → comp → Showcase)
**Start trigger:** pitch/proposal to an owner; deal created in Deal Pipeline (Seller Rep or Landlord Rep).
1. **Initiation**
   - New Deal record (type Seller Rep or Landlord Rep), Stage = Prospect; Property lookup; Lead Broker. Verified [S6][S9]
   - Internal Colleagues added as Associated Parties with commission split and access (Read / Read-Write). Verified [S11]
2. **Data processing**
   - Stage → Proposal → Listing; Listing & Marketing section (sites, duration, listed price). Verified [S6][S9]
   - "Sync With Showcase" checked + ≥1 internal broker in Associated Parties → property/deal syncs to Showcase listing; "Send to Showcase" button for immediate push. Verified [S21][S15]
3. **Business operations**
   - Showcase leads flow back as Inquiries (Listing Inquiry related list; "New Inquiry" button). Verified [S6][S21]
   - Offers logged via "New Offer" (Seller Rep: LOI/Offers stage; Landlord Rep: RFP stage). Verified [S6][S9]
   - "Send Activity Report" / branded client activity report to owner client. Verified [S5][S4]
   - Deal Stage Tracker records days in each stage. Verified [S13]
4. **Decision/approval**
   - Client accepts an offer → Escrow/Due Diligence (sale) or Lease Execution (lease); DD/Escrow/PSA or Lease Execution section completed. Verified [S6][S9]
5. **Completion**
   - Stage = Closed → automation creates Sale Comp or Lease Comp (requires Property; Lease comps also require Space/Unit). Comp link shown at top of deal. Verified [S10][S9]
   - v3.56: previous owner/tenant added as Associated Party on Property/Space (ownership/tenancy history). Verified [S15]
   - Rethink → Showcase comp sync (comps created in Rethink). Verified [S21]
6. **Post-completion**
   - Invoice created from Invoices related list (Deal Commission (Gross) auto-filled) → Submit for Approval → Approve → Send. Verified [S12]
   - Comp usable in GEOsearch, PDFs and future proposals. Verified [S32]
- **Alternate / rejection:** Missing Property or Space → no comp created; fix fields, move deal back to an open stage, then to Closed again ("reopen" path). Verified [S10]
- **Cancellation / lost:** No "Lost"/"Dead" stage in published defaults; the "Status" field likely carries active/dead — **Unknown** values. Admin told not to rename "Closed" because automations depend on it [S9].

### 6.3 Tenant Rep / Buyer Rep requirement deal
**Start trigger:** client requirement (tenant needs space / buyer wants acquisition), often from Prospect conversion or Inquiry.
1. **Initiation** — Deal (Tenant Rep or Buyer Rep), Stage Prospect; Client Requirements (Tenant: rent amount, availability date; Buyer: min/max purchase price, property type, class). Verified [S7][S8]
2. **Data processing** — Inquiry/Requirement → "Requirements/Inquiries Match Properties" component scores on-market properties (weights: Max Purchase Price 25%, Min SF 25%, Property Class 5%, Min Cap Rate 5%, Date Space Needed 5%; only "For Sale" or Date Available ≤ today). Verified [S37]
3. **Business operations** — GEOsearch → create Site Selections linked to deal; tour map (Google Maps); scoring and client feedback; Tenant stages Pursuit → Assignment → Survey/Tours → RFP; Buyer stages Identify Acquisition → Underwrite → LOI/Offers. Verified [S7][S8][S32][S34]
4. **Decision/approval** — Offers / RFP responses compared side by side; client selects site. Verified [S34]
5. **Completion** — Lease Execution (tenant) or Escrow/Due Diligence (buyer) → Closed → Lease or Sale Comp auto-created (same required-field rule). Verified [S10]
6. **Post-completion** — Invoice and approval; Associated Party history on property/space; Alerts on lease expiration for renewal pipeline. Verified [S12][S15][S29]

### 6.4 Commission invoicing and approval
**Start trigger:** deal reaches close (or expense to bill).
1. Initiation — "New" on Invoices related list. Verified [S12]
2. Data processing — Deal Commission (Gross) auto-populated; line items added from existing receipt or "Upload New Receipt". Verified [S12]
3. Business operations — Status set (Draft). Verified [S12]
4. Decision/approval — "Submit for Approval" with Approver and Comments; approver gets email and clicks "Approve". Verified [S12]
5. Completion — "Send" to contact in "To" field. Verified [S12]
6. Post-completion — Related tab: files, line items, approval history; invoice logo configurable. Verified [S12][S40]
- Rejection path: Unknown (standard Salesforce reject likely). Inferred.

**Ordered stage lists (key object: Deal Pipeline `TTL_Core__Deal__c`)** — Verified defaults, customer-customisable [S14]:
- Seller Rep: 1 Prospect · 2 Proposal · 3 Listing · 4 LOI/Offers · 5 Escrow/Due Diligence · 6 Closed (· "Testing" appears in help article) [S6]
- Buyer Rep: 1 Prospect · 2 Identify Acquisition · 3 Underwrite · 4 LOI/Offers · 5 Escrow/Due Diligence · 6 Closed (· "Testing") [S8]
- Landlord Rep: 1 Prospect · 2 Proposal · 3 Listing · 4 RFP · 5 Lease Execution · 6 Closed [S9]
- Tenant Rep: 1 Prospect · 2 Pursuit · 3 Assignment · 4 Survey/Tours · 5 RFP · 6 Lease Execution · 7 Closed [S7]

## 7. Automation table

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Comp on close | Deal Stage → Closed | Deal Pipeline | Create Sale/Lease Comp with ~20 mapped fields | Comp linked to deal; skipped if Property (or Space for lease) blank | Apex trigger or record-triggered Flow (package) | Verified behaviour [S10]; Inferred tech |
| Ownership/tenancy history | Deal closes | Deal → Property/Space | Add previous owner/tenant as Associated Party | History on property/space | Apex/Flow | Verified [S15] |
| Prospect conversion carry-over | Convert Prospect | Prospect → Deal | Copy client requirement fields; existing deal only blank fields | — | Apex | Verified [S15] |
| Deal Stage Tracker | Stage change (only after component added) | Deal | Create tracker row with start/end/days | Stage duration reporting | Apex/Flow | Verified [S13] |
| Showcase → Rethink sync | Showcase change | Property, Deal, Space, Comps, Leads | Instant create/update; match by Buildout Id, else exact address + lead broker | Records created with Sync With Showcase checked | External (Buildout API/webhook) | Verified [S21][S15] |
| Rethink → Showcase sync | Sync With Showcase = true and ≥1 internal broker | Property, Deal, Space, Comp | Scheduled batch (15 min–daily; spaces/comps 10 min–daily) or "Send to Showcase" | Listing updated in Showcase | Scheduled Apex + callout | Verified [S21] |
| Rethink Alerts | Daily scheduled run | Contact, Prospect, Property, Space/Unit, Deal Pipeline, Offer | Email using template from "Rethink Alerts" folder, before/after a date field | Email within ~1 hr of run | Scheduled Apex | Verified [S29] |
| Action Plans | User applies template | Any (list, deal, property, contact) | Create task series with owners and due dates | Tasks | Action Plans app (likely Salesforce Labs) | Verified [S28] |
| List Membership update | Add/remove contact to list | Contact | Update List Membership picklist | Segment by list | Apex | Verified [S26] |
| Invoice gross commission | New invoice | Invoice | Populate Deal Commission (Gross) | — | Formula/Flow | Verified [S12] |
| Invoice approval | Submit for Approval | Invoice | Email approver; approval history | Approved → Send | Approval Process | Verified [S12] |
| On-market matching | View Inquiry record | Inquiry/Requirement | Weighted match to properties | Suggestions → link/create deal | LWC + Apex | Verified [S37] |
| Send Contact Email | Button on Associated Parties | Deal | Draft email listing parties' names/emails/phones | Email in Activity panel | Quick action/Apex | Verified [S11] |
| Rethink+ owner unlock | User unlock | Prospect | Consume credit, retrieve contact | Owner contact data | External data API | Verified [S30] |
| Recurring tasks | Task recurrence | Task | Standard recurrence | — | Standard | Verified [S44] |

## 8. UI / UX

- **App**: Lightning app(s) "Rethink" plus "Prospecting Console" console app (April 2025); App Launcher item "Rethink Settings"; "Rethink+ Search" tab. Verified [S38][S29][S30]
- **Home**: customisable home page by profile; report charts and dashboards on home. Verified [S40][S42]
- **Navigation**: tabs include Companies, Contacts, Properties, Spaces/Units, Deal Pipeline (by rep type), Comps, Inquiries/Requirements, Lists, GEOsearch. Verified [S35][S16][S37][S26]
- **Record pages**: Lightning record pages with Details / Related / Activity tabs; highlights panel; dynamic forms and actions; Stage path on Deal; "Comp" link at top of closed deal. Verified [S35][S40][S10]
- **List views**: Table (default, spreadsheet-like, inline edit) and Kanban (columns = Deal Stage, summary = Gross Commission). Verified [S6][S9]
- **Map views**: GEOsearch with radius/polygon, map marker colours, PDF export with logo/footer. Verified [S32][S5]
- **Utility**: Lists widget lower-left (Play/Next/Skip To). Verified [S26]
- **Stacking Plan** tab on Office property pages. Verified [S31]
- **New design theme**: "How to Upgrade to the New Rethink/Apto Design Theme". Verified [S40]
- **Mobile**: Salesforce mobile app (article "Creating a Rethink App for Mobile Devices"). Verified [S5]
- **Portals**: none found. Unknown.
- **Public screenshot/demo URLs (not downloaded)**:
  - https://www.buildout.com/tour/crm — tour page; images: `https://cdn.prod.website-files.com/641a1c972968413ab4e2fd3b/688bc20c5a2f0880484d8ea2_Section_01.webp` (dashboard), `..._Rethink_LP_Section_02.webp` (contact view with requirements pop-up), `..._Rethink_LP_Section_03.webp` (Rethink+ map search with owner contacts/AI callouts), `..._Rethink_LP_Section_04.webp` (deal pipeline Kanban). Observed via page text [S4]
  - https://rethink.help.buildout.com/en/articles/8043436-rethink-video-library — video sections: Intro to Rethink; Rethink Deal Pipeline Overview; Prospecting Tools in Rethink; Initial Admin Tasks; Rethink Fundamentals & Database Hygiene; Rethink Deal Flow & Transaction Management (embed URLs not exposed). [S53]
  - https://rethink.help.buildout.com/en/articles/7919999-rethink-webinar-tutorials — webinar list. [S53]
  - Help articles S6–S9 contain screenshots of Table/Kanban and deal sections.

## 9. Reporting

- Standard Salesforce reports/dashboards; custom report types; joined reports; summary formulas; scheduled/subscribed reports; dynamic dashboards (View As); adoption, login history, email message reports. Verified [S42]
- "Deal Activity Report" and "Sending an Activity Report" (client-facing activity report from deal); "branded client activity reports". Verified [S9][S5][S4]
- KPIs implied: pipeline Gross Commission by stage (Kanban), days in stage (Deal Stage Tracker), activity counts, comps. Verified/Inferred [S6][S13]
- Objects driving reports: Deal Pipeline, Activities, Comps, Properties, Spaces, Lists. Inferred.
- Pre-built dashboard names: Unknown.

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Buildout Showcase | Listing marketing / websites | Bi-directional (configurable) | Property↔Listing, Deal↔Listing, Space↔Lease Space, Sale/Lease Comps, Leads→Inquiries | Showcase→Rethink instant; Rethink→Showcase scheduled or button | Buildout API + webhooks; external ID "Buildout Id" | Verified | [S20][S21][S15] |
| Showcase email (contact lists) | Use Rethink contact lists in Showcase | Rethink → Showcase | Contact lists | — | — | Verified (title) | [S45] |
| ProspectNow | Property/owner data (Buildout-owned) | Into Rethink | Property data | — | — | Verified (title) | [S45] |
| Rethink+ data | Ownership, financials, owner contacts | Into Rethink | Property, Prospect, Financials | User search/unlock | External data service | Verified | [S30] |
| Outlook / Gmail | Email & calendar | Bi-directional | Emails, events | — | Einstein Activity Capture (included); Cirrus Insight (AppExchange); M365 auth moved EWS → Microsoft Graph | Verified | [S22][S44] |
| Microsoft Teams | Collaboration | — | — | — | Requires Sales & Service Cloud licence (extra cost) | Verified | [S22] |
| Mailchimp | Email marketing | Bi-directional (paid version) | Contacts, campaigns, MC Subscriber Activity | — | AppExchange (free and paid versions) | Verified | [S22] |
| Constant Contact | Email marketing | — | — | — | Middleware; "high effort" | Verified | [S22] |
| HubSpot / Marketo / Pardot | Marketing automation | Sync contacts/accounts | — | — | Vendor connectors | Verified | [S22] |
| Phone dialers | Calling | — | Calls | Click-to-dial | PhoneIQ, RingCentral, Revenue Intelligence, PhoneBurner, Dialpad (AppExchange); Terrakotta.ai | Verified | [S22][S45] |
| Document generation | Proposals/letters | Out | Docs | — | Nintex Drawloop DocGen, Conga, S-Docs, Google Docs | Verified | [S22][S45] |
| E-signature | Contracts | Out | — | — | DocuSign, Adobe Sign | Verified | [S22] |
| SMS/WhatsApp | 1:1 chat | — | — | — | Mogli | Verified | [S22] |
| Business card scanners | Contact capture | In | Contacts | — | Vision-e, ScanBizCards | Verified | [S22] |
| Slack | Notifications/collab | — | — | — | Salesforce-Slack | Verified (title) | [S45] |
| SmartCloud | Unknown purpose | — | — | — | AppExchange | Verified (title) | [S45] |
| Claude Desktop | AI assistant over CRM data | Read/write | Companies, contacts, deals, properties, spaces, offers, comps, listings, prospects, brokers | User prompt | Third-party open-source MCP server `@advanced-communities/salesforce-mcp-server` + Salesforce CLI; not built/supported by Buildout | Verified | [S33] |
| CoStar | — | — | — | — | Not mentioned in integration options | Unknown | [S22] |

## 11. Limitations & what would be hard to recreate

- **Hard to recreate**: Rethink+ national property/owner data, LLC unmasking, owner-unlock credit pool and "likely to sell" signals (licensed data) [S30][S47]; Buildout Showcase bi-directional sync with Buildout Id matching logic [S20][S21]; GEOsearch map UX with PDF/tour outputs [S32]; Stacking Plan component [S31]; weighted requirement-to-property matching [S37].
- **Easy to recreate on Salesforce**: four rep-type pipelines as record types + paths; comp-on-close Flow; Associated Parties junction with access levels; Invoice + approval; Deal Stage Tracker; Lists/Action Plans; date-based alerts.
- **Vendor limitations**: Compact Layouts overwritten on every upgrade [S25]; Closed stage must not be renamed [S9]; comp not created if Property/Space missing [S10]; list position not saved [S26]; GEOsearch shows 500 results max [S26]; list view select 200 at a time [S26]; Salesforce Platform licence limits (standard Lead/Opportunity use constrained — Inferred); competitor claims of no native dialer/mass email platform [S47] (partially contradicted: help documents mass email via templates/List Email [S44]); competitor claim "portfolio view not native" [S47] contradicted by Portfolio record type [S17].
- **Gaps (Unknown)**: API names for all objects except Deal and Colleague; Deal "Status" values; Offer fields/status values; Site Selection fields; vendor Apex/Flow names; AppExchange listing; how Lists store members.

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| S1 | Buildout announces acquisition of Rethink | https://www.buildout.com/press/buildout-announces-acquisition-of-rethink | vendor site | 2026-11-12 |
| S2 | Buildout + Rethink company news / FAQ | https://www.buildout.com/company-news/buildout-rethink | vendor site | 2026-11-12 |
| S3 | Buildout llms.txt (product summaries) | https://www.buildout.com/llms.txt | vendor site | 2026-11-12 |
| S4 | Buildout CRM tour (Rethink / Rethink+ pricing) | https://www.buildout.com/tour/crm | vendor site | 2026-11-12 |
| S5 | Rethink Help Center home | https://rethink.help.buildout.com/en/ | help | 2026-11-12 |
| S6 | Deal Pipeline - Seller Rep | https://rethink.help.buildout.com/en/articles/7920035-deal-pipeline-seller-rep | help | 2026-11-12 |
| S7 | Deal Pipeline - Tenant Rep | https://rethink.help.buildout.com/en/articles/7920033-deal-pipeline-tenant-rep | help | 2026-11-12 |
| S8 | Deal Pipeline - Buyer Rep | https://rethink.help.buildout.com/en/articles/7920036-deal-pipeline-buyer-rep | help | 2026-11-12 |
| S9 | Deal Pipeline - Landlord Rep | https://rethink.help.buildout.com/en/articles/7920032-deal-pipeline-landlord-rep | help | 2026-11-12 |
| S10 | Creating Internal Comps from Closed Deals | https://rethink.help.buildout.com/en/articles/7920031-creating-internal-comps-from-closed-deals | help | 2026-11-12 |
| S11 | Adding Parties to a Deal | https://rethink.help.buildout.com/en/articles/7920040-adding-parties-to-a-deal | help | 2026-11-12 |
| S12 | Creating Invoices in Rethink | https://rethink.help.buildout.com/en/articles/7920042-creating-invoices-in-rethink | help | 2026-11-12 |
| S13 | Deal Stage Tracker Setup & Overview | https://rethink.help.buildout.com/en/articles/7920129-deal-stage-tracker-setup-overview | help | 2026-11-12 |
| S14 | Customizing Deal Stages in Deal Pipeline | https://rethink.help.buildout.com/en/articles/7920171-customizing-deal-stages-in-deal-pipeline | help | 2026-11-12 |
| S15 | Rethink Fall 2026 Release Notes - v3.56 | https://rethink.help.buildout.com/en/articles/18308922-rethink-fall-2026-release-notes-v3-56 | release notes | 2026-11-12 |
| S16 | Manually Creating External Lease & Sale Comps | https://rethink.help.buildout.com/en/articles/7920029-manually-creating-external-lease-sale-comps | help | 2026-11-12 |
| S17 | Enabling Property Portfolio Functionality | https://rethink.help.buildout.com/en/articles/7920145-enabling-property-portfolio-functionality | help | 2026-11-12 |
| S18 | Adding Spaces/Units to Your CRM | https://rethink.help.buildout.com/en/articles/7920028-adding-spaces-units-to-your-crm | help | 2026-11-12 |
| S19 | Adding Properties to Your CRM | https://rethink.help.buildout.com/en/articles/7920030-adding-properties-to-your-crm | help | 2026-11-12 |
| S20 | Rethink & Showcase Integration Field Mapping | https://rethink.help.buildout.com/en/articles/11844717-rethink-showcase-integration-field-mapping | help | 2026-11-12 |
| S21 | Rethink & Showcase Integration User Guide | https://rethink.help.buildout.com/en/articles/10433088-rethink-showcase-integration-user-guide | help | 2026-11-12 |
| S22 | Integration Options with Rethink and Apto | https://rethink.help.buildout.com/en/articles/8921829-integration-options-with-rethink-and-apto | help | 2026-11-12 |
| S23 | Rethink User Profile Types | https://rethink.help.buildout.com/en/articles/7920093-rethink-user-profile-types | help | 2026-11-12 |
| S24 | Rethink User License Management | https://rethink.help.buildout.com/en/articles/7920088-rethink-user-license-management | help | 2026-11-12 |
| S25 | Considerations for Rethink Updates | https://rethink.help.buildout.com/en/articles/10104301-considerations-for-rethink-updates | help | 2026-11-12 |
| S26 | Prospecting Lists in Rethink | https://rethink.help.buildout.com/en/articles/7920044-prospecting-lists-in-rethink | help | 2026-11-12 |
| S27 | Build Your Prospect Universe | https://rethink.help.buildout.com/en/articles/14079541-build-your-prospect-universe | help | 2026-11-12 |
| S28 | Set Follow-Ups and Action Plans | https://rethink.help.buildout.com/en/articles/14079978-set-follow-ups-and-action-plans | help | 2026-11-12 |
| S29 | Rethink Alerts | https://rethink.help.buildout.com/en/articles/14443449-rethink-alerts-stay-on-top-of-important-dates-automatically | help | 2026-11-12 |
| S30 | Rethink+ User Guide | https://rethink.help.buildout.com/en/articles/11849878-rethink-user-guide | help | 2026-11-12 |
| S31 | Setting Up Stacking Plan | https://rethink.help.buildout.com/en/articles/7920139-setting-up-stacking-plan | help | 2026-11-12 |
| S32 | Using GEOsearch in Rethink | https://rethink.help.buildout.com/en/articles/7920045-using-geosearch-in-rethink | help | 2026-11-12 |
| S33 | Connecting Claude Desktop with Rethink | https://rethink.help.buildout.com/en/articles/15465872-connecting-claude-desktop-with-rethink | help | 2026-11-12 |
| S34 | Unlock More Value from Rethink: 3 Powerful Features | https://rethink.help.buildout.com/en/articles/12926039-unlock-more-value-from-rethink-3-powerful-features-to-start-using-today | help | 2026-11-12 |
| S35 | Adding Companies to Your CRM | https://rethink.help.buildout.com/en/articles/7920023-adding-companies-to-your-crm | help | 2026-11-12 |
| S36 | Adding Contacts to Your CRM | https://rethink.help.buildout.com/en/articles/7920024-adding-contacts-to-your-crm | help | 2026-11-12 |
| S37 | Suggested On-Market Property Matching | https://rethink.help.buildout.com/en/articles/9792868-suggested-on-market-property-matching | help | 2026-11-12 |
| S38 | Prospecting Console Lightning App | https://rethink.help.buildout.com/en/articles/11021572-prospecting-console-lightning-app | help | 2026-11-12 |
| S39 | Launch Outreach | https://rethink.help.buildout.com/en/articles/14079870-launch-outreach | help | 2026-11-12 |
| S40 | System Administrator Tasks (collection, 66 articles) | https://rethink.help.buildout.com/en/collections/5823900-system-administrator-tasks | help | 2026-11-12 |
| S41 | Product Updates (collection, 23 articles) | https://rethink.help.buildout.com/en/collections/5823919-product-updates | release notes | 2026-11-12 |
| S42 | Reports & Dashboards (collection) | https://rethink.help.buildout.com/en/collections/5825619-reports-dashboards | help | 2026-11-12 |
| S43 | Importing & Exporting (collection) | https://rethink.help.buildout.com/en/collections/6179184-importing-exporting | help | 2026-11-12 |
| S44 | Activity Tracking (collection) | https://rethink.help.buildout.com/en/collections/5823886-activity-tracking | help | 2026-11-12 |
| S45 | Integrations (collection) | https://rethink.help.buildout.com/en/collections/5823898-integrations | help | 2026-11-12 |
| S46 | Rethink CRM: Key Features, Pricing, Alternatives (SharpLaunch) | https://www.sharplaunch.com/sites/rethink | third party | 2026-11-12 |
| S47 | Unreal vs Rethink (competitor comparison) | https://www.unrealcrm.com/comparison/unreal-vs-rethink | third party (competitor) | 2026-11-12 |
| S48 | G2 REthink CRM reviews (403; search snippet) | https://www.g2.com/products/rethink-crm/reviews | review | 2026-11-12 |
| S49 | G2 Rethink (Buildout) reviews (search snippet) | https://www.g2.com/products/rethink/reviews | review | 2026-11-12 |
| S50 | Capterra Rethink CRM reviews (403; search snippet) | https://www.capterra.com/p/133963/REthink/reviews/ | review | 2026-11-12 |
| S51 | Think Tech Labs announces REthink Commercial/Residential release (PRWeb, 2015; snippet) | https://www.prweb.com/releases/think_tech_labs_announces_latest_release_of_rethink_commercial_and_rethink_residential/prweb12877007.htm | third party / press | 2026-11-12 |
| S52 | MergerLinks / PrivSource: Buildout acquires Rethink (2021-02-23) | https://app.mergerlinks.com/transactions/2021-02-23-rethink | third party | 2026-11-12 |
| S53 | Rethink Video Library | https://rethink.help.buildout.com/en/articles/8043436-rethink-video-library | help / video index | 2026-11-12 |
| S54 | Ascendix: Top 5 Salesforce-based CRMs (403; snippet; competitor) | https://ascendix.com/blog/salesforce-commercial-real-estate-crm/ | third party (competitor) | 2026-11-12 |
| S55 | Buildout pricing | https://www.buildout.com/pricing | vendor site | 2026-11-12 |
| S56 | PR Newswire: rethink reveals new branding (2019; title only) | https://www.prnewswire.com/news-releases/rethink-reveals-new-branding-and-direction-to-power-commercial-real-estate-transactions-from-prospecting-to-closing-300810558 | press | 2026-11-12 |
