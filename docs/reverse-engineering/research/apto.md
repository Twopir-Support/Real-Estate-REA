# Apto (Commercial Real Estate CRM, now Buildout) — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

**Method note.** apto.com no longer resolves (DNS failure / wpengine certificate mismatch on www). The current vendor documentation is the **Apto Help Center hosted by Buildout** (apto.help.buildout.com, Intercom), which was fetchable; Buildout blog posts were fetchable. AppExchange has no current Apto listing. G2, GlobeNewswire 2017 releases and NAI Global pages returned 403, so those facts come from search-engine snippets and are marked as such. Text inside help-center screenshots/GIFs was not readable, so most field-level API names are Unknown. Some Apto help articles share text with the Rethink help center (e.g. "Importing Data with Data Import Wizard" says "Rethink" throughout) — noted where it matters. No video was watched, so nothing is labelled Observed.

## 0. Identity and status

| Item | Finding | Label | Source |
|---|---|---|---|
| Product name | Apto (Apto CRM; historic modules Apto Commissions / "Back Office", Apto Mobile, Apto Prospect & Nurture, Apto Data) | Verified (help center) / snippets for module launches | [S1][S5][S28][S29] |
| Original publisher | Apto, Inc., Denver, Colorado (founded 2011 per Dealroom, 2012 per CB Insights); CEO Tanner McGraw (2016) | Third-party snippets (founding); Verified (CEO quote in Buildout press) | [S30][S31] |
| Current owner | **Buildout** (CRE marketing/CRM vendor); acquisition announced **19 Jan 2022** ("Apto is now part of Buildout") | Verified | [S1] |
| Ownership history | Apto/Buildout integration partnership 26 Sep 2016 → Buildout acquires Apto Jan 2022 (Buildout also owns Rethink CRM) | Verified | [S1][S31] |
| Platform | **Salesforce-based.** Buildout: "Salesforce-based CRM functionality customized for commercial real estate"; users get a "Salesforce Platform" user licence plus the managed package licence "Commercial Real Estate Broker" and permission set "Apto x7"; namespace `McLabs2__` | Verified | [S2][S12][S15] |
| Managed package | Installed package named **"Commercial Real Estate Broker"** (licences managed under Setup → Installed Packages → Manage Licenses) | Verified | [S15] |
| Namespace | `McLabs2__` ("Apto's internal prefix"; examples `McLabs2__Property__c`, `McLabs2__Listing__c`) | Verified | [S12] |
| AppExchange listing | **None found today.** A 2026 competitor comparison says Apto is "unavailable on AppExchange". No listing id. | Third-party snippet; absence Inferred | [S27] |
| Current status | **Legacy / maintenance-only.** "Apto is no longer being sold to new customers—only maintained for its current base"; "it's no longer available to new brokerages"; "Apto is heavily supported for our existing customers". No sunset date published. Buildout recommends **Buildout Rethink / Rethink+** instead. Apto login link on buildout.com points to the Rethink login page. | Verified | [S2][S3] |
| Still developed? | Help center is maintained and still adding articles in 2026 (e.g. "Over the Term Invoices (Back Office)" dated 22 Apr 2026; "Connecting Claude Desktop with Apto"; "Setting Up Passkeys…") | Verified | [S10][S12][S25] |
| Rebrand claim | Some third parties say Apto was "rebranded as Buildout CRM"; Buildout's own pages still call it "Apto". Treat rebrand as unconfirmed. | Third-party snippet; vendor contradicts | [S2][S27][S34] |
| Native vs integrated | Native Salesforce org delivered by vendor (each customer is a Salesforce org; "Requesting Help from Salesforce Support", "Check Your Salesforce Version and Status" articles) | Verified | [S25][S36] |

**Bottom line:** Apto is a Salesforce-native CRE brokerage CRM (namespace `McLabs2__`) that **still runs for existing customers on Salesforce but is not sold to new customers**. Buildout's go-forward Salesforce-based product is Rethink/Rethink+ (also Salesforce-based, per Buildout's 2022 statement about offering "a Salesforce-based CRM"), which is a different product.

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| G2 | 3.3/5, 37 reviews | 3.3/5 (search snippet of G2 seller page, 2026-11-12) | 37 | https://www.g2.com/sellers/apto ; https://www.g2.com/products/apto/reviews | Direct fetch 403. Snippet: "37 reviews and an average star rating of 3.3". G2 compare pages show a different metric (7.0/10 from 24 reviews, Real Estate CRM category). **Matches supplied.** [S26] |
| Capterra | — | not found | — | — | No Apto Capterra page located. |
| Trustpilot | — | not rated here | — | https://ca.trustpilot.com/review/apto.com | Contains negative single reviews and an Apto reply pointing to support.apto.com/hc/en-us help center relaunch. [S33] |
| AppExchange | — | no listing | — | — | See section 0. [S27] |

## 2. Overview (12 questions)

