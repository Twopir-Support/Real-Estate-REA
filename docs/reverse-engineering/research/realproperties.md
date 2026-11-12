# Real Properties (Real Intelligence, Inc.) — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Verified (search snippet)** — taken from a search-engine snippet, page not opened in full.
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.

Never invent API names. **No object, field, class, Flow or component API name for Real Properties is published anywhere we could find.** Every API name in this file is a `Proposed:` name of ours.

> **Read this first.** Public material on Real Properties is very thin: a 2008 AppExchange listing (last updated 2022), a few short vendor web pages (some dated 2011–2019), and directory profiles. There is no help center, no field list, no release notes and no demo we could open. **Sections 4, 6 and 7 are therefore an "Inferred reference architecture"**: a plausible design for what the vendor describes (properties, buildings, units, tenants/residents, leases, floor plans, leads), built from standard Salesforce patterns. It must not be presented as the product's actual schema.

## 0. Identity and status

### 0.1 Candidates considered

| # | Candidate | Publisher | URL | Name match | Fits "Salesforce app"? | Decision |
|---|---|---|---|---|---|---|
| 1 | **Real Properties** | Real Intelligence, Inc. (Los Gatos, CA) | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016cgZEAQ | Exact | Yes — AppExchange "Salesforce App", native, unmanaged package | **Chosen** |
| 2 | Realty Pro | Unknown publisher (user guide on Notion) | https://tide-gold-7de.notion.site/ebd/21e8f18e64fd80d7ab7ecd340ed9ea95 | No | Yes (install via AppExchange search "Realty Pro") | Rejected — different name |
| 3 | Propertybase (Salesforce Edition) | Lone Wolf / Propertybase | https://www.propertybase.com/real-estate-crm/salesforce-edition | No | Yes | Rejected — different name |
| 4 | Real Estate Management | Techila Global Services | https://techilaservices.com/product/real-estate-management | No | Yes (Salesforce partner product) | Rejected — generic name |
| 5 | Booking Ninjas property management | Booking Ninjas | https://www.bookingninjas.com/solutions/residential/multifamily-property | No | Yes | Rejected — different name |
| 6 | Real Facilities / Real Floorplans / Real Offices | Real Intelligence, Inc. | https://realintelligence.com/products/ | Sibling products | Yes | **Not merged.** Real Floorplans is documented as an add-on *to* Real Properties, so its integration claims are kept; Real Facilities (move management) facts are kept separate |

No AppExchange listing named "Real Property Management", "RealProperties" or "Real Estate Properties" was found (search, 2026-11-12). **Verified (search)** [WS]

**Why candidate 1:** it is the only exact-name match; its AppExchange listing is titled "Real Properties – Real Intelligence, Inc."; the vendor's own pages call it "Real Properties" and say it is built on Salesforce.com. **Confidence: high that this is the product named "Real Properties"; low on any functional detail.**

**Caution:** the SourceForge profile titled "Real Properties" actually describes the sibling **Real Facilities** application (move requests, AutoCAD floor plans) [SF]. Those facts are listed separately in section 3 and not attributed to Real Properties.

### 0.2 Identity

