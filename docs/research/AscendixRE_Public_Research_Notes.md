# AscendixRE: Functional Research (public sources only)

Researched 2026-11-12. Everything comes from public pages: the Ascendix Help Center (help.ascendix.com, hosted on Helpjuice and mirrored at ascendix.helpjuice.com), the AppExchange listing, and search-engine snippets of ascendix.com pages. **ascendix.com returned HTTP 403 to direct fetches**, so marketing and blog pages are known only from search snippets and are labelled that way. No source code was looked for or obtained.

**Labels**
- **VERIFIED [n]**: stated on the cited public page. Source numbers are listed at the end.
- **VERIFIED-snippet [n]**: taken from a search-result snippet of an ascendix.com page I could not open in full.
- **ASSUMPTION**: my inference or a common CRE CRM pattern, for our own design. Not documented by Ascendix.

**A general warning.** The public help center is thin on schema. Most articles are short overviews or point to videos and screenshots. Field lists, picklist values and `ascendix__` API names are rarely given. Every API name, field and picklist value Ascendix does publish is collected below.

---

## 0. Product overview and editions

- AscendixRE is a commercial real estate (CRE) CRM delivered as a managed package on Salesforce. It runs on Enterprise and Unlimited editions and requires Platform Cloud. It is Lightning Ready, supports multiple currencies, and its tabs and objects do not count against org limits. **VERIFIED [AX]**
- Pricing starts at $79 per user per month. One snippet mentions a $99 plan that includes commissions. **VERIFIED [AX]**, **VERIFIED-snippet [S-comm]**
- Capabilities listed on AppExchange: property, lease and listing management; deal flow; stacking plans with PDF and Excel export; commission splits, tiered payouts and custom arrangements; a mapping tool; pre-built lease and sale fields; a 360-degree property view with image collections; reports and advanced search; listing-portal integrations. **VERIFIED [AX]**
- Add-ons:
  - Ascendix Search: advanced search, map, bulk operations, mass email, Mailchimp. Included in Enterprise. **VERIFIED [AX]**
  - Composer: document generation. Included in Enterprise. **VERIFIED [AX]**
  - MarketSpace: listing portal and deal rooms. **VERIFIED-snippet [S-inq]**
  - AI Suite: AI Agent, Harvest email capture, Composer AI, and an xRE Connector for ChatGPT and Claude. **VERIFIED [AX]**
- Editions:
  - "Foundations" and "Enterprise". Ascendix Search is an add-on to Foundations and is included in Enterprise. **VERIFIED [H-prospects]**
  - "Ascendix Lite" app (release 1.42): only core objects, a simplified navigation bar, permission set `AscendixRELite`. **VERIFIED [H-lite]**
  - Persona bundles: Tenant Rep, Landlord Rep, Investment Sales, Land Brokers. **VERIFIED-snippet**
- Package namespace is `ascendix`. Seen in the field `ascendix__CapitalSource__c`, the Apex class `ascendix.RestController`, and the custom permission `ascendix.Commission Privacy Admin`. **VERIFIED [H-capsrc][H-web2inq][H-privacy]**
- Named permission sets: `AscendixREBroker` ("AscendixRE Broker"), `AscendixREAdmin`, `AscendixRELite`, "AscendixRE Commission Privacy", `Ascendix_Search_User`. Named profiles: "AscendixRE Standard User", "AscendixRE Administrator". **VERIFIED [H-psf][H-capsrc][H-privacy][H-leasecomp]**
- **AscendixRE Admin Console** is a custom admin app. **VERIFIED [H-dealavail][H-psf][H-rentcfg]** Its tabs include:
  - Object Configurations / Object Field Mapping
  - Business Logic, with Validation and Automation sub-tabs
  - Accounting, with a Commission Privacy tab
  - Web Form Generator
  - Image Viewer configuration

  Configuration is stored in Custom Metadata Types, including `AutomationSetting__mdt`, "Object Name Mapping", "Relationship Type", and a Stacking Plan feature record. **VERIFIED [H-rentcfg][H-names][H-reltgrid][H-stackcfg]**
- Not supported: Salesforce Essentials, Group and Professional editions. Stacking Plan may not work in Classic. **VERIFIED [H-limits]**

---

## 1. Overall object model

### 1.1 App menu (tabs) as documented [H-glossary] — VERIFIED

| Tab / Object | Documented meaning (paraphrased) |
|---|---|
| Home | Daily overview of tasks and events (navigation tab, not data) |
| Chatter | Internal collaboration |
| Dashboards | Charts, graphs, funnels |
| **Inquiries** | Leads from calls or emails about leasing or buying space, or general space requirements |
| **Contacts** | People linked to Accounts, in roles such as prospect, client or broker |
| **Accounts** | Companies |
| **Deals** | Opportunity pipeline by business line (tenant rep, landlord rep and others). Private by default |
| **Properties** | Building data: location, type, size, class |
| **Availabilities** | Vacant units or suites in a Property |
| **Leases** | Lease abstracts: a tenant Account occupying a Property |
| **Sales** | A Property's sale history (sale comps) |
| **Listings** | The listing agreement or contract a listing broker holds for a Property |
| Calendar / Tasks / Notes | Standard Activities and Notes. Calendar does not sync with Outlook |
| Reports | Standard reports |

### 1.2 Complete list of documented custom objects

The API names below are as published. Unprefixed names such as `DealPeriod__c` presumably carry the `ascendix__` prefix in subscriber orgs (ASSUMPTION).

