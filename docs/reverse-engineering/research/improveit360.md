# improveit 360 — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

> Research note. The vendor runs two public Zendesk help centers: **support.improveit360.com** (the older "Classic" product, managed-package namespace `i360__`) and **i360lightning.zendesk.com** (the current "improveit 360 Lightning" product, namespace `i360core__`). Most of the detail below comes from the Lightning help center, read through its public Zendesk Help Center JSON API (`/api/v2/help_center/...`) because the HTML pages returned 403. The two generations have **different data models**: Classic is built around a custom `Prospect` object, while Lightning uses standard Account/Contact plus custom Sales Opportunity, Sales Appointment, Sale and Project objects. This file describes **Lightning** unless it says "Classic".

---

## 0. Identity and status

| Item | Value | Label | Source |
|---|---|---|---|
| Product name | improveit 360 (also styled "improveit! 360", "i360") | Verified | [S1][S7] |
| Current product generation | "improveit 360 Lightning", a Lightning managed package; release v1.43 is "Summer 2026", created 2026-06-23 and updated 2026-11-09 | Verified | [S32] |
| Publisher / legal entity | improveit 360 (Improveit! 360 LLC per Crunchbase) | Verified (vendor) / third party (entity name) | [S3][S7] |
| Parent company | **EverCommerce** (Nasdaq: EVCM). The vendor's own "LLM Info" page, last updated June 2026, says "Parent company: EverCommerce" | Verified | [S3] |
| Ownership history | Origin: designed in 2000 by a large ("Big 500") remodeler and replacement contractor [S2]. PitchBook says the company was formerly PE-backed and previously known as **Enovation Solutions** [S8]. **Acquired by EverCommerce, announced 2017-03-01**, terms undisclosed [S7][S8]. No later divestiture found: EverCommerce sold its fitness business in early 2025 and its marketing-technology unit (EverConnect) to Ignite Visibility in Oct 2025, and neither deal covered improveit 360 [S48]. | Verified (vendor: origin, parent) / third party (deal date) | [S2][S3][S7][S8][S48] |
| HQ | 4249 Easton Way, Columbus, OH 43219, USA; phone (866) 421-3360 | Verified | [S1][S3] |
| Founded | The vendor says "Over 23 years in the home improvement industry" [S1] and that the system was designed "back in 2000" [S2]. CB Insights lists 2000; Capterra lists 1999. | Verified (vendor wording) / third party | [S1][S2][S9] |
| Salesforce relationship | "Salesforce partner since 2009" [S2]. Salesforce **OEM partner**: the glossary says improveit 360 "cannot use the native Leads, Opportunities, or Cases objects as an OEM partner" [S14]. The site's Login link goes to login.salesforce.com [S1]. | Verified | [S2][S14][S1] |
| Native vs integrated | **Native on Salesforce today.** It is a managed package (`i360core__` namespace) running in a Salesforce org, with Apex triggers, LWC, Aura and Flows [S13][S31]. Marketing copy says "Now on Lightning" [S1]. | Verified | [S1][S13][S31] |
| AppExchange listing | **Not found.** Searches turned up no public AppExchange listing. It is sold direct as an OEM bundle with the Salesforce licence. | Unknown (Inferred: OEM-distributed, not marketplace-listed) | — |
| Status | **Active.** There are 2026 releases (v1.40 Feb 2026, v1.43 Summer 2026), and the LLM-info page was updated June 2026. | Verified | [S31][S32][S3] |
| Scale claim | "More than 15,000 contractors use improveit 360" (homepage). The Why-us page says "thousands of users". | Verified (vendor claim, unaudited) | [S1][S2] |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| G2 | 4.6/5, 13 reviews | 4.6/5 (2026-11-12, **search-engine snippet**; direct fetch of g2.com returned 403) | 13 | https://www.g2.com/products/improveit-360/reviews | Matches the supplied value. The snippet also says the G2 profile has not been managed by the vendor for over a year. |
| Capterra | — | 3.7/5 (2026-11-12, search snippet; direct fetch returned 403) | 19 | https://capterra.com/p/130645/improveit-360/reviews/ | Ease of Use sub-score 3.3/5 per snippet. Capterra lists the founding year as 1999. |
| GetApp | — | 3.7/5 (snippet, same Gartner Digital Markets data as Capterra) | 19 | https://www.getapp.com/construction-software/a/improveit-360 | Snippet lists a "starting price US$125.00, per feature" and says "does not have an API available". The API point is contradicted by vendor docs (REST eLead endpoint, Vendo/OneClick APIs) [S30][S33]. |
| AppExchange | — | Not listed / not found | — | — | No listing found. See §0. |

## 2. Overview (12 questions)