| Item | Value | Label | Source |
|---|---|---|---|
| Product | Real Properties | Verified | [AX-RP] |
| Publisher | Real Intelligence, Inc. — "based in the heart of Silicon Valley", privately funded, Salesforce ISV and OEM partner | Verified | [AX-RP][RI-partners] |
| HQ | Los Gatos, CA (West Main Street) | Verified (search snippet, LinkedIn) | [LI] |
| Founded | 2003 per LinkedIn; 1998 per GoodFirms snippet — conflicting | Verified (search snippet), conflict | [LI][GF] |
| Size | 2–10 employees (LinkedIn) | Verified (search snippet) | [LI] |
| Salesforce partner since | 2008 | Verified | [RI-home] |
| AppExchange listing | listingId `a0N300000016cgZEAQ`; solution type "Salesforce App"; categories Sales; Engineering, Construction & Real Estate | Verified | [AX-RP] |
| Listed on | 10/30/2008 | Verified | [AX-RP] |
| Last updated | 03/04/2022 (listing page, fetched). A search snippet instead showed "latest release 3/15/2009" and "not reviewed by Salesforce" — the listing may have been edited in 2022 without a new package release | Verified, conflict noted | [AX-RP][WS] |
| Package | **Unmanaged package**; code viewable and modifiable | Verified | [AX-RP] |
| Platform | **Native on Salesforce** (Force.com). Can be used with existing Salesforce licences or bought from Real Intelligence (OEM) | Verified | [AX-RP][RI-products][RI-partners] |
| Status | Listing still live; no evidence of active development (vendor pages dated 2011–2019; no release notes). **Inferred: legacy / minimally maintained** | Inferred | [RI-partners][RI-home] |
| Ownership history | No acquisition or rename found | Unknown | — |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| AppExchange | Not publicly verified | 5.00 (fetched 2026-11-12) | 2 | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016cgZEAQ | Review text, dates and reviewers not visible in fetch |
| SourceForge | — | 0.0 / no reviews | 0 | https://sourceforge.net/software/product/Real-Properties | Profile mixes in Real Facilities content |
| SoftwareReview.com | — | No ratings | 0 | https://softwarereview.com/s/real-properties | Profile unclaimed |
| GoodFirms | — | Not visible (403) | — | https://www.goodfirms.co/software/real-properties | Snippet: "Contact Vendor" pricing |
| G2 / Capterra | — | No product page found for Real Properties | — | https://www.g2.com/products/real-intelligence/reviews (company-level, not opened) | — |

## 2. Overview

- **What it is** — A Salesforce app for property, facility and event management that "tracks building, tenant, and lease details"; with Real Floorplans it shows floor-plan-based status in real time. **Verified** [AX-RP]
- **Developer** — Real Intelligence, Inc. **Verified** [AX-RP]
- **Industry** — Listed industry solutions: hospitality and lodging; trade show/event/conference; assisted living; shopping centres; commercial property management; residential real estate management; asset management. **Verified** [AX-RP]
- **Target users** — Property managers, leasing/sales staff for condos and residential units, event organisers. Vendor tagline: "Generate more leads, close more sales, track units and residents." **Verified** [RI-products]
- **Problems solved** — Visualising occupancy/availability on floor plans; tracking units, residents/tenants and leases inside the CRM. **Verified** [AX-RP][RI-floor]
- **Major functions** — Properties, Buildings and Units; analytics and reporting; email marketing; Outlook/Word/Excel integration; task and event calendar; advanced website integration; standard and custom action plans (workflow); paid add-ons: interactive floor plans, reservations, geocoding/mapping. **Verified, column assignment Inferred** (comparison chart flattened in fetch) [RI-pricing]
- **Differentiators** — CAD floor plans, Google Earth/Maps and QR codes integrated with Salesforce; usable on PC, web, mobile, digital signage. **Verified** [AX-RP]
- **Native/integrated** — Native app on the Salesforce Platform. **Verified** [AX-RP]
- **Editions** — Professional, Enterprise, Unlimited, Force.com, Developer. **Verified** [AX-RP]
- **Pricing** — "Paid"; per user per year (no amount). SourceForge shows "from $50/month/user" (possibly for Real Facilities). 30-day free trial (2011 page). Education/charity pricing. **Verified** [AX-RP][RI-pricing][RI-partners]; $50 **Verified (directory)** [SF]
- **Package** — Unmanaged. **Verified** [AX-RP]
- **Limitations & dependencies** — Unmanaged (no upgrades, customer owns code); dated listing; floor plans need Real Floorplans (Flash/SWF in older demos); no published docs. **Verified** (unmanaged, SWF links) [AX-RP][RI-floor]; others **Inferred**

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Property / building / unit inventory | Tracks properties, buildings and units | Property managers, sales | Building, unit details | Tenants/residents, leases, floor plans | Spreadsheet -> CRM records | Verified (feature); fields Unknown | [AX-RP][RI-pricing] |
| Tenant / resident tracking | Tracks tenants (commercial) and residents (residential/assisted living) | Property managers | Tenant/resident details, occupancy | Units, leases | — | Verified (feature) | [AX-RP][RI-products][RI-floor] |
| Lease tracking | Lease details per tenant | Property managers | Lease details (no field list) | Tenant, unit | — | Verified (feature); fields Unknown | [AX-RP] |
| Sales & marketing CRM (leads, contacts) | "Generate more leads, close more sales"; email marketing | Leasing/sales agents | Leads, Accounts, Contacts | Units | — | Verified (claim) | [RI-products][RI-pricing] |
| Real Floorplans (add-on) | CAD floor plans coloured by live Salesforce data; e.g. booth availability, sponsorship level, rental rates (Dreamforce 2012); occupancy, plan and resident info (assisted living) | Managers, event organisers, buyers/visitors | Status per space | Units/spaces | Static plans -> live status map | Verified | [RI-floor][AX-RP] |
| Reservations (paid) | Reservation of spaces/rooms | Event/conference organisers | Reservations | Spaces | — | Verified (feature listed) | [RI-pricing] |
| Action plans / workflow | Standard and custom action plans | Users | Tasks | Any record | — | Verified (feature listed) | [RI-pricing] |
| Mapping (paid) | Geocoding, Google Maps / Google Earth | Users | Lat/long | Properties | — | Verified | [RI-pricing][AX-RP] |
| QR codes | QR codes generated per record (e.g. per artist in an art-show project) | Event organisers | QR code | Records | — | Verified | [RI-home][AX-RP] |
| *Sibling, not Real Properties:* Real Facilities | Move requests (>10,000/yr) with automated approvals, QR asset tracking, AutoCAD floor plans, move-request dashboard | Facilities, IT, HR | Move requests, assets, spaces | People, places, things | Effort reduction claims | Verified for Real Facilities only | [RI-fac][SF] |