| Object (label) | API name (if published) | Evidence |
|---|---|---|
| Property | not published (likely `ascendix__Property__c`, ASSUMPTION) | [H-glossary][H-connect] |
| Availability | not published | [H-glossary][H-dealavail] |
| Listing | not published | [H-glossary][H-listmap] |
| Lease | not published | [H-glossary][H-close] |
| Sale | not published. Example source fields `SaleDate__c`, `SalePrice__c` | [H-names] |
| Deal | not published. Field `GrossFeeRatePerUOM__c` | [H-psf] |
| Inquiry | not published | [H-glossary][H-inq-what] |
| Commission | not published | [H-comm] |
| Commission Privacy | not published | [H-privacy] |
| Deal Period (Rent Table period on Deal) | `DealPeriod__c` | [H-rentcfg] |
| Lease Period (Rent Table period on Lease) | `LeasePeriod__c` | [H-rentcfg] |
| Prospective Listing (Inquiry to Listing link; shown on Listing as "Prospective Inquiries") | not published | [H-multilist][RN-127] |
| Prospective Buyer (Seller Rep deal to buyer Account/Contact) | not published | [H-autopop][H-addtodeal][RN-116] |
| Deal Source (Capital Markets) | not published. Has lookup `ascendix__CapitalSource__c` | [H-dealsrc][H-capsrc] |
| Capital Source (lenders and capital providers) | not published | [H-capsrc] |
| Term Sheet (quotes on a Deal Source) | not published | [H-termsheet] |
| Deal Property (multiple properties per Capital Markets deal) | label "Deal properties" | [H-multiprop] |
| Relationship (records to internal Users; extensible by lookups) | not published | [H-reltgrid] |
| Market Rent | not published | [H-names] |
| Unit | not published | [H-names] |
| Unit Profile | not published | [H-names] |
| Offer (offer tracking on Landlord Rep and Seller Rep deals) | object not named, feature only | [RN-116] |
| Bypass Validation Rules (custom setting) | `BypassValidationRules__c` (fields `DealPeriodValidation__c`, `LeasePeriodValidation__c`) | [H-rentcfg] |
| Ad-Hoc List (Ascendix Search) | not published | [H-adhoc] |
| Custom metadata: AutomationSetting, Object Name Mapping, Relationship Type, Stacking Plan feature | `AutomationSetting__mdt` | [H-rentcfg][H-names][H-reltgrid][H-stackcfg] |

Standard objects used: Account, Contact, Lead (search and campaigns), Task, Event, Note, Campaign, User. **VERIFIED [H-bulk][H-glossary]**

**Not found in public docs:** Floor or Suite objects (stacking plan floors are entered on the Property, see section 10), Loan, Investor, Payment or Payment Schedule, Deal Contact or Deal Party junction (beyond Prospective Buyer), Requirement or Preference as a separate object, Comp object (comps are the Lease and Sale records), Document Template.

### 1.3 Relationships as documented

- **Property is the hub.** Lease, Inquiry, Deal, Availability, Listing and Sale all relate to Property. **VERIFIED [H-connect]**
- Accounts and Contacts may link to a property in roles such as owner, finance, asset manager, marketing and property manager. **VERIFIED [H-connect]**
- Contact belongs to an Account. **VERIFIED [H-acctcont]**
- Availability is a child of Property: vacant suites in a Property. **VERIFIED [H-glossary]**
- Deal has lookups to Property, Space (Availability), and Tenant (Account). **VERIFIED [H-newdeal]**
  - It also has these party fields: Client, Client Contact, Client Role, Client Contact Role, Tenant, Tenant Contact, Owner/Landlord, Owner/Landlord Contact, Buyer, Buyer Contact. **VERIFIED [H-autopop]**
  - It also has fields for Lender / Lender Contact, Deal Source, Primary Connection, and Lead Broker Role. **VERIFIED [H-lite]**
- Lease relates to Property and a Tenant Account. Its fields include Unit Name/Number, Unit Type, Property, Lease Type, Size, Lease Rate, Floor, Tenant, Commencement Date and Expiration Date. **VERIFIED [H-close]**
- Sale relates to Property. Its fields include Sale Date, Listing Price, Sale Price, Buyer, Buyer Contact, Seller and Seller Contact. **VERIFIED [H-close]**
- Listing relates to Property. Fields copied from Property: Listing Broker Company, Listing Broker Contact, Owner/Landlord, Owner/Landlord Contact, Market, Region, Sub Market, Property Type, Property Sub Type, Description, Location Description, Website. **VERIFIED [H-prepop]**
- Inquiry relates to Listing, and to many Listings through Prospective Listings, one of which is marked Primary. It also has a Broker Company and a Broker Contact. **VERIFIED [H-multilist]**, **VERIFIED-snippet [S-inq]**
- Commission is a child of Deal. It links to a User (Inside Broker) or to an Account and Contact (Analyst or Co-Broker). **VERIFIED [H-comm]**
- Deal Period is a child of Deal. Lease Period is a child of Lease. **VERIFIED [H-rentcfg]**
- Capital Markets chain: Deal Source is a child of Deal and looks up to Capital Source. Term Sheet is a child of Deal Source. **VERIFIED [H-dealsrc][H-capsrc][H-termsheet]**
- Deal Property is a junction between a Capital Markets Deal and Property. **VERIFIED [H-multiprop]**
- Relationship type (lookup versus master-detail) is not published for any of these. **ASSUMPTION**: lookups, except master-detail for Commission, Deal Period, Lease Period, Term Sheet and Prospective Listing.

### 1.4 Documented picklist values (consolidated)