1. **What it is**: an enterprise CRM and business-management system for home-improvement, remodeling and replacement contractors, covering leads through sales, production, payments and reporting. Verified [S1][S3].
2. **Developer**: improveit 360, an EverCommerce company (Columbus, OH). Verified [S3].
3. **Industry**: residential home improvement (windows, siding, roofing, baths, remodeling), including franchises and dealer networks. Verified [S2][S3]. The Permit Type values (Roofing, Siding, Electrical, Plumbing, Building) also reflect this. Verified [S30].
4. **Target users**: owners, marketing managers, call-center appointment setters, schedulers and dispatchers, in-home sales reps, sales managers, production and project managers, installers and subcontractors (as Staff), and finance/commission admins. Verified for setters, dispatchers, sales reps and production managers [S25][S20][S22]. The rest is Inferred from objects such as Commission and Payment [S14].
5. **Problems solved**: lead-source ROI ("closed-loop marketing"), speed to appointment, appointment resulting discipline, quote-to-sale conversion, production scheduling, deposit and payment collection, and KPI visibility. Verified [S1][S17][S40].
6. **Major functions**: CRM and lead management; marketing status and lifecycle automation; appointment scheduling; online invoicing and payments; project management; homeowner financing; lending; sales tools and quoting; marketing and call centers; BI and reporting. Verified (vendor module list) [S1][S3].
7. **Differentiators**: built by a remodeler; home-improvement vocabulary (Rehash, Reset, One Leg, Demoed, Net); closed-loop lead-source cost ROI; Time Block capacity scheduling; integrations with industry estimating tools (Vendo, OneClick Contractor, SalesPro/Leap). Verified [S2][S17][S19][S5].
8. **Native / integrated**: Salesforce-native managed package distributed under an OEM agreement. Verified [S14][S13].
9. **Editions / licences**: Salesforce licences are bundled under the OEM agreement (Inferred from "OEM partner" [S14]). Extra admin user licences are bought from improveit 360 (Verified [S33]). The help center references profiles "i360 Admin Profile" and "Production Manager Profile" [S32][S22]. Exact Salesforce licence type (Platform vs Sales Cloud): Unknown.
10. **Pricing**: not published. The pricing page is a "GET PRICING" form [S4]. GetApp snippet: from US$125 "per feature" [S12]. Treat as Unknown.
11. **Managed / unmanaged**: managed package. "Protected Custom Settings" are visible only to the OEM partner, and namespace-prefixed Apex (`i360core.`) exists. Verified [S26][S33][S34].
12. **Limitations & dependencies**: cannot use standard Lead, Opportunity or Case objects [S14]. Commission tracking "is manual" out of the box [S37]. Sale Status values should not be modified because it "will result in inefficient List Views" [S16]. Un-resulting an appointment deletes the downstream Sale, Project, Receipts and Adjustments (Classic) [S41]. Integrations depend on Protected Settings enabled by vendor support [S26]. Verified.

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| eLead intake (web-to-eLead, email-to-eLead, REST endpoint) | Receives leads from providers (HomeAdvisor/Angi, Zapier, Think Unlimited, ActiveProspect). Maps JSON to eLead fields, optionally geocodes, and can **auto-convert** to Account, Contact, Sales Opportunity and Sales Appointment. | Marketing, integrations | eLead: name, address, phone/email, Source, Text Opt Out, Conversion Issue | Account, Contact, Inquiry, Sales Opportunity, Sales Appointment | Before: lead provider. After: Sales Opportunity, Inquiry | Verified | [S13][S14][S35][S44] |
| Quick Lead | Manual lead-entry tool for a new Account/Contact plus Sales Opportunity (fields driven by field sets). Sets Marketing Status "New Leads". | Call center / setters | Account, Contact, Address, Sales Opportunity | Inquiry (optional) | After: appointment setting | Verified | [S17][S28][S29] |
| Inquiry (call center) | One record per inbound inquiry that aggregates all interests. Has a quick action to schedule an appointment and a Status field (added v1.40). | Call center (Five9, Regal) | Interests, Lead Source Name, Taken On, contact/address data, Most Recent Appointment Date, Quoted Amount | Sales Opportunity, Sales Appointment, Task | Optional layer | Verified | [S28][S30][S31] |
| Marketing / Lead Source & cost | Lead Source (campaign) with Source and Source Type hierarchy, plus Lead Source Cost for ROI | Marketing | Lead Source, Source, Source Type, Cost | Sales Opportunity | Feeds ROI reports | Verified | [S14] |
| Marketing Status automation | Rule engine that sets Account Marketing Status from Opportunity Result, Appointment Status or Sale Status | System, marketing | Marketing Status, Marketing Status Date | Account | Throughout lifecycle | Verified | [S17] |
| Appointment scheduling | Staff Calendar (drag-select rep and time), Scheduling Calendar, Time Block Calendar, Staff Work Week view | Setters, schedulers | Sales Appointment date/time, Sales Rep 1/2, Type, Set By/On, Assigned By/On | Time Block, Staff, Event | After: confirmation, then dispatch | Verified | [S18][S25][S30][S13] |
| Time Blocks & Dispatcher | Capacity- or staff-availability-based blocks by product category, weekday and territory. Dispatcher assigns reps to unassigned appointments. | Managers, dispatchers | Time Block: Department, Territory, Capacity, Availability, Scheduled | Sales Appointment, Project Activity | Between setting and running | Verified | [S25][S27][S26] |
| Territories | Geographic territory auto-assigned to Address by weighted City/County/State/Zip | Admin | Territory, weights | Address, then Time Blocks | Setup | Verified | [S14][S26][S13] |
| In-home sales & Resulting | Result wizard on the Sales Appointment: Status, Status Detail, Result, Result Detail, then the next action (schedule, no action, task, create sale) | Sales reps, managers | Appointment Status/Detail, Opportunity Result/Detail, counts (Issued, Demoed) | Quote, Sale, Task | After appointment | Verified | [S18][S19][S20] |
| Quoting | Quote and Quote Items, Quote Templates and Template Items, "Create Quote" quick action, Import Quote | Sales reps | Quote, products, prices | Sales Appointment, Sale, Job Material | Accepted quote becomes the Sale | Verified | [S14][S30][S31] |
| Third-party estimating | Vendo, OneClick Contractor, SalesPro (Leap) and Acorn quote; results posted back via Apex REST | Sales reps | Status/Result, Total Price Quoted, contract docs | Sales Appointment, Sales Opportunity, Sale | Replaces in-app resulting | Verified | [S21][S30][S32][S33][S5] |
| Sale / contract | Sale and Sale Items, Status lifecycle (In Review → Approved/Not Approved → Net → Complete), Canceled record type | Sales managers, office | Status, Status Detail, dates (Sold/Approved/Net/Complete/Canceled On), tax rate | Project, Payment, Loan, Commission | After: production | Verified | [S16][S14][S13] |
| Financing & lending | Loan (child of Sale) and Loan Options from Lender Accounts | Sales, finance | Loan Option, Type, Interest Rate, borrower/co-borrower | Sale, Account (Lender) | During sale | Verified | [S14][S13] |
| Project / production ("Production 2.0") | Project from Sale (Master-Detail), Project Templates that create Project Activities, Gantt, completion %, permits | Production managers | Project status (formula), Activities (Start/End, Completed, Canceled, On Hold), Project Manager | Sale, Staff, Task/Event, Permit, Job Material, Project Cost | After: completion | Verified | [S23][S24][S30][S31][S15] |
| Crew / installer scheduling | Project Activities scheduled on the Staff/Scheduling Calendar to Staff (users or subcontractors). Staff Capabilities control who appears. | Production schedulers | Project Activity Assigned To, Start/End, Duration (working hours/days) | Staff, Time Block, Event | — | Verified | [S13][S14][S30] |
| Materials & job costing | Material (inventory on hand), Job Material from Quote/Sale Items, Project Costs (labor, materials, permits, commission) | Production, finance | Material Cost, Quantity On Hand, Project Cost Type/Amount | Product, Project, Sale | — | Verified | [S13][S14] |
| Payments | Payment (Sale required, Project optional), Payment Links (hosted payments, PaySimple), mobile payment collection | Office, reps | Amount, Type, Do Not Apply, link delivery | Sale, Project | — | Verified | [S13][S14][S32][S1] |
| Commissions | Commission per Staff on Sale/Project, plus Commission Adjustment (payments, bonuses, deductions). Manual out of the box. | Finance | Commission Amount, Ready to Pay, Adjusted, Paid | Staff, Sale, Project | Post-sale | Verified | [S36][S37] |
| Customer communication | Two-way texting via Twilio (Inbound/Outbound Text), templated email with ICS calendar invite, automated reminders, GuildQuality surveys | Office, system | Text bodies, statuses, SID | Account, Contact | Whole lifecycle | Verified | [S13][S31][S32][S4] |
| Files / photos | File Manager component on record pages; CompanyCam integration | All | Files | Account, Project | — | Verified | [S34][S5] |
| Reporting & dashboards | KPI dashboards per user, scheduled reports, appointment count fields | Managers | Counts and amounts | All | — | Verified | [S1][S19][S4] |