## 4. Data model — **Inferred reference architecture**

Nothing in this section is published by the vendor except the *existence* of the concepts in the "Basis" column. Object API names are all ours (`Proposed:`), using the project's `TC_` convention with an `RP` infix to keep them distinct from the AscendixRE mirror.

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields (Inferred) | Parent | Children | Label | Source / basis |
|---|---|---|---|---|---|---|---|---|
| Account | `Account` | Standard | Owners, commercial tenants, brokerages | Type (Owner, Tenant, Vendor) | — | Property, Lease | Verified (Accounts listed) / roles Inferred | [RI-pricing] |
| Contact | `Contact` | Standard | Residents, tenant contacts, buyers | Role | Account | Lease (as resident) | Verified (Contacts listed) | [RI-pricing] |
| Lead | `Lead` | Standard | Prospective buyers/renters | Unit of interest | — | — | Inferred from "Generate more leads" | [RI-products] |
| Property | Unknown. `Proposed: TC_RP_Property__c` | Custom | Site / complex / event venue | Address, type (Commercial, Residential, Retail, Hospitality, Assisted Living, Event), geolocation | Account (owner) | Building | Verified (concept "Properties") | [RI-pricing][AX-RP] |
| Building | Unknown. `Proposed: TC_RP_Building__c` | Custom | Building within property | Floors, CAD floor plan reference | Property | Unit | Verified (concept "Buildings") | [RI-pricing][AX-RP] |
| Unit / Space | Unknown. `Proposed: TC_RP_Unit__c` | Custom | Unit, suite, office, cube or booth | Floor, size, rate, status (Available/Occupied/Reserved/Sold), plan type | Building | Lease, Reservation | Verified (concept "Units"; booths/offices/cubes in sibling Real Offices) | [RI-pricing][RI-floor] |
| Lease | Unknown. `Proposed: TC_RP_Lease__c` | Custom | Tenancy agreement | Tenant Account/Contact, Unit, start, end, rent, status | Unit | — | Verified (concept "lease details") | [AX-RP] |
| Resident / Tenant | Unknown. Inferred as Contact/Account roles, or `Proposed: TC_RP_Occupant__c` junction Unit–Contact | Junction (Inferred) | Who occupies a unit | Move-in, move-out | Unit, Contact | — | Verified (concept "residents", "tenant") | [RI-products][AX-RP] |
| Reservation | Unknown. `Proposed: TC_RP_Reservation__c` | Custom | Time-bound booking of space (rooms, booths) | Start, end, status | Unit | — | Verified (feature "Reservations") | [RI-pricing] |
| Floor Plan | Unknown. `Proposed: TC_RP_Floor_Plan__c` | Custom / External file | CAD/SVG drawing with space ids mapped to Units | Building, file, space-id map | Building | — | Verified (concept); storage Unknown | [RI-floor][AX-RP] |
| Sale / Transaction | Unknown. `Proposed: TC_RP_Transaction__c` or standard `Opportunity` | Inferred | Unit sale (condos) or lease deal | Unit, buyer, price, stage | Unit | — | Inferred from "close more sales" and condo use | [RI-products] |
| Event | Unknown (standard `Event` or `Proposed: TC_RP_Venue_Event__c`) | Inferred | Trade show / conference | Venue property, dates | Property | Reservation | Verified (concept "event management") | [AX-RP] |