| Picklist | Values | Source |
|---|---|---|
| Deal record types (business lines) | Tenant Representation, Landlord Representation, Seller Representation, Buyer Representation, Listing Pursuit, Capital Markets, Asset Management, Consulting, Financing, Lease Administration, Project Management, Property Management | VERIFIED [H-close] |
| Deal Status on close | Won, Lost | VERIFIED [H-close] |
| Deal Sub Type (Listing Pursuit) | Lease Listing - Exclusive; Lease Listing - Non Exclusive; Sale Listing - Exclusive; Sale Listing - Non-Exclusive; Sale or Lease; Sublease | VERIFIED [H-listmap] |
| Listing record types | Lease, Sale, Sale or Lease (plus Exclusive and Sublease checkboxes) | VERIFIED [H-listmap] |
| Inquiry types | Lease, Sale | VERIFIED [H-inq-mgmt], VERIFIED-snippet [S-inq] |
| Client Role / Client Contact Role defaults | Tenant; Owner/Landlord; Seller (also Buyer, by implication) | VERIFIED [H-autopop] |
| Commission record types | Inside Broker (default), Analyst, Co-Broker, Expense | VERIFIED [H-comm] |
| Gross Fee Method (Deal) | Percent, Amount, By $ per SF | VERIFIED [H-comm][H-psf] |
| Total Rent Calculation | Annual Ratio Rent (default), Monthly Rate | VERIFIED [H-renttotal] |
| Rent Type | exists, with a configurable default; values not published | VERIFIED [H-renttable] |
| Contact Relationship Type | examples: Partner, Vendor, Client, Prospect (customizable) | VERIFIED [H-reltypes] |
| Contact Category / Contact Type | includes Prospect | VERIFIED [H-prospects] |
| Availability Status | includes Closed (set by deal-close mapping); other values not published | VERIFIED [H-dealavail] |
| Prospective Listing Status | exists, values not published | VERIFIED [H-multilist] |
| Property record types | "Office" is named, since Stacking Plan defaults to the Office Property record type. Property Type and Sub Type come from the record type | VERIFIED [H-stackcfg][H-prepop] |
| Scorecard Summary type | Average, Count, Max, Min, Sum | VERIFIED [H-scorecard] |
| Deal Stage | exists and supports chart colors; values **not published** | VERIFIED [H-newdeal][RN-127] |
| Lease Type | exists; values **not published** | VERIFIED [H-close] |
| Property Class | exists; values **not published** | VERIFIED [H-glossary] |

The following are all ASSUMPTION; Ascendix does not publish them. Suggested defaults for our build:
- Property record types: Office, Retail, Industrial, Multifamily, Land, Hospitality, Mixed-Use, Special Purpose.
- Property Class: A, B, C.
- Deal Stage: Prospect, Pitch/Proposal, Touring, LOI, Negotiation, Lease/PSA Out, Executed/Closed. This is supported indirectly by a snippet mentioning an "LOI" stage that can trigger client email.
- Lease Type: Gross, Modified Gross, NNN, Full Service, Ground, Percentage.
- Availability Status: Available, Pending, Leased/Closed, Off Market.

---

## 2. Module details

### Module 1: Property Management
- **Purpose:** The building is the central record. Every other record connects to it. **VERIFIED [H-connect]**
- **Property vs Listing:** A Property is the physical building: characteristics, location, total space, floors. A Listing is the agreement won to sell or lease it. Marketing and inquiries attach to the Listing. Land-broker trials merge the Property and Listing tabs. **VERIFIED [H-propvslist]**
- **Fields named:** Location, Type, Size, Class, Number of floors, Average floor size (for stacking plan), Market, Region, Sub Market, Description, Location Description, Website, Listing Broker Company/Contact, Owner/Landlord and Owner/Landlord Contact. The last group is inferred from the fields that pre-populate onto a new Listing. Property Type and Property Sub Type come from the record type. There is also a Primary Image field. **VERIFIED [H-propintro][H-prepop][H-imgviewer]**, plus a snippet for floors [S-stack]
- **UI features:**
  - Summary/highlights view.
  - One-click image gallery (AscendixRE Image Viewer component, 25 MB upload limit).
  - One-click stacking plan.
  - Map of location.
  - Quick actions: log call, task, appointment, email.
  - Hover quick links over related lists.

  **VERIFIED [H-propintro][H-imgviewer][H-limits]**
- **Scan Search Filter on Property:** view related Inquiries, Availabilities, Deals and Leases, filtered (for example, leases expiring this year, or deals in a given stage). Filters are temporary and per user. **VERIFIED [H-ways]**
- **Import:** a Property import that geocodes in chunks of 99. **VERIFIED [H-limits]**
- **Related:** Leases tab, used to launch the Lease Comp Report. **VERIFIED [H-leasecomp]**
- **ASSUMPTION:** address, lat/long geolocation, year built, land area, parking, zoning, APN, owner Account lookup.

### Module 2: Account and Contact Management
- **Purpose:** an Account is a company and a Contact is a person at it. Neither needs a property link, but either can have one, in roles such as owner, finance, asset manager, marketing or property manager. **VERIFIED [H-acctcont][H-connect]**
- **Contact roles:** the glossary describes contacts as prospect, client or broker. The **Relationship Type** picklist on Contact is customizable, with example values Partner, Vendor, Client and Prospect. A Category or Contact Type field marks Prospects. **VERIFIED [H-glossary][H-reltypes][H-prospects]**
- **Deal-level client roles:** Client Role and Client Contact Role on Deal default by record type to Tenant, Owner/Landlord or Seller. **VERIFIED [H-autopop]**
- **Relationship object and grid:** the "AscendixRE Relationship Grid Universal" component links records to internal Users through a Relationship object. Admins add a lookup on Relationship to any object (for example, Listing) and define Relationship Types in custom metadata. **VERIFIED [H-reltgrid]**
- **Layouts:** "AscendixRE Account Layout" and "AscendixRE Contact Layout". **VERIFIED [RN-127]**
- **Automated follow-ups:** an "Automated Follow-up Tasks" checkbox and a sequence picklist on Contact. Tasks are generated with a due date, the client name and a sequence number. **VERIFIED [H-followup]**
- **Prospecting:** list views of Prospects; workflows for 30-60-90 day drip calls; Ascendix Search lists with a split-screen activity view. **VERIFIED [H-prospects]**
- **ASSUMPTION:** a junction for multiple Account-Contact or Contact-Property roles. Only the Relationship-to-User grid is documented.

### Module 3: Listing Management
- **Purpose:** records the listing agreement or contract a listing broker holds. It is the anchor for marketing, inbound inquiries, and "foot traffic" reporting to owners. **VERIFIED [H-listintro][H-propvslist][H-inq-what]**
- **Record types:** Lease, Sale, Sale or Lease. Checkboxes: Exclusive, Sublease. **VERIFIED [H-listmap]**
- **Fields:**
  - Name, Property, Region, Market (from Listing Pursuit close). **VERIFIED [H-close]**
  - Pre-populated from Property on create only, and editable: Listing Broker Company, Listing Broker Contact, Owner/Landlord, Owner/Landlord Contact, Market, Region, Sub Market, Property Type, Property Sub Type, Description, Location Description, Website. **VERIFIED [H-prepop]**
  - Primary image field. **VERIFIED [H-imgviewer]**