## 4. Data model

Namespace prefixes: **Lightning `i360core__`** is Verified from field API names `i360core__First_Name__c`, `i360core__Last_Name__c` and `i360core__Source__c` [S35] and Apex `i360core.OneClickResultApi` and `i360core.FileManagerController` [S33][S34]. **Classic `i360__`** is Verified from `i360__Prospect__c`, `i360__Result__c` and `i360__Result_Detail__c` [S38][S39]. The vendor publishes a full object/field schema as a downloadable Excel attachment ("as of June 2025") [S14][S15]. It was **not downloaded** (instruction: do not download files), so most object API names below are `Proposed:` and follow the `i360core__<Label_With_Underscores>__c` convention.

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields (labels; Verified) | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Account | `Account` | Standard | Customer, vendor or lender household/org. Record types **Vendor**, **Customer**. | Primary Contact, Contact Email, Not Qualified Reasons, Marketing Status, Marketing Status Date | — | Contact, Address, Sales Opportunity, Sales Appointment, Sale, Inquiry, Loan Option (as Lender) | Verified | [S14][S13][S17] |
| Contact | `Contact` | Standard | Person on an Account; lookup, re-parentable | Email, Text Opt Out, Text Opt Out Date | Account (lookup) | — | Verified | [S14][S15][S13] |
| Address | Proposed: `i360core__Address__c` | Custom | Job/property location. Required for Sales Appointment, Sale and Project. | Street, City, County, State/Province, Zip, Territory, Geolocation Status, Verification Status/Error, Time Zone, UTC Offset, DST | Account (lookup, optional) | Sales Appointment, Sale, Project | Verified (object/fields) / Proposed (API) | [S14][S13][S15] |
| Territory | Proposed: `i360core__Territory__c` | Custom | Geographic division auto-assigned to Address | weights in custom settings | — | Address, Time Block | Verified / Proposed | [S14][S26] |
| eLead | Proposed: `i360core__eLead__c` | Custom | Inbound third-party lead staging; auto-convert | First/Last Name (`i360core__First_Name__c`, `i360core__Last_Name__c`), Source (`i360core__Source__c`), address, Text Opt Out, eLead Conversion Issue, lookups to Account, Contact, Inquiry, Sales Appointment, Sales Opportunity | — | — | Verified (3 field API names) / Proposed (object API) | [S35][S13] |
| eLead JSON Mapping | Unknown (tab "eLead Endpoint JSON Mapping") | Config | Maps provider JSON keys to eLead fields | Name, API Name, key path | — | — | Verified (tab) | [S35] |
| Inquiry | Proposed: `i360core__Inquiry__c` | Custom | Call-center inquiry aggregating all interests | Account, Contact, Interested In, Lead Source, Taken By/On, Not Qualified, Status (v1.40) | Account | Task | Verified / Proposed | [S28][S13][S31] |
| Lead Source | Proposed: `i360core__Lead_Source__c` | Custom | Marketing campaign / source attribution | Source, Source Type (global picklist), Territory | — | Lead Source Cost, Sales Opportunity | Verified / Proposed | [S14] |
| Lead Source Cost | Proposed: `i360core__Lead_Source_Cost__c` | Custom | Marketing spend for ROI | amount, period | Lead Source | — | Verified / Proposed | [S14] |
| Sales Opportunity | Proposed: `i360core__Sales_Opportunity__c` | Custom | **One product interest** per inquiry (replaces standard Opportunity). Lead Source, Interested In and Taken On are required. | Result, Result Detail, Interested In, Lead Source, Source, Source Type, Taken By, Taken On, Sale, Address, Most Recent Appointment Date, Most Recent Sales Appointment | Account | Sales Appointment Opportunity, Task, Think Unlimited Lead Score | Verified / Proposed | [S14][S13] |
| Sales Appointment | Proposed: `i360core__Sales_Appointment__c` | Custom | In-home sales visit. Account, Address and Type are required. | Appointment Date/Time, End Date/Time, Type, Status, Status Detail, Sales Rep 1, Sales Rep 2, Set By/On, Assigned By/On, Confirmed On, Previous Appointment, Inquiry, Most Recent Sales Opportunity, Most Recent Lead Source, Sale Total, Sale Item Total, Sold, Vendo External Id, local time fields | Account, Address | Sales Appointment Opportunity, Quote, Event | Verified / Proposed | [S14][S13][S18][S19] |
| Sales Appointment Opportunity | Proposed: `i360core__Sales_Appointment_Opportunity__c` | Junction | Links appointments and opportunities (many-to-many: one visit can pitch several interests) | Sales Appointment, Sales Opportunity | Sales Appointment, Sales Opportunity | — | Verified (object exists) / Proposed | [S13] |
| Time Block | Proposed: `i360core__Time_Block__c` | Custom | Scheduling capacity window. Record types **Capacity Scheduling**, **Staff Availability**. | Name, Department, Start/End Date/Time, Territory, Capacity, Availability, Scheduled, Staff | Staff (for availability) | Sales Appointment, Project Activity | Verified / Proposed | [S25][S30][S31] |
| Staff | Proposed: `i360core__Staff__c` | Custom | Internal staff, optionally a User; subcontractors allowed. Staff Name and Start Date are required. | Create User, Email, Start Date, capabilities | User (optional) | Commission, Time Block, Permit (Ordered By) | Verified / Proposed | [S14][S13][S37] |
| Product | Proposed: `i360core__Product__c` (custom, not standard Product2: Unknown) | Custom (Inferred) | Catalog with SKU and cost. Product Category is required. | Product Category, SKU, cost | — | Quote Item, Sale Item | Verified (object) / Unknown (std vs custom) | [S14] |
| Quote | Proposed: `i360core__Quote__c` | Custom (glossary lists it among custom managed objects) | Estimate, optionally tied to a Sales Appointment | Search Text, totals | Sales Appointment (optional) | Quote Item, Job Material | Verified / Proposed | [S14][S13] |
| Quote Item | Proposed: `i360core__Quote_Item__c` | Custom | Quote line | Quote, Product, Quantity | Quote | — | Verified / Proposed | [S13] |
| Quote Template / Quote Template Item | Proposed: `i360core__Quote_Template__c` / `i360core__Quote_Template_Item__c` (release notes print "Quote Template c") | Config | Predefined product sets | Quote Template, Product | — | — | Verified / Proposed | [S14][S31] |
| Sale | Proposed: `i360core__Sale__c` | Custom | Signed contract. Status is required. Record types: standard and **Canceled**. | Status, Status Detail, Sold On, Approved On, Not Approved On, In Review On, Net On, Canceled On, Complete On, Sales Tax Rate, Product Categories, Most Recent Payment Link, Sales Rep 1/2 Email | Account | Sale Item, Project (MD), Payment (MD), Loan, Commission | Verified / Proposed | [S14][S16][S13] |
| Sale Item | Proposed: `i360core__Sale_Item__c` | Custom | Products sold | Sale, Product, Type, Staff, Quantity, Unit Price, Taxable | Sale | Permit (lookup), Job Material | Verified / Proposed | [S13][S30] |
| Loan | Proposed: `i360core__Loan__c` | Custom | Financing on a Sale | Loan Option, Type, Interest Rate, borrower/co-borrower | Sale | — | Verified / Proposed | [S14][S13] |
| Loan Option | Proposed: `i360core__Loan_Option__c` | Config | Lender product. Lender (Account) is required. | Lender, Type, Interest Rate | Account (Lender) | Loan | Verified / Proposed | [S14] |
| Payment | Proposed: `i360core__Payment__c` | Custom (**Master-Detail to Sale**) | Payment or discount. Amount, Type and Sale are required. | Amount, Type, Do Not Apply, Project | Sale (MD), Project (lookup) | — | Verified | [S14][S15][S13] |
| Payment Link | Proposed: `i360core__Payment_Link__c` | Custom | Hosted payment link sent by email/text | Link, Delivery Method, Delivery Error, Email, Phone, Project, Sale | Sale, Project | — | Verified / Proposed | [S13][S31][S32] |
| Webhook Event | Proposed: `i360core__Webhook_Event__c` | Custom (integration log) | Inbound payment and Twilio webhooks | Type, JSON Payload | — | — | Verified / Proposed | [S13] |
| Project | Proposed: `i360core__Project__c` | Custom (**Master-Detail to Sale**) | Production job | Status (formula, not customisable), Project Manager, Start Date, Project Price, Total Payments Received, Product Categories, Project's Name ("Contact Full Name : Product Category"), Most Recent Payment Link | Sale (MD) | Project Activity, Project Cost, Permit, Job Material, Payment | Verified / Proposed | [S14][S15][S23][S24][S13] |
| Project Activity | Proposed: `i360core__Project_Activity__c` | Custom | Production step, either a Task or an Appointment (on the Staff Calendar) | Name, Step, Start, End, Duration (Working Hours/Days), Assigned To, Completed/On, Canceled/On, On Hold, Activity Status (formula), Completion Status | Project | Event, Task | Verified / Proposed | [S14][S13][S23][S24] |
| Project Template | Proposed: `i360core__Project_Template__c` | Config | Reusable set of steps, usually per Product Category | Name | — | Project Template Activity | Verified / Proposed | [S14][S30] |
| Project Template Activity | Proposed: `i360core__Project_Template_Activity__c` | Config | Templated step with dependencies. Name and Step are required. | Step, dependency, duration | Project Template | — | Verified / Proposed | [S14] |
| Project Cost | Proposed: `i360core__Project_Cost__c` | Custom | Job-cost entries. Type and Amount are required. | Project, Amount, Incurred On, Category, Description, Memo | Project | — | Verified / Proposed | [S14][S13] |
| Permit (v1.25) | Proposed: `i360core__Permit__c` | Custom | Permit tracking | Project (lookup, required), Sale Item, Ordered By (Staff), Permit Number, Submitted/Received/Closed dates, Permit Type, Permit Status, Comments | Project | — | Verified / Proposed | [S30] |
| Material | Proposed: `i360core__Material__c` | Custom | Inventory item | Quantity On Hand, cost | — | Job Material | Verified / Proposed | [S13] |
| Job Material | Proposed: `i360core__Job_Material__c` | Custom | Materials consumed per Project/Sale/Quote | Estimated Material Cost, Material Cost, Material, Material Quantity, Project, Sale, Quote, Product | Project/Sale/Quote | — | Verified / Proposed | [S13] |
| Commission | Proposed: `i360core__Commission__c` | Custom | Staff commission on Sale/Project | Commission Amount, Ready to Pay, Adjusted Amount, Amount Paid to Staff | Staff, Sale/Project | Commission Adjustment | Verified / Proposed | [S36] |
| Commission Adjustment | Proposed: `i360core__Commission_Adjustment__c` | Custom | Payment, bonus or deduction | Type, Type Detail (dependent), Amount | Commission | — | Verified / Proposed | [S36] |
| Inbound Text / Outbound Text | Proposed: `i360core__Inbound_Text__c` / `i360core__Outbound_Text__c` | Custom | SMS log (Twilio) | To/From Number, Body, Status, Message SID, Read, Error Message | Account, Contact | — | Verified / Proposed | [S13][S14] |
| Marketing Status Rule | Unknown (`Proposed: i360core__Marketing_Status_Rule__c`) | Config | "When X status → set Marketing Status Y" | Section, primary value, detail value, target Marketing Status, Inquiry Status | — | — | Verified (object) / Proposed | [S17] |
| Think Unlimited Lead Score | Proposed: `i360core__Think_Unlimited_Lead_Score__c` | Integration | Lead score exchange | Lead Score, Acknowledged/On, Acknowledgment Id, Request Payload, Response Error | Sales Opportunity | — | Verified / Proposed | [S13] |
| Task / Event / Files / Notes | `Task`, `Event`, `ContentDocument`, Notes | Standard | Follow-ups, calendar sync, documents | Event Sync Generated (custom on Event) | any | — | Verified | [S14][S13] |
| Custom settings | Names (labels): Marketing Settings (hierarchy), Scheduling Settings, Trigger Settings, Protected Settings, "Enable Vendo Integration", "Vendo Sale Creation", "Show Calendar Distance" | Config | Feature toggles | — | — | — | Verified (labels) | [S17][S26][S27][S28][S30] |
| **Classic** Prospect | `i360__Prospect__c` | Custom (Classic) | Customer/household record in the Classic data model | Phone 1 etc. | — | Appointment, Interest (Unknown), Sale, Project | Verified (API) | [S38] |
| **Classic** Appointment | Unknown (fields `i360__Result__c`, `i360__Result_Detail__c` verified) | Custom (Classic) | Sales appointment with Result | Result, Result Detail | Prospect | Sale, Marketing Opportunity | Verified (fields) | [S39][S43] |
| **Classic** Marketing Opportunity, Sale Items, Receipts, Adjustments | Unknown | Custom (Classic) | Classic equivalents of the opportunity/payment objects | — | — | — | Verified (names only) | [S41][S43] |

