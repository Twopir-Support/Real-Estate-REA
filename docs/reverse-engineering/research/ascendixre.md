# AscendixRE — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Verified (search snippet)** — taken from a search-engine snippet of a vendor page that returned HTTP 403 to direct fetch (ascendix.com, g2.com, capterra.com). Treat as weaker than Verified.
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.

Never invent API names. Only names quoted from Ascendix pages appear as API names. Everything else is `Unknown` with a `Proposed:` name in our own `TC_` convention (the names used by the TC mirror already built in this repo).

Basis: a prior research pass (repo file `docs/research/AscendixRE_Public_Research_Notes.md`, same date) was reused and re-labelled (VERIFIED -> Verified, VERIFIED-snippet -> Verified (search snippet), ASSUMPTION -> Inferred). Fresh research on 2026-11-12 added: current AppExchange rating, release notes 1.39-1.43, AI Suite (Harvest, Conversational Agent, Connector, Composer AI), Automatching on the Preferences object, MarketSpace process, commission payout order. Direct fetches of ascendix.com, g2.com and capterra.com returned 403. help.ascendix.com and its mirror ascendix.helpjuice.com worked, except MarketSpace articles, which redirect to a sign-in page.

## 0. Identity and status

| Item | Value | Label | Source |
|---|---|---|---|
| Product name | AscendixRE (also "AscendixRE CRM"). Pricing and AI pages in 2026 brand the plans "xRE Foundations" and "xRE Enterprise" and the add-on "xRE AI Suite" | Verified (search snippet) | [S-pricing][S-ai] |
| Publisher | Ascendix Technologies (Dallas, TX) | Verified | [PR-AI] |
| AppExchange listing | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5eloEAB — listing id `a0N3000000B5eloEAB` | Verified | [AX] |
| Listed on AppExchange | 10/02/2014; last updated 09/18/2026 | Verified | [AX] |
| Latest release | AscendixRE 1.43, 25 Sep 2026 (1.42 Jul 2026; 1.41 May 2026; 1.40 Dec 2025; 1.39 Aug 2025) | Verified | [RN-index][RN-143] |
| Status | Active, in continuous development; AI Suite launched 10 Jun 2026 | Verified | [RN-index][PR-AI] |
| Ownership history | No acquisition or rename found. "xRE" appears to be a 2026 plan/brand label, not a new product | Inferred (no rename announcement found; help center still says "AscendixRE") | [S-pricing][RN-143] |
| Platform | **Native on Salesforce**: managed package, namespace `ascendix`, auto-upgrades | Verified | [AX][H-capsrc][H-web2inq] |
| Sister products (same vendor, separate) | Ascendix Search (search/map/bulk ops), Composer (document generation, also for Dynamics 365), MarketSpace (listing portal and deal rooms; add-on to Salesforce or standalone with its own database), Harvest, Ascendix Conversational Agent | Verified / Verified (search snippet) for MarketSpace | [AX][H-composer][S-ms][HV-setup][AIC-install] |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| G2 | 4.3/5, 9 reviews | 4.3/5 (search snippet, 2026-11-12) | 9 | https://www.g2.com/products/ascendixre/reviews | Page returned 403; value seen in search snippets of the product and compare pages. Matches supplied value. |
| AppExchange | — | 4.98 (fetched 2026-11-12) | 91 | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5eloEAB | Fetched directly. Vendor case study elsewhere claims "4.97 CSAT" — older figure. |
| Capterra | — | Not visible (403). Snippets suggest 0 reviews | 0? | https://www.capterra.com/p/128399/AscendixRE/ | Do not rely on it. |
| TrustRadius / PeerSpot | — | No reviews shown (snippet) | 0 | https://www.trustradius.com/products/ascendixre/reviews | Snippet only. |
| Techjockey / SoftwareFinder | — | 4.3 (5 ratings) / 4.0 (3 reviews) per snippet | small | https://www.techjockey.com/detail/ascendixre | Aggregators, low weight. |

## 2. Overview