- **What it is** — CRM and deal-management system for commercial real-estate (CRE) brokers, built on Salesforce: companies, contacts, properties, spaces, ownership/locations, listings, deal pipeline(s), offers, comps, commission/back office (invoices, payments), prospecting console, reporting. Verified [S2][S8][S10][S12].
- **Developer** — Apto, Inc. (Denver); now Buildout. Verified [S1].
- **Industry** — Commercial real estate brokerage (office, industrial, retail, land, multifamily, hospitality). Verified [S18][S19].
- **Target users** — CRE brokers, teams, brokerages (historically CBRE, JLL, Cushman & Wakefield, Colliers, NAI Global offices; "CRM of choice for 6 of the top 8 CRE brands" in 2016). Profiles: Administrator, Operations, Broker, Associate. Verified (profiles) [S16]; customers from vendor press 2016 [S31] and partner snippets.
- **Problems solved** — Prospecting owners/tenants, tracking ownership and lease expirations, managing pursuits → listings → escrow → closed deals, logging marketing activity for client reports, comp database, commission booking and invoicing. Verified [S2][S6][S10][S12][S13][S21].
- **Major functions** — Prospecting Console, Deal Pipeline (single-object or multi-object), Deal Parties & Offers, Comps (lease/sale), Book Lease Wizard & Over-the-Term invoicing, Stacking Plans, Marketing Activity Reports, Buildout marketing integration, Einstein Activity Capture email sync. Verified [S6][S7][S10][S11][S13][S14][S21].
- **Differentiators** — CRE-specific data structures (ownership "Portfolio" vs tenant "Locations"), stacking plans, back-office commission/invoicing in same org, Buildout marketing publishing. Verified [S3][S4][S8][S14].
- **Native/integrated** — Native Salesforce (managed package "Commercial Real Estate Broker"). Verified [S15].
- **Editions/licences required** — "Salesforce Platform" user licence + package licence; Microsoft Teams integration requires Sales & Service Cloud licence bought from Salesforce; more licences via "Need More Licenses?" article. Verified [S11][S15][S25].
- **Pricing & licensing** — Not public. Onboarding includes one data source import; extra sources $300 each. Comparably snippet mentions Basic and Pro packages. Verified ($300) [S17]; packages third-party [S35].
- **Managed/unmanaged** — Managed (namespace `McLabs2__`, installed package with licence management). Verified [S12][S15].
- **Limitations & dependencies** — Not sold to new customers; Salesforce admin-heavy ("often requiring IT support"); prospecting/marketing not built in (per Buildout); dated maps; many clicks for data entry (G2 reviews); Platform licence limits standard objects (Inferred: Platform licence lacks Opportunity/Lead, hence custom deal objects). Verified [S2][S26]; licence reasoning Inferred.

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Companies & Contacts | Every Contact must belong to a Company (placeholder "Private Investor"/"No Company"); Contact Type required; record types incl. Tenant and Principal | Brokers, associates | Company, Contact, Contact Type | Properties (ownership/locations), Deal Parties | Rolodex → relational CRM | Verified | [S8][S19][S23] |
| Properties | Property records with record types Office, Industrial, Land, Multifamily, Portfolio, Retail; Building SF; Market/Submarket; Property Owner (Contact/Company) lookups | Brokers, research | `McLabs2__Property__c` | Spaces, Ownership, Comps, Listings | — | Verified | [S12][S18][S19] |
| Spaces / Units | Leasable areas on a Property (Floor, Suite critical) | Leasing brokers | Space (Floor, Suite) | Stacking Plan, Listings | — | Verified | [S14][S22] |
| Ownership ("Portfolio") & Locations | Ownership links Principal/Company to Property; "Locations" are active leases for tenants | Brokers | Ownership; lease/location records | Property, Contact, Company | — | Verified (concepts); Ownership object named in [S12] | [S8][S12] |
| Stacking Plans | Floor/suite stack on Office/Multifamily properties, colour-coded by time to lease expiry | Leasing brokers | Space data | Property | Spreadsheet stacks → live view | Verified | [S14] |
| Prospecting Console | Salesforce console app ("Apto Prospecting Console"), split view of a list view + record tabs + activity log | Brokers, associates | Activities | Any object list view | — | Verified | [S13] |
| Deal Pipeline — single-object | One **Deal** object ("Deal Pipeline") with **Deal Stage** picklist per record type | Brokers, managers | Deal, Deal Stage, Status, commission fields | Deal Parties, Offers, Activities | — | Verified | [S6][S9][S12] |
| Deal Pipeline — multi-object | **Pursuit → Listing → Project → Closed Deal** as separate objects (internal names: Pursuit = "Proposal", Project = "Escrow") | Brokers | Pursuit, Listing, Project, Closed Deal | Comps, Commission, Invoices | — | Verified | [S12] |
| Assignments (tenant rep) | Tenant-rep engagements with need dates; activities logged to Listings, Assignments, Deals | Tenant-rep brokers | Assignment, need date | Activities, reports | — | Verified (label) | [S12][S20] |
| Deal Parties | Contacts/Companies on a Deal with Role | Brokers | Company, Contact, Role | Deal | — | Verified | [S7] |
| Offers ("Deal Offers") | Offers received on active listings/deals | Listing brokers | Offer details (fields in screenshots) | Deal | — | Verified | [S7] |
| Comps | Lease Comp / Sale Comp records with Deal and Property lookups; price/SF, cap rate | Research, brokers | Comp | Property, Deal, Closed Deal | — | Verified | [S12][S18][S22][S23] |
| Back Office / Commissions | Commission entries on Closed Deal (rate types incl. Flat Fee), commission splits, Book Lease Wizard, invoices (incl. Over the Term), payments | Accounting, ops | Closed Deal commission, Invoice, Payment, Commission splits | Comp, Closed Deal | Spreadsheet AR → automated invoices | Verified | [S10][S12][S28] |
| Activities | Tasks, emails, events; calls, tours, offers logged to listings/deals; Einstein Activity Capture | Brokers | Task/Event/EmailMessage | Marketing Activity Report | — | Verified | [S20][S21][S36] |
| Projects | "Projects" (stored as "Escrow") — in-contract stage of multi-object pipeline | Brokers | Project | Closed Deal | — | Verified (label/internal) | [S12] |
| Marketing (Buildout) | Publish listing to Buildout; nightly sync of property/space/listing changes; Buildout generates flyers/websites | Marketing coordinators | Property, Space, Listing, images | Buildout | Manual flyers → generated | Verified | [S4][S31] |
| Reports & Dashboards | Standard Salesforce reports; Marketing Activity Report, "Deals With Activities"; joined reports; dynamic dashboards | Managers | — | All objects | — | Verified | [S21][S24] |
| AI connector (DIY) | Third-party Salesforce MCP server lets Claude Desktop read/write Apto data under user permissions | Power users | — | All objects | — | Verified | [S12] |

