# Proposed Salesforce architecture

This is a recommended architecture for our own real-estate application on Salesforce. It draws on the reverse-engineering of eight products (see `Real_Estate_Applications_Reverse_Engineering.pptx`, sections 2–4). It is an **independent design**: it uses no vendor code, trademarks or confidential material. All object, class, component and Flow names are ours, in the project's `TC_` convention.

It builds on the **TC Commercial Real Estate** app already in this repository (phases P1–P7: objects, Apex services, LWCs, Flows, reports). Throughout this document, "Built" means the item exists in `force-app/main/default`, and "Proposed" means it is recommended but not yet built.

---

## 1. What the research tells us

### 1.1 Common to most products (the core)

| Capability | Where we saw it | Decision |
|---|---|---|
| People and companies on standard Account and Contact, plus role records | All eight | Reuse Account and Contact, and keep role junctions (Deal parties, Prospective Buyer) |
| Inventory hub: Property, with units or spaces below it | AscendixRE, Propertybase, Apto, REthink, Real Properties (Booker25 generalises it as Resource) | Keep `TC_Property__c`, `TC_Unit__c` and `TC_Availability__c` (Built) |
| Demand captured in a custom object, not standard Lead | AscendixRE Inquiry, Propertybase Request, improveit 360 eLead/Inquiry | Keep `TC_Inquiry__c` (Built) and add structured criteria (Proposed `TC_Preference__c`) |
| Pipeline with stages and a structured close | AscendixRE, REthink, Apto, Left Main, improveit 360 | Keep `TC_Deal__c` with record types and the Close Deal dialog (Built) |
| Close creates the outcome record | AscendixRE (Lease/Sale/Listing), REthink (comp), Left Main (Transaction) | Keep metadata-driven close mapping, `TC_FieldMappingService` (Built) |
| Follow-up automation | All | Use Flows for task lists and reminders (Built), and add cadences in P3 |

### 1.2 Unique, and worth adopting as modules

| Capability | Source product | Priority |
|---|---|---|
| Criteria matching by field name (min/max fields map to inventory fields) | Propertybase | P2a |
| Lead routing: round robin and click-to-claim, with notifications | Propertybase, Left Main | P2a |
| Conflict-checked bookings (None / Soft / Hard) with calendar sync | Booker25 / GoMeddo | P2b |
| Offer counter-chain that drives Listing status | Propertybase | P2c |
| Portal syndication with per-portal mapping | Propertybase, AscendixRE | P3 |
| Cadences across email, SMS and tasks | Left Main, Propertybase | P3 |
| Investor acquisitions and dispositions | Left Main | P3 |
| Commission invoicing and payments | Apto, Propertybase, improveit 360 | P3 |
| Email-to-record drafts with human review (AI) | AscendixRE Harvest | P3 |

Not recommended for now: CAD floor plans (Real Properties; niche, and costly to build), home-improvement production scheduling (improveit 360; different industry), and capital-markets term sheets beyond what is already built.

---

## 2. Data model

### 2.1 Standard objects reused

| Object | Use |
|---|---|
| Account | Owners, tenants, buyers, lenders, brokerages. The type is held in a picklist. |
| Contact | People. A relationship-type picklist covers Client, Prospect, Partner and Vendor. |
| Task / Event | Activities. Showings are kept in a custom object so conflicts can be checked, and an Event is then created on the agent's calendar. |
| User | Brokers and agents, routing membership, commission recipients. |
| Campaign | Marketing source tracking (optional). |

We deliberately do **not** depend on Lead or Opportunity. Two of the products studied bundle Salesforce Platform licences, which do not include those objects. Using custom Inquiry and Deal objects keeps the application licence-neutral.

### 2.2 Custom objects