- **What it is** — A commercial real estate (CRE) CRM for brokers built on Salesforce: properties, availabilities, listings, leases, sales comps, inquiries, deals, commissions, stacking plans, capital markets. **Verified** [AX][H-glossary]
- **Developer** — Ascendix Technologies, Dallas, TX. **Verified** [PR-AI]
- **Industry** — Commercial real estate brokerage (tenant rep, landlord rep, investment sales, capital markets/mortgage banking, land brokers). **Verified** [H-close]; persona bundles **Verified (search snippet)** [S-persona]
- **Target users** — Brokers, analysts, brokerage admins and accounting (commission privacy), mortgage brokers. **Verified** [H-privacy][H-cm-def]
- **Problems solved** — One system for building data, comps, pipeline, splits and marketing; replaces spreadsheets for stacking plans and commission splits. **Verified** [AX]
- **Major functions** — Property/Availability/Listing/Lease/Sale records; Inquiry capture and conversion; Deal pipeline with 12 record types; rent tables; commissions; stacking plans; map search; Composer documents; AI Suite. **Verified** [AX][H-close][H-renttable]
- **Differentiators** — Property-hub model, deal-close object mapping engine, commission privacy, rent tables, stacking plan, AI Suite with MCP-style Connector for Claude/ChatGPT. **Verified** [H-connect][H-listmap][H-privacy][PR-AI]
- **Native/integrated** — Native managed package; Harvest and the Conversational Agent run on Agentforce/Einstein in the same org; Connector is an external bridge. **Verified** [AX][HV-setup][S-connector]
- **Editions / licences** — Salesforce Enterprise or Unlimited; Platform Cloud licence included in the plan price. Not Essentials, Group, Professional. **Verified** [AX][H-limits]; licence bundling **Verified (search snippet)** [S-pricing]
- **Pricing & licensing** — From $79/user/month (AppExchange). xRE Foundations $79, xRE Enterprise $99/user/month (commissions, Composer, Search included); xRE AI Suite from $39/month per org, requires Enterprise. Nonprofit discounts. **Verified** [AX]; tiers **Verified (search snippet)** [S-pricing][S-ai]
- **Package** — Managed (namespace `ascendix`). **Verified** [AX][H-capsrc]
- **Limitations & dependencies** — Stacking plan may fail in Classic/Safari; editable grid shows 1,000 and updates 500 records; image upload 25 MB; geocoding import chunks of 99; Web-to-Inquiry no Time/DateTime fields; Harvest needs Agentforce/Einstein licence. **Verified** [H-limits][HV-setup]

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Property management | Building master; hub for all records; image gallery, map, stacking plan | Brokers, researchers | Location, type/sub type (record type), size, class, floors, avg floor size, market/region/submarket, owner and broker parties | Availability, Lease, Sale, Listing, Deal, Inquiry | Before: building data in spreadsheets; after: one property hub | Verified | [H-connect][H-propintro][H-prepop] |
| Availability management | Vacant suites in a property; status closed by deal close; automatch to Preferences | Landlord reps | Status, size, floor, image; unit lookups | Property, Deal (Space), Inquiry, Preferences | — | Verified (fields partly Inferred) | [H-availintro][H-dealavail][AUTO] |
| Listing management | Listing agreement held by listing broker; anchor for marketing and inquiries | Listing brokers | Record type Lease/Sale/Sale or Lease, Exclusive, Sublease, broker/owner/market fields | Property, Inquiry (Prospective Listing), Deal, MarketSpace | — | Verified | [H-listmap][H-prepop][H-multilist] |
| Lease management (comps) | Lease abstracts; rent table; expiration reminders; lease comp report | Tenant & landlord reps | Unit, type, size, rate, floor, tenant, commencement/expiration; Lease Periods | Property, Tenant Account, Deal | — | Verified | [H-close][H-renttable][H-leaseexp][H-leasecomp] |
| Sale management (comps) | Sale history of a property | Investment sales | Sale date, listing price, sale price, buyer/seller and contacts | Property, Deal | — | Verified | [H-close][H-names] |
| Inquiry management | Lead/interest capture (call, email, portal, web form, Harvest, LoopNet/Crexi); multi-listing; convert or disqualify | Brokers, assistants | Contact/company, broker, preferences (price, size, type, date), listing | Listing (Prospective Listings), Account/Contact/Deal on convert | Before: leads in inbox; after: tracked and reportable "foot traffic" | Verified | [H-inq-what][H-multilist][RN-139][RN-116] |
| Preferences & automatching | Saved Ascendix Search on Preferences object turned into an automatch shown on Availability ("Find Preferences") | Landlord reps | Move-in range, area, rent, property type, sale/lease, region | Availability, Property | Manual filter -> one-click matches | Verified | [AUTO][HV-setup] |
| Deal management | Pipeline by business line (12 record types); party auto-population; close dialog creates Lease/Sale/Listing | Brokers | Stage, parties, fee fields, lease terms, close status/date/value | Property, Availability, Account, Commission, Deal Period, Prospective Buyer, Offer, Deal Source | — | Verified | [H-close][H-autopop][H-newdeal] |
| Rent tables | Generated periods on Deal and Lease; review flags; carry-forward deal -> lease | Brokers, analysts | From, To, Duration, Rate, Rent/Month, Total | Deal, Lease | — | Verified | [H-renttable][H-renttotal][H-rentcfg][RN-143] |
| Commissions | Gross fee calc; commission records by type; splits; privacy; payouts | Brokers, accounting | Gross fee method/percent/amount, per-SF rate; commission type, %, gross/net/house | Deal, User, Account/Contact | Before: spreadsheet splits | Verified | [H-comm][H-psf][H-privacy] |
| Capital markets | Deal sources (lenders), capital sources, term sheets, multiple properties | Mortgage brokers | Deal Source, Capital Source lookup, term sheet quotes | Deal, Property | — | Verified | [H-dealsrc][H-termsheet][H-multiprop] |
| Stacking plan | Floor-by-floor view of leases and availabilities | Landlord reps, tenant reps | Floors, avg floor size, leases, availabilities | Property, Lease, Availability | — | Verified | [H-stack][H-stackcfg][S-stack] |
| Ascendix Search & map | Advanced search, map (OSM/Google), shapes, radius, saved searches, ad-hoc lists, bulk ops, mass email, Mailchimp | All users | Saved searches, ad-hoc lists | All objects | — | Verified | [H-map][H-search-index][H-bulk][H-adhoc] |
| Composer | Templates -> PDF / email / microsite; tour books, flyers, lease comp reports | Marketing, brokers | Templates, publications | Any record via dynamic elements | — | Verified | [H-compover][H-compfunc][H-tourbook] |
| MarketSpace | Public listing portal; webform -> Inquiry; deal room with NDA gate | Listing brokers, investors | Inquiries, deal room access | Listing, Availability, Inquiry, Deal | — | Verified (search snippet) | [S-ms][S-inq] |
| AI Suite | Harvest (email -> draft records), Agent (chat/voice CRUD), Connector (Claude/ChatGPT), Composer AI (documents) | Brokers | Record Request Sets, chat sessions, action logs | All core objects | Manual entry -> reviewed AI drafts | Verified | [PR-AI][HV-convert][AIC-install][S-connector] |
| Admin Console | Object field mapping, business logic toggles, accounting/privacy, web form generator, image viewer, name formats | Admins | Custom metadata records | All | — | Verified | [H-rentcfg][H-names][H-listmap] |
| Activities & follow-ups | Std activities; follow-up sequences; lease expiration Flow; drip tasks | Brokers | Tasks/Events | Contact, Lease | — | Verified | [H-followup][H-leaseexp][H-prospects] |

## 4. Data model