## 4. Data model

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Company | `Account` (Inferred) | Standard | Firms, owners, tenants; "Private Investor"/"No Company" placeholder | Name, Property Owner (Company) relation | — | Contact, Ownership, Locations | Inferred (Salesforce Account relabelled; help refers to "Accounts (Companies)" in HubSpot/Marketo integration notes) | [S11][S19] |
| Contact | `Contact` | Standard | People; record types incl. **Tenant**, **Principal**; Contact Type required | Contact Type, Company (required), Property Owner (Contact) relation | Company | Deal Parties, Ownership, Locations | Verified (object, types); API std | [S8][S18][S19] |
| Property | `McLabs2__Property__c` | Custom | Building/land asset | Property Name (required), record type (Office, Industrial, Land, Multifamily, Portfolio, Retail), Building SF, Market, Submarket (dependent picklist), Property Owner (Contact), Property Owner (Company), Property Type multi-picklist (Industrial, Hospitality, Office, Land, Retail), Tags | — | Space, Ownership, Comp, Listing, Stacking Plan | Verified | [S12][S18][S19] |
| Space / Unit | `Proposed: Space__c` (API Unknown; label "Space"/"Spaces/Units") | Custom | Leasable area | Floor, Suite, size (>5,000 SF query example), availability, lease expiration (Inferred from stacking colour) | Property | Listing (Inferred) | Verified (object); API Unknown | [S12][S14][S22] |
| Ownership | `Proposed: Ownership__c` (API Unknown) | Junction | Owner (Contact/Company) ↔ Property ("Portfolio" on owner side) | owner, property | Property, Contact/Company | — | Verified (object label "ownership" in [S12]); API Unknown | [S8][S12] |
| Location (lease) | `Proposed: Location__c` (API Unknown) | Junction | Tenant ↔ Property active lease ("Locations") | tenant, property, lease dates (Inferred) | Property, Contact/Company | — | Verified (concept); object existence Inferred | [S8] |
| Deal (Deal Pipeline) | `Proposed: Deal__c` (API Unknown; object label "Deal Pipeline", record label "Deal") | Custom | Single-object pipeline for lease/sale/tenant-rep deals | **Deal Stage** (picklist per record type), Status, Gross Commission, House Fee, net commission formula, projected close date | Property (Inferred) | Deal Party, Offer, Comp, Activities | Verified (object, Deal Stage) | [S6][S9][S12][S18] |
| Pursuit | `Proposed: Pursuit__c` — internal object name "Proposal" (exact API Unknown) | Custom | Multi-object pipeline stage 1 (proposal/pitch) | Unknown | Property/Company (Inferred) | Listing (Inferred) | Verified (label + internal name) | [S12] |
| Listing | `McLabs2__Listing__c` | Custom | Marketed availability (sale or lease); stage 2 of multi-object pipeline; publishable to Buildout | listing status, price, images (via Buildout) | Property / Space | Offers, activities, Project (Inferred) | Verified | [S4][S12][S21] |
| Project | `Proposed: Project__c` — internal object name "Escrow" (exact API Unknown) | Custom | In-contract/escrow stage of multi-object pipeline | projected close date (Inferred from "Deals in contract and their projected close dates") | Listing (Inferred) | Closed Deal (Inferred) | Verified (label + internal name) | [S12] |
| Closed Deal | `Proposed: Closed_Deal__c` (API Unknown) | Custom | Booked transaction; holds commission structure; parent of invoices | commission entries (rate type e.g. Flat Fee, start/end term), invoice settings | Comp / Project (Inferred) | Invoice, Commission split | Verified | [S10][S12] |
| Comp | `Proposed: Comp__c` (API Unknown) | Custom | Lease or sale comparable; record types **Lease Comp**, **Sale Comp** | Deal (lookup), Property (lookup), Building SF (formula from Property), price per SF, cap rate, close date, Broker, Buyer, owner | Property, Deal | — | Verified (record types from Data Import Wizard article that mixes "Rethink" wording) | [S12][S18][S22][S23] |
| Assignment | `Proposed: Assignment__c` (API Unknown) | Custom | Tenant-rep engagement with need date | need date | Company/Contact (Inferred) | Activities | Verified (label) | [S12][S20] |
| Deal Party | `Proposed: Deal_Party__c` (API Unknown) | Junction | Company + Contact + Role on a Deal | Company, Contact, Role | Deal | — | Verified | [S7][S12] |
| Offer ("Deal Offers") | `Proposed: Deal_Offer__c` (API Unknown) | Custom | Offers received on listings/deals | Unknown (screenshots) | Deal | — | Verified | [S7][S12] |
| Commission split | `Proposed: Commission_Split__c` (API Unknown) | Custom | Broker/house split of commission | split %, amount (Inferred) | Deal / Closed Deal | — | Verified (label "commission splits") | [S12] |
| Commission booking / entry | `Proposed: Commission__c` (API Unknown) | Custom | Commission lines on Closed Deal (rate type, term) | rate type (Flat Fee…), start/end term | Closed Deal | Invoice line items (Inferred) | Verified (concept) | [S10][S12] |
| Invoice | `Proposed: Invoice__c` (API Unknown) | Custom | Commission invoice; "Invoices" list view; PDF preview; Over-the-Term monthly generation | invoice number, Invoice Type ("Over the Term"), Billing Cycle End, Next Invoice Date, Invoice Creation Action (--None--, Email to Recipient, Send Notification to User), Invoice Notification User, due date | Closed Deal | Payment | Verified | [S10] |
| Payment | `Proposed: Payment__c` (API Unknown) | Custom | Payments against invoices | Unknown | Invoice | — | Verified (label) | [S10][S12] |
| Task / Event / EmailMessage | standard | Standard | Calls, tours, offers, emails | Activity type, custom activity fields | any | — | Verified | [S20][S21][S24] |
| MC Subscriber Activity | API Unknown | Custom (Mailchimp free app) | Mailchimp activity | — | Contact | — | Verified (name) | [S11] |

