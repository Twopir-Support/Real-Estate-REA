# Proposed Architecture and Implementation Plan

Status: **AWAITING APPROVAL.** Nothing has been deployed to `REA-Dev` yet.

Inputs:
- [00_Org_Assessment.md](00_Org_Assessment.md)
- [AscendixRE_Functional_Analysis.md](AscendixRE_Functional_Analysis.md)
- [Salesforce_Data_Model.md](Salesforce_Data_Model.md)
- [Salesforce_ERD.md](Salesforce_ERD.md)

## 1. Decisions to approve

| # | Decision | Recommendation | Alternative |
|---|---|---|---|
| D1 | Where CRE deals live | **Custom `Deal__c`**, so the 578 SDO Opportunities, their stages, record types and Rewind trigger stay untouched | Opportunity with a new "CRE Deal" record type and sales process. It shares Forecasting, but risks clashing with the SDO demo. |
| D2 | Stacking plan storage | **No object.** The LWC builds it live from Units + Leases. | A `Stacking_Plan__c` snapshot object |
| D3 | Objects added beyond the brief | **Add** `Lease_Period__c` (rent table), `Sale__c` (sale history), and the junctions `Inquiry_Match__c` and `Deal_Party__c`. All four match documented AscendixRE features. | Leave them out and accept gaps in the comparison |
| D4 | Charts in the LWC dashboards | **Our own lightweight SVG chart component.** No external library to download. | Chart.js as a static resource (downloaded from a CDN) |
| D5 | Maps | **The base `lightning-map` component** (no licence needed) plus radius search in Apex. Salesforce Maps is left as an optional extra. | Build on the Salesforce Maps package |
| D6 | Document generation | **Visualforce PDF templates** saved as Files: Property Flyer, Lease Comp Report, Deal / Commission Statement | Document Builder (only 5 licences) |
| D7 | Object_Field_Inventory.xlsx | Generate it with Node + the `exceljs` npm package. That's a dev-only dependency: `npm install`, not added to the org. | Ship a CSV instead |
| D8 | Naming | `REA_` prefix on Apex, Flows, permission sets and the app; `rea` prefix on LWCs. Object API names stay unprefixed (`Property__c`), as the brief asked. | – |

## 2. Solution architecture

```mermaid
flowchart TB
    subgraph UI[Lightning UI · App "REA Commercial Real Estate"]
        HOME[REA Home page<br/>reaPropertyDashboard]
        REC[Record pages<br/>reaPropertyDetail · reaStackingPlan<br/>reaAvailabilityManager · reaLeaseManager<br/>reaListingManager · reaInquiryMatches]
        APP[App pages<br/>reaDealPipeline · reaPropertySearch<br/>reaCommissionDashboard]
        QA[Quick Actions<br/>Close Deal · Convert Inquiry · Find Matches<br/>Generate Rent Schedule · Generate PDF]
    end
    subgraph APEX[Apex · with sharing · USER_MODE data access]
        CTRL[LWC controllers<br/>REA_*Controller]
        SVC[Services<br/>REA_DealService · REA_CommissionService<br/>REA_LeaseService/Calculator · REA_InquiryMatchService<br/>REA_InquiryConversionService · REA_PropertyRollupService<br/>REA_ListingService]
        TRG[One trigger per object → REA_TriggerHandler<br/>bypass through the REA_Automation_Settings__c custom setting]
    end
    subgraph AUTO[Declarative]
        FLOW[Record-triggered Flows<br/>Scheduled Flows]
        VR[Validation rules · Formulas · Roll-ups]
        EMAIL[Email templates + alerts]
    end
    DATA[(14 custom objects + Account/Contact/Task/Event/Files)]
    UI --> CTRL --> SVC --> DATA
    TRG --> SVC
    FLOW --> DATA
    VR --> DATA
```

**Engineering standards** (per the brief and Salesforce best practice):
- **Triggers.** One trigger per object containing no logic. It calls a handler,
  which delegates to stateless, bulk-safe service classes (collections in, no
  SOQL or DML in loops) with a recursion guard.
- **Security:**
  - Controllers are `with sharing`.
  - SOQL uses `WITH USER_MODE`; DML uses `AccessLevel.USER_MODE` or
    `Security.stripInaccessible`.
  - Trigger roll-ups that write to parent records the user may not own run in a
    narrowly scoped `without sharing` inner class, with that choice documented.
- **No hard-coded IDs.** Configuration lives in custom metadata
  `REA_Stage_Setting__mdt`: stage → default probability, and stage → automatic
  Task.
- **Kill switch.** The `REA_Automation_Settings__c` hierarchy custom setting
  turns automation off for data loads (`Bypass_Triggers__c`,
  `Bypass_Validation__c`). This mirrors Ascendix's documented bypass setting.

## 3. Build inventory

### 3.1 Data layer
- 14 custom objects and about 210 custom fields, including 6 on Account and
  Contact.
- About 30 validation rules, about 25 formula fields, and 9 roll-up summaries
  where master-detail allows.