Namespace `ascendix` **Verified** [H-capsrc]. Unprefixed names below presumably carry `ascendix__` in subscriber orgs — **Inferred** (the one fully-qualified field published is `ascendix__CapitalSource__c`).

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Property | Unknown. `Proposed: TC_Property__c` | Custom | Building master, hub | Record type (Office named; drives Property Type/Sub Type), Class, Market, Region, Sub Market, Number of floors, Average floor size, Description, Location Description, Website, Listing Broker Company/Contact, Owner/Landlord(+Contact), Primary Image | — | Availability, Lease, Sale, Listing, Deal, Inquiry, Deal Property | Verified | [H-connect][H-prepop][H-stackcfg][H-imgviewer][S-stack] |
| Availability | Unknown. `Proposed: TC_Availability__c` | Custom | Vacant suite | Status (incl. Closed), Primary Image; size/floor/rate Inferred | Property | Deal (Space lookup), Inquiry | Verified | [H-glossary][H-dealavail][H-newdeal] |
| Unit | Unknown. `Proposed: TC_Unit__c` | Custom | Named in name-format config; no description | Unknown | Unknown (Property Inferred) | Unknown | Verified (existence only) | [H-names] |
| Unit Profile | Unknown. `Proposed: TC_Unit_Profile__c` | Custom | Named only | Unknown | Unknown | Unknown | Verified (existence only) | [H-names] |
| Market Rent | Unknown. `Proposed: TC_Market_Rent__c` | Custom | Named only | Unknown | Unknown | Unknown | Verified (existence only) | [H-names] |
| Listing | Unknown. `Proposed: TC_Listing__c` | Custom | Listing agreement | Record types Lease / Sale / Sale or Lease; Exclusive, Sublease checkboxes; Name, Property, Region, Market, broker/owner fields (copied from Property on create), Primary Image | Property | Prospective Listing, Inquiry, Deal | Verified | [H-listmap][H-prepop][H-close] |
| Lease | Unknown. `Proposed: TC_Lease__c` | Custom | Lease abstract / comp | Unit Name/Number, Unit Type, Property, Lease Type, Size, Lease Rate, Floor, Tenant (Account), Commencement Date, Expiration Date, Rent Type, Period Length, Total Rent Calculation | Property; Tenant Account | Lease Period | Verified | [H-close][H-renttable] |
| Lease Period | `LeasePeriod__c` | Custom (child) | Rent table row on Lease | From, To, Duration, Rate, Rent Per Month, Total rent | Lease | — | Verified | [H-rentcfg][H-renttable] |
| Sale | Unknown. `Proposed: TC_Sale__c` (fields `SaleDate__c`, `SalePrice__c` published) | Custom | Sale comp | Sale Date, Listing Price, Sale Price, Buyer(+Contact), Seller(+Contact) | Property | — | Verified | [H-close][H-names] |
| Inquiry | Unknown. `Proposed: TC_Inquiry__c` | Custom | Lead / interest | Type (Lease/Sale), Contact & Company info, Broker Company, Broker Contact, Listing lookup, Price Min/Max, space and property-type requirements, move-in/purchase date | Listing (lookup) | Prospective Listing | Verified | [H-inq-what][H-multilist][H-prosplist] |
| Prospective Listing | Unknown. `Proposed: TC_Prospective_Listing__c` | Junction | Inquiry <-> Listing; shown on Listing as "Prospective Inquiries" | Status (values Unknown), Primary (one), Description (255) | Inquiry, Listing | — | Verified | [H-multilist][RN-127] |
| Preference(s) | Unknown. "Preferences" object; `Proposed: TC_Preference__c` (not yet in our mirror) | Custom | Buyer/tenant search criteria used by automatching; included in Harvest's base xRE duplicate-rule set | Move-in date range, area, rent limits, property type, Sale or Lease, Region, Property lookup (example path Preference -> Property -> Name) | Unknown (Inquiry or Contact Inferred) | — | Verified (object and example criteria) | [AUTO][HV-setup] |
| Deal | Unknown. `Proposed: TC_Deal__c`; field `GrossFeeRatePerUOM__c` published | Custom | Pipeline record | 12 record types; Stage; Deal Sub Type; Property, Space (Availability), Tenant; Client, Client Contact, Client Role, Client Contact Role; Tenant Contact; Owner/Landlord(+Contact); Buyer(+Contact); Lender(+Contact); Deal Source; Primary Connection; Lead Broker Role; Allowances; Gross Deal Value; Gross Fee Method/Percent/Amount; Size; Status (Won/Lost); Actual Close Date; Actual Value; Multiple Properties checkbox; Opened for Editing | Property, Availability, Account | Commission, Deal Period, Prospective Buyer, Offer, Deal Source, Deal Property | Verified | [H-newdeal][H-autopop][H-lite][H-comm][H-psf][H-close][H-multiprop] |
| Deal Period | `DealPeriod__c` | Custom (child) | Rent table row on Deal | as Lease Period | Deal | — | Verified | [H-rentcfg] |
| Commission | Unknown. `Proposed: TC_Commission__c` | Custom (child) | Split line | Record types Inside Broker / Analyst / Co-Broker / Expense; User; Account; Contact; Fee Method; Fee Percent; Fee Percent (House); Description; Direct Expenses; Gross Commission; Net Commission; House; Status | Deal | Commission Privacy | Verified | [H-comm][H-cust-logic][H-privacy] |
| Commission Privacy | Unknown | Custom | Record-level visibility of commission amounts per broker | Unknown | Commission (Inferred) | — | Verified (existence) | [H-privacy] |
| Prospective Buyer | Unknown. `Proposed: TC_Prospective_Buyer__c` | Junction | Seller Rep deal <-> buyer Account/Contact; one Primary | Account (optional), Contact, Primary | Deal | — | Verified | [H-autopop][H-addtodeal][RN-143] |
| Offer | Unknown (feature only). `Proposed: TC_Offer__c` | Custom (Inferred) | Offer tracking on Landlord Rep and Seller Rep deals | Unknown | Deal | — | Verified (feature); object Inferred | [RN-116] |
| Deal Source | Unknown. `Proposed: TC_Deal_Source__c`; field `ascendix__CapitalSource__c` | Custom | Lender interested in a capital markets deal | Capital Source lookup | Deal | Term Sheet | Verified | [H-dealsrc][H-capsrc] |
| Capital Source | Unknown. `Proposed: TC_Capital_Source__c` | Custom | Lender / capital provider master (can be hidden) | Unknown | — | Deal Source | Verified | [H-capsrc] |
| Term Sheet | Unknown. `Proposed: TC_Term_Sheet__c` | Custom | Lender quote | Term Sheet Name, Capital Source, Quote Day, Lender Name | Deal Source | — | Verified | [H-termsheet][RN-139] |
| Deal Property | Unknown (label "Deal properties"). `Proposed: TC_Deal_Property__c` | Junction | Many properties on one capital markets deal | Deal, Property | Deal, Property | — | Verified | [H-multiprop][RN-140] |
| Relationship | Unknown. `Proposed: TC_Relationship__c` | Custom | Links records to internal Users with a Relationship Type | User, admin-added lookups (e.g. Listing), type | any | — | Verified | [H-reltgrid] |
| Ad-Hoc List | Unknown | Custom (Ascendix Search) | Static shareable record lists | Sharing Read/Read-Write | — | — | Verified | [H-adhoc] |
| Searches | Unknown ("Searches" object in App Manager) | Custom (Ascendix Search) | Saved searches; automatch definitions (Ascendix ID, Template field) | Ascendix ID, Template | — | — | Verified | [AUTO] |
| Record Request Set (Harvest) | Unknown | Custom (Harvest package) | One per parsed email; holds draft records pending approval | Draft records; error message | — | — | Verified (name as UI tab) | [HV-convert][HV-limits] |
| Agent objects (Conversational Agent) | `Memory__c` (`Is_Global__c`), `MemorySignal__c`, `AgentSession__c`, `AgentChatMessage__c`, `AgentPlan__c`, `AgentPlanRun__c`, `AgentActionLog__c`, `LLM_Usage_Event__c`; metadata `AgentPrompt__mdt` (`IsActive__c`) | Custom (AI add-on) | Chat sessions, memory, plans, audit log, usage | as named | — | — | Verified | [AIC-install] |
| Config | `AutomationSetting__mdt`; "Object Name Mapping", "Relationship Type", "Stacking Plan" custom metadata; custom setting `BypassValidationRules__c` (`DealPeriodValidation__c`, `LeasePeriodValidation__c`); custom setting "AI Agent Settings" (field Max Create/Update Records) | Config | Toggles and mappings | — | — | — | Verified | [H-rentcfg][H-names][H-reltgrid][H-stackcfg][AIC-install] |
| Standard | Account, Contact, Lead, Task, Event, Note, Campaign, User | Standard | Companies, people, activities, campaigns | Contact: Relationship Type (Partner, Vendor, Client, Prospect), Category/Contact Type (Prospect), Automated Follow-up Tasks checkbox, sequence picklist | — | — | Verified | [H-glossary][H-reltypes][H-prospects][H-followup] |