### Relationships
- Company → Contact (one-to-many; Contact must have Company). Verified [S8][S19].
- Property ↔ Contact/Company via ownership ("Portfolio") and via lease ("Locations"). Verified [S8]; Property Owner (Contact/Company) lookups on Property create "owned properties" related lists. Verified [S18].
- Property → Space (related list "Spaces"). Verified [S14].
- Comp → Deal (lookup), Comp → Property (lookup). Verified [S18].
- Deal → Deal Party (Company, Contact, Role); Deal → Offers (related list). Verified [S7].
- Closed Deal → Invoices (related list); commission entries on Closed Deal. Verified [S10].
- Comp ↔ Closed Deal: Book Lease Wizard launches from the comp, and invoice-failure emails go to the "comp owner" → Comp and Closed Deal are tightly linked (possibly the same record family "closed deals and comps"). Inferred [S10][S12].
- Multi-object pipeline order Pursuit → Listing → Project → Closed Deal. Verified order of listing in [S12]; conversion mechanism Unknown.
- Lookup vs master-detail for all of the above: Unknown.

### Record types (found)
- Property: Office, Industrial, Land, Multifamily, Portfolio, Retail. Verified [S19].
- Contact: Tenant, Principal (others in unreadable graphic). Verified [S8].
- Comp: Lease Comp, Sale Comp. Verified [S22][S23].
- Deal: lease vs sale (and tenant rep) record types implied; Deal Stage values are assigned per record type. Verified (per-record-type picklist) [S6][S9]; names Unknown.

### Picklist values (found)
- **Deal stages:** "four deal stages in Apto", from **Pursuit** to **Closed**. Middle two not named. Verified [S6]. Inferred mapping to multi-object pipeline: Pursuit → Listing → Project/Escrow (in contract) → Closed (Deal) — matches the four objects in [S12].
- Deal **Status**: field exists; values Unknown. Verified [S12].
- Market / Submarket: dependent picklist (values org-specific). Verified [S18].
- Property type multi-picklist: Industrial, Hospitality, Office, Land, Retail. Verified [S18].
- Invoice Creation Action: --None--, Email to Recipient, Send Notification to User. Verified [S10].
- Commission rate type: includes Flat Fee (others Unknown). Verified [S10].
- Deal Party Role: values Unknown. [S7]
- For contrast only (Rethink, **not Apto**): Tenant Rep stages Prospect, Pursuit, Assignment, Survey/Tours, RFP, Lease Execution, Closed. Verified for Rethink [S32]. Do not attribute to Apto.

### Roll-ups, formulas, validation, external IDs
- Formula examples: Net commission = Gross Commission − House Fee (vendor example); Comp "Building SF" pulled from Property. Verified [S18].
- Field history tracking, validation rules, matching/duplicate rules available as standard Salesforce admin features. Verified [S25].
- External IDs: Unknown.

### Compact ERD edge list
```
Account(Company) -> Contact (lookup, std) [Verified]
Account/Contact -> Ownership <- McLabs2__Property__c (junction, "Portfolio") [Verified concept; API Unknown]
Account/Contact -> Location(lease) <- McLabs2__Property__c (junction, "Locations") [Verified concept; object Inferred]
McLabs2__Property__c -> Space (lookup|MD unknown) [Verified]
McLabs2__Property__c -> McLabs2__Listing__c (lookup) [Inferred]
Space -> McLabs2__Listing__c (lookup) [Inferred]
Pursuit("Proposal") -> McLabs2__Listing__c -> Project("Escrow") -> Closed Deal (pipeline progression) [Verified order; link type Unknown]
Deal -> Deal Party (junction Account+Contact+Role) [Verified]
Deal -> Offer (lookup) [Verified]
McLabs2__Property__c -> Comp (lookup) [Verified]
Deal -> Comp (lookup) [Verified]
Comp -> Closed Deal (Book Lease Wizard) [Inferred]
Closed Deal -> Commission entry / Commission split (lookup|MD unknown) [Verified concept]
Closed Deal -> Invoice (lookup) [Verified]
Invoice -> Payment (lookup) [Verified label; link Inferred]
Contact/Account -> Assignment (lookup) [Inferred]
```

## 5. Technical components

- **Package / namespace** — Managed package "Commercial Real Estate Broker", namespace `McLabs2__`. Verified [S12][S15].
- **Licensing/security** — User licence "Salesforce Platform"; permission set "Apto x7"; profile types Administrator (1 per 50 users), Operations, Broker, Associate; "Export Reports" permission typically admin-only; sharing rules, MFA, passkeys, Setup Audit Trail. Verified [S15][S16][S25].
- **Apps** — "Apto Prospecting Console" (Lightning console app, opened via App Launcher "nine dots"). Verified [S13].
- **Wizards / custom UI** — "Book Lease" button on comp detail opens the **Book Lease Wizard** (invoice section, over-the-term settings). Invoice PDF "Preview". Stacking Plan component on Property details. LWC/Aura/VF names Unknown. Verified (labels) [S10][S14].
- **Scheduled processing** — Monthly invoice generation on "Next Invoice Date"; failure email to comp owner. Likely Scheduled Apex (Inferred). Verified behaviour [S10].
- **Flows** — Help center teaches customers to build their own Flows ("Introduction to Flows", "Creating Flows"); no packaged Flow names published. Verified (articles exist) [S25]; packaged Flow names Unknown.
- **Formula fields / validation** — customer-configurable; examples above. Verified [S18][S25].
- **Lightning features** — Dynamic Forms, Dynamic Actions, Lightning Record Pages, compact layouts, Kanban tiles, Highlights Panel, Global Actions, in-app guidance. Verified [S25].
- **Integrations tech** — Einstein Activity Capture (Gmail/Outlook), AppExchange dialers (PhoneIQ, RingCentral, PhoneBurner, Dialpad, Revenue Intelligence), Mogli SMS/WhatsApp, S-Docs/DocuSign/AdobeSign, Mailchimp, HubSpot, Marketo, Pardot, Microsoft Teams, Google Docs; Buildout listing sync. Verified [S4][S11][S36].
- **API access** — Standard Salesforce APIs (Salesforce CLI login used for the MCP connector `@advanced-communities/salesforce-mcp-server`). Verified [S12].
- **Apex class names, triggers, LWC names** — Unknown (none published).