| Object | API name | Status | Parent / key relationships | Purpose |
|---|---|---|---|---|
| Property | `TC_Property__c` | Built | Owner Account (lookup) | Building hub: class, market, floors, geolocation |
| Unit | `TC_Unit__c` | Built | Property (MD) | Physical suite or unit |
| Availability | `TC_Availability__c` | Built | Property (MD), Unit (lookup) | Marketable vacant space with status and rate |
| Listing | `TC_Listing__c` | Built | Property (lookup) | Listing agreement, Lease or Sale |
| Inquiry | `TC_Inquiry__c` | Built | Contact, Listing (lookups) | Demand: source, type, status |
| Prospective Listing | `TC_Prospective_Listing__c` | Built | Inquiry ↔ Listing (junction) | Listings of interest |
| Deal | `TC_Deal__c` | Built | Property, Availability, Account | Pipeline by record type |
| Offer | `TC_Offer__c` | Built | Deal | Offers; extend with a counter-chain |
| Lease / Sale | `TC_Lease__c` / `TC_Sale__c` | Built | Property, Account | Outcome records and comps |
| Deal / Lease Period | `TC_Deal_Period__c` / `TC_Lease_Period__c` | Built | Deal / Lease (MD) | Rent tables |
| Commission | `TC_Commission__c` | Built | Deal (MD), User | Splits, validation, payout order |
| Capital markets | `TC_Deal_Source__c`, `TC_Capital_Source__c`, `TC_Term_Sheet__c`, `TC_Deal_Property__c` | Built | Deal | Debt placement |
| **Preference** | `TC_Preference__c` | Proposed | Inquiry (MD) | Criteria as `X_Min__c` / `X_Max__c` pairs that mirror Availability and Listing fields |
| **Showing** | `TC_Showing__c` | Proposed | Deal or Inquiry, Availability, User | Viewing with start, end, status, feedback and rating |
| **Portal Publication** | `TC_Portal_Publication__c` | Proposed | Listing (MD) | One row per portal: status, last sync, error |
| **Closing Milestone** | `TC_Closing_Milestone__c` | Proposed | Deal (MD) | Checklist item with due date, owner and done flag |
| **Routing Member** | `TC_Routing_Member__c` | Proposed | User | Membership in a routing group, active flag, last assigned |
| **Integration Log** | `TC_Integration_Log__c` | Proposed | — | Request/response record for each callout or inbound call |

### 2.3 Configuration

| Item | Status | Purpose |
|---|---|---|
| `TC_Automation_Setting__mdt` | Built | Feature toggles and validation switches |
| `TC_Object_Field_Mapping__mdt`, `TC_Object_Name_Mapping__mdt` | Built | Close mapping and record naming |
| `TC_Deal_Stage_Setting__mdt` | Built | Stage-based task lists |
| `TC_Stacking_Plan_Setting__mdt` | Built | Stacking plan options |
| `TC_Bypass_Settings__c` | Built | Hierarchy custom setting to bypass automation during data loads |
| `TC_Matching_Rule__mdt` | Proposed | Maps Preference fields to target fields and operators |
| `TC_Routing_Rule__mdt` | Proposed | Source → group → distribution method (round robin or claim) |
| `TC_Conflict_Rule__mdt` | Proposed | None / Soft / Hard conflict rule for each resource type |
| `TC_Portal__mdt` | Proposed | Portal endpoint, field map and Named Credential name |

### 2.4 Relationship notes

- Use master-detail only where the child has no meaning without its parent and must inherit sharing: Unit, Availability, Periods, Commission, Preference, Portal Publication and Closing Milestone.
- Use lookups for everything else, so records survive reparenting and keep their own sharing (Deal → Property, Inquiry → Contact).
- Add external IDs to `TC_Inquiry__c` (source system id), `TC_Listing__c` (portal or MLS id) and `TC_Property__c` (source id), so migrations and upserts are idempotent.

---

## 3. Application architecture

```
Users (brokers, coordinators, managers, accounting, admins, prospects)
   │
Experience   LWC: tcPropertySearch · tcStackingPlan · tcDealPipeline · tcCloseDeal · tcInquiryMatches
             (built) + tcShowingScheduler · tcPortalPublisher · tcLeadInbox (proposed)
   │
Logic        Triggers → TC_TriggerHandler → services (TC_DealService, TC_CommissionService, …)
             Flows for single-record, admin-owned automation
   │
Data         Standard Account/Contact + TC_ custom objects (section 2)
   │
Config       Custom metadata + bypass custom setting + permission set groups
   │
External     Web forms (Apex REST) · portals · calendar · e-signature · maps · email/SMS · accounting
```

### 3.1 LWC (Lightning Web Components)