- **Processes:**
  - Closing a Listing Pursuit Deal as Won can create a Listing.
  - Deal Sub Type maps to Listing record type, Exclusive and Sublease. The mapping is configurable in Admin Console Object Field Mapping, with static or dynamic mappings.

  **VERIFIED [H-close][H-listmap]**
- **Related:** Prospective Inquiries (renamed from Prospective Listings in 1.27); multiple deals per lease listing in multi-tenant buildings. Listings were removed from the related list on the Landlord Rep deal type. **VERIFIED [RN-127][H-dealwhat]**
- **Marketing:** MarketSpace portal. Portal requests create an Inquiry linked to the Listing and Availability. LoopNet and Crexi email parsing to Inquiries is deprecated. **VERIFIED-snippet [S-inq]**, **VERIFIED [H-config-index]**
- **ASSUMPTION:** listing status (Active, Under Contract, Expired, Withdrawn), asking rate or price, listing start and expiration dates, commission terms.

### Module 4: Lease Management
- **Purpose:** lease abstracts of tenant Accounts occupying Properties. They serve as lease comps and drive expiration prospecting. **VERIFIED [H-glossary][H-leaseintro][H-dealwhat]**
- **Fields:** Unit Name/Number, Unit Type, Property, Lease Type, Size, Lease Rate (/SF), Floor, Tenant, Commencement Date, Expiration Date. Rent Table fields: Rent Type, Lease Rate /SF, Size (SF), Lease Commencement, Lease Expiration, Period Length (Months), Total Rent Calculation. **VERIFIED [H-close][H-renttable][H-renttotal]**
- **Rent Table (Lease Period, `LeasePeriod__c`):**
  - Period fields: From, To, Duration, Rate, Rent Per Month, Total rent.
  - Generated automatically from the deal or lease fields, with 12-month default periods.
  - Total rent formulas: Annual Ratio Rent = (days in period ÷ days in year) × monthly rate × 12. Monthly Rate = duration × monthly rent.
  - A non-blocking review flags gaps, overlaps and blank rent.
  - Validation rule `PreventBlankRateAndRentPerMonth`.
  - Decimal scale is configurable.

  **VERIFIED [H-renttable][H-renttotal][H-rentcfg][H-config-index]**
- **Creation:** closing a Tenant Rep or Landlord Rep Deal as Won can create a Lease. The setting `AUTOLeaseRentTableFromDeal` copies the Deal's rent table. **VERIFIED [H-close][H-rentcfg]**
- **Lease expiration reminders:** predefined Flow "Lease expiration". It creates Tasks for the lease owner at 18, 12 and 6 months before expiration, and the thresholds can be edited in the Flow. **VERIFIED [H-leaseexp]**
- **Lease Comp Report:** select Leases on a Property or Deal, click "Generate Lease Comp Report", and choose a Composer template. Output is downloaded or emailed. **VERIFIED [H-leasecomp]**
- **Stacking plan:** colors leases by expiration date. **VERIFIED-snippet [S-stack]**
- **ASSUMPTION:** options (renewal, expansion, termination), escalations, free rent, TI allowance (a Deal field "Allowances" exists [H-lite]), security deposit, landlord Account, sublease flag.

### Module 5: Deal Management
- **Purpose:** the pipeline of likely revenue events. **VERIFIED [H-dealwhat]**
  - Tenant Rep and Buyer Rep: create at LOI and track candidate properties.
  - Landlord Rep: create at serious intent on a suite.
  - Seller Rep: create once a buyer short list exists.
- **Record types:** the 12 listed in 1.4. **VERIFIED [H-close]**
- **Core fields:**
  - Deal Name, Property (lookup), Space (lookup to Availability), Deal Type (picklist), Stage (picklist), Tenant (Account lookup, with inline "+ New Account"). **VERIFIED [H-newdeal]**
  - Parties: Client, Client Contact, Client Role, Client Contact Role, Tenant, Tenant Contact, Owner/Landlord, Owner/Landlord Contact, Buyer, Buyer Contact. **VERIFIED [H-autopop]**
  - Others: Lead Broker Role, Deal Source, Primary Connection, Allowances, Lender, Lender Contact, Opened for Editing. **VERIFIED [H-lite]**
  - Financial: Gross Deal Value, Gross Fee Method, Gross Fee Percent, Gross Fee Amount, Fee Rate per SF (`GrossFeeRatePerUOM__c`), Size. **VERIFIED [H-comm][H-psf]**
  - Close: Deal Status (Won/Lost), Actual Close Date, Actual Value. **VERIFIED [H-close]**
  - Lease terms (a "Lease Terms" tab on Tenant Rep): Rent Type, Lease Rate /SF, Commencement, Expiration, Period Length, Total Rent Calculation. **VERIFIED [H-lite][H-renttable]**
  - Multiple Properties checkbox (Capital Markets). **VERIFIED [H-multiprop]**
- **Deal parties and client roles:**
  - Auto-population on create: Client Role and Client Contact Role become Tenant (Tenant Rep), Owner/Landlord (Landlord Rep) or Seller (Seller Rep).
  - Tenant and Tenant Contact copy from Client (Tenant Rep). Owner/Landlord copies from Client (Landlord Rep).
  - Buyer copies from the Primary Prospective Buyer (Seller Rep).
  - Only empty fields are filled, and the logic can be turned off in the Admin Console.

  **VERIFIED [H-autopop]**