**Relationships (verified)** [S15][S14][S13]:
- Project → Sale: **Master-Detail** (a Project cannot exist without a Sale). Verified [S15].
- Payment → Sale: **Master-Detail**. Verified [S15].
- Address → Account and Contact → Account: **Lookup**, re-parentable, may be blank. Verified [S15].
- Sales Appointment ↔ Sales Opportunity: **many-to-many via Sales Appointment Opportunity**. Verified [S13].
- Loan is a "child of Sale"; Lead Source Cost is a "child of Lead Source"; Project Template Activity sits under Project Template; Commission Adjustment sits under Commission; Quote Template Item sits under Quote Template. Verified [S14][S36]. Lookup vs master-detail is Unknown.
- Permit: Project (Lookup, required), Sale Item (Lookup), Ordered By (Lookup → Staff). Verified [S30].

**Record types**: Account (Vendor, Customer); Sale (standard, Canceled); Time Block (Capacity Scheduling, Staff Availability). Verified [S14][S25][S31].

**Picklists (verified values)**:
- *Marketing Status* (global picklist `Marketing_Status`): Confirmed, Dead, New eLead, New Leads, Past Customers, Pending Confirmation, Rehash, Reset (customisable) [S17].
- *Sales Appointment Status*: **Ran** is the only value documented [S18][S19]. Other Status values (for example a not-ran status) are Unknown.
- *Sales Appointment Status Detail* (under Ran): Sold; Demoed, Not Sold; Follow-up; No Show; Not Demoed; One Leg; Canceled [S18][S19].
- *Sales Appointment Type*: Reset, Follow-up (customisable; others Unknown) [S18].
- *Sales Opportunity Result*: Sold, Not Sold [S18]. Vendo mapping also uses "Lost" and "Pending" [S21].
- *Sales Opportunity Result Detail* (Not Sold): Demoed and Quoted, Rehash, Follow-up. "Demoed Not Quoted" also appears [S18][S21].
- *Sale Status*: In Review (default), Approved, Not Approved, Net, Complete. "Canceled" is handled through the Canceled record type and Canceled On date [S16][S13][S20]. *Status Detail* examples: Approved for Production, Approved for Service [S16][S20].
- *Project Status* (Production 2.0, formula): Not Started, In Progress, Completed, Canceled [S23]. Older/custom values seen: Active, Installed, Pending [S22].
- *Project Activity Status* (formula): Not Started, Not Started - Late, In Progress, In Progress - Late, On Hold, Completed, Canceled [S23]. *Completion Status*: Incomplete, Early, On Time, Late [S24].
- *Permit Type*: Roofing, Siding, Electrical, Plumbing, Building. *Permit Status*: Prepared, Applied, Received, Canceled [S30].
- *Commission Adjustment Type / Type Detail*: e.g. Payment / Staff Payment [S36].
- *Task Type*: "Sales Opportunity Rehash" [S18].