| Component | Status | Purpose |
|---|---|---|
| `tcPropertySearch` | Built | Filtered search with map pins |
| `tcStackingPlan` | Built | Floor-by-floor occupancy |
| `tcDealPipeline` | Built | Kanban board by stage, with totals |
| `tcCloseDeal` | Built | Won/Lost dialog with a mapping preview |
| `tcConvertInquiry` | Built | Converts an inquiry and lets the user choose the listing |
| `tcInquiryMatches` | Built | Matches for an inquiry; to be extended so it reads Preference rules |
| `tcCommissionGrid`, `tcCommissionDashboard` | Built | Split entry and payouts |
| `tcRentTable`, `tcTermSheetCompare` | Built | Rent periods and lender quotes |
| `tcShowingScheduler` | Proposed | Calendar of agents and units; drag to book, with conflict feedback |
| `tcPortalPublisher` | Proposed | Publish, pause and retry per portal; shows sync errors |
| `tcLeadInbox` | Proposed | Claim queue with an SLA timer |

### 3.2 Apex

| Layer | Built | Proposed |
|---|---|---|
| Entry points | Object triggers → `TC_TriggerHandler`; `@AuraEnabled` controllers (`TC_DealUIController`, `TC_PropertyUIController`, `TC_RecordUIController`); `TC_DailyScheduler` | Apex REST `TC_InquiryIntakeRest` (`/services/apexrest/tc/inquiry/v1`); Email Service `TC_PortalLeadEmailHandler` |
| Services | `TC_DealService`, `TC_InquiryService`, `TC_LeaseService`, `TC_RentTableService`, `TC_CommissionService`, `TC_FieldMappingService`, `TC_NamingService`, `TC_PropertyRollupService` | `TC_MatchingService` (queueable, dynamic SOQL from `TC_Matching_Rule__mdt`), `TC_RoutingService` (uses `FOR UPDATE` on `TC_Routing_Member__c` for round-robin state), `TC_BookingService` (overlap queries, bulk-safe), `TC_PortalService` (queueable callouts with retry) |
| Cross-cutting | `TC_Settings`, `TC_Exception`, `TC_TestDataFactory` | `TC_IntegrationLogger` |

Standards: `with sharing` by default, `WITH USER_MODE` / `Security.stripInaccessible` for FLS, one trigger per object, and no SOQL or DML inside loops. Tests cover 200-record bulk and each persona's permission set.

### 3.3 Flow vs Apex

| Automation | Trigger | Recommended | Status |
|---|---|---|---|
| Inquiry follow-up task | Inquiry created | Record-triggered Flow (`TC_Inquiry_New_Follow_Up`) | Built |
| Deal stage tasks | Stage change | Record-triggered Flow + CMDT (`TC_Deal_Stage_Tasks`) | Built |
| Lease expiration reminders | Days before expiry | Scheduled-path Flow (`TC_Lease_Expiration_Reminders`) | Built |
| Listing expiration | Expiry date | Scheduled Flow (`TC_Listing_Expiration`) | Built |
| Commission defaults | Commission save | Autolaunched Flow (`TC_Commission_Trigger`) | Built |
| Close Deal mapping | Close Won | Apex | Built |
| Automatching | Preference or Availability change | Apex queueable | Proposed |
| Lead routing | Inquiry created | Apex + CMDT | Proposed |
| Showing conflict check | Showing insert/update | Apex trigger | Proposed |
| Showing notifications | Showing booked/changed | Record-triggered Flow (email + custom notification) | Proposed |
| Offer accepted → Listing/Availability status | Offer status change | Record-triggered Flow | Proposed |
| Portal feed | Listing published | Apex queueable callout | Proposed |
| Cadence steps | Enrolment date + offsets | Scheduled Flow, or Apex batch at volume | Proposed |

Rule of thumb: use Flow for single-record logic that admins own, and Apex for bulk work, logic that spans several objects, callouts, calculations and anything that needs locking.

### 3.4 Security

- Permission set groups by persona: **TC Broker**, **TC Coordinator**, **TC Manager**, **TC Accounting**, **TC Admin**.
- OWD: Deal Private, Inquiry Private, Commission controlled by parent. Property, Listing and Availability are Public Read Only.
- Commission privacy: brokers see only their own commission lines, through sharing records written by `TC_CommissionService`. Accounting sees all of them.
- Guest site user (inquiry intake only): create on Inquiry and Preference only, protected by a token and rate limiting in Apex.