## 6. Business processes

### P1. Prospecting & relationship building (owners and tenants)
**Start trigger:** Broker targets a market/submarket, property type or lease-expiry window.
1. **Initiation**
   - Import data (CoStar, Reonomy, Yardi exports, prior CRM backups) via onboarding or Data Import Wizard / Data Loader. Verified [S17][S22].
   - Create Company → Contact (Contact Type, record type Tenant/Principal) → Property (record type). Verified [S8][S19].
2. **Data processing**
   - Link owners to properties (Ownership / "Portfolio") and tenants to properties ("Locations"); add Spaces with Floor/Suite. Verified [S8][S14].
   - Duplicate/matching rules prevent duplicates (standard Salesforce). Verified [S25].
3. **Business operations**
   - Build list views (e.g. office properties in submarket; last activity date filter) and work them in the **Apto Prospecting Console** split view, logging calls in the Activity Log. Verified [S13].
   - Stacking plan colour-codes lease expiries to find tenants to call. Verified [S14].
4. **Decision/approval**
   - Broker decides to pursue → create Pursuit (multi-object) or Deal at stage Pursuit (single-object). Verified [S6][S12]. No approval process documented. Unknown.
5. **Completion**
   - Activities recorded (Tasks/Events, Einstein Activity Capture emails). Verified [S36].
6. **Post-completion**
   - Chatter follows on properties alert brokers (e.g. comp added to target property, deal stage changes — use cases). Verified [S23]. Adoption/activity reports ("Tracking Activity for Specific Brokers"). Verified [S24].

### P2. Landlord/seller representation: Pursuit → Listing → Project (Escrow) → Closed Deal
**Start trigger:** Owner pitch / proposal opportunity.
1. **Initiation** — Pursuit record (internal "Proposal") or Deal with Deal Stage = Pursuit; Deal Parties added (Company, Contact, Role). Verified [S6][S7][S12].
2. **Data processing** — On win, Listing (`McLabs2__Listing__c`) for the Property/Space; "Publish a listing to Buildout with a click" copies fields and images; Buildout updated nightly with property, space availability and listing status changes. Verified [S4][S12].
3. **Business operations** — Marketing activity (calls, emails, tours, offers) logged against the Listing; Offers ("Deal Offers") logged as received; "Marketing Activity Report" / "Deals With Activities" shared with the owner client. Verified [S7][S20][S21].
4. **Decision/approval** — Offer accepted → Project (internal "Escrow", "deals in contract" with projected close dates). Verified [S12]. Mechanism of conversion (button/flow/manual) Unknown.
5. **Completion** — Closed Deal booked with commission entries and commission splits (broker/house; Gross Commission − House Fee); Comp created (Sale Comp or Lease Comp). Verified [S10][S12][S18].
6. **Post-completion** — Invoices generated (one-off or Over the Term), payments recorded; comps feed future pricing analysis. Verified [S10][S12].
   - **Alternate paths:** Pursuit lost — status values Unknown; firms that moved from multi-object to single Deal pipeline keep older deals "as history" and some show an open status that should be treated as history. Verified [S12]. Listing withdrawn/expired values Unknown.

### P3. Tenant representation (Assignment → lease)
**Start trigger:** Tenant client engagement (need date for space).
1. **Initiation** — Assignment (tenant rep) with need date, or Deal with tenant-rep record type at stage Pursuit. Verified (Assignment, need date) [S12][S20].
2. **Data processing** — Search available Spaces (e.g. "Available spaces over 5,000 SF in a named submarket"). Verified (example query) [S12].
3. **Business operations** — Tours/calls logged to the Assignment; offers/proposals tracked. Verified [S20].
4. **Decision/approval** — Lease negotiated; stage moves through Deal Stage values configured per record type. Verified [S9]; names Unknown.
5. **Completion** — Lease Comp + Closed Deal via **Book Lease** (Book Lease Wizard from comp). Verified [S10].
6. **Post-completion** — Commission invoicing (see P4); Location (tenant lease) on Property updated (Inferred).

### P4. Commission booking & invoicing (Back Office)
**Start trigger:** Deal closes (Closed Deal / Book Lease).
1. **Initiation** — Book Lease Wizard launched from comp; commission structure entered on Closed Deal. Verified [S10].
2. **Data processing** — Invoice section: Invoice Type (e.g. "Over the Term"), Billing Cycle End (day of month or "Last"), Next Invoice Date, Invoice Creation Action, Invoice Notification User. Verified [S10].
3. **Business operations** — Monthly invoice auto-generated on Next Invoice Date; date advances one month; current PDF includes unpaid prior line items; due date computed from payment info (editable). Verified [S10].
4. **Decision/approval** — Single-month adjustment via new commission entry with rate type "Flat Fee" and start/end term; no approval process documented. Verified [S10]; approvals Unknown.
5. **Completion** — Invoice emailed to recipient or user notified; payments recorded against invoices; Buildout advises AI tools must not change invoices, payments or commission bookings. Verified [S10][S12].
6. **Post-completion** — Failure → email to comp owner with reasons; revenue forecasting/reporting (Apto Commissions 2017 launch: "forecast revenue, report on performance and get paid"). Verified [S10]; [S28] snippet.