**Formulas / roll-ups / validation (verified)**: Project Status and Project Activity Status are formulas driven by the Sale Canceled On date and Activity Status Max/Min [S23][S24]. Project "Total Payments Received" is recalculated by trigger [S13]. A Sales Tax formula with ROUND was fixed in v1.43 [S32]. A validation rule hides Lead Source Name from Sales Rep users [S30]. A Flow blocks reverting Project Status from Completed (exempting the Production Manager Profile) [S22]. Appointment count checkboxes are set by Flows [S19]. External IDs: Vendo External Id on Sales Appointment [S13]. Hatch uses an External ID match [S45].

**ERD edge list**
```
Account -> Contact (lookup) [Verified]
Account -> Address (lookup) [Verified]
Territory -> Address (lookup) [Verified object; field Inferred]
Account -> Inquiry (lookup) [Verified]
Account -> Sales Opportunity (lookup) [Verified]
Lead Source -> Sales Opportunity (lookup) [Verified]
Lead Source -> Lead Source Cost (child) [Verified]
eLead -> Account/Contact/Inquiry/Sales Opportunity/Sales Appointment (lookup, set on conversion) [Verified]
Account -> Sales Appointment (lookup) [Verified]
Address -> Sales Appointment (lookup, required) [Verified]
Sales Appointment -> Sales Appointment Opportunity <- Sales Opportunity (junction) [Verified]
Sales Appointment -> Sales Appointment (Previous Appointment, self lookup) [Verified]
Time Block -> Sales Appointment / Project Activity (lookup) [Inferred: "Scheduled" updated by trigger]
Staff -> Sales Appointment (Sales Rep 1 / Sales Rep 2 lookups) [Verified fields]
Sales Appointment -> Quote (lookup, optional) [Verified]
Quote -> Quote Item (child) [Verified]
Quote Template -> Quote Template Item (child) [Verified]
Account -> Sale (lookup) [Verified]
Sales Opportunity -> Sale (Sale lookup on Opportunity) [Verified]
Sale -> Sale Item (child) [Verified]
Sale -> Loan (child) [Verified]
Loan Option -> Loan (lookup) [Verified]
Sale -> Payment (MD) [Verified]
Sale -> Project (MD) [Verified]
Project -> Payment (lookup) [Verified]
Project -> Project Activity (child) [Verified]
Project Template -> Project Template Activity (child) [Verified]
Project -> Project Cost (child) [Verified]
Project -> Permit (lookup, required) [Verified]
Sale Item -> Permit (lookup) [Verified]
Material -> Job Material (lookup) [Verified]
Project/Sale/Quote -> Job Material (lookup) [Verified]
Staff -> Commission (lookup) ; Commission -> Commission Adjustment (child) [Verified]
Sale/Project -> Payment Link (lookup) [Verified]
Account/Contact -> Inbound Text / Outbound Text (lookup) [Verified]
Project Activity / Sales Appointment -> Event (WhatId) [Verified]
```

## 5. Technical components

