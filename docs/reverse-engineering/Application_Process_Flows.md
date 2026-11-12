# Application process flows

Detailed business processes for the eight applications, start to finish. Researched 12 November 2026 from public sources only; no product was installed.

**Labels.** Verified = stated by the vendor. Observed = seen in an official walkthrough. Inferred = reasoned, not confirmed. Unknown = no reliable information. Source ids refer to each product's table in `Research_Sources_and_References.md`.

Each process follows six stages: initiation, data processing, business operations, decision/approval, completion, post-completion, with alternate paths. The matching diagrams are in `Real_Estate_Applications_Reverse_Engineering.pptx`.

## Contents

1. [Propertybase](#1-propertybase)
2. [Apto](#2-apto)
3. [AscendixRE](#3-ascendixre)
4. [REthink CRM](#4-rethink-crm)
5. [Left Main REI](#5-left-main-rei)
6. [improveit 360](#6-improveit-360)
7. [Real Properties](#7-real-properties)
8. [Booker25](#8-booker25)

---

## 1. Propertybase

### Business processes
#### P1. Lead capture → routing → qualification
**Start trigger:** Portal email lead, website visitor registration/saved search, Facebook Lead Ad, webform/REST call, or manual entry.
1. **Initiation**
   - Front Desk receives a portal email at the customer's Front Desk address and parses it (Verified [S25]); or WebToProspect REST is called with `prospect{contact, request, favoriteListings}` (Verified [S13]); or a Boston Logic website login creates a Contact with Lead Source "BostonLogic" (Verified [S32]).
   - `pba__TechnicalSourceSystem__c` / Lead Source set (e.g. "Zillow", "Facebook", "FrontDesk"). Verified [S25].
2. **Data processing**
   - Duplicate check: existing Contact found (Record ID → External ID → Plugin → Email → Phone) → `enrich` fills only null fields; a **new Inquiry is always created** and linked. Verified [S13][S25].
   - Optional Linked Listing created when the message carries a listing reference or `favoriteListings`. Verified [S13][S25].
3. **Business operations (routing)**
   - Process Builder "Lead Routing - Contact"/"Lead Routing - Inquiry" sets Contact Routing Source → Team → Distributor: Click to Claim (email all; first click wins via `pba.ClickToClaim`), Auto-Assign, or Round Robin ("Next Up", "Restart Rotation"). Verified [S23].
   - Alternative add-on: Sales Rotation by `pbasr__Rotation_Name__c`, working days, after-4pm → next day, Listing Owner Priority, FrontDesk Priority; Task "Call Regarding New Enquiry" + email. Verified [S24].
4. **Decision/approval**
   - Returning lead → previous owner (not configurable in Lead Routing; options in Sales Rotation: Assign to Contact Owner / Previous Rotation Member / Reallocate). Verified [S23][S24].
   - No active members → Default Rotation User; failure → admin emails. Verified [S24].
5. **Completion**
   - Agent contacts lead; Contact Stage path moves (e.g. "Contacted Lead" → "Active"; full list Unknown). Verified (values as examples) [S9][S21].
   - "Last Attempted Contact" updated by Process Builder "1.1 Update Contact based off Call Outcomes". Verified [S30].
6. **Post-completion**
   - Contact enrolled in Drip Campaign / Action Plan / recurring email; Marketing Health dashboard tracks coverage. Verified [S30][S35].
   - **Alternate paths:** User Opt-Out/Disabled skips user (Verified [S23]); Click-to-Claim unclaimed timeout/escalation — Unknown [S23].

#### P2. Buyer inquiry → matching → showings → favourites
**Start trigger:** New Inquiry (`pba__Request__c`) from P1 or "New Inquiry" on Contact.
1. **Initiation** — Agent records criteria (property type, beds, baths, budget, custom `_min`/`_max` fields) on the Inquiry. Verified [S12][S15].
2. **Data processing** — "Matching"/"Find Matching Listing" opens the Listing Browser with filters auto-built from same-named fields (Inquiry `X_min__c`/`X_max__c` ↔ Listing `X__c`), honouring `browsers_match_mapping`, `browsers_match_active_field`, blacklist (system fields) and whitelist. Verified [S11][S12].
3. **Business operations** — Agent selects listings and (a) sends them via Quicksend, (b) creates a PDF, (c) creates Linked Listings ("Add to client favorites"). Reverse: Listing "Matching" tab finds Contacts whose Inquiries match. Verified [S14][S22][S44].
4. **Decision/approval** — Client gives feedback/rating on Linked Listing; Showings (Event record type "Showing", rating 1–5, Client Feedback) are mirrored to Favorites by packaged Event trigger via `showingsFavoriteFieldMappings`. Verified [S7][S37].
5. **Completion** — Buyer chooses a listing → P3 (New Offer from Contact or Listing). Verified [S21][S22].
6. **Post-completion** — Inquiry status updated (values Unknown); website favourites/saved searches keep flowing from Boston Logic (Website Listing - Favorite; Inquiry "Is Website Saved Search"). Verified [S32]; Inquiry status values Unknown.
   - **Alternate:** Inquiry reassigned to another Contact → packaged trigger updates its Favorites. Verified [S7]. Contact deleted → abandoned Requests deleted. Verified [S7].

#### P3. Listing intake → publication (seller side)
**Start trigger:** Seller/owner engagement; "New Listing" or Listing Wizard.
1. **Initiation** — New Listing (record type Sale or Rent, fixed). Listing Wizard checks duplicate Properties (`listingNewWizard_duplicateCheckCommand` address/city/name) and links or creates Property. Verified [S10][S11][S22].
2. **Data processing** — Property auto-created; Listing→Property sync of same-name fields (ongoing); Property→Listing once at creation. Media uploaded (Property Media). Verified [S10].
3. **Business operations** — Status typically In Preparation/Off-Market → Active (example validation: requires price, portal fields, ≥1 image). Verified [S9][S34].
4. **Decision/approval** — Publishing controls: lock when "Published" for non-admin profiles (example rule); Auto Publish requires Portal.Auto Publish Listing + Listing.System Allowed for Portals + Allowed for Auto Publish. Verified [S9][S33].
5. **Completion** — Listing exported to portal feeds (Rightmove, Zoopla, Zillow, Idealista…) and to Propertybase Websites (pocket/coming-soon listings via Boston Logic). "Listed on these portals" records created. Verified [S33][S38].
6. **Post-completion** — Listing activity reported (Website Listing views/favorites; marketing reports); unpublish = deactivate in Portal Syndication; published listings cannot be deleted until all portal entries removed. Verified [S22][S29].
   - **Alternate:** Manually unpublished listings are not auto-republished. Verified [S33]. Dotloop: "LOOP IT" creates a loop from Listing. Verified [S34].

#### P4. Offer → counter → acceptance → closing → transaction/commission
**Start trigger:** "New Offer" on Contact or Listing (Offer Creation Wizard: pick or create Listing, then relate Contact). Verified [S19][S21][S22].
1. **Initiation** — `pba__Offer__c` created with offered amount (`pba__OfferedAmount_pb__c`), buyer, target close date, conditions in internal notes. Verified [S16][S18][S20].
2. **Data processing** — Offer history related list records buyer/seller offers and counters. Verified [S18].
3. **Business operations** —
   - "Create Counter Offer": new Offer linked to original; original Status → "Inactive"; listing unchanged. Verified [S18].
   - "Reservation": Offer → "Active (Reservation)"; Listing → "Reserved". Verified [S18].
4. **Decision/approval** —
   - "Accept Offer": Offer → "Accepted"; Listing → "Sold" (vendor default; other versions use "Under Offer"/"Under Contract"/"Pending"). Packaged Offer trigger sets `pba__SystemHasAcceptedOffer__c` / `...ExclusiveOffer__c` on Listing. Verified [S7][S9][S18].
   - "Cancel Offer": Offer → "Cancelled"; Listing → "Available". Verified [S18].
   - No approval process found. Unknown.
5. **Completion** — "New Closing" from Offer copies data (Listing link, CurrencyIsoCode); Closing tracks status, target/actual date, commission overview, desk fee deductions, closing checklist; Closing trigger sets `pba__SystemHasXXX__c` on Offer and `pba__SystemHasClosedClosing__c` on Listing (Inferred from naming + [S7] pattern). Example rule: Closed requires ClosingDate; a second non-cancelled Closing blocked. Verified [S7][S9][S17].
6. **Post-completion** — Transactions synced from Workspace/BackAgent (phases Start → Contract → Showing → Pre-Closing → Post-Closing) with Transaction Members (Side/Role); Financial Add-On Payments/Cash/Receipts (Payment → Paid automatically when fully allocated); Campaign ROI counts accepted/closed offers; dashboards "All Closed Transactions YTD" etc. Verified [S20][S26][S27][S29].
   - **Alternate/cancel:** Closing status "Canceled" (Verified [S9]); Transaction report "All Cancelled Transactions YTD" (Verified [S29]); reopen behaviour Unknown.

#### Status lists (ordered, best evidence)
- **Listing** (typical lifecycle, union of vendor values): In Preparation / Off-Market → Private (optional) → Active / Available / Published → Under Offer / Reserved / Pending / Under Contract → Sold (or Leased mapped to Sold for Dotloop) → Archived. Verified values [S9][S18][S34]; order Inferred.
- **Offer:** (initial Unknown) → Active (Reservation) → Accepted | Cancelled | Inactive (superseded by counter). Verified [S18].
- **Closing:** (open values Unknown) → Closed | Canceled. Verified [S9].
- **Transaction phase:** Start → Contract → Showing → Pre-Closing → Post-Closing. Verified [S27].
- **Contact stage:** includes "Contacted Lead", "Active"; grouped Leads vs Clients. Partial. Verified [S9][S30].
- **Payment:** Planned → Pending → Paid | Cancelled. Verified [S26].

### Automation in these processes
| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Shadow account + individual flag sync | Contact insert/update | Contact/Account | Create/maintain individual account, sync `pba__SystemIsIndividual__c`, record types | 1:1 person accounts without Person Accounts | Apex trigger (packaged) | Verified [S7] |
| Delete abandoned requests | Contact delete | Request | Delete orphan Requests | Clean data | Apex trigger | Verified [S7] |
| Showing ↔ Favorite feedback mirror | Event insert/update | Event, Favorite | Copy mapped fields | Feedback on Linked Listing | Apex trigger + setting | Verified [S7] |
| Request reassign → Favorites | Request contact change | Favorite | Update contact on favourites | Consistency | Apex trigger | Verified [S7] |
| Listing → Property sync | Listing insert/update | Property | Create Property; copy same-name fields | Property history | Apex trigger + settings | Verified [S7][S10] |
| Offer system flags | Offer insert/update | Listing | Set `pba__SystemHasXXX__c` | Listing knows accepted/exclusive offer | Apex trigger | Verified [S7] |
| Closing system flags + copy | Closing insert/update | Offer, Closing | Set flags; copy Listing + CurrencyIsoCode | Consistency | Apex trigger | Verified [S7] |
| Offer buttons | User click | Offer, Listing | Set Offer status & Listing status | Lifecycle | Apex/VF or quick actions (Unknown) | Verified behaviour [S18] |
| Offer Automation / Closing Automation | Offer/Closing change | Listing | Tick listing system checkboxes | Used by validation | Process Builder | Verified (name) [S9] |
| Lead Routing - Contact / - Inquiry | New Contact / Inquiry | Contact | Set Routing Source → distributor assigns owner, notify (email, Chatter, SMS) | Lead ownership | Process Builder + Apex + VF | Verified [S23] |
| Sales Rotation | New enquiry with Rotation Name | Request, Task | Assign member, create Task, email | Rotation | Apex (add-on) | Verified [S24] |
| Front Desk parsing | Inbound email | Contact, Request, Linked Listing, Task | Parse + upsert | Lead in CRM | External service + REST | Verified [S25] |
| WebToProspect | HTTP POST | Contact, Request, Linked Listing | Dedupe + create | Lead in CRM | Apex REST | Verified [S13] |
| Drip campaign | Start Drip Campaign button or Process Builder on Contact | Drip Campaign | Scheduled emails | Nurture | Scheduled Apex / Email Scheduler | Verified [S35] |
| Update Contact based off Call Outcomes | Call logged | Contact | Set Last Attempted Contact | Dashboard | Process Builder "1.1 ..." | Verified [S30] |
| Auto Publish | Listing/Portal criteria true | Portal listing | Publish once (async) | Syndication | Apex async | Verified [S33] |
| Website activity sync | Website event | Website Listing-*, Contact, Request | Create records immediately | Behaviour tracking | External (Boston Logic) → API | Verified [S32] |
| Transaction sync | Save in Workspace/BackAgent | Transaction, Member, Contact | Upsert (one-way into CRM) | Back-office visibility | External integration | Verified [S27][S28] |
| Payment overdue / paid | Due date passed / full allocation | Payment | Set Overdue / Status Paid | AR tracking | Formula / Apex | Verified behaviour [S26]; tech Inferred |
| Campaign ROI copy | CampaignResult update | CampaignResult | Field updates from formulas | Roll-ups | Workflow | Verified [S20] |
| Website user sync | "sync users" button | User → Boston Logic | Push users | Agent pages | External | Verified [S32] |

---

## 2. Apto

### Business processes
#### P1. Prospecting & relationship building (owners and tenants)
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

#### P2. Landlord/seller representation: Pursuit → Listing → Project (Escrow) → Closed Deal
**Start trigger:** Owner pitch / proposal opportunity.
1. **Initiation** — Pursuit record (internal "Proposal") or Deal with Deal Stage = Pursuit; Deal Parties added (Company, Contact, Role). Verified [S6][S7][S12].
2. **Data processing** — On win, Listing (`McLabs2__Listing__c`) for the Property/Space; "Publish a listing to Buildout with a click" copies fields and images; Buildout updated nightly with property, space availability and listing status changes. Verified [S4][S12].
3. **Business operations** — Marketing activity (calls, emails, tours, offers) logged against the Listing; Offers ("Deal Offers") logged as received; "Marketing Activity Report" / "Deals With Activities" shared with the owner client. Verified [S7][S20][S21].
4. **Decision/approval** — Offer accepted → Project (internal "Escrow", "deals in contract" with projected close dates). Verified [S12]. Mechanism of conversion (button/flow/manual) Unknown.
5. **Completion** — Closed Deal booked with commission entries and commission splits (broker/house; Gross Commission − House Fee); Comp created (Sale Comp or Lease Comp). Verified [S10][S12][S18].
6. **Post-completion** — Invoices generated (one-off or Over the Term), payments recorded; comps feed future pricing analysis. Verified [S10][S12].
   - **Alternate paths:** Pursuit lost — status values Unknown; firms that moved from multi-object to single Deal pipeline keep older deals "as history" and some show an open status that should be treated as history. Verified [S12]. Listing withdrawn/expired values Unknown.

#### P3. Tenant representation (Assignment → lease)
**Start trigger:** Tenant client engagement (need date for space).
1. **Initiation** — Assignment (tenant rep) with need date, or Deal with tenant-rep record type at stage Pursuit. Verified (Assignment, need date) [S12][S20].
2. **Data processing** — Search available Spaces (e.g. "Available spaces over 5,000 SF in a named submarket"). Verified (example query) [S12].
3. **Business operations** — Tours/calls logged to the Assignment; offers/proposals tracked. Verified [S20].
4. **Decision/approval** — Lease negotiated; stage moves through Deal Stage values configured per record type. Verified [S9]; names Unknown.
5. **Completion** — Lease Comp + Closed Deal via **Book Lease** (Book Lease Wizard from comp). Verified [S10].
6. **Post-completion** — Commission invoicing (see P4); Location (tenant lease) on Property updated (Inferred).

#### P4. Commission booking & invoicing (Back Office)
**Start trigger:** Deal closes (Closed Deal / Book Lease).
1. **Initiation** — Book Lease Wizard launched from comp; commission structure entered on Closed Deal. Verified [S10].
2. **Data processing** — Invoice section: Invoice Type (e.g. "Over the Term"), Billing Cycle End (day of month or "Last"), Next Invoice Date, Invoice Creation Action, Invoice Notification User. Verified [S10].
3. **Business operations** — Monthly invoice auto-generated on Next Invoice Date; date advances one month; current PDF includes unpaid prior line items; due date computed from payment info (editable). Verified [S10].
4. **Decision/approval** — Single-month adjustment via new commission entry with rate type "Flat Fee" and start/end term; no approval process documented. Verified [S10]; approvals Unknown.
5. **Completion** — Invoice emailed to recipient or user notified; payments recorded against invoices; Buildout advises AI tools must not change invoices, payments or commission bookings. Verified [S10][S12].
6. **Post-completion** — Failure → email to comp owner with reasons; revenue forecasting/reporting (Apto Commissions 2017 launch: "forecast revenue, report on performance and get paid"). Verified [S10]; [S28] snippet.

#### Status / stage lists
- **Deal (single-object) Deal Stage:** Pursuit → (2 unnamed stages) → Closed. Default middle values Unknown; customers customise per record type. Verified [S6][S9].
- **Multi-object pipeline (object = stage):** Pursuit ("Proposal") → Listing → Project ("Escrow") → Closed Deal. Verified [S12].
- **Invoice:** generated → (sent/notified) → paid in full / not paid in full; explicit status values Unknown. Verified (partial) [S10].
- **Listing status:** synced to Buildout ("listing status"); values Unknown. Verified field existence [S4].

### Automation in these processes
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

---

## 3. AscendixRE

### Business processes
#### 6.1 Inquiry -> Deal -> Lease/Sale -> Commission (core brokerage)
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

#### 6.2 Listing pursuit -> Listing -> Availability -> Marketing -> Inquiries
**Start trigger:** broker pursues an owner's listing assignment (Listing Pursuit deal) or creates a Listing from a Property.

1. **Initiation** — Listing Pursuit Deal with Deal Sub Type (6 values). **Verified** [H-listmap]
2. **Data processing** — On Won close, mapping creates Listing: record type from Sub Type (Lease/Sale/Sale or Lease), Exclusive and Sublease flags; Name, Property, Region, Market copied. Or Listing created from Property: broker, owner, market, type, description, website auto-filled (create only). **Verified** [H-listmap][H-prepop][RN-143]
3. **Business operations** — Availabilities (vacant suites) created/imported under the Property; images via Image Viewer; stacking plan shows them yellow. Composer flyers/brochures/microsites; MarketSpace publishes CRM property data as a public listing; Ascendix Search mass email (150/send) and Mailchimp. **Verified** [H-availintro][H-imgviewer][S-stack][H-compover][S-ms][H-bulk]
4. **Decision / approval** — Inquiries arrive and link to Listing (Prospective Inquiries related list); automatch on Availability lists matching Preferences. Deal room access gated by NDA acceptance (investment sales). **Verified** [RN-127][AUTO]; NDA **Verified (search snippet)** [S-ms]
5. **Completion** — Landlord Rep / Seller Rep deal created and closed (6.1); Availability -> Closed. **Verified** [H-dealavail]
6. **Post-completion** — "Foot traffic" inquiry reporting and listing activity reports to owner (Composer AI). **Verified** [H-inq-what][PR-AI]
- Listing status values (Active/Expired/Withdrawn): **Unknown**. Alternate: listing pursuit Lost -> no Listing.

#### 6.3 Capital markets (debt placement)
**Start trigger:** client needs financing for one or more properties.
1. **Initiation** — Capital Markets Deal (or Financing record type); Multiple Properties checkbox -> Deal Properties tab. **Verified** [H-close][H-multiprop]
2. **Data processing** — Deal Sources added in editable grid on record page "AscendixRE Deal - Capital Markets", each pointing to a Capital Source (lender master). **Verified** [H-dealsrc][H-capsrc]
3. **Business operations** — Lenders quote; Term Sheets recorded on Deal Source (Name, Capital Source, Quote Day, Lender Name). **Verified** [H-termsheet][RN-139]
4. **Decision** — Comparison tab shows all Term Sheets side by side; also visible on client page. **Verified** [H-dealsrc]
5. **Completion** — Status set on Details tab (no dialog); commissions as 6.4. **Verified** [H-close]
6. **Post-completion** — Report on Deal Properties object. **Verified** [H-multiprop]. Loan servicing, maturity tracking: **Unknown** (no Loan object found).
- Deal Source / Term Sheet statuses: **Unknown**. Stage automation and inactivity triggers claimed on mortgage-banking page: **Verified (search snippet)** [S-stages].

#### 6.4 Commission calculation and payout
**Start trigger:** Gross Deal Value entered on Deal (lease total rent over term, or sale price). **Verified** [H-comm]
1. **Initiation** — Gross Fee Method: Percent (× Gross Deal Value), Amount, or By $ per SF (Size × `GrossFeeRatePerUOM__c`; Tenant/Landlord Rep only; validation `VALDealGrossFeeRatePerUOM`). **Verified** [H-comm][H-psf][RN-143]
2. **Data processing** — Commission records via dialog or bulk mode (up to 30 of one type): Inside Broker (User, broker %, house %), Analyst/Co-Broker (Account, Contact, Fee Method, %), Expense (Fee Method, %). Custom fields via field sets; `Commission_Trigger` Flow may set defaults. **Verified** [H-comm][H-multicomm][H-cust-logic]
3. **Business operations** — Payout order: Co-Brokers paid first, Expenses second **Verified (search snippet)** [S-commorder]; then net split among Inside Brokers and House — **Inferred** from Inside Broker broker%/house% fields and Gross/Net/House fields.
4. **Decision / validation** — Splits ≤100%; Inside Broker total = 100% and ≥1 Inside Broker (optional) at Close Deal. **Verified** [H-split100][H-ibval]
5. **Completion** — Commission Privacy (one-way toggle): brokers see only their own Gross Commission; admins/privacy-admin see Net and House; reassignment for inactive users. **Verified** [H-privacy]
6. **Post-completion** — Invoices, payments against invoices, payment vouchers, payout reporting, tiered payouts/house plans, mid-year changes — **Verified (search snippet)** marketing only [S-comm][S-commpay]; objects and statuses **Unknown**. Expected payment dates queryable via Connector **Verified (search snippet)** [S-commpay].

#### Ordered status lists (key objects)
- **Deal Status:** (open) -> Won | Lost [H-close] — Verified. **Deal Stage:** Unknown values; Proposed (ours): Prospect, Pitch/Proposal, Touring, LOI, Negotiation, Lease/PSA Out, Executed — Inferred (LOI stage named in snippets).
- **Availability Status:** ... -> Closed [H-dealavail] — Verified (others Unknown; Proposed: Available, Pending, Closed, Off Market).
- **Inquiry:** Active -> Converted | Disqualified — Inferred from "Active Inquiries" list and Convert/Disqualify actions [RN-116][H-multilist].
- **Harvest Record Request Set:** pending approval -> approved (or failed with error) — Verified in part [HV-convert][HV-limits]; exact values Unknown.

### Automation in these processes
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

---

## 4. REthink CRM

### Business processes
#### 6.1 Prospecting → qualified prospect → deal
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

#### 6.2 Seller Rep / Landlord Rep listing deal (listing → close → comp → Showcase)
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

#### 6.3 Tenant Rep / Buyer Rep requirement deal
**Start trigger:** client requirement (tenant needs space / buyer wants acquisition), often from Prospect conversion or Inquiry.
1. **Initiation** — Deal (Tenant Rep or Buyer Rep), Stage Prospect; Client Requirements (Tenant: rent amount, availability date; Buyer: min/max purchase price, property type, class). Verified [S7][S8]
2. **Data processing** — Inquiry/Requirement → "Requirements/Inquiries Match Properties" component scores on-market properties (weights: Max Purchase Price 25%, Min SF 25%, Property Class 5%, Min Cap Rate 5%, Date Space Needed 5%; only "For Sale" or Date Available ≤ today). Verified [S37]
3. **Business operations** — GEOsearch → create Site Selections linked to deal; tour map (Google Maps); scoring and client feedback; Tenant stages Pursuit → Assignment → Survey/Tours → RFP; Buyer stages Identify Acquisition → Underwrite → LOI/Offers. Verified [S7][S8][S32][S34]
4. **Decision/approval** — Offers / RFP responses compared side by side; client selects site. Verified [S34]
5. **Completion** — Lease Execution (tenant) or Escrow/Due Diligence (buyer) → Closed → Lease or Sale Comp auto-created (same required-field rule). Verified [S10]
6. **Post-completion** — Invoice and approval; Associated Party history on property/space; Alerts on lease expiration for renewal pipeline. Verified [S12][S15][S29]

#### 6.4 Commission invoicing and approval
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

### Automation in these processes
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

---

## 5. Left Main REI

### Business processes
#### 6.1 Seller lead intake → qualification → conversion (acquisitions front end)
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

#### 6.2 Acquisition opportunity → appointment → offer → contract (Opportunity pipeline)
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

#### 6.3 Transaction management & disposition (contract → assignment/sale → close)
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

#### 6.4 Cadence lifecycle (cross-object follow-up engine)
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

### Automation in these processes
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

---

## 6. improveit 360

### Business processes
#### P1. Lead-to-appointment (marketing intake and setting)
**Start trigger**: an eLead arrives via the REST/email endpoint (HomeAdvisor/Angi, Zapier, ActiveProspect, Think Unlimited), or a call-center agent uses Quick Lead [S35][S28][S5].
1. **Initiation**
   - eLead record created; eLeadTrigger records text opt-out and optionally verifies/geocodes the address. Verified [S13].
   - Or Quick Lead creates Account + Contact + Address + Sales Opportunity (Lead Source, Interested In, Taken On required). Verified [S14][S28].
2. **Data processing**
   - eLead JSON Mapping resolves provider keys; Source Name comes from a header/property or `i360core__Source__c`. Verified [S35].
   - Auto-conversion (optional) creates Account, Contact, Sales Opportunity (one per interest) and Sales Appointment; failures are written to "eLead Conversion Issue". Verified [S13][S14].
   - Duplicate lead prevention is a listed feature; mechanism Unknown [S4].
   - Inquiry created if "Create Inquiry Records for Quick Leads/eLeads" is enabled. Verified [S28].
3. **Business operations**
   - Marketing Status set to **New eLead** or **New Leads** on the Account. Verified [S17].
   - SalesOpportunityTrigger/InquiryTrigger create "set appointment" Tasks for setters when enabled. Verified [S13][S29].
   - Setter books a Sales Appointment from the Opportunity or Inquiry (quick action) on the Staff Calendar, or into a Time Block. Set By/Set On are stamped. Verified [S13][S30][S25].
4. **Decision / approval**
   - Not qualified → Account "Not Qualified Reasons" set; AccountTrigger closes the related opportunity and inquiry tasks. Marketing Status can become **Dead**. Verified [S13][S17].
   - Time Block at capacity → red (blocked), or orange if "Allow Overcapacity Scheduling". Verified [S25].
5. **Completion**
   - Sales Appointment saved; Event created and synced (EventTrigger keeps times aligned); Marketing Status → **Pending Confirmation**. Verified [S13][S17].
   - Dispatcher assigns Sales Rep 1/2 to unassigned Time Block appointments (Assigned By/On stamped). Verified [S25][S13].
6. **Post-completion**
   - Confirmation call → Confirmed On populated ("Confirmed" count field). Verified [S19].
   - Reminders by text/email; ICS invite via "Send Templated Email with Attached Calendar Invite". Verified [S4][S31].
   - Lead Source Cost vs sales gives closed-loop ROI. Verified [S14][S40].
- **Alternate paths**: an existing customer gets a new Sales Opportunity without an Inquiry [S28]. A lead score goes out to Think Unlimited [S13]. Call-center integrations (Five9, RingCentral, Regal) [S5][S28].

#### P2. In-home sale and appointment resulting
**Start trigger**: the Sales Appointment date arrives and the rep runs the appointment (in i360 mobile, or in Vendo/OneClick/SalesPro) [S18][S21].
1. **Initiation**
   - Rep opens the Sales Appointment (Account, Address and Type required); appointment details appear on the calendar tile/hover field sets. Verified [S14][S31].
2. **Data processing**
   - Quote built with "Create Quote" quick action, Quote Items, or a Quote Template; QuoteItemTrigger creates Job Materials when materials are enabled. Verified [S30][S13].
   - Optional financing: create Loan from Loan Options. Verified [S14][S31].
3. **Business operations**
   - **Result** button: choose Status (e.g. **Ran**) → Status Detail (Sold / Demoed, Not Sold / Follow-up / No Show / Not Demoed / One Leg / Canceled) → per-Opportunity Result (**Sold / Not Sold**) → Result Detail (Demoed and Quoted / Rehash / Follow-up). Dependent picklists. Verified [S18][S19].
   - Flows "Sales Appointment Issued" / "Sales Appointment Demoed" set the count checkboxes. Verified [S19].
   - Marketing Status Rules update Account status (Confirmed, Rehash, Reset...). Verified [S17].
4. **Decision / approval** (Save & Next actions) [S18]
   - **Sold** → "Create Sale": select Opportunities and the accepted Quote → Sale + Sale Items created; Quote, Quote Items and Loan associated. Verified [S18][S20].
   - **Not Sold / Rehash** → create Task Type "Sales Opportunity Rehash". Verified [S18].
   - **Follow-up** → schedule a new Sales Appointment Type "Follow-up" linked by Previous Appointment. Verified [S18].
   - **Reschedule to another date** → result original as Canceled, new appointment Type "Reset". Verified [S18].
   - **Take no action** → end. Verified [S18].
5. **Completion**
   - SaleTrigger stamps Sold On, Status defaults **In Review**, updates appointment Sale Total and Sold. Verified [S13][S16].
   - With Vendo, results post back to the Apex REST endpoint (VendoResultApi), and "Vendo Sale Creation" creates the Sale for Sold opportunities. Verified [S30][S21].
6. **Post-completion**
   - GuildQuality survey sent (optional). Verified [S32].
   - Second sale on an already resulted appointment is supported (Classic article). Verified [S41].
   - **Un-result**: removing a result deletes the related Sale, Sale Items, Receipts/Adjustments and Projects (Classic). The documented practice is to set Sale Status to Canceled instead. Verified [S41]. Lightning advises against re-resulting Sold appointments [S19].

#### P3. Sale approval to production (project management)
**Start trigger**: a Sale is created (status In Review) [S16].
1. **Initiation**
   - Sale (Status **In Review**, In Review On stamped). Verified [S13][S16].
2. **Data processing**
   - Office reviews contract, deposit and financing; Loan details are copied from the Loan Option by trigger. Verified [S13].
   - Deposit taken as Payment or Payment Link (hosted, PaySimple; credit/ACH). Verified [S13][S32][S1].
3. **Decision / approval**
   - Status → **Approved** (Approved On) or **Not Approved** (Not Approved On). Verified [S16].
   - After the right-of-rescission period → **Net** (Net On; "ready for production"). Status Detail e.g. "Approved for Production". Verified [S16].
   - **Cancellation**: Sale Canceled (Canceled record type / Canceled On), Project formula status → **Canceled**; the vendor suggests auto-cancelling Project Activities. Verified [S16][S23][S14].
4. **Business operations**
   - SaleTrigger "can create a project" (Project MD to Sale); project name "Contact Full Name : Product Category". Verified [S13][S24].
   - Project Template applied (UI or invocable from Flow) → Project Activities (steps such as Approve Contract, Re-Measure, Order Roofing Materials, Installation). Verified [S30][S23].
   - Activities scheduled to Staff/crews on Scheduling Calendar, Time Blocks or the Gantt (productionGantt). Events and Tasks are kept in sync by ProjectActivityTrigger/TaskTrigger. Verified [S13][S31].
   - Permits (Prepared → Applied → Received, or Canceled), Job Materials (inventory decremented) and Project Costs. Verified [S30][S13].
5. **Completion**
   - Activity Completed checkbox/date; Project Status formula → **Completed** when all activities are done; Sale Status → **Complete** (Complete On). Verified [S23][S16].
   - Final balance collected via Payment / Payment Link; Total Payments Received rolls up by trigger. Verified [S13].
6. **Post-completion**
   - Marketing Status → **Past Customers**. Verified [S17].
   - Commissions entered and paid through Commission Adjustments (manual by default). Verified [S36][S37].
   - Reverting a Completed project is blocked by Flow (except the Production Manager Profile). Verified [S22].
   - Customer survey (GuildQuality), QuickBooks sync via DBSync. Verified [S32][S5].

#### P4. Closed-loop marketing status (cross-cutting)
**Start trigger**: a change to Opportunity Result/Detail, Appointment Status/Detail, or Sale Status/Detail [S17].
- Initiation: "Use Marketing Status Automation" must be on (Marketing Settings hierarchy setting). Verified [S17].
- Data processing: rules in the active section (Sales Opportunity or Sales Appointment; Sale rules always run) are matched on primary + detail value. Verified [S17].
- Business operations: Account Marketing Status and Marketing Status Date are updated; the optional Inquiry Status is updated. Verified [S17].
- Decision: no update if the value is unchanged; duplicate rules are blocked. Verified [S17].
- Completion: Field history is tracked. Verified [S17].
- Post-completion: lists by Marketing Status (Rehash, Reset) feed re-marketing campaigns (EverConnect, Hatch). Inferred from status semantics plus [S5][S45].

**Ordered status lists**
- Sale: In Review → Approved | Not Approved → Net → Complete (Canceled via record type/date) [S16].
- Sales Appointment (lifecycle, Inferred order from count fields [S19]): Set → Confirmed (Confirmed On) → Assigned/Dispatched (Assigned On) → Resulted (Status Ran + Detail) or Canceled.
- Project (Production 2.0): Not Started → In Progress → Completed | Canceled [S23].
- Project Activity: Not Started → (Not Started - Late) → In Progress → (In Progress - Late) → Completed | On Hold | Canceled [S23].
- Marketing Status (typical journey, vendor default order): New eLead / New Leads → Pending Confirmation → Confirmed → Rehash | Reset → Past Customers | Dead [S17].
- Permit: Prepared → Applied → Received | Canceled [S30].

### Automation in these processes
| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| eLead conversion | eLead insert (setting on) | eLead | Create Account/Contact/Opportunity/Appointment, Inquiry | Lead in pipeline | Apex trigger (eLeadTrigger) | Verified [S13] |
| Address territory + geocode | Address insert/update | Address | Assign Territory, verify, time zone | Routing to Time Blocks | Apex (AddressTrigger) + callout | Verified [S13] |
| Set-appointment tasks | New Opportunity/Inquiry | Sales Opportunity, Inquiry | Create Task | Setter work queue | Apex | Verified [S13] |
| Appointment ↔ Event sync | Appointment/Activity/Event change | Sales Appointment, Project Activity, Event | Create/update Event | Calendar consistency | Apex | Verified [S13] |
| Issued/Demoed counts | Appointment resulted | Sales Appointment | Set checkboxes | Reporting | Flow ("Sales Appointment Issued"/"Demoed") | Verified [S19] |
| Marketing Status rules | Result/Status change | Opp, Appointment, Sale → Account | Update Marketing Status/Date | Closed-loop marketing | Apex + config object | Verified [S17] |
| Sale status date stamps | Sale Status change | Sale | Stamp Approved/Net/Not Approved/Complete/Canceled On | Audit, reports | Apex (SaleTrigger) | Verified [S16][S13] |
| Create Project from Sale | Sale (config) | Sale → Project | Insert Project | Production starts | Apex (SaleTrigger) | Verified [S13] |
| Apply Project Template | UI or Flow | Project | Create Project Activities | Production plan | Invocable Apex | Verified [S30] |
| Project/Activity status | Field changes | Project, Project Activity | Formula status, completion % | Gantt/list views | Formula | Verified [S23][S24] |
| Block status revert | Project Status change | Project | Error | Data integrity | Flow | Verified [S22] |
| Payment rollup | Payment change | Payment → Project | Total Payments Received | Balance due | Apex | Verified [S13] |
| Payment link delivery | Payment Link insert | Payment Link | Send email/text | Customer pays online | Apex + PaySimple/Twilio | Verified [S13][S32] |
| Inbound SMS processing | Webhook | Webhook Event → Inbound Text | Create text, publish event | Two-way texting | Apex REST + platform event | Verified [S13] |
| Material costing | Job Material change | Job Material, Material, Project Cost | Costs, inventory | Job costing | Apex | Verified [S13] |
| Vendo / OneClick result post-back | External POST | Sales Appointment, Opportunity, Sale | Update results, create Sale | Estimator integration | Apex REST (VendoResultApi, i360core.OneClickResultApi) | Verified [S30][S33] |
| GuildQuality / marketing updates | Opp/Appt/Sale/Project changes | various | Callout | Surveys, marketing sync | Apex (async, Inferred) | Verified [S13][S32] |
| Staff → User creation | Staff "Create User" | Staff | Create User | Login provisioning | Apex | Verified [S13] |
| Commission calc | — | Commission | None out of the box | Manual entry | Custom Flow (per client) | Verified [S36][S37] |

---

## 7. Real Properties

### Business processes
The vendor documents no process steps. The processes below are what the advertised features imply. Every bullet is **Inferred** unless tagged otherwise.

#### 6.1 Property and unit inventory set-up
**Start trigger:** a new property, building or venue is taken on for management or sale.
1. **Initiation** — Property record created (owner Account linked); Buildings added. Basis: "Properties, Buildings and Units" [RI-pricing] (Verified concept).
2. **Data processing** — Units/spaces created per floor; CAD floor plan imported and each drawn space mapped to a Unit (Real Floorplans add-on) [RI-floor] (Verified concept); address geocoded (paid geocoding) [RI-pricing].
3. **Business operations** — Unit status maintained (Available / Occupied / Reserved / Sold — Proposed values).
4. **Decision/approval** — None documented.
5. **Completion** — Floor plan published read-only or editable to permitted users (pattern Verified for Real Facilities [RI-fac], assumed here).
6. **Post-completion** — Occupancy dashboards; website integration shows availability publicly [RI-pricing] (Verified feature).

#### 6.2 Lead -> sale or lease of a unit (residential/condo/commercial)
**Start trigger:** prospect enquiry (website integration, email marketing, AdWords in sibling product).
1. **Initiation** — Lead created ("Generate more leads") [RI-products] (Verified claim).
2. **Data processing** — Lead qualified; unit(s) of interest linked; interactive floor plan used to show availability [RI-floor].
3. **Business operations** — Action plan tasks and calendar events (tours) [RI-pricing] (Verified feature).
4. **Decision/approval** — Lead converted to Account/Contact/Opportunity (standard Salesforce); Opportunity stages (Proposed: Prospecting, Tour, Application/Offer, Negotiation, Closed Won/Lost).
5. **Completion** — Won: Lease record created (rental) or unit marked Sold (sale); unit status updated so floor plan recolours in real time [AX-RP] (real-time status Verified).
6. **Post-completion** — Tenant/resident record maintained; email marketing; reporting.
- **Alternate paths:** Lost -> unit stays Available; lease application rejected -> Opportunity Closed Lost; reservation instead of lease for short stays/events.

#### 6.3 Tenancy / lease administration
**Start trigger:** lease signed.
1. **Initiation** — Lease linked to tenant and unit ("tracks building, tenant, and lease details") [AX-RP] (Verified concept).
2. **Data processing** — Dates, rent, terms recorded (fields Unknown).
3. **Business operations** — Tasks for renewals and move-ins via action plans.
4. **Decision/approval** — Renewal or termination decision (Proposed).
5. **Completion** — Lease status Active -> Expired/Terminated (Proposed); unit back to Available.
6. **Post-completion** — Occupancy and lease reporting [RI-pricing] (analytics Verified).
- Accounting/billing: "Billing & Invoicing" and "Accounting Integration" appear only on a third-party directory feature checklist [SR] — **Unknown** whether implemented.

#### 6.4 Space reservation / event floor management
**Start trigger:** event or booking request (trade show booth, conference room, rental).
1. **Initiation** — Reservation against a space (paid "Reservations" feature) [RI-pricing].
2. **Data processing** — Booth sponsorship level and rental rate shown on the floor plan (Dreamforce 2012 example) [RI-floor] (Verified example).
3. **Business operations** — Exhibitor/attendee CRM records; QR codes per record [RI-home] (Verified example).
4. **Decision** — Booking confirmed or released (Proposed statuses: Requested, Confirmed, Cancelled).
5. **Completion** — Floor plan shows booked spaces in real time.
6. **Post-completion** — Reports on occupancy/revenue.

**Status lists (all Proposed / Inferred):**
- Unit: Available -> Reserved -> Occupied | Sold -> Available (on move-out)
- Lease: Draft -> Active -> Renewed | Expired | Terminated
- Opportunity (standard): Prospecting -> Tour -> Application/Offer -> Negotiation -> Closed Won | Closed Lost
- Reservation: Requested -> Confirmed -> Completed | Cancelled

### Automation in these processes
| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Action plans | Record created / stage change | Lead, Opportunity, Lease | Create task sequences | Follow-up | Workflow rules / Flow | Verified (feature) [RI-pricing]; mechanics Inferred |
| Floor-plan status refresh | Unit status change | Unit | Recolour plan | Real-time view | Visualforce/JS reading records | Verified (outcome) [AX-RP]; tech Inferred |
| Geocoding | Address saved | Property | Set lat/long | Map | Integration (paid) | Verified (feature) [RI-pricing] |
| QR code generation | Record created | Any | Generate QR code | Tracking | Formula/image or Apex | Verified (example) [RI-home] |
| Unit status on lease/sale | Lease Active / Opp Won | Unit | Set Occupied/Sold | Inventory accurate | Workflow/Flow | Inferred |
| Lease renewal reminder | N days before end | Lease | Task | Renewal | Scheduled Flow | Inferred |

---

## 8. Booker25

### Business processes
#### P1. Internal booking (planner books a room/resource/staff)
**Start trigger**: a user drags across a time range on a Lightning calendar, or opens the Standalone Reservation Form or a time-slot-picker flow [B19][B20][snippet "Basic calendar use"].
1. **Initiation**
   - The calendar opens the Reservation form; the user picks a Reservation Type, which sets the field set, record type and optional fixed duration. Verified [B12].
   - The status picklist defaults to the status flagged **Default** and shows only active statuses linked to the type. Verified [B12][B13].
2. **Data processing**
   - Local start/end (`B25__StartLocal__c`/`B25__EndLocal__c`) are converted using the resource timezone; read-only date/time fields are derived. Verified [B41].
   - Optional services, attendees (Reservation Contacts) and quantity are added. Verified [B42][B43].
   - Price is calculated from the Resource/Type price method and pricing unit, or by a custom calculator. "Disable Subtotal Input" stops manual overrides. Verified [B27][B28].
3. **Business operations (conflict check)**
   - Engine checks Double Booking, Capacity (Reservation quantity field vs dimension capacity field, e.g. `B25__Quantity__c` vs `B25__Capacity__c`) and Availability against `B25__Availability__c` per dimension. Verified [B14].
   - Exceptions: status flags **Allow Double Bookings** (also skips capacity) and **Allow Unavailable Bookings**; custom checkbox exception fields; Resource Type "Allow Double Bookings". Verified [B14][B16].
4. **Decision / approval**
   - **Hard** conflict blocks the save with an error. **Soft** conflict warns, allows the save and creates `B25__Conflict__c` for later resolution. **None** ignores it. Verified [B14].
   - In the rule-based model, formula conditions decide (e.g. block overlap unless the user has an override permission). Verified [B15] (snippet).
   - Approval: no built-in approval process documented. Status values such as **Optional → Definite** act as a soft approval stage (Inferred from [B44]). Standard Salesforce Approval Processes on `B25__Reservation__c` are possible but not documented (Unknown).
5. **Completion**
   - Reservation saved and shown on the calendar with the colour for its Status × Type. Verified [B13].
   - Flow "Send New or Updated Reservation Confirmation" (once activated) emails `B25__Contact__c` with template "Reservation Details" plus an ICS attachment. Verified [B24].
   - Outlook/Google Sync Connection pushes the event to the resource/staff calendar. Verified [B31].
6. **Post-completion**
   - **Update**: changes to start/end/resource send "Reservation Updated". Verified [B24].
   - **Reschedule**: "GoMeddo - Reschedule Reservation" flow template. Verified [B22].
   - **Cancel**: set a cancellation status (e.g. "Cancelled" with Allow Unavailable/Double Bookings so it no longer blocks) (Verified example [B14]). Deleting a reservation fires "Send Cancel Email" with template "Reservation Canceled" [B23]. Real-estate page: a cancelled space is released for other customers [B3].
   - **Check-in/out** for attendees via QR on the Salesforce mobile app or the API. Verified [B26].
   - Reporting: occupancy, popular times. Verified [B3][B20].

#### P2. Self-service web booking (widget / Experience Cloud / API)
**Start trigger**: a visitor opens the GoMeddo widget (script button or iframe), a custom front end using the JS SDK, or an Experience Cloud page [B34][B35].
1. **Initiation**: the widget lists API-Visible, active Resources; the visitor picks a resource/service or blueprint. Verified [B34][B33].
2. **Data processing**: available time slots are computed (TimeSlotFinder / TimeSlotGenerator / "availability-based" model, widget only) from Availability and existing reservations. Verified [B9][B34] (snippet).
3. **Business operations**: the visitor enters contact details and custom fields (stored on Reservation Contact); vouchers and price are calculated. Verified [B43][B28].
4. **Decision**: conflict checking runs as in P1. Widget settings choose the default status and reservation type, so an "Optional/requested" status can be used for staff review (Inferred from [B34] default-status setting). Guest access needs Guest User sharing; Community Plus licences are recommended. Verified [B35].
5. **Completion**: Reservation and Reservation Contact are created (Contact or Lead matched or created); confirmation email with ICS and optional QR email. Verified [B24][B22][B43].
6. **Post-completion**: "GoMeddo - Register to Reservation" for joining group sessions; bookings can become leads for marketing follow-up; payments via partners (e.g. Asperato). Verified [B22][B3][B2].

#### P3. Recurring / scheduled programmes (courses, classes, standing meetings)
**Start trigger**: a planner uses the Recurring Reservation component or builds a Schedule of Reservation Templates [B20][B30].
1. **Initiation**: create `B25__Recurring_Reservation__c` (recurrence type, interval, end condition) or `B25__Schedule__c` with templates; the onCreate hook can pre-fill templates. Verified [B11][B29].
2. **Data processing**: `B25.RecurringReservations.generateRecurringReservationSeries` clones the prototype per occurrence, optionally skipping unavailable dimensions. Verified [B11].
3. **Business operations**: the series is validated with `B25.BulkReservationValidator.validate`, which returns soft/hard conflicts per occurrence. Verified [B10][B11].
4. **Decision**: occurrences with hard conflicts must be resolved (move/skip); soft conflicts are kept as Conflict records. Verified [B10][B14].
5. **Completion**: "Publish Related Templates" generates actual Reservations from templates; a publish class is customisable ("Customize the Published Reservations"). Verified [B20][B30].
6. **Post-completion**: attendees register; check-in tracking; occupancy reporting. Verified [B22][B26].

#### P4. Calendar synchronisation (Outlook / Google)
**Start trigger**: an admin creates a Sync Connection for a Resource or Staff record [B31].
1. Initiation: Office 365 authentication set up through Azure AD and the Outlook Settings tab; Google sync licences are requested from support. Verified [B31][B32] (snippet).
2. Data processing: `B25__User_Id__c` (Outlook mailbox), optional calendar name (defaults to primary), "Activate After Validation". Verified [B31].
3. Business operations: GoMeddo keeps delta tokens and subscription ids to sync changes; only events organised by the synced calendar are synced. Verified [B31][B32].
4. Decision: validation failures go to child Outlook Sync Error records; `B25__Valid__c` is maintained by GoMeddo. Verified [B31].
5. Completion: reservations appear in Outlook/Google calendars. Verified [B4] ("two-way Office 365 and Google calendar sync").
6. Post-completion: licensing gives 10 Sync Connections per GoMeddo licence. Verified [B32].

**Reservation status list (ordered, as far as documented)**: statuses are admin-defined records. Documented examples, in typical order: **Optional** (tentative; often flagged Allow Double Bookings) → **Definite** (confirmed) → **Cancelled** (flagged Allow Unavailable Bookings). Verified examples [B44][B14]. Additional states such as checked-in/checked-out are attendee-level datetimes, not statuses [B26]. Any other default status names are Unknown.

### Automation in these processes
| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Conflict checking | Reservation insert/update | Reservation (+ junction children) | Evaluate double booking/capacity/availability; block or create Conflict | Prevents double booking | Apex (managed trigger/engine) | Verified [B14][B10] |
| Rule-based conflicts | Reservation save | Reservation | Formula rules | Hard/soft conflict | Apex + config | Verified [B15] |
| Time-zone derivation | Reservation save | Reservation | Fill Start/End and date/time fields | Correct local times | Apex | Verified [B41] |
| Fixed duration | Type selected | Reservation | End = Start + Duration | Consistent slots | Apex/UI | Verified [B12] |
| Price calculation | Start/End/Base Price/Method/Quantity change | Reservation | Compute subtotal | Pricing | Apex (+ plugin interface) | Verified [B27][B28] |
| Auto-link types/statuses/calendars | New Type/Status/Calendar | Reservation Type, Status, Calendar | Create link records | Config completeness | Apex triggers | Verified [B12][B13] |
| Confirmation email + ICS | Reservation create/update | Reservation | Email "Reservation Details"/"Reservation Updated" | Customer informed | Record-triggered Flow template | Verified [B24] |
| Cancel email | Reservation delete | Reservation | Email "Reservation Canceled" via Email Alert | Customer informed | Flow template | Verified [B23] |
| QR code + QR email | Reservation Contact added | Reservation Contact | Generate QR; send | Check-in enabled | Apex + Flow template | Verified [B26][B22] |
| Recurring series | User action | Recurring Reservation | Generate + validate series | Many reservations | Apex API | Verified [B11] |
| Publish templates | Button | Schedule/Reservation Template | Create reservations | Programme calendar | Apex (customisable publish class) | Verified [B20][B30] |
| Calendar sync | Reservation change / Outlook webhook (Inferred) | Sync Connection | Push/pull events | Calendars aligned | External callouts + subscriptions | Verified (function) [B31] |
| Occupancy | On demand | Resource | Compute occupancy % | Dashboards, AI tool | Invocable/Flow | Verified [B21][B37] |
| Agentforce/MCP tools | AI request | Reservation, Resource | Get occupancy, timeslots, create reservation | AI booking | Flows `GMCopilot__Get_Occupancy_For_Agentforce`, `GMCopilot__Generate_Possible_Timeslots_From_Agentforce`; Apex `GMCopilot__AgentforceReservationCreator` | Verified [B37] |