**Relationships (found).** Property is the hub for Lease, Inquiry, Deal, Availability, Listing, Sale [H-connect]. Availability child of Property [H-glossary]. Deal looks up Property, Space (Availability), Tenant (Account) [H-newdeal]. Commission, Deal Period, Prospective Buyer, Deal Source are Deal children; Lease Period is a Lease child; Term Sheet a Deal Source child; Deal Property junction Deal–Property; Prospective Listing junction Inquiry–Listing [H-comm][H-rentcfg][H-dealsrc][H-termsheet][H-multiprop][H-multilist]. **Lookup vs master-detail is not published for any relationship — Unknown.** Inferred: master-detail for Deal Period, Lease Period, Commission, Term Sheet, Prospective Listing (child rows deleted with parent, rolled into grids).

**Record types (Verified).** Deal: Tenant Representation, Landlord Representation, Seller Representation, Buyer Representation, Listing Pursuit, Capital Markets, Asset Management, Consulting, Financing, Lease Administration, Project Management, Property Management [H-close]. Listing: Lease, Sale, Sale or Lease [H-listmap]. Commission: Inside Broker (default), Analyst, Co-Broker, Expense [H-comm]. Property: Office named (others Unknown) [H-stackcfg].

**Picklists (Verified).** Deal Status: Won, Lost [H-close]. Deal Sub Type (Listing Pursuit): Lease Listing - Exclusive; Lease Listing - Non Exclusive; Sale Listing - Exclusive; Sale Listing - Non-Exclusive; Sale or Lease; Sublease [H-listmap]. Inquiry type: Lease, Sale [H-inq-mgmt]. Client Role defaults: Tenant, Owner/Landlord, Seller [H-autopop]. Gross Fee Method: Percent, Amount, By $ per SF [H-comm]. Total Rent Calculation: Annual Ratio Rent (default), Monthly Rate — taxonomy expanded in 1.39 to "industry standards" [H-renttotal][RN-139]. Contact Relationship Type examples: Partner, Vendor, Client, Prospect [H-reltypes]. Availability Status includes Closed [H-dealavail]. Scorecard summary: Average, Count, Max, Min, Sum [H-scorecard].
**Unknown:** Deal Stage values (exist; stages are customizable, Kanban with stage totals; investment sales pages mention off-market sourcing -> LOI -> due diligence -> close — Verified (search snippet) [S-stages]), Lease Type, Property Class, Rent Type, Inquiry status, Prospective Listing Status, Commission Status, Offer status.

**Roll-ups / formulas / validation (Verified).** Gross Fee Amount = Size × Fee Rate per SF (per-SF method) [H-psf]. Total rent: Annual Ratio Rent = days in period ÷ days in year × monthly rate × 12; Monthly Rate = duration × monthly rent [H-renttotal]. Validation rule `PreventBlankRateAndRentPerMonth`; automation settings `VALDealGrossFeeRatePerUOM`, `VALDealRentTableReview`, `VALLeaseRentTableReview`, `VALDealPeriodRentRequired`, `VALLeasePeriodRentRequired`, `AUTOLeaseRentTableFromDeal` [H-rentcfg][H-psf]. Splits ≤100% (Analyst/Co-Broker/Expense); Inside Broker ≤/=100% and at least one Inside Broker (off by default) [H-split100][H-ibval]. Scorecards: up to 5 roll-up tiles [H-scorecard]. **External IDs: Unknown.**

**ERD edge list**
```
Property -> Availability (lookup?) [Verified rel, type Unknown]
Property -> Listing (lookup) [Verified]
Property -> Lease (lookup) [Verified]
Property -> Sale (lookup) [Verified]
Property -> Deal (lookup) [Verified]
Property -> Inquiry (lookup) [Verified]
Property -> Deal Property (junction) [Verified]
Availability -> Deal (lookup, field "Space") [Verified]
Account -> Deal (lookup: Client, Tenant, Owner/Landlord, Buyer, Lender) [Verified]
Contact -> Deal (lookup: *Contact fields) [Verified]
Account -> Lease (lookup: Tenant) [Verified]
Account/Contact -> Sale (lookup: Buyer, Seller) [Verified]
Listing -> Inquiry (lookup) [Verified]
Inquiry -> Prospective Listing <- Listing (junction) [Verified]
Deal -> Commission (MD inferred) [Verified rel]
User -> Commission (lookup, Inside Broker) [Verified]
Deal -> Deal Period (MD inferred) [Verified rel]
Lease -> Lease Period (MD inferred) [Verified rel]
Deal -> Prospective Buyer (child) [Verified]; Account/Contact -> Prospective Buyer (lookup) [Verified]
Deal -> Offer (child) [Inferred]
Deal -> Deal Source (child) [Verified]; Capital Source -> Deal Source (lookup ascendix__CapitalSource__c) [Verified]
Deal Source -> Term Sheet (child) [Verified]
Deal -> Deal Property (junction) [Verified]
Availability <- automatch -> Preference (search-based, not a relationship) [Verified]
Preference -> Property (lookup) [Verified via example path]
User -> Relationship <- any object (lookup) [Verified]
Inquiry -> (convert) Account, Contact, Deal [Verified, process not relationship]
Deal -> (close) Lease | Sale | Listing [Verified, process]
```

## 5. Technical components