- **Prospective Buyers:** a related list on Seller Rep deals. The Account field is optional. Contacts can be added from Ascendix Search with "Add to Deal". **VERIFIED [H-addtodeal][RN-116]**
- **Offers:** offer tracking on Landlord Rep and Seller Rep deals. **VERIFIED [RN-116]**
- **Close Deal process:** a "Close Deal" button opens a dialog with Status, Actual Close Date and Actual Value. **VERIFIED [H-close]**
  - Tenant Rep and Landlord Rep, when Won: optionally create a Lease.
  - Seller Rep and Buyer Rep, when Won: optionally create a Sale.
  - Listing Pursuit, when Won: optionally create a Listing.
  - Capital Markets: the status is set on the Details tab, without the dialog.
  - Close buttons can differ by record type. **VERIFIED [H-config-index]**
  - The linked Availability can be set to Closed by an object mapping. **VERIFIED [H-dealavail][RN-127]**
  - Validation, disabled by default: at least one Inside Broker commission must exist, and Inside Broker fee percents must total 100%. **VERIFIED [H-ibval]**
- **UI:**
  - Highlights panel, activity panel, hover quick links. **VERIFIED [H-dealintro]**
  - Kanban pipeline with stage totals and stage chart colors. **VERIFIED [RN-127]**, **VERIFIED-snippet**
  - Scorecards: up to 5 roll-up tiles on the record page, for example a sum over Commissions. **VERIFIED [H-scorecard]**
  - Editable grids with bulk edit, custom buttons and sorting. Limits: 1,000 records shown, 500 updated at a time. **VERIFIED [H-cm-index][H-limits]**
- **Automation:** stage-based workflows, such as emailing the client at the LOI stage. **VERIFIED-snippet [S-deal]**

### Module 6: Availability Management (spaces and suites)
- **Purpose:** vacant units or suites within a Property. Supports skimming, updating, creating and batch import. **VERIFIED [H-glossary][H-availintro]**
- **Fields:**
  - Status; "Closed" is a documented value. **VERIFIED [H-dealavail]**
  - Primary image field. **VERIFIED [H-imgviewer]**
  - Inferred from lease creation and deal lookup: Unit Name/Number, Unit Type, Floor, Size, Lease Rate. **ASSUMPTION**
- **Relationships:** child of Property. Deal.Space looks up to Availability. MarketSpace inquiries link to Availability. **VERIFIED [H-newdeal][S-inq]**
- **Stacking plan:** availabilities appear yellow by default. **VERIFIED-snippet [S-stack]**
- **Automation:** deal close sets the status to Closed, through a configurable static mapping. **VERIFIED [H-dealavail]**
- Related objects named but not described: **Unit** and **Unit Profile**. **VERIFIED [H-names]**
- **ASSUMPTION:** availability type (Direct, Sublease), date available, asking rate and rate type, min and max divisible SF, space use.

### Module 7: Inquiry Management (requirements and prospect matching)
- **Purpose:** an unqualified lead or indication of interest, arriving by phone, email, portal or web form. It is either about a listed space, or a general buying or leasing criterion with no listing. **VERIFIED [H-inq-what][H-connect][H-glossary]**
- **Types:** Lease and Sale Inquiries. **VERIFIED [H-inq-mgmt]**
- **Fields:**
  - Contact and Company info; Broker Company and Broker Contact. **VERIFIED [H-inq-what]**, **VERIFIED-snippet [S-inq]**
  - Preferences: Price Min/Max, space requirements, property type requirements, required move-in or purchase date. **VERIFIED [H-inq-what]**
  - Listing lookup. **VERIFIED [H-prosplist]**
- **Prospective Listings:** many Listings per Inquiry. Fields: Status, Primary (one only) and Description (255 characters). Managed in an editable grid. **VERIFIED [H-multilist]**
- **Convert Inquiry:**
  - Creates an Account, Contact and Deal, and keeps preference data.
  - Custom fields are not carried over.
  - The listing for the deal is chosen at conversion (Primary by default, or "--None--"), with a warning if that listing is on another active deal.
  - A Connections tab shows the created records.

  **VERIFIED [H-multilist][H-inq-what]**, **VERIFIED-snippet [S-inq]**
- **Disqualification:** a disqualify dialog, used from Active Inquiries. **VERIFIED [RN-116]**, **VERIFIED-snippet**
- **Web-to-Inquiry:** the Admin Console Web Form Generator builds an HTML form on an Experience site, using the guest user and the `ascendix.RestController` Apex class. Dates must be yyyy-MM-dd, and Time and DateTime fields are not supported. **VERIFIED [H-web2inq][H-limits]**
- **Matching:** **no automatic requirement-to-availability matching engine is documented.** Matching is done by searching and filtering with Ascendix Search. An AI Agent "Tenant Rep – Lease Expiration Alert" finds contacts with a lease preference whose lease expires within 180 days. **VERIFIED-snippet**. Our own matching engine would be an **ASSUMPTION / design opportunity**.

### Module 8: Capital Sources (lenders, investors, loans)
- **Purpose:** Capital Markets deals put a property financing transaction in front of several lenders. **VERIFIED [H-cm-def]**
- **Deal Source:** each record is a capital source interested in lending on the deal, used by mortgage brokers. It has the field `ascendix__CapitalSource__c`, a lookup to Capital Source. It is managed in an editable grid on the record page "AscendixRE Deal - Capital Markets". **VERIFIED [H-dealsrc][H-capsrc]**
- **Capital Source object:** the lender or capital provider master. Admins can hide it. **VERIFIED [H-capsrc]**
- **Term Sheet (1.39):** a related list on Deal Source. Fields: Term Sheet Name, Capital Source, Quote Day, Lender Name. A comparison tab shows all term sheets on a deal side by side, and they also appear on the client's page. **VERIFIED [H-termsheet][H-dealsrc]**
- **Multiple Properties (1.40):** a checkbox reveals a Deal Properties tab, backed by the Deal Property object. Report on Deal Properties, not Property. **VERIFIED [H-multiprop]**
- Other fields: Lender and Lender Contact on Seller Rep and Buyer Rep deals; a Financing deal record type. **VERIFIED [H-lite][H-close]**
- **Not documented:** a Loan object (amount, rate, maturity), investor criteria, debt/equity types. **ASSUMPTION** for our build.