### Status / stage lists
- **Deal (single-object) Deal Stage:** Pursuit → (2 unnamed stages) → Closed. Default middle values Unknown; customers customise per record type. Verified [S6][S9].
- **Multi-object pipeline (object = stage):** Pursuit ("Proposal") → Listing → Project ("Escrow") → Closed Deal. Verified [S12].
- **Invoice:** generated → (sent/notified) → paid in full / not paid in full; explicit status values Unknown. Verified (partial) [S10].
- **Listing status:** synced to Buildout ("listing status"); values Unknown. Verified field existence [S4].

## 7. Automation table

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Publish listing to Buildout | User click | Listing, Property, Space | Copy fields + images to Buildout | Marketing materials | External API (button) | Verified [S4] |
| Nightly Buildout update | Nightly schedule | Property, Space, Listing | Push changes | Marketing in sync | Scheduled external sync | Verified [S4] |
| Over-the-Term invoice generation | Next Invoice Date reached | Closed Deal, Invoice | Create monthly invoice, roll unpaid lines, advance date | Recurring billing | Scheduled Apex (Inferred) | Verified behaviour [S10] |
| Invoice creation action | Invoice created | Invoice | Email to Recipient / notify user | Delivery | Apex/Flow (Unknown) | Verified [S10] |
| Invoice failure alert | Generation fails | Comp owner | Email reasons | Ops awareness | Apex (Inferred) | Verified [S10] |
| Net commission formula | Field change | Deal/Closed Deal | Gross − House Fee | Net commission | Formula | Verified (example) [S18] |
| Comp Building SF | Record view | Comp | Pull Property Building SF | Analysis | Formula (cross-object) | Verified (example) [S18] |
| Email/calendar capture | Email/meeting | Activity | Log to records | Activity history | Einstein Activity Capture | Verified [S36] |
| Chatter feed tracking | Tracked field change (e.g. stage) | Deal, Property | Feed post / alert followers | Collaboration | Salesforce Feed Tracking | Verified (use case) [S23] |
| Scheduled reports / subscriptions | Schedule | Reports | Email report | Management info | Salesforce reporting | Verified [S24] |
| Customer-built Flows | Customer-defined | Any | Customer-defined | — | Flow | Verified (capability) [S25] |
| Pipeline progression Pursuit→Listing→Project→Closed Deal | User action | pipeline objects | Create next record | Stage change | Unknown (button/Flow/Apex) | Unknown |

## 8. UI / UX

- **Navigation:** Lightning app with nav bar (customisable default navigation bar), tabs for Companies, Contacts, Properties, Deal Pipeline, Comps, Listings, Invoices, Reports, Dashboards; "Deal Offers" can be added to the nav bar. Verified [S7][S10][S25].
- **Home page:** CRM Home Page customisable per profile type; report charts and dashboards on home. Verified [S24][S25][S36].
- **Record pages:** Highlights panel (compact layouts), Details/Related tabs, enhanced related lists (up to 10 columns), hover details, Dynamic Forms/Actions, Activity timeline; Property page shows Stacking Plan and Spaces related list; Contact profile sections "Locations" / "Portfolio"; Deal page sections Deal Parties and Offers. Verified [S7][S8][S14][S25].
- **List views:** Table, Kanban (tiles customisable, e.g. Deal Pipeline by stage), Split view. Verified [S23][S25].
- **Console:** Apto Prospecting Console with split view and sub-tabs, History utility. Verified [S13].
- **Maps:** a maps feature exists (reviewers call it dated). Third-party (G2 snippet) [S26].
- **Mobile:** Apto Mobile App launched March 2017 (GlobeNewswire snippet); current mobile is Salesforce mobile (Inferred). [S29]
- **Public screenshots/demo URLs (not downloaded):**
  - https://plus.cretech.com/product-demos/videos/apto — "Virtual Demo Day September 2021 - Apto" (CREtech product demo video page).
  - https://apto.help.buildout.com/en/articles/7919917-apto-deal-pipeline-overview — embedded video: creating a lease/sale deal and moving Pursuit → Closed.
  - https://apto.help.buildout.com/en/articles/7919935-object-overview-companies-contacts-and-properties — GIFs of Company/Contact/Property records and record types.
  - https://apto.help.buildout.com/en/articles/8038587-using-stacking-plans — screenshots of stacking plan on property.
  - https://apto.help.buildout.com/en/articles/7919922-understanding-the-prospecting-console-layout — screenshots of console split view.
  - https://apto.help.buildout.com/en/articles/14723715-over-the-term-invoices-back-office — screenshots of Book Lease Wizard invoice section and sample invoice emails.
  - https://apto.help.buildout.com/en/articles/7919915-creating-deal-parties-and-offers — screenshots of Deal Parties and Offer form.

## 9. Reporting