**Relationships, record types, picklists, roll-ups, formulas, validation rules, external IDs:** all **Unknown**. Inferred: status picklist on Unit drives floor-plan colouring (vendor shows "booth availability" and "occupancy" overlays [RI-floor]); roll-up of occupied units to Building/Property for occupancy reporting.

**ERD edge list (Inferred reference architecture)**
```
Account -> Property (lookup: owner) [Inferred]
Property -> Building (MD) [Inferred]
Building -> Unit (MD) [Inferred]
Building -> Floor Plan (lookup) [Inferred]
Unit -> Lease (lookup) [Inferred]
Account -> Lease (lookup: tenant) [Inferred]
Contact -> Occupant <- Unit (junction) [Inferred]
Unit -> Reservation (lookup) [Inferred]
Unit -> Transaction/Opportunity (lookup) [Inferred]
Lead -> (convert) Account/Contact/Opportunity [Inferred, standard Salesforce]
```

## 5. Technical components

| Area | Verified | Inferred | Unknown |
|---|---|---|---|
| Package | Unmanaged, editable code [AX-RP] | Custom objects + page layouts + reports | Namespace (none expected for unmanaged) |
| Apex / Visualforce | — | Visualforce or Flash embeds for floor plans (2008–2012 era; SWF demo files) [RI-floor] | All class/page names |
| LWC / Aura | — | Unlikely (listing pre-dates Lightning) | — |
| Workflow | "Standard and Custom Action Plans (Workflow Automation)" [RI-pricing] | Workflow rules / tasks | Names |
| Approvals | Automated approvals exist in **Real Facilities** (move requests) [RI-fac] | — | Any in Real Properties |
| Security | "Sharing rules, Account Security, Profile and Custom Security" listed [RI-pricing] | Standard profiles/sharing | Perm sets |
| Integrations | CAD floor plans, Google Earth, Google Maps, QR codes [AX-RP]; Outlook/Word/Excel [RI-pricing]; also Oracle Fusion and Microsoft Dynamics for floor plans (company profile) [LI] | — | Mechanism |

## 6. Business processes — **Inferred reference architecture**

The vendor documents no process steps. The processes below are what the advertised features imply. Every bullet is **Inferred** unless tagged otherwise.

### 6.1 Property and unit inventory set-up
**Start trigger:** a new property, building or venue is taken on for management or sale.
1. **Initiation** — Property record created (owner Account linked); Buildings added. Basis: "Properties, Buildings and Units" [RI-pricing] (Verified concept).
2. **Data processing** — Units/spaces created per floor; CAD floor plan imported and each drawn space mapped to a Unit (Real Floorplans add-on) [RI-floor] (Verified concept); address geocoded (paid geocoding) [RI-pricing].
3. **Business operations** — Unit status maintained (Available / Occupied / Reserved / Sold — Proposed values).
4. **Decision/approval** — None documented.
5. **Completion** — Floor plan published read-only or editable to permitted users (pattern Verified for Real Facilities [RI-fac], assumed here).
6. **Post-completion** — Occupancy dashboards; website integration shows availability publicly [RI-pricing] (Verified feature).

### 6.2 Lead -> sale or lease of a unit (residential/condo/commercial)
**Start trigger:** prospect enquiry (website integration, email marketing, AdWords in sibling product).
1. **Initiation** — Lead created ("Generate more leads") [RI-products] (Verified claim).
2. **Data processing** — Lead qualified; unit(s) of interest linked; interactive floor plan used to show availability [RI-floor].
3. **Business operations** — Action plan tasks and calendar events (tours) [RI-pricing] (Verified feature).
4. **Decision/approval** — Lead converted to Account/Contact/Opportunity (standard Salesforce); Opportunity stages (Proposed: Prospecting, Tour, Application/Offer, Negotiation, Closed Won/Lost).
5. **Completion** — Won: Lease record created (rental) or unit marked Sold (sale); unit status updated so floor plan recolours in real time [AX-RP] (real-time status Verified).
6. **Post-completion** — Tenant/resident record maintained; email marketing; reporting.
- **Alternate paths:** Lost -> unit stays Available; lease application rejected -> Opportunity Closed Lost; reservation instead of lease for short stays/events.