| Area | Verified | Inferred | Unknown |
|---|---|---|---|
| Apex | `ascendix.RestController` (Web-to-Inquiry REST endpoint) [H-web2inq]; `EmailParserHandler` (Harvest email service) [HV-setup]; `AgentMemoryDecayScheduler` (Agent scheduled job) [AIC-install] | Triggers for name formatting, deal-close mapping, rent table generation and commission calcs (behaviour implies Apex) | Trigger/class names for core package |
| LWC / components | "AscendixRE Image Viewer"; "AscendixRE Relationship Grid Universal"; Scorecard Configuration component; Stacking Plan; editable grids; Close Deal dialog; Commission dialog; `agentChat` (Agent) [H-imgviewer][H-reltgrid][H-scorecard][AIC-install] | LWC (Lightning Ready; editable grids) | Bundle API names other than `agentChat` |
| Flows | "Lease expiration" Flow (18/12/6-month tasks) [H-leaseexp]; Autolaunched Flow `Commission_Trigger` (input variable `commission`) [H-cust-logic] | Follow-up sequence and drip tasks are Flow-based | Others |
| Field sets | `CommissionFields_<RecordType>` e.g. `CommissionFields_Inside_Broker`; `Commission_Trigger_Fields` [H-custdialog][H-cust-logic] | — | — |
| Scheduled jobs | `AgentMemoryDecay` (daily 03:00), `AgentPlanScheduler` [AIC-install] | Lease expiration scheduled paths | Core package jobs |
| Approval processes | None documented | — | Unknown |
| Security | Perm sets `AscendixREBroker`, `AscendixREAdmin`, `AscendixRELite`, "AscendixRE Commission Privacy", `Ascendix_Search_User`, "Ascendix Harvest User", "Ascendix Harvest Admin", "AscendixRE AI Chat User", "AscendixRE AI Chat Admin"; profiles "AscendixRE Standard User", "AscendixRE Administrator"; custom permission `ascendix.Commission Privacy Admin`; Deals private by default [H-psf][H-privacy][H-lite][HV-setup][AIC-install][H-glossary] | Commission Privacy implemented via sharing records | OWD for other objects |
| Admin config | Admin Console app; `AutomationSetting__mdt`; Object Name Mapping; Object Field Mapping; Relationship Type; Stacking Plan metadata; `BypassValidationRules__c` [H-rentcfg][H-names][H-listmap] | — | Metadata API names except `AutomationSetting__mdt` |
| Integrations | AscendixRE Connected App with OAuth PKCE + refresh-token rotation (1.41) [RN-141]; Email Service for Harvest; Agentforce provider (default model "Anthropic Sonnet 4.6") [HV-setup]; Google Maps API key/Map ID; Mailchimp [H-map][H-bulk] | Connector is an MCP server using the Connected App (OAuth) | Connector tool names, endpoints |

## 6. Business processes

### 6.1 Inquiry -> Deal -> Lease/Sale -> Commission (core brokerage)
**Start trigger:** a call, email, MarketSpace webform, Web-to-Inquiry form, LoopNet/Crexi notification or Harvest-parsed email expresses interest in space or a listing.

1. **Initiation**
   - Inquiry created manually, by Web-to-Inquiry (guest user -> `ascendix.RestController`), by MarketSpace webform (linked to Listing + Availability), or auto from LoopNet/Crexi (linked to matching Listing/Property; failure notifies user). **Verified** [H-web2inq][S-ms][RN-139]
   - Harvest path: email forwarded -> one Record Request Set with draft Inquiry/Contact/Account etc. -> broker approves. **Verified** [HV-convert]
   - Type set to Lease or Sale. **Verified** [H-inq-mgmt]
2. **Data processing**
   - Preferences captured (price min/max, size, property type, date). **Verified** [H-inq-what]
   - Listing lookup set; Prospective Listings grid holds several Listings, one Primary; changing the Listing field updates the grid. **Verified** [H-multilist][H-prosplist]
   - Duplicate rules (Harvest auto-generates inactive xRE rules for Account, Availability, Contact, Lease, Deal, Inquiry, Listing, Preference, Property, Sales). **Verified** [HV-setup]
   - Record name auto-formatted from Object Name Mapping. **Verified** [H-names]
3. **Business operations**
   - Broker qualifies; Ascendix Search / map / automatch used to find spaces. **Verified** [H-map][AUTO]
   - Tours and follow-ups logged as Tasks/Events (also by Agent voice/text). **Verified** [PR-AI]
4. **Decision / approval**
   - **Convert Inquiry**: creates Account, Contact, Deal; keeps preference data; custom fields not carried; choose listing (Primary default or "--None--"), warning if listing on another active deal; Connections tab shows results. **Verified** [H-multilist][H-inq-what]
   - **Alternate — Disqualify**: disqualify dialog on Active Inquiries. **Verified** [RN-116]. Status values Unknown; Proposed: Active, Converted, Disqualified.
5. **Deal working (Completion of pipeline)**
   - Deal record type picked; Client Role/Client Contact Role and party fields auto-populate (only empty fields; can be disabled). **Verified** [H-autopop]
   - Stage advances on Kanban (values Unknown; stage-based automation e.g. client email at LOI — Verified (search snippet) [S-deal]).
   - Lease terms tab / rent table (Deal Periods) generated, 12-month default periods, review flags non-blocking. **Verified** [H-renttable][RN-143]
   - Seller Rep: Prospective Buyers added (incl. from Search "Add to Deal"); Primary buyer copies to Buyer; Offers tracked on Landlord/Seller Rep. **Verified** [H-addtodeal][RN-116]
   - Gross Deal Value, Gross Fee Method, commissions added (see 6.4).
   - **Close Deal** button: Status Won/Lost, Actual Close Date, Actual Value. Optional validation: ≥1 Inside Broker, Inside Broker % = 100. **Verified** [H-close][H-ibval]
6. **Post-completion**
   - Won Tenant/Landlord Rep -> optional Lease created via Object Field Mapping; `AUTOLeaseRentTableFromDeal` copies Deal Periods to Lease Periods. **Verified** [H-close][H-rentcfg][RN-143]
   - Won Seller/Buyer Rep -> optional Sale. Won Listing Pursuit -> optional Listing (6.2). **Verified** [H-close]
   - Linked Availability set to Closed via mapping. **Verified** [H-dealavail]
   - Lease expiration Flow creates Tasks at 18/12/6 months -> new prospecting (loops back to Initiation). **Verified** [H-leaseexp]
   - **Lost**: Status Lost, no record created. **Verified** [H-close]. Reopen: "Opened for Editing" field exists on Deal [H-lite]; reopen behaviour Unknown.
   - Capital Markets deals set status on Details tab without dialog. **Verified** [H-close]

### 6.2 Listing pursuit -> Listing -> Availability -> Marketing -> Inquiries
**Start trigger:** broker pursues an owner's listing assignment (Listing Pursuit deal) or creates a Listing from a Property.

1. **Initiation** — Listing Pursuit Deal with Deal Sub Type (6 values). **Verified** [H-listmap]
2. **Data processing** — On Won close, mapping creates Listing: record type from Sub Type (Lease/Sale/Sale or Lease), Exclusive and Sublease flags; Name, Property, Region, Market copied. Or Listing created from Property: broker, owner, market, type, description, website auto-filled (create only). **Verified** [H-listmap][H-prepop][RN-143]
3. **Business operations** — Availabilities (vacant suites) created/imported under the Property; images via Image Viewer; stacking plan shows them yellow. Composer flyers/brochures/microsites; MarketSpace publishes CRM property data as a public listing; Ascendix Search mass email (150/send) and Mailchimp. **Verified** [H-availintro][H-imgviewer][S-stack][H-compover][S-ms][H-bulk]
4. **Decision / approval** — Inquiries arrive and link to Listing (Prospective Inquiries related list); automatch on Availability lists matching Preferences. Deal room access gated by NDA acceptance (investment sales). **Verified** [RN-127][AUTO]; NDA **Verified (search snippet)** [S-ms]
5. **Completion** — Landlord Rep / Seller Rep deal created and closed (6.1); Availability -> Closed. **Verified** [H-dealavail]
6. **Post-completion** — "Foot traffic" inquiry reporting and listing activity reports to owner (Composer AI). **Verified** [H-inq-what][PR-AI]
- Listing status values (Active/Expired/Withdrawn): **Unknown**. Alternate: listing pursuit Lost -> no Listing.