- Standard Salesforce reports/dashboards: creating/modifying reports, custom report types, joined reports, summary formulas, scheduled and subscribed reports, dynamic dashboards ("View As"). Verified [S24].
- Named reports: **"Marketing Activity Report"** (per listing: calls, emails, tours, offers), **"Deals With Activities"**, report on Email Messages, User Login History Report, adoption reports, "Tracking Activity for Specific Brokers". Verified [S21][S24].
- KPIs (from vendor examples): deals in contract and projected close dates; tenant-rep need dates in next 90 days; comps (price/SF, cap rate) by market/time; commission split per deal; available space by submarket; activity per broker. Verified (as example queries) [S12].
- Back-office revenue forecasting (Apto Commissions, 2017). Snippet [S28].

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Buildout (marketing) | Flyers, property websites, email marketing | Out (Apto → Buildout) | Properties, spaces, listings, images | Button + nightly | Vendor integration | Verified | [S4][S31] |
| Gmail / Outlook (Einstein Activity Capture) | Email & calendar sync | In | Emails, events | Continuous | Salesforce EAC | Verified | [S11][S36] |
| Dialers: PhoneIQ, RingCentral, PhoneBurner, Dialpad, Revenue Intelligence, Terrakotta.ai | Calling | Bi (Inferred) | Calls/activities | User | AppExchange apps | Verified (options) | [S11] |
| Mogli | SMS/WhatsApp | Bi (Inferred) | Messages | User | App | Verified | [S11] |
| Vision-e, ScanBizCards | Business card scanning | In | Contacts | User | AppExchange | Verified | [S11] |
| S-Docs, DocuSign, AdobeSign, Google Docs | Documents & e-signature | Out/In | Documents | User | AppExchange / Salesforce | Verified | [S11][S25] |
| Mailchimp (free / paid via Beaufort), Constant Contact, HubSpot, Marketo, Pardot | Marketing email/automation | Bi (Mailchimp paid) / varies | Contacts, Accounts (Companies), campaign activity ("MC Subscriber Activity") | Sync | AppExchange/middleware | Verified | [S11] |
| Microsoft Teams | Collaboration | Bi | — | — | Salesforce Teams integration (needs Sales & Service Cloud licence) | Verified | [S11] |
| CoStar, Reonomy, Yardi (exports) | Data import | In | Properties, contacts, comps | Onboarding/import | CSV + Data Import Wizard/Data Loader | Verified | [S17][S22] |
| Apto Data (2019) | 30 property data points | In | Property attributes | Unknown | Unknown | Third-party snippet | [S29] |
| Claude Desktop (DIY MCP) | AI querying/updating | Bi | All objects user can access | User prompts | `@advanced-communities/salesforce-mcp-server` + Salesforce CLI | Verified | [S12] |

## 11. Limitations & what would be hard to recreate