**Apex triggers (Verified, 25 named)** [S13]: AccountTrigger, AddressTrigger, ContactTrigger, ContentDocumentTrigger, eLeadTrigger, EventTrigger, InboundTextTrigger, InquiryTrigger, JobMaterialTrigger, LoanTrigger, OutboundTextTrigger, PaymentLinkTrigger, PaymentTrigger, ProjectActivityTrigger, ProjectTrigger, QuoteItemTrigger, QuoteTrigger, SaleItemTrigger, SalesAppointmentOpportunityTrigger, SalesAppointmentTrigger, SalesOpportunityTrigger, SaleTrigger, StaffTrigger, TaskTrigger, ThinkUnlimitedLeadScoreTrigger, UserTrigger, WebhookEventTrigger.

**Apex classes (Verified names)**: `i360core.OneClickResultApi` [S33]; `i360core.FileManagerController`, `FileManagerControllerTest` [S34]; `VendoResultApi`, `VendoResultApiTest` [S30]; SecurityUtilities, VendoCanceledSalesAppointmentsQueueable, VendoSalesAppointmentsQueueable, VendoUtilities, CalendarController, EventTriggerUtilities, ProjectActivityTriggerUtilities, SalesAppointmentTriggerUtilities, TimeBlockController, WithoutSharingUtilities [S31]. Invocable: "Send Templated Email with Attached Calendar Invite" (input class `ICSFlowMethodInput`) [S31][S32]. An invocable method applies a Project Template to a Project (inputs Project Id, Project Template Id); its class name is Unknown [S30].

**Lightning Web Components (Verified)** [S31]: hoverFieldSetComponent, staffCalendarCalendar, staffCalendarContainer, createLoan, rescheduleSalesAppointment, datatableWithPagination, editInstalledQuantity, productionGantt, welcomeHubAnnouncements, quoteAndSaleItemCreate.
**Aura (Verified)** [S31]: eLeadConvertActionAura, importQuoteAura, createLoanAura, rescheduleAura, cloneProjectTemplateAura, cloneQuoteTemplateAura, editInstalledQuantityAura, quoteAndSaleItemCreateAura. There is also an Aura "Create Project Template Activity" component [S30].
**Static resource**: mobile-datatable-fix [S31].

**Flows (Verified names)**: "Sales Appointment Issued", "Sales Appointment Demoed" [S19]. A Project Status validation flow exists, name Unknown [S22]. Territory assignment to Accounts, Lead Sources or Staff "requires a Flow" (customer-built) [S14].

**Field sets (Verified)**: Staff Calendar Record Detail; Time Block Calendar Detail; Calendar Hover; Create Quote Item; Create Quote Template Item; Create Sale Item; Gantt Edit - General / Status / Dates; Gantt Hover; Item Card; Scheduling Calendar Event Tiles; Staff Calendar Event Tiles; Schedule Quick Action; Assign Materials to Products; Calendar (Staff); Task Related Panel [S30][S31][S32].

**Security**: Permission sets: Vendo, Minimum Access, Read Only, GuildQuality, Acorn, PaySimple Hosted Payments [S31][S32]. Custom permissions: Acorn, GuildQuality, Hosted Payments, Vendo [S32]. Profiles: i360 Admin Profile, Production Manager Profile [S32][S22]. Protected Custom Settings are editable only by the OEM partner via Grant Login Access [S26]. MFA physical key guidance exists [help article 44711584848919].

**Platform events / CDC (Verified)**: Content Document Change Event and Text Message Event are published by triggers [S13].

**Admin UI**: "Setup & Configuration" app page (User Setup, Calendar & Scheduling); "Merge Staff Records"; "Marketing Status Setup" tab [S32][S17].

## 6. Business processes

### P1. Lead-to-appointment (marketing intake and setting)
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

### P2. In-home sale and appointment resulting
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

### P3. Sale approval to production (project management)
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

### P4. Closed-loop marketing status (cross-cutting)
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

## 7. Automation table

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

## 8. UI / UX
- **App**: Lightning app. A "Welcome Hub" home page with announcements and GuildQuality components [S31][S32]. An App Launcher item opens Setup & Configuration and Merge Staff Records [S32].
- **Calendars**: Staff Calendar (staffCalendarContainer/staffCalendarCalendar), Scheduling Calendar, Time Block Calendar (capacity colours red/orange), Staff Work Week and Staff Day views, Dispatcher with clock icon for unassigned appointments, and distance display (can be toggled) [S25][S30][S31].
- **Record pages**: Sales Appointment with Result and Schedule quick actions, a Create Quote quick action and a hover field set; Inquiry with a schedule quick action; Project with Gantt (productionGantt), File Manager tab and Task Related Panel [S30][S31][S32][S34].
- **List views**: Sales by Status/Status Detail (e.g. "Approved for Production") [S16].
- **Mobile**: Salesforce mobile app with a mobile datatable fix and a mobile payments app [S31][S1]. The pricing page mentions mobile calendar syncing [S4].
- **Portals**: no customer portal documented (Unknown).
- **Public media (URLs only, not downloaded)**:
  - https://support.improveit360.com/hc/article_attachments/360058545253/improveit360_closed_looped.png: closed-loop marketing flow chart [S40].
  - https://i360lightning.zendesk.com/hc/article_attachments/17806800854295: Lightning Object Relationship Diagram image [S15].
  - https://support.improveit360.com/hc/en-us/articles/360052467574: Appointment Scheduling and Resulting Process Diagram (PDF attached).
  - https://support.improveit360.com/hc/en-us/articles/360036453554: Wistia video, "result an appointment as sold and create a sale" [S42].
  - https://support.improveit360.com/hc/en-us/articles/360036043053: video, resulting and creating a Marketing Opportunity (Classic) [S43].
  - https://i360lightning.zendesk.com/hc/en-us/articles/26334050050967: "Appointment Scheduling & Resulting" video set.
  - https://ace.easy-lms.com/appointment-scheduling-lightning/course-101374: vendor training course (LMS).