- Tabs, compact layouts, page layouts and list views for the new objects only.
  Existing layouts aren't changed.
- Custom report types: Properties with Units, Deals with Commissions, Leases
  with Periods, Inquiries with Matches, Listings with Availabilities.

### 3.2 Apex
| Class | Responsibility |
|---|---|
| `REA_TriggerHandler` | Base handler: context routing, bypass, recursion guard |
| `REA_PropertyRollupService` | Leased SF, Available SF, Active Listings and Avg Asking Rent onto Property; Portfolio SF and Leased SF onto Account |
| `REA_PropertyUnitService` | Unit status, current tenant and current lease sync |
| `REA_LeaseCalculator` | Term, escalated rent schedule, total lease value (annual-ratio method) |
| `REA_LeaseService` | Defaults (landlord from owner), active-lease overlap check per unit, rent-schedule generation, status transitions |
| `REA_DealCalculator` | Transaction value by deal type (escalated lease consideration, sale price, loan amount) |
| `REA_DealService` | Defaults (client role, lead broker, probability by stage), **Close Deal** processing: create Lease + rent schedule / Sale / Listing, close the Availability, set the actual close date |
| `REA_CommissionService` | Gross fee (Percent / Amount / $ per SF), split recalculation, house share, ≤100% enforcement, status on close |
| `REA_InquiryMatchService` | Scores available spaces against an inquiry (type, SF band, rent cap, city/submarket, date) and creates `Inquiry_Match__c` rows; one Primary |
| `REA_InquiryConversionService` | Converts an Inquiry to a Deal (plus the Account when missing) and carries the Primary match to the Deal |
| `REA_ListingService` | Defaults copied from the Property; Total Available SF |
| `REA_PropertySearchController` | Filtered and radius search (`DISTANCE`/`GEOLOCATION` SOQL), saved criteria |
| `REA_StackingPlanController` | Floor → unit → lease/availability structure |
| `REA_DashboardController` | KPI aggregates for the property and commission dashboards (aggregate SOQL, cacheable) |
| `REA_PipelineController` | Kanban data and stage updates |
| `REA_DocumentController` + 3 VF pages | Property Flyer, Lease Comp Report, Deal Commission Statement; save as a File |
| `REA_InvocableActions` | Flow-callable wrappers (Find Matches, Generate Rent Schedule) |
| `REA_TestDataFactory` + about 14 test classes | Positive, negative, bulk (200 records), and permission tests (`System.runAs` a Broker user) |

### 3.3 Lightning Web Components
| LWC | Placement | Function |
|---|---|---|
| `reaPropertyDashboard` | REA Home | KPIs: portfolio SF, occupancy, available SF, active listings, pipeline, weighted fees, expiring leases. Charts: occupancy by type, pipeline by stage, expirations by year. Filters: market, type, broker. |
| `reaPropertyDetail` | Property page | Hero card with photo, key stats, occupancy gauge, location map, quick links |
| `reaStackingPlan` | Property page | Floors × units in proportion to SF; colour by status and expiration year; legend; filter; click-through |
| `reaAvailabilityManager` | Property and Listing pages | Editable datatable of spaces, add space, status quick-change |
| `reaLeaseManager` | Property and Lease pages | Rent roll for the property, expiration buckets, rent-schedule view, Generate Schedule |
| `reaListingManager` | Listings app page | Card or list of listings with status filters, days on market, expiring soon |
| `reaDealPipeline` | Deals app page | Kanban by stage with drag-and-drop, stage totals (SF, fee, weighted), filters by type and broker |
| `reaPropertySearch` | Search app page | Criteria panel, radius search, results table, map markers |
| `reaCommissionDashboard` | Commissions app page | Gross/net/house by broker, projected vs earned vs paid, upcoming due |
| `reaInquiryMatches` | Inquiry page | Find Matches, scored results, set primary, Convert to Deal |
| `reaChart`, `reaKpiTile`, `reaUtils` | shared | SVG bar/donut/column charts, KPI tile, formatting and error helpers |

