# Architecture and Implementation Plan — TC Commercial Real Estate

**Status:** approved 2026-11-12. Building.
- **Scope:** mirror the AscendixRE structure as publicly documented.
- **Naming:** everything uses the `TC_` prefix.

The comparison with AscendixRE is in the "AscendixRE to TC Mapping" artifact and
in [AscendixRE_vs_TC_Comparison.md](AscendixRE_vs_TC_Comparison.md).

## 1. Decisions

| # | Decision |
|---|---|
| D1 | CRE deals live in the custom `TC_Deal__c` object, with 12 record types that mirror AscendixRE's business lines. The org's Opportunity object is left untouched. |
| D2 | There is no stacking-plan object. `tcStackingPlan` builds the plan live from Units, Leases and Availabilities, as AscendixRE does from floors, leases and availabilities. |
| D3 | Object structure follows AscendixRE: 21 objects, including Unit, Unit Profile, Deal and Lease Periods, Prospective Listing and Prospective Buyer, Offer, Deal Source, Term Sheet, Deal Property, Relationship and Market Rent. |
| D4 | Dashboard charts are drawn by our own SVG component. No external chart library is downloaded. |
| D5 | Maps use the base `lightning-map` component plus a radius search in Apex. |
| D6 | Documents are Visualforce PDFs, saved as Files. |
| D7 | Object_Field_Inventory.xlsx is generated with Node (`exceljs`, a dev-only dependency). |
| D8 | `TC_` prefix on every component. LWCs use `tc` because the platform requires a lowercase first letter. |
| D9 | The model is defined once in `scripts/model/tc-model.js`. `scripts/generate.js` emits the metadata, the data model doc and the field inventory from it. |

## 2. Configuration that mirrors the AscendixRE Admin Console

| AscendixRE feature | TC equivalent |
|---|---|
| `BypassValidationRules__c` | `TC_Bypass_Settings__c` (hierarchy setting). Every TC validation rule and trigger checks it. |
| `AutomationSetting__mdt` toggles | `TC_Automation_Setting__mdt`, with 8 records such as `TC_VAL_Inside_Broker_100`, which is off by default as in AscendixRE |
| Object Name Mapping | `TC_Object_Name_Mapping__mdt` + `TC_NamingService` |
| Object Field Mapping (deal close) | `TC_Object_Field_Mapping__mdt` + `TC_FieldMappingService` |
| Stacking Plan metadata record | `TC_Stacking_Plan_Setting__mdt` |
| Commission Privacy | Custom permission `TC_Commission_Privacy_Admin` plus field-level security (the Broker permission set can't see House or Net) |

## 3. Apex

| Class | Responsibility |
|---|---|
| `TC_TriggerHandler` | Base handler: context routing, bypass setting, recursion guard |
| `TC_Settings` | Cached access to the automation, stage, naming and mapping metadata |
| `TC_NamingService` | Builds record names from the name-format metadata |
| `TC_FieldMappingService` | Copies fields from a source record to a new target record using the mapping metadata |
| `TC_RentTableService` | Generates Deal and Lease Periods, calculates period rent (Annual Ratio Rent or Monthly Rate), copies a deal's rent table to its lease, flags gaps and overlaps |
| `TC_DealService` | Stage probability, client field auto-population, gross deal value and gross fee, Close Deal processing (creates the Lease, Sale or Listing and closes the Availability) |
| `TC_CommissionService` | Gross, house and net commission per record type; splits ≤ 100%; optional rule that inside-broker splits total 100%; status changes when the deal closes |
| `TC_LeaseService` | Landlord defaulting, unit occupancy sync, overlap check, status sweep |
| `TC_PropertyRollupService` | Leased SF, available SF, active listings and average asking rate on Property; portfolio SF on Account |
| `TC_ListingService` | Copies Property fields onto a new Listing; total available SF |
| `TC_InquiryService` | Convert to Account + Contact + Deal; Find Matches (TC extra); one Primary prospective listing |
| `TC_TermSheetService` | Copies the capital source and lender name onto each Term Sheet |
| Controllers | `TC_StackingPlanController`, `TC_PropertySearchController`, `TC_DashboardController`, `TC_PipelineController`, `TC_RentTableController`, `TC_CloseDealController`, `TC_DocumentController` |
| Scheduled | `TC_DailyScheduler`: lease status sweep and follow-up sequences |
| Tests | `TC_TestDataFactory`, plus one test class per service and controller (positive, negative, bulk and permission cases) |

## 4. Lightning Web Components

| LWC | Placement | AscendixRE counterpart |
|---|---|---|
| `tcPropertyDetail` | Property page | Property highlights, map, image |
| `tcImageViewer` | Property, Listing and Availability pages | Image Viewer |
| `tcStackingPlan` | Property page | Stacking Plan |
| `tcScorecard` | Record pages | Scorecard |
| `tcRentTable` | Deal and Lease pages | Rent Table grid |
| `tcCloseDeal` | Deal quick action | Close Deal dialog |
| `tcCommissionGrid` | Deal page | Commissions dialog and bulk entry |
| `tcConvertInquiry` | Inquiry quick action | Convert Inquiry |
| `tcInquiryMatches` | Inquiry page | Prospective Listings grid, plus TC matching |
| `tcTermSheetCompare` | Deal page | Term sheet comparison |
| `tcRelationshipGrid` | Record pages | Relationship Grid |
| `tcDealPipeline` | App page | Kanban pipeline |
| `tcPropertySearch` | App page | Map search (radius) |
| `tcPropertyDashboard`, `tcCommissionDashboard` | Home and app pages | Dashboards |
| `tcChart`, `tcUtils` | Shared | – |

## 5. Automation (Flows)

| Flow | Behaviour |
|---|---|
| `TC_Lease_Expiration_Reminders` | Scheduled daily. Creates Tasks 18, 12 and 6 months before expiration, matching AscendixRE's documented thresholds. |
| `TC_Inquiry_New_Follow_Up` | Record-triggered. Creates a follow-up Task for the owner. |
| `TC_Deal_Stage_Tasks` | Record-triggered. Creates Tasks at LOI and at Lease/PSA Out, and emails the lead broker when a deal is won. |
| `TC_Listing_Expiration` | Scheduled. Creates a Task 30 days before a listing expires and sets the status to Expired after the expiration date. |
| `TC_Commission_Trigger` | Autolaunched hook called from the commission dialog, mirroring AscendixRE's custom-logic Flow. |

## 6. Phases

Each phase is committed to GitHub before the next one starts.

| Phase | Content |
|---|---|
| P1 | Data model: 21 objects, 343 fields, 25 record types, validation rules, layouts, tabs, permission sets, settings and metadata records. Dry run passes: 596 of 596 components. |
| P2 | Apex services, triggers, controllers and tests (`RunSpecifiedTests`, TC tests only) |
| P3 | LWCs, Visualforce PDFs, quick actions, Lightning pages and the app `TC_Commercial_Real_Estate` |
| P4 | Flows and email alerts |
| P5 | Report types, reports and a dashboard |
| P6 | Sample data and an end-to-end process test |
| P7 | Documentation set and comparison |

**Safety rules for every deploy:**
- Deploys are additive only. There's no destructive manifest.
- No existing component is modified. Standard objects receive new `TC_` fields only.
- Tests run as `RunSpecifiedTests` with TC test classes only.