## 9. Reporting
- Dashboards tailored per user KPI; scheduled automated reports; emailing reports and dashboards and sharing folders [S1][S4][help 43940715613079]. Verified.
- KPIs from Sales Appointment count fields: Set, Confirmed / Not Confirmed, Ran, Issued, Demoed, Sold, Canceled. These give the set-to-issue, demo and closing ratios. Verified [S19].
- Lead Source / Lead Source Cost → cost per lead, cost per sale, marketing ROI. Verified [S14].
- Sale by Status (backlog: Approved/Net), Project completion %, Activity late flags, Total Payments Received / Balance Due, Commission owed. Verified objects [S16][S23][S13][S36]. Exact standard report names: Unknown. A blog post "Home improvement CRM reports guide" exists [S1].

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Lead providers (HomeAdvisor/Angi, etc.) | Lead intake | In | eLead JSON | Provider POST | eLead REST endpoint + JSON Mapping; Zapier | Verified | [S35] |
| ActiveProspect, Think Unlimited | Lead gen / scoring | In / Out | Leads, lead scores | Opportunity insert | Apex callout (ThinkUnlimitedLeadScoreTrigger) | Verified | [S5][S13] |
| EverConnect (sold to Ignite Visibility in 2025) | Marketing | Out | Marketing status | Status changes | Unknown | Verified (listed) | [S5][S48] |
| Vendo (Paradigm) | In-home estimating / resulting | Bi | Appointments out; results, Total Price Quoted, docs in | Appointment save; Vendo result | Apex queueables + Apex REST VendoResultApi | Verified | [S30][S31][S21] |
| OneClick Contractor | Estimating | Bi (results in; job status not back) | Appointments, results | Result in OCC | External Client App OAuth client-credentials; `i360core.OneClickResultApi` | Verified | [S33][S47] |
| SalesPro (Leap), Acorn | Estimating / quote | Bi (Inferred) | Quotes | — | Acorn component + custom permission | Verified (listed) | [S5][S32] |
| PandaDoc, CompanyCam, Siro, Calendly | Contracts, photos, call recording, scheduling | varies | — | — | Partner connectors | Verified (listed) | [S5] |
| Five9, RingCentral, Regal | Call center | Bi | Calls, Inquiry | — | AppExchange/partner; Regal via Flow → postEvents | Verified | [S5][S28] |
| Hatch | SMS/email campaigns | Bi, every 15 min | Opportunity, Appointment, Project; Notes/Tasks back | Hatch events | Hatch connector | Verified (third-party doc) | [S45] |
| Twilio | Two-way texting | Bi | Outbound/Inbound Text | Outbound Text insert; webhook | Apex callout + webhook | Verified | [S13] |
| PaySimple (Hosted Payments) | Card/ACH payments | Bi | Payment Links, payment webhooks | Payment Link insert; webhook | Apex + Webhook Event | Verified | [S13][S32] |
| GuildQuality | Customer surveys | Out | Survey triggers | Opp/Appt/Sale/Project changes | Apex | Verified | [S13][S32] |
| QuickBooks | Accounting | Out (Inferred) | Sales, payments | — | DBSync | Verified (listed) | [S5] |
| Address verification / geocoding | Address quality | Out | Address | Address save | Callout (provider Unknown) | Verified (function) | [S13] |
| SolutionView | Sales presentation app | Bi | Quote when "Pending", Sale when "Sold" | Appointment end | Partner | Verified (third party) | [S46] |
| SalesRabbit | Door-to-door canvassing | Out → i360 | Leads/appointments | — | Partner (page 403) | Observed (search title) | [S49] |