### 6.3 Tenancy / lease administration
**Start trigger:** lease signed.
1. **Initiation** — Lease linked to tenant and unit ("tracks building, tenant, and lease details") [AX-RP] (Verified concept).
2. **Data processing** — Dates, rent, terms recorded (fields Unknown).
3. **Business operations** — Tasks for renewals and move-ins via action plans.
4. **Decision/approval** — Renewal or termination decision (Proposed).
5. **Completion** — Lease status Active -> Expired/Terminated (Proposed); unit back to Available.
6. **Post-completion** — Occupancy and lease reporting [RI-pricing] (analytics Verified).
- Accounting/billing: "Billing & Invoicing" and "Accounting Integration" appear only on a third-party directory feature checklist [SR] — **Unknown** whether implemented.

### 6.4 Space reservation / event floor management
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

## 7. Automation table (Inferred unless noted)

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Action plans | Record created / stage change | Lead, Opportunity, Lease | Create task sequences | Follow-up | Workflow rules / Flow | Verified (feature) [RI-pricing]; mechanics Inferred |
| Floor-plan status refresh | Unit status change | Unit | Recolour plan | Real-time view | Visualforce/JS reading records | Verified (outcome) [AX-RP]; tech Inferred |
| Geocoding | Address saved | Property | Set lat/long | Map | Integration (paid) | Verified (feature) [RI-pricing] |
| QR code generation | Record created | Any | Generate QR code | Tracking | Formula/image or Apex | Verified (example) [RI-home] |
| Unit status on lease/sale | Lease Active / Opp Won | Unit | Set Occupied/Sold | Inventory accurate | Workflow/Flow | Inferred |
| Lease renewal reminder | N days before end | Lease | Task | Renewal | Scheduled Flow | Inferred |

## 8. UI / UX
- Standard Salesforce tabs for Properties, Buildings, Units and standard CRM; task and event calendar. **Inferred** from feature list [RI-pricing].
- Interactive floor plans (Real Floorplans) usable on PC, web, mobile and digital signage. **Verified** [AX-RP]
- Screenshot / demo URLs (not downloaded):
  - http://www.realintelligence.com/real-estate/floorplans/Dreamforce_2008/dreamforce-fp2.jpg — Dreamforce exhibitor floor plan screenshot (booth availability).
  - http://www.realintelligence.com/real-estate/floorplans/Dreamforce_2012/Dreamforce_2012_04.swf — interactive Flash floor plan, Dreamforce 2012.
  - http://www.realintelligence.com/real-estate/floorplans/AL_Building/al-type.jpg — assisted-living building floor plan screenshot.
  - http://www.realintelligence.com/real-estate/floorplans/AL_Building/AL_Building_Private2.swf — interactive Flash assisted-living plan.
  - https://realintelligence.com/wp-content/uploads/2019/12/Riverport-Flats-1.png — floor plan image ("Riverport Flats"), shown on the Real Properties page.
  - https://realintelligence.com/wp-content/uploads/2024/09/Real-Facilities-Dashboard-1024x682.png — Real Facilities move-request dashboard (sibling product).
  - https://appexchange.salesforce.com/partners/servlet/servlet.FileDownload?file=00P3000000P3fQiEAJ — AppExchange-hosted PDF "Real Properties and Real Floorplans Powered by Real Intelligence" (not opened, per instructions).
  - https://realintelligence.com/products/RealProperties.pdf — Real Properties data sheet (linked from products page; not opened).
  - https://vimeo.com/realintelligence — vendor Vimeo channel (no video list retrievable).
  - Nothing was watched; no Observed claims.