### Module 9: Commission Calculations
- **Deal-level fee:**
  - Gross Deal Value: total rent over the term for leases, or the sale price.
  - Gross Fee Method: Percent, Amount, or By $ per SF.
  - Gross Fee Percent; Gross Fee Amount. For the per-SF method, Amount = Size × Fee Rate per SF.
  - Validation `VALDealGrossFeeRatePerUOM` requires Size and Rate.
  - The per-SF method applies to Landlord Rep and Tenant Rep only.

  **VERIFIED [H-comm][H-psf]**
- **Commission object** (child of Deal, from the Commissions related list). Record types:
  - Inside Broker: User, Fee Percent (broker), Fee Percent (House).
  - Analyst and Co-Broker: Account, Contact, Fee Method, Fee Percent.
  - Expense: Fee Method, Fee Percent.

  Other fields: Description, Direct Expenses, Gross Commission, Net Commission, House, Status (privacy). **VERIFIED [H-comm][H-cust-logic][H-privacy]**
- **Bulk mode:** up to 30 commissions of one type at once, in a grid. **VERIFIED [H-multicomm]**
- **Dialog customization:**
  - Field sets named `CommissionFields_<RecordType>`, for example `CommissionFields_Inside_Broker`. Maximum 10 fields; no multi-select picklist, rich text or parent fields.
  - Custom logic through the field set `Commission_Trigger_Fields` and the Autolaunched Flow `Commission_Trigger`, which takes a `commission` record variable. Example: set Fee Percent and Direct Expenses for each broker.
  - Commission logic can be disabled entirely.

  **VERIFIED [H-custdialog][H-cust-logic][H-limits][H-config-index]**
- **Validations:**
  - Broker splits may not exceed 100% (Analyst, Co-Broker, Expense).
  - Inside Broker fee percents must total 100%, and at least one Inside Broker is required (disabled by default).

  **VERIFIED [H-split100][H-ibval][RN-127]**
- **Commission Privacy:**
  - A one-way toggle in Admin Console > Accounting.
  - Brokers see only their own Gross Commission. Admins and holders of the `ascendix.Commission Privacy Admin` permission see Net and House.
  - Implemented through Commission Privacy records, with reassignment for inactive users.

  **VERIFIED [H-privacy]**
- **Marketing claims:** tiered payouts and house plans, mid-year changes, lease-term splits, referral deductions, and invoice, payment, voucher and payout visibility. **VERIFIED [AX]**, **VERIFIED-snippet [S-comm]**
- **Payment schedules and installments are not documented in the help center.** **ASSUMPTION** for our build: Commission Payment (installment) child records with due date, amount, status (Invoiced, Paid) and an invoice number.

### Module 10: Stacking Plans
- **Purpose:** a visual of tenants and vacant space by floor within a property. **VERIFIED [H-stack]**
- **Configuration:** enabled by default for the Office Property record type. Add other record type API names in the Custom Metadata "Stacking Plan" record. **VERIFIED [H-stackcfg][RN-127]**
- **Data:** number of floors and average floor size on the Property build the skeleton. Leases and availabilities then fill it. **VERIFIED-snippet [S-stack]**
- **Visuals:**
  - Availabilities are yellow by default.
  - Leases are color-coded by lease expiration date, with a legend under an "LXD" label.
  - Numeric formatting was improved in 1.18.

  **VERIFIED-snippet [S-stack]**, **VERIFIED [RN-118]**
- **Export:** PDF and Excel. **VERIFIED [AX]**
- **Limits:** Safari cross-site cookie issues; may not work in Classic. **VERIFIED [H-limits]**
- **ASSUMPTION:** click a block to open the lease or availability, filter by expiration year, and drag and drop is probably not supported. None of this is documented.

### Module 11: Property Search and Mapping
- **Global search** and Scan Search Filters on records. **VERIFIED [H-ways]**
- **Ascendix Search (add-on):**
  - Map providers: OpenStreetMap (default) or Google Maps (API key and Map ID).
  - Draw circle, rectangle or polygon shapes; search the visible area or a drawn shape with "Filter by Map"; take measurements.
  - Customizable pins (color, shape, size) and admin-defined popups.
  - Map features rely on Salesforce geocoding for Accounts, Contacts and Leads, plus custom objects.

  **VERIFIED [H-map]**
  - Radius search, a range option, OR / NOT IN conditions, expanded operators. **VERIFIED [H-search-index]**
  - Saved, shared and deleted searches; pin an object or saved search; search via charts; hover-over map preview. **VERIFIED [H-search-index]**
  - Ad-Hoc Lists: static, private by default, shareable with Read or Read/Write access. **VERIFIED [H-adhoc]**
- **Bulk operations:**
  - Mass update: 2,000 records.
  - Bulk notes: 2,000. Bulk events, tasks and calls: 500 each.
  - Follow and unfollow.
  - Mass email: 150 per send, with templates.
  - Add to campaign; export to Excel.
  - Mailchimp campaigns and statistics.

  **VERIFIED [H-bulk][H-search-index]**
- Composer can be launched from Search. **VERIFIED [H-search-index]**
- Property map on the record page. **VERIFIED [H-propintro]**

### Module 12: Dashboards and Reports
- Uses standard Salesforce Reports and Dashboards: charts, graphs, funnels. The help center has articles on accessing, running and creating them. **VERIFIED [H-glossary][H-dash][H-reporting]**
- Reporting note: to report on deal properties, use the Deal Properties object. **VERIFIED [H-multiprop]**
- Scorecards (record-level roll-up KPIs). Lease Comp Report through Composer. **VERIFIED [H-scorecard][H-leasecomp]**
- Inquiries support "foot traffic" reporting for listings. **VERIFIED [H-inq-what]**
- **Names of prebuilt reports and dashboards are not published.** **ASSUMPTION** for our build: Pipeline by Stage, Lease Expirations by Year, Commissions by Broker, Inquiries by Listing, Availabilities by Property, Closed Deals YTD.