### 6.3 Capital markets (debt placement)
**Start trigger:** client needs financing for one or more properties.
1. **Initiation** — Capital Markets Deal (or Financing record type); Multiple Properties checkbox -> Deal Properties tab. **Verified** [H-close][H-multiprop]
2. **Data processing** — Deal Sources added in editable grid on record page "AscendixRE Deal - Capital Markets", each pointing to a Capital Source (lender master). **Verified** [H-dealsrc][H-capsrc]
3. **Business operations** — Lenders quote; Term Sheets recorded on Deal Source (Name, Capital Source, Quote Day, Lender Name). **Verified** [H-termsheet][RN-139]
4. **Decision** — Comparison tab shows all Term Sheets side by side; also visible on client page. **Verified** [H-dealsrc]
5. **Completion** — Status set on Details tab (no dialog); commissions as 6.4. **Verified** [H-close]
6. **Post-completion** — Report on Deal Properties object. **Verified** [H-multiprop]. Loan servicing, maturity tracking: **Unknown** (no Loan object found).
- Deal Source / Term Sheet statuses: **Unknown**. Stage automation and inactivity triggers claimed on mortgage-banking page: **Verified (search snippet)** [S-stages].

### 6.4 Commission calculation and payout
**Start trigger:** Gross Deal Value entered on Deal (lease total rent over term, or sale price). **Verified** [H-comm]
1. **Initiation** — Gross Fee Method: Percent (× Gross Deal Value), Amount, or By $ per SF (Size × `GrossFeeRatePerUOM__c`; Tenant/Landlord Rep only; validation `VALDealGrossFeeRatePerUOM`). **Verified** [H-comm][H-psf][RN-143]
2. **Data processing** — Commission records via dialog or bulk mode (up to 30 of one type): Inside Broker (User, broker %, house %), Analyst/Co-Broker (Account, Contact, Fee Method, %), Expense (Fee Method, %). Custom fields via field sets; `Commission_Trigger` Flow may set defaults. **Verified** [H-comm][H-multicomm][H-cust-logic]
3. **Business operations** — Payout order: Co-Brokers paid first, Expenses second **Verified (search snippet)** [S-commorder]; then net split among Inside Brokers and House — **Inferred** from Inside Broker broker%/house% fields and Gross/Net/House fields.
4. **Decision / validation** — Splits ≤100%; Inside Broker total = 100% and ≥1 Inside Broker (optional) at Close Deal. **Verified** [H-split100][H-ibval]
5. **Completion** — Commission Privacy (one-way toggle): brokers see only their own Gross Commission; admins/privacy-admin see Net and House; reassignment for inactive users. **Verified** [H-privacy]
6. **Post-completion** — Invoices, payments against invoices, payment vouchers, payout reporting, tiered payouts/house plans, mid-year changes — **Verified (search snippet)** marketing only [S-comm][S-commpay]; objects and statuses **Unknown**. Expected payment dates queryable via Connector **Verified (search snippet)** [S-commpay].

### Ordered status lists (key objects)
- **Deal Status:** (open) -> Won | Lost [H-close] — Verified. **Deal Stage:** Unknown values; Proposed (ours): Prospect, Pitch/Proposal, Touring, LOI, Negotiation, Lease/PSA Out, Executed — Inferred (LOI stage named in snippets).
- **Availability Status:** ... -> Closed [H-dealavail] — Verified (others Unknown; Proposed: Available, Pending, Closed, Off Market).
- **Inquiry:** Active -> Converted | Disqualified — Inferred from "Active Inquiries" list and Convert/Disqualify actions [RN-116][H-multilist].
- **Harvest Record Request Set:** pending approval -> approved (or failed with error) — Verified in part [HV-convert][HV-limits]; exact values Unknown.

## 7. Automation table

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Record name formatting | Create/update | Availability, Commission, Deal, Deal Period, Inquiry, Lease, Lease Period, Listing, Market Rent, Sale, Unit, Unit Profile | Build name from Source Attributes + Format | Consistent names | Apex + custom metadata | Verified [H-names] |
| Client field auto-population | Deal create | Deal | Fill Client Role, Tenant/Owner/Buyer from Client or Primary Prospective Buyer | Parties set | Apex | Verified [H-autopop] |
| Rent table generation | Lease-term fields set | Deal, Lease | Create Deal/Lease Periods (12-month default) | Rent schedule | Apex | Verified [H-renttable] |
| Rent table review | Save | Deal Period, Lease Period | Flag gaps/overlaps/blank rent (non-blocking) | Warnings | Apex (setting toggles) | Verified [H-rentcfg][RN-143] |
| Deal close mapping | Close Deal Won | Deal -> Lease/Sale/Listing, Availability | Create target record, copy fields, set Availability Closed | Comps/listing created | Apex + Object Field Mapping metadata | Verified [H-close][H-listmap][H-dealavail] |
| Rent table carry-forward | Deal -> Lease creation | Lease Period | Copy Deal Periods | Lease schedule | Apex (`AUTOLeaseRentTableFromDeal`) | Verified [H-rentcfg] |
| Gross fee calc | Fee fields change | Deal | Compute Gross Fee Amount | Fee | Apex/formula | Verified [H-psf] |
| Commission custom logic | Commission dialog field change | Commission | Run `Commission_Trigger` Flow | Defaults set | Autolaunched Flow | Verified [H-cust-logic] |
| Split validations | Save / Close | Commission, Deal | Block >100% or missing Inside Broker | Clean splits | Apex validation | Verified [H-split100][H-ibval] |
| Commission privacy | Toggle on | Commission | Create privacy records/sharing | Restricted view | Apex + sharing | Verified [H-privacy] |
| Lease expiration reminders | 18/12/6 months before expiration | Lease | Create Task for owner | Prospecting | Flow (scheduled path) | Verified [H-leaseexp] |
| Client follow-up sequence | Checkbox + sequence on Contact | Contact -> Task | Create dated tasks | Drip cadence | Flow | Verified [H-followup] |
| Web-to-Inquiry | Form submit | Inquiry | REST insert as guest | Inquiry | Apex REST | Verified [H-web2inq] |
| LoopNet/Crexi inquiry | Portal notification | Inquiry | Create and link to Listing/Property; notify on failure | Inquiry | Integration/email parsing | Verified [RN-139] |
| Harvest parsing | Email to service address | Record Request Set -> any configured object | LLM parse, ≤25 suggestions, review then approve | Draft records | Apex email service + Agentforce | Verified [HV-setup][HV-limits] |
| Agent memory decay | Daily 03:00 | `Memory__c` | Decay memory | Housekeeping | Scheduled Apex | Verified [AIC-install] |
| Automatching | Open Availability | Preferences | Run saved automatch search | Matching preferences listed | Ascendix Search component | Verified [AUTO] |
| Stage-based emails/tasks | Stage change (e.g. LOI) / inactivity | Deal | Email client / create tasks | Follow-up | Flow | Verified (search snippet) [S-deal][S-stages] |