## 11. Limitations & what would be hard to recreate
- **Resulting wizard + dependent picklist matrix** (Status → Status Detail → Result → Result Detail → next action) with downstream record creation and destructive un-result semantics.
- **Time Block capacity scheduling** with territory/product-category filters, overcapacity colours and Dispatcher; custom LWC calendars with field-set-driven tiles.
- **Marketing Status rule engine** across three objects with hierarchy-setting precedence.
- **Production 2.0** formula status, Gantt, template dependencies and working-day durations.
- **Integration surface** (Vendo, OneClick, PaySimple, Twilio, GuildQuality, Think Unlimited) with protected settings controlled by the OEM.
- **Gaps**: Sales Appointment Status values other than "Ran", Inquiry Status values, exact object API names (in the undownloaded Excel schema), report/dashboard names, licence type and pricing, commission automation (client-specific), and the Classic-to-Lightning migration path and Classic sunset date are all Unknown.

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| S1 | improveit 360 home page | https://www.improveit360.com/home | vendor site | 2026-11-12 |
| S2 | Why improveit 360 | https://www.improveit360.com/why-us/ | vendor site | 2026-11-12 |
| S3 | Official Information About improveit 360 (LLM info) | https://www.improveit360.com/llm-info/ | vendor site | 2026-11-12 |
| S4 | Pricing | https://www.improveit360.com/pricing/ | vendor site | 2026-11-12 |
| S5 | Integrations | https://www.improveit360.com/integrations/ | vendor site | 2026-11-12 |
| S6 | Project Management feature | https://www.improveit360.com/features/project-management/ | vendor site | 2026-11-12 |
| S7 | EverCommerce acquires Improveit! 360 (2017-03-01) | https://www.crunchbase.com/acquisition/evercommerce-acquires-improveit-360--eb17f0f7 | third party (search snippet) | 2026-11-12 |
| S8 | Improveit! 360 company profile | https://pitchbook.com/profiles/company/93146-05 | third party (search snippet) | 2026-11-12 |
| S9 | improveit 360 profile | https://www.cbinsights.com/company/improveit-360 | third party (search snippet) | 2026-11-12 |
| S10 | G2 improveit 360 reviews | https://www.g2.com/products/improveit-360/reviews | review (snippet; 403 on fetch) | 2026-11-12 |
| S11 | Capterra improveit 360 reviews | https://capterra.com/p/130645/improveit-360/reviews/ | review (snippet; 403 on fetch) | 2026-11-12 |
| S12 | GetApp improveit 360 | https://www.getapp.com/construction-software/a/improveit-360 | review (snippet) | 2026-11-12 |
| S13 | Trigger Summaries and affected Objects and Fields (id 43938318720407) | https://i360lightning.zendesk.com/hc/en-us/articles/43938318720407 | help (Lightning) | 2026-11-12 |
| S14 | Glossary of Terms by Object (id 14139954090903) | https://i360lightning.zendesk.com/hc/en-us/articles/14139954090903 | help (Lightning) | 2026-11-12 |
| S15 | Object Relationship Diagram (id 17157646616471) | https://i360lightning.zendesk.com/hc/en-us/articles/17157646616471-Object-Relationship-Diagram | help (Lightning) | 2026-11-12 |
| S16 | Sale Status and Status Detail (id 16306465472279) | https://i360lightning.zendesk.com/hc/en-us/articles/16306465472279 | help (Lightning) | 2026-11-12 |
| S17 | Marketing Status and Marketing Status Rules (id 38686988745367) | https://i360lightning.zendesk.com/hc/en-us/articles/38686988745367 | help (Lightning) | 2026-11-12 |
| S18 | Rescheduling and Resulting Sales Appointments (id 15969138416279) | https://i360lightning.zendesk.com/hc/en-us/articles/15969138416279 | help (Lightning) | 2026-11-12 |
| S19 | Appointment Reporting Count Fields (id 23353079949207) | https://i360lightning.zendesk.com/hc/en-us/articles/23353079949207 | help (Lightning) | 2026-11-12 |
| S20 | Sales Manager Training (id 27948192315543) | https://i360lightning.zendesk.com/hc/en-us/articles/27948192315543 | help (Lightning; search API excerpt) | 2026-11-12 |
| S21 | Vendo Troubleshooting FAQs (id 36133688242327) | https://i360lightning.zendesk.com/hc/en-us/articles/36133688242327 | help (Lightning; search API excerpt) | 2026-11-12 |
| S22 | Project Status check for User Error (id 27826530359959) | https://i360lightning.zendesk.com/hc/en-us/articles/27826530359959 | help (Lightning; search API excerpt) | 2026-11-12 |
| S23 | Production 2.0 Project Status and Completion % (id 32405652900503) | https://i360lightning.zendesk.com/hc/en-us/articles/32405652900503 | help (Lightning; search API excerpt) | 2026-11-12 |
| S24 | Production 2.0 Setup (id 31614329502103) | https://i360lightning.zendesk.com/hc/en-us/articles/31614329502103 | help (Lightning; search API excerpt) | 2026-11-12 |
| S25 | Time Blocks (id 15690884483863) | https://i360lightning.zendesk.com/hc/en-us/articles/15690884483863 | help (Lightning) | 2026-11-12 |
| S26 | Custom Settings and Protected Settings (id 18363788986263) | https://i360lightning.zendesk.com/hc/en-us/articles/18363788986263 | help (Lightning) | 2026-11-12 |
| S27 | Enable and Disable Time Block Scheduling (id 17741141613719) | https://i360lightning.zendesk.com/hc/en-us/articles/17741141613719 | help (Lightning) | 2026-11-12 |
| S28 | The Inquiry object (id 28506355089303) | https://i360lightning.zendesk.com/hc/en-us/articles/28506355089303 | help (Lightning) | 2026-11-12 |
| S29 | Release Notes v1.21 (Winter 2024) (id 20331943826327) | https://i360lightning.zendesk.com/hc/en-us/articles/20331943826327 | release notes | 2026-11-12 |
| S30 | Release Notes v1.25 (id 22823863557655) | https://i360lightning.zendesk.com/hc/en-us/articles/22823863557655-Release-Notes-v1-25 | release notes | 2026-11-12 |
| S31 | Lightning Release v1.40 Technical Notes (id 38130601845655) | https://i360lightning.zendesk.com/hc/en-us/articles/38130601845655 | release notes | 2026-11-12 |
| S32 | Lightning Release v1.43 (Summer 2026) (id 41426893753239) | https://i360lightning.zendesk.com/hc/en-us/articles/41426893753239 | release notes | 2026-11-12 |
| S33 | One Click Contractor Integration Setup Guide (id 19620884534423) | https://i360lightning.zendesk.com/hc/en-us/articles/19620884534423 | help (search API excerpt) | 2026-11-12 |
| S34 | Configure the File Manager Component on a Record Page (id 18378164304151) | https://i360lightning.zendesk.com/hc/en-us/articles/18378164304151 | help (search API excerpt) | 2026-11-12 |
| S35 | eLead JSON Mapping Object Records (id 22521191847063) | https://i360lightning.zendesk.com/hc/en-us/articles/22521191847063-eLead-JSON-Mapping-Object-Records | help (Lightning) | 2026-11-12 |
| S36 | Using Commissions and Commission Adjustments (id 16585311448599) | https://i360lightning.zendesk.com/hc/en-us/articles/16585311448599 | help (search API excerpt) | 2026-11-12 |
| S37 | Example Commission Calculation Scenarios (id 38310922096919) | https://i360lightning.zendesk.com/hc/en-us/articles/38310922096919 | help (search API excerpt) | 2026-11-12 |
| S38 | Where do I find API information for improveit 360 Objects/Fields (Classic) | https://support.improveit360.com/hc/en-us/articles/4409779762839 | help (Classic) | 2026-11-12 |
| S39 | Validation Rule: Result Detail Required When Resulting Appointment (Classic) | https://support.improveit360.com/hc/en-us/articles/360058222433 | help (Classic) | 2026-11-12 |
| S40 | improveit 360 Sales and Closed-Loop Marketing Flow (Classic) | https://support.improveit360.com/hc/en-us/articles/360043353293 | help (Classic) | 2026-11-12 |
| S41 | Classic support excerpts: un-result warning; Add a second sale to Resulted Appointment | https://support.improveit360.com/hc/en-us/articles/4406123821335-Add-a-second-sale-to-Resulted-Appointment | help (Classic; search snippet) | 2026-11-12 |
| S42 | Result an Appointment as Sold (Classic, video) | https://support.improveit360.com/hc/en-us/articles/360036453554-Result-an-Appointment-as-Sold | help/video | 2026-11-12 |
| S43 | Video: Resulting an Appointment and Creating a Marketing Opportunity (Classic) | https://support.improveit360.com/hc/en-us/articles/360036043053 | help/video | 2026-11-12 |
| S44 | eLead Standard Field Mapping (Classic) | https://support.improveit360.com/hc/en-us/articles/360051591334-eLead-Standard-Field-Mapping | help (search snippet) | 2026-11-12 |
| S45 | Hatch: improveit360 (i360) Lightning integration | https://docs.usehatchapp.com/integrations/crm-field-management-systems/improveit360-i360-lightning.md | third party | 2026-11-12 |
| S46 | SolutionView: improveit 360 Terms and Definitions | https://help.solutionview.app/article/172-improveit-360-terms-and-definitions | third party | 2026-11-12 |
| S47 | OneClickContractor: ImproveIt360 Lightning Integration - Jobs (snippet; page 404 on fetch) | https://help.oneclickcontractor.com/knowledge/improveit360-lightning-integration-jobs | third party (snippet) | 2026-11-12 |
| S48 | EverCommerce Announces Sale of Its Marketing Technologies Solutions to Ignite Visibility (Oct 2025) | https://www.nasdaq.com/press-release/evercommerce-announces-sale-its-marketing-technologies-solutions-ignite-visibility | third party (press release) | 2026-11-12 |
| S49 | SalesRabbit: ImproveIt 360 Lightning (403 on fetch) | https://help.salesrabbit.com/hc/en-us/articles/39086730362775-ImproveIt-360-Lightning | third party | 2026-11-12 |