### Module 13: Document Generation (Composer)
- Composer is a brochure and report generator for Salesforce and Dynamics. **VERIFIED [H-composer][H-compover]**
  - Outputs: PDF (through an editable intermediate "Publication"), HTML email (Mailchimp), and microsite (ZIP of landing pages).
  - Templates can be built from scratch or from defaults, in US and EU paper sizes.
  - Data is pulled dynamically, with rules for inclusion and order.
  - Maps with amenity icons; automatic table of contents; bulk generation.
- Use cases: property tour books (generate and send to contacts), flyers, activity reports, Lease Comp Reports. **VERIFIED [AX][H-tourbook][H-leasecomp]**
- Composer AI (AI Suite) produces branded PDFs from live data. **VERIFIED [AX]**

### Module 14: Activity Tracking and Follow-ups
- Standard Salesforce Tasks, Events, Calendar, Notes and Chatter. Quick actions on every core record: log call, new task, new appointment, send email. **VERIFIED [H-glossary][H-propintro]**
- A "most recent note" can be shown on the record. Field tracking and audit is supported. **VERIFIED [H-config-index]**
- **Automation:**
  - Automated follow-up sequences on Contact. **VERIFIED [H-followup]**
  - Lease expiration reminder Flow at 18, 12 and 6 months. **VERIFIED [H-leaseexp]**
  - Workflow-generated drip tasks (30-60-90 day), which can be turned off. **VERIFIED [H-prospects][H-cust-index]**
  - Email notifications. **VERIFIED [H-config-index]**
- **Bulk activity creation and call lists** through Ascendix Search. **VERIFIED [H-bulk][H-prospects]**
- **Harvest** (AI Suite) captures deal emails automatically. **VERIFIED [AX]**

---

## 3. Other platform patterns worth copying (VERIFIED)

- **Auto-naming of records** through the "Object Name Mapping" custom metadata. **VERIFIED [H-names]**
  - Covered objects: Availability, Commission, Deal, Deal Period, Inquiry, Lease, Lease Period, Listing, Market Rent, Sale, Unit, Unit Profile.
  - Attributes: Source Attributes (field list), Format (for example `{0} - {1}`), Overwrite, Date, Number and Currency Format, Default String Value, Is Active.
- **Object Field Mapping engine** in the Admin Console: source object to target object, optionally scoped by record type, with static or dynamic field mappings. Drives deal-close record creation. **VERIFIED [H-listmap][H-dealavail]**
- **Automation and validation toggles** in `AutomationSetting__mdt`, scoped by record type. Named settings: `AUTOLeaseRentTableFromDeal`, `VALDealRentTableReview`, `VALLeaseRentTableReview`, `VALDealPeriodRentRequired`, `VALLeasePeriodRentRequired`, `VALDealGrossFeeRatePerUOM`. **VERIFIED [H-rentcfg][H-psf]**
- **Bypass custom setting** `BypassValidationRules__c` for data loads. **VERIFIED [H-rentcfg]**
- Other utilities: a "Copy From" feature driven by FieldSets; a configurable System of Measurement (SF or sq m); localization; time zone. **VERIFIED [H-config-index]**

---

## 4. Gaps: what could not be found publicly
- `ascendix__` API names for core objects and most fields (only `ascendix__CapitalSource__c`, `GrossFeeRatePerUOM__c`, `DealPeriod__c`, `LeasePeriod__c`, `SaleDate__c`, `SalePrice__c` and `BypassValidationRules__c` are published).
- Picklist values for Deal Stage, Lease Type, Property Type and Class, Availability Status (other than Closed), Rent Type, and Inquiry Status.
- Commission payment schedules and installments.
- Loan and investor objects (Capital Markets is lender-quote oriented).
- An automated inquiry-to-availability matching engine.
- Names of prebuilt reports and dashboards.
- Stacking plan color thresholds and interactions.
- Field-level detail for Unit, Unit Profile, Market Rent and Offer.

---

