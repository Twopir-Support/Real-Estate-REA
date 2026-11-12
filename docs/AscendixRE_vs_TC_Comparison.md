# AscendixRE vs TC Commercial Real Estate — Implementation Comparison

This compares AscendixRE's **publicly documented** functionality
([AscendixRE_Functional_Analysis.md](AscendixRE_Functional_Analysis.md)) with
what is **built and deployed** in `REA-Dev`.

**Status key**
- ✅ **Built:** matches the documented behaviour.
- 🟡 **Partial:** the core is built and some documented features are missing.
- ⛔ **Not built:** see [Known_Limitations.md](Known_Limitations.md).
- ➕ **TC extra:** not documented by AscendixRE.

## Object structure

| AscendixRE object | TC object | Status |
|---|---|---|
| Property | `TC_Property__c` (8 record types) | ✅ |
| Availability | `TC_Availability__c` | ✅ (fields beyond Status are TC design) |
| Listing | `TC_Listing__c` (Lease / Sale / Sale or Lease) | ✅ |
| Lease | `TC_Lease__c` | ✅ |
| Lease Period / Deal Period | `TC_Lease_Period__c` / `TC_Deal_Period__c` | ✅ |
| Sale | `TC_Sale__c` | ✅ |
| Deal | `TC_Deal__c` (12 record types) | ✅ |
| Inquiry | `TC_Inquiry__c` | ✅ |
| Prospective Listing | `TC_Prospective_Listing__c` | ✅ |
| Prospective Buyer | `TC_Prospective_Buyer__c` | ✅ |
| Offer | `TC_Offer__c` | ✅ (fields are TC design) |
| Commission | `TC_Commission__c` (Inside Broker / Analyst / Co-Broker / Expense) | ✅ |
| Commission Privacy | `TC_Commission_Privacy_Admin` custom permission + field-level security | 🟡 |
| Capital Source / Deal Source / Term Sheet / Deal Property | Same four, prefixed `TC_` | ✅ |
| Relationship | `TC_Relationship__c` + relationship grid | ✅ |
| Market Rent / Unit / Unit Profile | Same three, prefixed `TC_` | ✅ (fields are TC design) |
| Bypass setting, AutomationSetting, Object Name Mapping, Object Field Mapping, Stacking Plan metadata | `TC_Bypass_Settings__c` + 4 matching `TC_*__mdt` types | ✅ |
| Admin Console app | Settings edited in Setup | 🟡 |

## Modules

| # | Module | AscendixRE (documented) | TC implementation | Status |
|---|---|---|---|---|
| 1 | Property Management | Hub record, gallery, map, stacking plan link, filtered related lists, geocoded import | Property 360 component, image viewer, map, Stacking Plan tab, roll-ups | ✅ |
| 2 | Accounts & Contacts | Relationship type, prospect category, relationship grid, follow-up sequences | `TC_` Contact fields, relationship grid, nightly follow-up sequences | ✅ |
| 3 | Listing Management | Record types, Exclusive and Sublease flags, Property prefill, Listing Pursuit creates a Listing | All built (prefill and close mapping in metadata). Expiry flow is a TC extra. | ✅ ➕ |
| 4 | Lease Management | Abstracts, rent tables, lease created on close, 18/12/6-month reminders, lease comp report | All built; the lease comp report is a fixed PDF | ✅ |
| 5 | Deal Management | 12 types, client auto-fill, prospective buyers, offers, Close Deal, Kanban, scorecards, grids | All built. Stage values are TC design. | ✅ |
| 6 | Availability Management | Vacant suites, Closed on deal close | Built, with units, divisibility and an image gallery | ✅ |
| 7 | Inquiry Management | Lease/Sale, prospective listings, convert, disqualify, web-to-inquiry | All except web-to-inquiry. Find Matches scoring is a TC extra. | 🟡 ➕ |
| 8 | Capital Sources | Deal sources, capital sources, term sheet comparison, multi-property deals | All built, plus lending criteria fields | ✅ |
| 9 | Commissions | Fee methods, four payee types, split rules, privacy, bulk entry, Flow hook | All built. Privacy is field-level only, and there are no tiered or instalment plans. | 🟡 |
| 10 | Stacking Plans | Floor skeleton, yellow vacancy, LXD colours, PDF/Excel export | Built, including an expiration filter. No export. | 🟡 |
| 11 | Search & Mapping | Map shapes, saved searches, ad-hoc lists, bulk actions, mass email | Filters, radius search, map and saved criteria | 🟡 |
| 12 | Dashboards & Reports | Standard reports and dashboards, scorecards | 8 report types, 11 reports, a dashboard and 2 LWC dashboards | ✅ |
| 13 | Document Generation | Composer designer, PDF, email, microsites | Three fixed PDFs, saved as Files | 🟡 |
| 14 | Activities | Tasks and events, reminders, sequences, drip tasks, Harvest | All except Harvest | 🟡 |

**Summary:**
- Modules: 8 of 14 built (✅) and 6 partial (🟡). No module is missing.
- Objects: 21 of the 22 documented objects exist with the same purpose. The
  22nd, Commission Privacy, is implemented as permissions.
- Fields: 181 of the 343 TC fields (53%) correspond to fields AscendixRE
  documents.

## What TC adds beyond the documentation

- An inquiry-to-listing matching score with reasons.
- Rent schedules with free rent and escalation.
- Scheduled lease status sweeps.
- A commission dashboard.
- A listing expiry flow.
- Radius property search.
- Bypass switches for triggers, validation rules and flows.
- A repeatable sample-data set with an end-to-end verification script.