## 8. UI / UX
- **Apps:** AscendixRE app; Ascendix Lite app (core objects, simplified nav, preconfigured record pages for Deals, Inquiries, Listings, Accounts, Contacts — 1.42); AscendixRE Admin Console; Harvest by Ascendix app (Record Request Sets tab). **Verified** [H-lite][RN-142][HV-convert]
- **Nav tabs:** Home, Chatter, Dashboards, Inquiries, Contacts, Accounts, Deals, Properties, Availabilities, Leases, Sales, Listings, Calendar, Tasks, Notes, Reports. **Verified** [H-glossary]
- **Record pages:** highlights panel, hover quick links, scorecards (≤5), editable grids (bulk edit, sort), Image Viewer, map, stacking plan button, Scan Search Filter, Connections tab on Inquiry, Lease Terms tab on Tenant Rep deal, "AscendixRE Deal - Capital Markets" page with Deal Sources grid and term sheet comparison tab, "Find Preferences" tab on Availability. **Verified** [H-propintro][H-scorecard][H-cm-index][H-dealsrc][AUTO]
- **Views:** Kanban deal pipeline with stage totals and chart colors; map search with shapes, pins, popups. **Verified** [RN-127][H-map]
- **Chat widget:** `agentChat` bottom-right. **Verified** [AIC-start]
- **Portals:** MarketSpace listing portal + NDA deal rooms; Web-to-Inquiry on Experience site. **Verified (search snippet)** [S-ms]; **Verified** [H-web2inq]
- **Mobile:** voice/text Agent "from any device". **Verified** [PR-AI]; Salesforce mobile layouts Unknown.
- **Demo/screenshot URLs (not downloaded):**
  - https://www.youtube.com/watch?v=6fg2v8V4oJA&list=PLWyInfkmAWD8CXrDraWUFYaRN7y7qwkXO — AscendixRE how-to video playlist (user/admin guides).
  - https://i.ytimg.com/vi/Mn4Bo4hsOsE/hqdefault.jpg — thumbnail of the AppExchange "Watch Demo" video (video id Mn4Bo4hsOsE).
  - https://help.ascendix.com/en_US/properties/1160683-ascendixre-stacking-plan-overview — article embedding the stacking plan video.
  - https://help.ascendix.com/en_US/inquiries/inquiry-management-with-ascendixre-crm — inquiry management video.
  - Content not watched; nothing labelled Observed.

## 9. Reporting
- Standard Salesforce reports/dashboards; help articles on creating them. **Verified** [H-dash][H-reporting]
- Scorecards (record-level roll-ups); Lease Comp Report via Composer; foot-traffic inquiry reporting; Deal Properties reporting; closed-deal commissions feeding pipeline reports. **Verified** [H-scorecard][H-leasecomp][H-inq-what][H-multiprop]; commissions **Verified (search snippet)** [S-yt]
- Composer AI documents: BOVs, comp reports, tour books, listing activity reports. **Verified** [PR-AI]
- Prebuilt report/dashboard names: **Unknown**. Inferred KPIs: pipeline by stage/record type, lease expirations by year, commissions by broker, inquiries by listing, availabilities by property.

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Claude / ChatGPT (AscendixRE Connector) | Query and update CRM from AI assistant | Bi-directional | Contacts, deals, listings, leases, commissions | User prompt | OAuth Connected App (PKCE); MCP | Verified; MCP **Verified (search snippet)** | [S-connector][RN-141][S-ai] |
| Agentforce / Einstein | LLM for Harvest and Agent | Outbound | Email text, record drafts | Email / chat | Agentforce provider, no API key | Verified | [HV-setup] |
| Email (Harvest) | Email -> draft records | Inbound | Email body ≤131,072 chars, attachments, ≤25 MB | Forward / rule | Salesforce Email Service + `EmailParserHandler` | Verified | [HV-setup][HV-limits] |
| LoopNet, Crexi | Portal leads -> Inquiry | Inbound | Inquiry + listing link | Portal notification | Unknown (old email-parsing method deprecated) | Verified | [RN-139][H-config-index] |
| MarketSpace | Listing portal, deal rooms | Out (listings) / In (inquiries) | Listings, availabilities, inquiries | Publish / webform | Ascendix product, Salesforce DB or standalone | Verified (search snippet) | [S-ms] |
| Experience site | Web-to-Inquiry | Inbound | Inquiry fields | Form submit | Apex REST `ascendix.RestController` | Verified | [H-web2inq] |
| Google Maps / OpenStreetMap | Map search | Read | Geocodes | Search | API key + Map ID | Verified | [H-map] |
| Mailchimp | Campaigns and stats | Out/In | Contacts, stats | Bulk action | Ascendix Search | Verified | [H-bulk] |
| Composer Online | Document generation | Read | Record data | User | Composer (also Dynamics 365) | Verified | [H-composer] |
| Outlook | Calendar | — | — | — | Not synced | Verified (limitation) | [H-glossary] |