## Sources
- [AX] AppExchange listing: https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3000000B5eloEAB
- [H-glossary] https://help.ascendix.com/app-menu-glossary
- [H-connect] https://ascendix.helpjuice.com/en_US/getting-started/how-all-the-data-connects
- [H-propvslist] https://help.ascendix.com/en_US/ascendixre-faq/what%E2%80%99s-the-difference-between-a-property-and-a-listing
- [H-propintro] https://help.ascendix.com/en_US/getting-started/properties-intro
- [H-availintro] https://help.ascendix.com/en_US/getting-started/availabilities-intro
- [H-leaseintro] https://help.ascendix.com/en_US/getting-started/leases-intro
- [H-listintro] https://help.ascendix.com/en_US/getting-started/listings-intro
- [H-dealintro] https://help.ascendix.com/en_US/getting-started/deals-overview
- [H-acctcont] https://help.ascendix.com/en_US/getting-started/accounts-contacts
- [H-dealwhat] https://help.ascendix.com/en_US/deals/what%E2%80%99s-a-deal-why-create-one
- [H-newdeal] https://help.ascendix.com/en_US/deals/adding-new-deals
- [H-autopop] https://help.ascendix.com/en_US/deals/-client-field-auto-population
- [H-close] https://help.ascendix.com/en_US/deal-closing-process
- [H-prospects] https://help.ascendix.com/en_US/deals/how-do-i-track-prospects-make-call-lists-follow-ups-etc
- [H-comm] https://help.ascendix.com/en_US/commissions/adding-commissions
- [H-multicomm] https://help.ascendix.com/en_US/commissions/adding-multiple-commission-records
- [H-custdialog] https://help.ascendix.com/en_US/configuration-admin/how-to-customize-commission-dialog-with-new-fields
- [H-cust-logic] https://help.ascendix.com/en_US/configuration-admin/how-to-create-custom-logic-on-the-commission-dialog
- [H-privacy] https://help.ascendix.com/en_US/configuration-admin/how-to-enable-commission-privacy-
- [H-split100] https://help.ascendix.com/en_US/configuration-admin/preventing-users-from-entering-more-than-100-commission-splits-between-brokers
- [H-ibval] https://help.ascendix.com/en_US/configuration-admin/how-to-set-up-the-inside-broker-validation-rules-disabled-by-default-
- [H-psf] https://help.ascendix.com/en_US/configuration-admin/configuring-the-per-square-foot-gross-fee-method
- [H-renttable] https://help.ascendix.com/en_US/rent-tables-/how-to-use-rent-tables-on-deals-and-leases-
- [H-renttotal] https://help.ascendix.com/en_US/rent-tables-/total-rent-calculation-on-rent-table-in-ascendix-re
- [H-rentcfg] https://help.ascendix.com/en_US/configuration-admin/configuring-rent-table-inheritance-and-validation-settings
- [H-addtodeal] https://help.ascendix.com/en_US/rent-tables-/user-guide-adding-a-contact-to-a-deal-via-add-to-deal
- [H-listmap] https://help.ascendix.com/en_US/object-configurations/configure-object-field-mapping-for-listing-pursuit-deal-record-type-
- [H-dealavail] https://help.ascendix.com/en_US/object-configurations/how-configure-themapping-between-deal-and-availability-deal-close-logic
- [H-prepop] https://help.ascendix.com/en_US/listings/prepopulating-listing-fields-from-property
- [H-multilist] https://help.ascendix.com/en_US/listings/how-to-add-multiple-listings-to-an-inquiry
- [H-prosplist] https://help.ascendix.com/en_US/properties/prospective-listings-%E2%80%93-auto-update-the-listings-grid-after-changing-inquirys-listing-field
- [H-inq-what] https://help.ascendix.com/faqs/what%E2%80%99s-an-inquiry
- [H-inq-mgmt] https://help.ascendix.com/en_US/inquiries/inquiry-management-with-ascendixre-crm
- [H-web2inq] https://help.ascendix.com/en_US/configuration-admin/1705711-how-to-configure-web-to-inquiry
- [H-cm-def] https://help.ascendix.com/en_US/capital-markets/capital-markets-deal-defined-
- [H-cm-index] https://help.ascendix.com/en_US/capital-markets
- [H-dealsrc] https://help.ascendix.com/en_US/capital-markets/capital-market-deal-sources-management-
- [H-capsrc] https://help.ascendix.com/en_US/configuration-admin/removing-capital-source-object-from-ui
- [H-termsheet] https://help.ascendix.com/en_US/configuration-admin/capital-market-term-sheet-object-enablement-
- [H-multiprop] https://help.ascendix.com/en_US/capital-markets/capital-market-how-to-enable-multiple-properties-on-the-deal-
- [H-stack] https://help.ascendix.com/en_US/properties/1160683-ascendixre-stacking-plan-overview
- [H-stackcfg] https://help.ascendix.com/en_US/configuration-admin/stacking-plan-configuration-
- [H-leaseexp] https://help.ascendix.com/en_US/configuration-admin/how-to-enable-lease-expiration-reminders-
- [H-leasecomp] https://help.ascendix.com/en_US/leases/generating-a-lease-comp-report
- [H-followup] https://help.ascendix.com/en_US/contacts-/how-to-enable-reminders-for-the-follow-ups-to-the-clients
- [H-reltypes] https://help.ascendix.com/en_US/fas-admin/how-to-add-relationship-types
- [H-reltgrid] https://help.ascendix.com/en_US/configuration-admin/relationship-grid-for-custom-objects
- [H-names] https://help.ascendix.com/en_US/configuration-admin/learn-how-to-configure-the-format-of-auto-populated-record-names-in-ascendixre-
- [H-scorecard] https://help.ascendix.com/en_US/configuration-admin/how-to-add-the-scorecard-configuration-component-to-the-lightning-record-page-
- [H-imgviewer] https://help.ascendix.com/en_US/configuration-admin/how-to-enable-the-image-viewer
- [H-config-index] https://help.ascendix.com/en_US/configuration-admin
- [H-cust-index] https://help.ascendix.com/en_US/customization-admin
- [H-limits] https://help.ascendix.com/en_US/ascendixre-limitations
- [H-lite] https://help.ascendix.com/en_US/ascendixre-user-guide/getting-started-with-the-ascendix-lite-app
- [H-ways] https://help.ascendix.com/en_US/csearch/1160558-ways-to-search
- [H-map] https://help.ascendix.com/en_US/search-search/map-search
- [H-search-index] https://help.ascendix.com/en_US/search-search
- [H-bulk] https://help.ascendix.com/en_US/data-search/mass-update-bulk-operations
- [H-adhoc] https://help.ascendix.com/en_US/search-search/ad-hoc-lists
- [H-composer] https://help.ascendix.com/en_US/composer
- [H-compover] https://help.ascendix.com/en_US/composer/product-overview
- [H-tourbook] https://help.ascendix.com/en_US/composer/generating-and-sending-property-tour-books-%7C-ascendixre-crm
- [H-dash] https://help.ascendix.com/en_US/dashboard
- [H-reporting] https://help.ascendix.com/en_US/reporting-admin
- [RN-116] https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-116
- [RN-118] https://help.ascendix.com/en_US/whats-new-in-ascendixre/whats-new-in-ascendixre-118
- [RN-127] https://help.ascendix.com/en_US/whats-new-in-ascendixre/1619416-what-s-new-in-ascendixre-1-27
- [S-stack] search snippets of https://ascendix.com/blog/stacking-plan-software/ (page itself returned 403)
- [S-comm] search snippets of https://ascendix.com/cre-commission-tracking-software-ascendixre/ and related commission blog posts (403)
- [S-inq] search snippets of https://ascendix.com/blog/commercial-real-estate-leads-inquiries/ and the MarketSpace pages (403)
- [S-deal] search snippets of https://ascendix.com/blog/salesforce-workflows-for-commercial-real-estate-brokers/ (403)