- **Product is closed to new customers** — anything we mirror is a legacy design; Buildout steers buyers to Rethink/Rethink+. Verified [S2][S3].
- **Two coexisting pipeline models** (single Deal object vs multi-object Pursuit/Listing/Project/Closed Deal) with historical records left open after migration — any clone must choose one and explain mapping. Verified [S12].
- **Back-office invoicing** — over-the-term recurring invoices with rolling unpaid line items and PDF generation; requires scheduled Apex, document generation and email. Verified behaviour [S10].
- **Stacking plan UI** — custom visual component on Property using Space Floor/Suite and lease expiry. Verified [S14].
- **Buildout publishing** — depends on Buildout's proprietary API. Verified [S4].
- **Data-model gaps (Unknown):** exact API names for every object except `McLabs2__Property__c` and `McLabs2__Listing__c`; Space/Ownership/Location/Comp/Deal/Deal Party/Offer/Commission/Invoice/Payment fields; Deal Stage defaults (two middle stages); Status values; listing status values; lookup vs master-detail; Apex/Flow/LWC names. The vendor has an "Apto Object Reference" file "available by request" — not public. Verified (existence of reference) [S12].
- **Documentation quality** — help centre text is thin (screenshots carry the detail) and some articles are copied from Rethink. Verified [S22].
- **Not to be confused with Rethink** — Rethink help shows tenant-rep stages Prospect → Pursuit → Assignment → Survey/Tours → RFP → Lease Execution → Closed; these are Rethink defaults, not Apto. Verified for Rethink [S32].

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| S1 | Buildout + Apto (acquisition announcement, 19 Jan 2022) | https://www.buildout.com/company-news/buildout-apto | vendor site | 2026-11-12 |
| S2 | Apto CRM vs Modern CRE CRMs: What Brokers Need to Know in 2025 | https://www.buildout.com/blog-posts/apto-crm-vs-modern-cre-crms-what-brokers-need-to-know-in-2025 | vendor site | 2026-11-12 |
| S3 | What Brokers Learned from Apto: 4 Lessons for Your Next CRM Investment | https://www.buildout.com/blog-posts/what-brokers-learned-from-apto-4-lessons-for-your-next-crm-investment | vendor site | 2026-11-12 |
| S4 | Buildout + Apto: Working Together for You | https://www.buildout.com/blog-posts/buildout-apto-working-together-for-you | vendor site | 2026-11-12 |
| S5 | Apto Help Center (Buildout) — home/collections | https://apto.help.buildout.com/en/ | help | 2026-11-12 |
| S6 | Apto Deal Pipeline Overview | https://apto.help.buildout.com/en/articles/7919917-apto-deal-pipeline-overview | help | 2026-11-12 |
| S7 | Creating Deal Parties and Offers | https://apto.help.buildout.com/en/articles/7919915-creating-deal-parties-and-offers | help | 2026-11-12 |
| S8 | Object Overview - Companies, Contacts and Properties | https://apto.help.buildout.com/en/articles/7919935-object-overview-companies-contacts-and-properties | help | 2026-11-12 |
| S9 | Customizing Deal Stages in Deal Pipeline | https://apto.help.buildout.com/en/articles/7920171-customizing-deal-stages-in-deal-pipeline | help | 2026-11-12 |
| S10 | Over the Term Invoices (Back Office) (22 Apr 2026) | https://apto.help.buildout.com/en/articles/14723715-over-the-term-invoices-back-office | help | 2026-11-12 |
| S11 | Integration Options with Rethink and Apto | https://apto.help.buildout.com/en/articles/8921829-integration-options-with-rethink-and-apto | help | 2026-11-12 |
| S12 | Connecting Claude Desktop with Apto | https://apto.help.buildout.com/en/articles/17582418-connecting-claude-desktop-with-apto | help | 2026-11-12 |
| S13 | Understanding the Prospecting Console Layout | https://apto.help.buildout.com/en/articles/7919922-understanding-the-prospecting-console-layout | help | 2026-11-12 |
| S14 | Using Stacking Plans | https://apto.help.buildout.com/en/articles/8038587-using-stacking-plans | help | 2026-11-12 |
| S15 | Adding a New User and Assigning an Apto License | https://apto.help.buildout.com/en/articles/7919909-adding-a-new-user-and-assigning-an-apto-license | help | 2026-11-12 |
| S16 | Permissions and User Profiles | https://apto.help.buildout.com/en/articles/7919906-permissions-and-user-profiles | help | 2026-11-12 |
| S17 | What Data Can Apto Import To My Account? | https://apto.help.buildout.com/en/articles/7919932-what-data-can-apto-import-to-my-account | help | 2026-11-12 |
| S18 | Creating Custom Fields: Field Types Explained | https://apto.help.buildout.com/en/articles/9358007-creating-custom-fields-field-types-explained | help | 2026-11-12 |
| S19 | Adding a Contact, Company & Property; Adding Properties to Your CRM | https://apto.help.buildout.com/en/articles/7919933-adding-a-contact-company-property ; https://apto.help.buildout.com/en/articles/7920030-adding-properties-to-your-crm | help | 2026-11-12 |
| S20 | Logging Activities to Deals | https://apto.help.buildout.com/en/articles/7919916-logging-activities-to-deals | help | 2026-11-12 |
| S21 | Marketing Activity Reports | https://apto.help.buildout.com/en/articles/7919912-marketing-activity-reports | help | 2026-11-12 |
| S22 | General Importing Questions; Importing Data with Data Import Wizard (text uses "Rethink") | https://apto.help.buildout.com/en/articles/7920099-general-importing-questions ; https://apto.help.buildout.com/en/articles/7920101-importing-data-with-data-import-wizard | help | 2026-11-12 |
| S23 | Help center search "comp" / "listing" results; How to Collaborate Using Chatter; List View Formats | https://apto.help.buildout.com/en/?q=comp ; https://apto.help.buildout.com/en/articles/7920155-how-to-collaborate-using-chatter ; https://apto.help.buildout.com/en/articles/9089881-list-view-formats | help | 2026-11-12 |
| S24 | Reports & Dashboards collection (18 articles) | https://apto.help.buildout.com/en/collections/5823869-reports-dashboards | help | 2026-11-12 |
| S25 | System Administration collection (57 articles: Flows, Dynamic Forms, validation, sharing, passkeys) | https://apto.help.buildout.com/en/collections/5823870-system-administration | help | 2026-11-12 |
| S26 | G2 — Apto seller/reviews page (search snippet; 403 on fetch) | https://www.g2.com/sellers/apto | review | 2026-11-12 |
| S27 | Ascendix: Why Salesforce for Commercial Real Estate? Top 5 Salesforce-Based CRMs (search snippet: Apto "unavailable on AppExchange") | https://ascendix.com/blog/salesforce-commercial-real-estate-crm/ | third party (competitor) | 2026-11-12 |
| S28 | Apto Commissions launch (GlobeNewswire, 24 May 2017) — search snippet; 403 on fetch | https://www.globenewswire.com/news-release/2017/05/24/1254186/0/en/Apto-Commissions-Launches-A-Simple-Way-for-Commercial-Real-Estate-Brokerages-to-Forecast-Revenue-Report-On-Performance-and-Get-Paid.html | press release | 2026-11-12 |
| S29 | Apto Mobile App (Mar 2017), Prospect & Nurture (Aug 2017), Apto Data (Nov 2019) — search snippets | https://www.globenewswire.com/news-release/2017/03/29/1254182/0/en/Apto-Makes-It-Easier-Than-Ever-for-CRE-Brokers-to-Be-Productive-on-the-Go-With-the-Launch-of-Apto-Mobile-App.html ; https://onlinemarketplaces.com/articles/apto-launches-apto-data-a-crm-and-deal-management-platform | press / third party | 2026-11-12 |
| S30 | Dealroom / CB Insights / PitchBook company profiles (founding year, Denver, acquisition 19 Jan 2022) — search snippets | https://dealroom.co/companies/apto/ ; https://www.cbinsights.com/investor/apto ; https://pitchbook.com/profiles/company/83914-39 | third party | 2026-11-12 |
| S31 | Apto Partners With Buildout (26 Sep 2016) | https://www.buildout.com/press/apto-partners-with-buildout | vendor press | 2026-11-12 |
| S32 | Deal Pipeline - Tenant Rep (**Rethink**, contrast only) | https://rethink.help.buildout.com/en/articles/7920033-deal-pipeline-tenant-rep | help (other product) | 2026-11-12 |
| S33 | Trustpilot — apto.com reviews (search snippet) | https://ca.trustpilot.com/review/apto.com | review | 2026-11-12 |
| S34 | UnrealCRM: Unreal vs Apto (competitor; search snippet) | https://www.unrealcrm.com/comparison/unreal-vs-apto | third party (competitor) | 2026-11-12 |
| S35 | Comparably — Apto FAQs (search snippet: Basic/Pro packages, "Commercial Real Estate Package") | https://www.comparably.com/companies/apto/faqs | third party | 2026-11-12 |
| S36 | Initial Apto Setup collection (24 articles incl. Einstein Activity Capture, Requesting Help from Salesforce Support) | https://apto.help.buildout.com/en/collections/5823857-initial-apto-setup | help | 2026-11-12 |
| S37 | CREtech Virtual Demo Day September 2021 - Apto | https://plus.cretech.com/product-demos/videos/apto | video page | 2026-11-12 |