## 11. Limitations & what would be hard to recreate
- Hard: stacking plan renderer (floors from Property, colour by lease expiry, PDF/Excel export); generic Object Field Mapping engine with static/dynamic mappings by record type; Composer template designer and microsite output; MarketSpace portal and NDA deal rooms; Harvest LLM parsing with review queue; MCP Connector; Ascendix Search map with polygon filters and automatching.
- Thin public detail: Deal Stage, Lease Type, Property Class, Inquiry/Listing status values; master-detail vs lookup; Unit/Unit Profile/Market Rent/Offer fields; commission invoices/vouchers/payment objects; report names; Preferences object parent.
- Documented limits: see section 2; Harvest ≤7 objects, ≤100 picklist values sent to AI, 2–3 min processing [HV-limits]; Agent cannot delete, ≤50 search results, ≤2,000-row CSV import [AIC-start].

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| AX | AscendixRE AppExchange listing | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5eloEAB | AppExchange | 2026-11-12 |
| PR-AI | Ascendix brings AI to AscendixRE CRM (press release, 10 Jun 2026) | https://www.einpresswire.com/article/918414512/ascendix-brings-ai-to-ascendixre-crm-with-new-ascendixre-ai-suite | vendor press release | 2026-11-12 |
| S-ai | xRE AI Suite page (snippet; 403) | https://ascendix.com/xre-ai-suite/ | vendor site | 2026-11-12 |
| S-pricing | AscendixRE pricing pages (snippet; 403) | https://ascendix.com/ascendixre-pricing/ | vendor site | 2026-11-12 |
| S-connector | AscendixRE Connector page (snippet; 403) | https://ascendix.com/ascendixre-connector-chatgpt-claude/ | vendor site | 2026-11-12 |
| S-ms | MarketSpace pages/help (snippet; help requires sign-in) | https://ascendix.com/marketspace ; https://help.ascendix.com/marketspace-for-ascendixre-property-listings-portal-deal-rooms | vendor site / help | 2026-11-12 |
| S-stages | Investment sales / landlord rep / mortgage banking pages (snippet) | https://ascendix.com/ascendixre-investment-sales-broker-crm/ ; https://ascendix.com/ascendixre-commercial-mortgage-banking-crm/ | vendor site | 2026-11-12 |
| S-commpay | Yardi CommissionTrac alternatives blog (snippet) | https://ascendix.com/blog/yardi-commissiontrac-commercialedge-commissions-alternatives/ | vendor blog | 2026-11-12 |
| S-commorder | Commissions help section (snippet: co-brokers paid first, expenses second) | https://ascendix.helpjuice.com/en_US/commissions | help (snippet) | 2026-11-12 |
| S-yt | Commission tracking page with video (snippet) | https://ascendix.com/cre-commission-tracking-software-ascendixre/ | vendor site | 2026-11-12 |
| S-persona | Persona bundle pages (snippet) | https://ascendix.com/ascendixre-crm-tenant-representation/ | vendor site | 2026-11-12 |
| S-g2 | G2 AscendixRE reviews (snippet; 403) | https://www.g2.com/products/ascendixre/reviews | review | 2026-11-12 |
| RN-index | What's new in AscendixRE (index) | https://help.ascendix.com/en_US/whats-new-in-ascendixre | release notes | 2026-11-12 |
| RN-143 | What's New in AscendixRE 1.43 | https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-143 | release notes | 2026-11-12 |
| RN-142 | What's new in AscendixRE 1.42 | https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-142 | release notes | 2026-11-12 |
| RN-141 | What's new in AscendixRE 1.41 | https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-140--copy-490 | release notes | 2026-11-12 |
| RN-140 | What's new in AscendixRE 1.40 | https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-140- | release notes | 2026-11-12 |
| RN-139 | What's new in AscendixRE 1.39 | https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-138-copy-319 | release notes | 2026-11-12 |
| HV-setup | Harvest: Setup Guide on Admin Console | https://help.ascendix.com/en_US/harvest-admin-guides/setup-guide-on-admin-console | help | 2026-11-12 |
| HV-convert | Converting emails to records with Harvest | https://help.ascendix.com/en_US/harvest-user-guides/converting-emails-to-records-with-harvest | help | 2026-11-12 |
| HV-objects | Configuring the objects for parsing with Harvest | https://ascendix.helpjuice.com/en_US/harvest-admin-guides/configuring-the-objects-for-parsing-with-harvest-by-ascendix | help | 2026-11-12 |
| HV-limits | Harvest Limitations | https://ascendix.helpjuice.com/en_US/harvest/harvest-limitations | help | 2026-11-12 |
| AIC-install | Ascendix Conversational Agent installation guide | https://ascendix.helpjuice.com/en_US/ascendixai-chat-admin-guide/installation-guide | help | 2026-11-12 |
| AIC-start | Ascendix Conversational Agent getting started | https://ascendix.helpjuice.com/en_US/ascendixai-chat-user-guide/agent-getting-started | help | 2026-11-12 |
| AUTO | How to Configure Automatching | https://ascendix.helpjuice.com/search-admin/how-to-configure-automatching | help | 2026-11-12 |
| H-compfunc | Functionality Description in Composer | https://help.ascendix.com/en_US/functionality-description-in-composer | help | 2026-11-12 |
| H-glossary … RN-127, S-stack, S-comm, S-inq, S-deal | All sources of the prior pass, ids unchanged (≈60 help.ascendix.com articles) | listed in repo file `docs/research/AscendixRE_Public_Research_Notes.md`, section "Sources" | help / AppExchange / snippet | 2026-11-12 |

Key prior-pass ids used above, for convenience: H-glossary https://help.ascendix.com/app-menu-glossary · H-connect https://ascendix.helpjuice.com/en_US/getting-started/how-all-the-data-connects · H-close https://help.ascendix.com/en_US/deal-closing-process · H-autopop https://help.ascendix.com/en_US/deals/-client-field-auto-population · H-newdeal https://help.ascendix.com/en_US/deals/adding-new-deals · H-comm https://help.ascendix.com/en_US/commissions/adding-commissions · H-psf https://help.ascendix.com/en_US/configuration-admin/configuring-the-per-square-foot-gross-fee-method · H-privacy https://help.ascendix.com/en_US/configuration-admin/how-to-enable-commission-privacy- · H-renttable https://help.ascendix.com/en_US/rent-tables-/how-to-use-rent-tables-on-deals-and-leases- · H-rentcfg https://help.ascendix.com/en_US/configuration-admin/configuring-rent-table-inheritance-and-validation-settings · H-listmap https://help.ascendix.com/en_US/object-configurations/configure-object-field-mapping-for-listing-pursuit-deal-record-type- · H-dealavail https://help.ascendix.com/en_US/object-configurations/how-configure-themapping-between-deal-and-availability-deal-close-logic · H-multilist https://help.ascendix.com/en_US/listings/how-to-add-multiple-listings-to-an-inquiry · H-web2inq https://help.ascendix.com/en_US/configuration-admin/1705711-how-to-configure-web-to-inquiry · H-dealsrc https://help.ascendix.com/en_US/capital-markets/capital-market-deal-sources-management- · H-capsrc https://help.ascendix.com/en_US/configuration-admin/removing-capital-source-object-from-ui · H-termsheet https://help.ascendix.com/en_US/configuration-admin/capital-market-term-sheet-object-enablement- · H-multiprop https://help.ascendix.com/en_US/capital-markets/capital-market-how-to-enable-multiple-properties-on-the-deal- · H-stack https://help.ascendix.com/en_US/properties/1160683-ascendixre-stacking-plan-overview · H-stackcfg https://help.ascendix.com/en_US/configuration-admin/stacking-plan-configuration- · H-leaseexp https://help.ascendix.com/en_US/configuration-admin/how-to-enable-lease-expiration-reminders- · H-names https://help.ascendix.com/en_US/configuration-admin/learn-how-to-configure-the-format-of-auto-populated-record-names-in-ascendixre- · H-map https://help.ascendix.com/en_US/search-search/map-search · H-limits https://help.ascendix.com/en_US/ascendixre-limitations · H-lite https://help.ascendix.com/en_US/ascendixre-user-guide/getting-started-with-the-ascendix-lite-app · RN-116 https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-116 · RN-127 https://help.ascendix.com/en_US/whats-new-in-ascendixre/1619416-what-s-new-in-ascendixre-1-27