### 3.4 Automation
| Item | Type | Behaviour |
|---|---|---|
| `REA_Inquiry_New_Follow_Up` | Record-triggered Flow (after insert) | Task "Follow up on inquiry", due in 1 business day, assigned to the owner |
| `REA_Deal_Stage_Change_Tasks` | Record-triggered Flow (after update) | Stage-based Tasks (e.g. Proposal/LOI → "Send LOI to client"; Under Contract → "Collect executed documents"); Closed Won → email alert to the lead broker |
| `REA_Lease_Expiration_Reminders` | Scheduled Flow (daily) | Tasks at 18, 12 and 6 months before expiration (matching Ascendix's documented thresholds) + email alert at 6 months |
| `REA_Listing_Expiration` | Scheduled Flow (daily) | Task 30 days before the agreement expires; status → Expired after the expiration date |
| `REA_Inquiry_Stale_Reminder` | Scheduled Flow (daily) | Open inquiries with no activity for 14 days → Task |
| `REA_Lease_Status_Sweep` | Scheduled Apex (daily) | Active → Expired after the expiration date, so unit and property roll-ups recalculate |
| Email templates and alerts | Classic Lightning templates | Lease Expiring, Deal Closed Won, Inquiry Assigned |

### 3.5 App and security
- **Lightning app** "REA Commercial Real Estate". Navigation: Home, Properties,
  Listings, Availabilities, Inquiries, Deals, Leases, Sales, Commissions,
  Capital Sources, Accounts, Contacts, Property Search, Deal Pipeline,
  Commission Dashboard, Reports, Dashboards.
- **Lightning record pages** for each object, activated as app defaults only.
  Org defaults and the SDO apps aren't touched.
- **Permission sets:**
  - `REA_CRE_Admin`: full access, including House/Net commission fields and
    plans.
  - `REA_CRE_Broker`: create/edit on operational objects, read-only on
    Commission Plans, no House/Net fields.
  - Both are assigned to the running admin user.

## 4. Phased delivery

Every phase is followed by a GitHub commit.

| Phase | Content | Org action | Gate |
|---|---|---|---|
| P1 | Objects, fields, VRs, tabs, layouts, permission sets, custom setting and metadata | `deploy validate` → `deploy quick`; assign permission sets | Describe check of every object and field |
| P2 | Apex services, triggers, controllers, tests | Validate with `RunSpecifiedTests` (REA tests only); deploy | All REA tests pass; ≥85% coverage per class |
| P3 | LWCs, VF pages, quick actions, record/app/home pages, the app | Validate → deploy | Pages render and are reachable from the App Launcher |
| P4 | Flows, email templates and alerts, scheduled jobs | Validate → deploy (Flows active) → schedule the Apex job | Flow tests and debug runs on sample records |
| P5 | Report types, reports, dashboard | Deploy | Reports return the sample data |
| P6 | Sample data (Apex script under `scripts/apex`) | Run against the org | Record counts and relationship checks; end-to-end process walk-through |
| P7 | Final documentation set and AscendixRE comparison | – | – |

**Safety rules for every deploy:**
- Manifest-scoped: `manifest/package-P*.xml` lists only `REA` components and the
  new objects, plus the 6 new fields on Account and Contact.
- No `destructiveChanges`.
- Never `RunLocalTests`: the 327 SDO classes aren't ours.
- Before each deploy, `sf project deploy preview` confirms only "Add"
  operations, apart from our own earlier components.

## 5. Sample data (P6)

| Data | Planned volume |
|---|---|
| Accounts | ~20: tenants, landlords/owners, buyers, sellers, 3 lenders/investors, 2 outside brokerages; flagged by `CRE_Roles__c` |
| Contacts | ~35 |
| Properties | 12: 4 office (Class A/B, with floors and units), 3 retail, 3 industrial, 1 flex, 1 land, spread over Dallas, Austin and Houston with geolocation |
| Units | ~60 across the office and retail buildings |
| Leases | ~30, with rent schedules |
| Availabilities | ~20 |
| Listings | 8 |
| Inquiries | 15, with matches |
| Deals | 20, across every stage and type |
| Deal Parties | ~45 |
| Commissions | ~35 |
| Commission Plans | 3 |
| Capital Sources | 4 |
| Sales | 6 |

All sample records carry the marker `REA Sample` in a description field, and a
cleanup script is provided, so the sample set can be removed without touching
SDO data.

## 6. Testing approach

- **Apex:** every service gets positive, negative and bulk tests.
  - Negative examples: splits over 100%, overlapping active leases, a closed-won
    deal edited by a broker, $ per SF on a sale deal, a Lost deal with no
    reason.
  - Permission tests run as a Broker user.
  - Target ≥85% per class, without coverage-only tests.
- **LWC:** manual walk-through on sample data. Jest tests for the calculation
  and formatting utils, if Node tooling is approved (D7).
- **Flows:** debug runs plus Apex tests that assert the Tasks the Flows create.

## 7. Risks

| Risk | Mitigation |
|---|---|
| Trial org expires 2026-12-13 | GitHub is the source of truth; the deploy is repeatable from the manifests |
| Existing SDO triggers on Account, Contact, Task and Event fire during our DML | Tests create these records through normal paths. Any SDO trigger failure is documented, not modified. |
| Multi-currency | Calculations stay in the deal's currency. Cross-currency roll-ups use the corporate currency (a documented limitation). |
| Scale of the build | Phased delivery. Each phase is validated and committed before the next starts. |

## 8. Out of scope (recorded in Known_Limitations.md)

- Web-to-Inquiry form (needs an Experience site).
- Polygon map drawing, ad-hoc lists, mass email and Mailchimp.
- Capital Markets Deal Source and Term Sheet.
- Tiered commission plans and payment installments.
- WYSIWYG document designer, microsites and bulk tour books.
- Stacking-plan Excel export.
- Contact follow-up drip sequences.
- Listing-portal (MarketSpace) integrations.
- AI Suite features.
- These deal types: Asset Management, Lease Administration, Project Management,
  Property Management.