## 9. Reporting
- "Analytics and Reporting" feature; dashboards for move requests exist in Real Facilities. **Verified** [RI-pricing][RI-fac]
- KPIs (Inferred): occupancy by building, available units, leases expiring, lead conversion, reservation revenue.

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| AutoCAD (CAD floor plans) | Interactive floor plans | Import | Drawings | Admin import | Real Floorplans | Verified | [AX-RP][RI-fac] |
| Google Maps / Google Earth | Mapping | Read | Locations | View | Unknown | Verified | [AX-RP] |
| QR codes | Record/asset tagging | Out | Codes | Record create | Unknown | Verified | [AX-RP][RI-home] |
| Outlook, Word, Excel | Office integration | Bi | Email, docs | User | Salesforce-era connectors | Verified (feature) | [RI-pricing] |
| Websites | Publish availability | Out | Units, status | Real time | "Basic/Advanced Website Integration" | Verified (feature) | [RI-pricing] |
| Email marketing | Campaigns | Out | Contacts | User | Unknown | Verified (feature) | [RI-pricing] |
| Oracle Fusion, Microsoft Dynamics | Floor-plan linkage on other CRMs | — | — | — | — | Verified (search snippet) | [LI] |
| Accounting / billing | Invoicing | — | — | — | — | Unknown (directory checklist only) | [SR] |

## 11. Limitations & what would be hard to recreate
- Biggest gap: **no published schema, process or UI**; the product cannot be mirrored with any fidelity from public sources. Any build is a design of our own guided by the feature list.
- Hard parts: CAD-to-interactive floor plan rendering with live status (originally Flash; would need SVG/LWC today); reservations calendar.
- Unmanaged package: customers own the code, no upgrade path — limits comparison of "current" behaviour.
- Ambiguity: residential (units, residents, condo sales), commercial (tenants, leases), assisted living and events all claimed by one listing; the true core use is unclear.

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| AX-RP | Real Properties – Real Intelligence, Inc. (AppExchange) | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016cgZEAQ | AppExchange | 2026-11-12 |
| RI-rp | Real Properties page | https://realintelligence.com/realproperties/ | vendor site | 2026-11-12 |
| RI-products | Products page | https://realintelligence.com/products/ | vendor site | 2026-11-12 |
| RI-pricing | Product comparison chart | https://realintelligence.com/products/pricing.html | vendor site | 2026-11-12 |
| RI-floor | Real Floorplans | https://realintelligence.com/products/real-floorplans.html | vendor site | 2026-11-12 |
| RI-fac | Real Facilities (sibling) | https://realintelligence.com/products/real-facilities/index.html | vendor site | 2026-11-12 |
| RI-partners | Partners page (c. 2011) | https://realintelligence.com/partners/index.html | vendor site | 2026-11-12 |
| RI-home | Home (2016–2019 content) | https://realintelligence.com/home/ | vendor site | 2026-11-12 |
| SF | SourceForge: Real Properties | https://sourceforge.net/software/product/Real-Properties | third party directory | 2026-11-12 |
| SR | SoftwareReview: Real Properties | https://softwarereview.com/s/real-properties | third party directory | 2026-11-12 |
| GF | GoodFirms: Real Properties (403; snippet) | https://www.goodfirms.co/software/real-properties | third party directory | 2026-11-12 |
| CU | Cuspera: Real Intelligence Real Properties (meta description only) | https://www.cuspera.com/products/real-intelligence-real-properties-x-12057 | third party directory | 2026-11-12 |
| LI | LinkedIn company page (snippet) | https://linkedin.com/company/real-intelligence | third party | 2026-11-12 |
| WS | Web searches for AppExchange "Real Properties", "Real Property Management", "RealProperties", "Real Estate Properties" | (search engine) | search | 2026-11-12 |
| C2 | Realty Pro user guide (candidate 2) | https://tide-gold-7de.notion.site/ebd/21e8f18e64fd80d7ab7ecd340ed9ea95 | third party | 2026-11-12 (snippet) |
| C3 | Propertybase Salesforce Edition (candidate 3) | https://www.propertybase.com/real-estate-crm/salesforce-edition | vendor site | 2026-11-12 (snippet) |
| C4 | Techila Real Estate Management (candidate 4) | https://techilaservices.com/product/real-estate-management | vendor site | 2026-11-12 (snippet) |
| C5 | Booking Ninjas multifamily (candidate 5) | https://www.bookingninjas.com/solutions/residential/multifamily-property | vendor site | 2026-11-12 (snippet) |