---

## 4. Integrations

| System | Direction | Technology | Error handling |
|---|---|---|---|
| Website / web forms | Into Salesforce | Apex REST on a guest Site, with token auth | 4xx with a field-level message; log in `TC_Integration_Log__c` |
| Portal lead emails | Into Salesforce | Email Service + one parser class per portal | Unparsed emails kept as Tasks for manual triage |
| Listing portals | Out of Salesforce | Queueable callouts via Named Credentials; mapping in `TC_Portal__mdt` | Retry with backoff; error shown on Portal Publication |
| Outlook / Google Calendar | Both ways | Einstein Activity Capture, or a sync service; ICS invites to clients | Sync status on Showing |
| E-signature | Both ways | Vendor managed package or API; envelope status written back to Deal/Offer | Webhook retries |
| Maps / geocoding | Out (query) | Salesforce Maps or a geocoding API via Named Credential | Address quality flag |
| Email / SMS provider | Out of Salesforce | Provider package or API; opt-out sync | Bounce and opt-out handling |
| Accounting | Out of Salesforce | Middleware or API for invoices and payouts | Reconciliation report |

---

## 5. End-to-end process (target)

1. **Enquiry in.** A web form, portal email, call or walk-in creates an Inquiry and its Preference through the REST endpoint or email service. A duplicate check runs on email and phone.
2. **Routing.** `TC_RoutingService` assigns an owner by round robin or claim, then notifies them by email, custom notification or SMS. An SLA timer starts.
3. **Matching.** `TC_MatchingService` finds Availabilities and Listings that fit the Preference, and the broker sends a shortlist.
4. **Showing.** A Showing is booked with a conflict check on the agent and the unit, and a calendar invite is sent. Feedback and a rating are captured afterwards.
5. **Qualify.** The broker converts the Inquiry (Account, Contact and Deal are created) or disqualifies it with a reason.
6. **Deal stages.** Qualified → Touring → Proposal / LOI → Negotiation → Contract → Closed Won or Lost. Stage tasks come from CMDT.
7. **Offer.** Offers and counters are recorded. Accepting an offer updates the Listing and Availability status.
8. **Close.** The Close Deal dialog maps the Deal to a Lease or Sale. Rent tables and commissions carry over, and Closing Milestones are completed.
9. **After close.** Expiry reminders, a review request and portal unpublish run. Commission payouts follow.

Alternate paths: a disqualified inquiry is closed with a reason. A lost deal keeps its history and releases any held Availability. A cancelled showing frees the slot. An offer that is countered becomes inactive and links to the new offer.

---

## 6. Roadmap

| Phase | Weeks | Scope |
|---|---|---|
| 0 Baseline | done | P1–P7 in this repo: commercial core, close mapping, commissions, capital markets, reports |
| 1 Demand | 1–4 | `TC_Preference__c`, `TC_MatchingService`, routing rules and `tcLeadInbox`, inquiry REST endpoint |
| 2 Showings | 5–8 | `TC_Showing__c`, conflict trigger, `tcShowingScheduler`, calendar sync, notification Flows |
| 3 Offer and close | 9–12 | Offer counter-chain, Closing Milestones, e-signature, status sync |
| 4 Market | 13–16 | `TC_Portal_Publication__c`, portal callouts, cadences, portal lead parsing |
| 5 Extend | 17+ | Investor acquisitions, invoicing and payments, AI email-to-record drafts, mobile |

The durations assume one admin, two developers and a part-time architect. Each phase ends with bulk tests, permission tests, an updated field inventory and a demo.

## 7. Risks

| Risk | Mitigation |
|---|---|
| Vendor internals are unknown, so a feature may behave differently from what we assume | Design from documented behaviour; validate with target users before each build |
| Platform vs Sales Cloud licences | Do not depend on Lead or Opportunity |
| Portal feed formats and terms differ by portal | One mapping record and adapter per portal; start with one or two portals |
| Governor limits on matching and conflict checks at volume | Run queueable or batch jobs, use selective queries, and add indexes on criteria fields |
| Data migration from namespaced products (`pba__`, `McLabs2__`, `ascendix__`, `TTL_Core__`) | Source-specific mapping tables and external IDs |
| IP | No vendor code or names; our own names and designs throughout |
