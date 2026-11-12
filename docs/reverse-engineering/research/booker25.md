# Booker25 (now GoMeddo) — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [B3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

> Research note. The vendor documentation lives in Confluence (gomeddo.atlassian.net, spaces **BPD** for the core product, **WID** for the widget, **FP25** for Floorplan, **GOI** for Outlook, plus a legacy gen25-jira.atlassian.net mirror). It is also mirrored at documentation.gomeddo.com. Many Confluence pages were truncated or rendered empty through WebFetch (especially `/wiki/x/...` short links), so some facts come from search-engine excerpts of those pages. Those are marked "(snippet)" in the source table. The managed-package namespace is **`B25`**. It was kept after the rebrand, so object API names still start `B25__`.

---

## 0. Identity and status

| Item | Value | Label | Source |
|---|---|---|---|
| Current name | **GoMeddo**. Booker25 was renamed GoMeddo effective 1 February 2023 (announced Feb 2023; a GoMeddo changelog entry dated 20 Jan 2023 carries the rebrand notes) | Verified (press) | [B1][B48] |
| Former name | Booker25 (CB Insights: "GoMeddo, formerly Booker25") | Verified | [B1][B45] |
| AppExchange listing | "GoMeddo: Native Salesforce scheduling, resource management and booking system". Listing id **a0N30000009xLwiEAE**: https://appexchange.salesforce.com/appxListingDetail?listingId=a0N30000009xLwiEAE | Verified | [B4][B2] |
| Publisher (AppExchange) | "Group25 - Connecting you to your customers" | Verified | [B4] |
| Group structure | GoMeddo is run by **Group25**, which also owns **Gen25**, a Salesforce consulting partner (NL/UK) | Verified (press) | [B1] |
| Brief's "Booker25 B.V." | Not found in public sources. Legal entity names other than Group25: Unknown | Unknown | — |
| HQ | Website footer: Naarderstraat 84, 1251 BH Laren (NH), Netherlands. The 2023 press article said "Amsterdam-based" | Verified | [B2][B1] |
| Leadership | Gijs Martens CEO (2023); Tim Schuitemaker managing director (website 2026, press 2023) | Verified | [B1][B2] |
| Funding | €2.5M raised in 2022 | Verified (press) | [B1] |
| First AppExchange release | 2015-06-05. Listing last updated 2026-09-24 | Verified | [B4] |
| Salesforce partner | Website shows a Salesforce Partner badge "Since 2010" | Verified | [B2] |
| Native vs integrated | **100% Salesforce-native managed package** ("built 100% in Salesforce"); automatic upgrades; booking data stays in the customer org | Verified | [B2][B3][B4] |
| Status | **Active.** Docs updated in 2025-2026; Agentforce/MCP integration pages; 2026 listing update | Verified | [B4][B37] |
| Current versions mentioned | GoMeddo v4.74 (Floorplan integration page); a "7.6 or later" requirement for the new hierarchy UI; an "Upgrading from version 6?" section | Verified (version labels only) | [B40][B16][B39] |
| Install | Production: https://packages.gomeddo.com/api/InstallPackage/B25 (sandbox variant redirects to test.salesforce.com); install "For Admins Only"; prerequisites: Enhanced Folders and Sharing for Lightning Email Templates, Lightning Web Security | Verified | [B39] |

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| AppExchange | "Not publicly verified" | **4.96 / 5** (fetched 2026-11-12) | **57** | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N30000009xLwiEAE | Fetched directly. |
| G2 (GoMeddo) | "Not publicly verified" | ~**4.8 / 5** (2026-11-12, **search-engine snippet only**; direct fetch 403) | 14 or 15 (snippets disagree) | https://www.g2.com/products/gomeddo/reviews | Snippet themes: confirmations and reminders (11 mentions), scheduling notifications (10). |
| Capterra (Booker25 legacy listing) | — | Not visible (403 on fetch); snippet shows the listing still named Booker25 with a "2026" page title, no rating seen | Unknown | https://www.capterra.com/p/182797/Booker25/ | Separate GoMeddo listing https://www.capterra.com/p/10026375/GoMeddo/. Snippets suggest little or no review data. |
| Software Advice / OMR | — | "No reviews yet" / "write the first review" (snippets) | 0 | https://www.softwareadvice.com/product/525127-GoMeddo/ | Software Advice snippet: "Starting at $795.00 per month". |

## 2. Overview (12 questions)
1. **What it is**: a Salesforce-native scheduling, resource-management and booking engine for rooms, people (staff), assets, services, activities/courses and appointments, with self-service booking pages and widgets. Verified [B2][B4].
2. **Developer**: GoMeddo (formerly Booker25), part of Group25, Laren/Amsterdam, NL. Verified [B1][B2][B4].
3. **Industry**: horizontal. Listed industries include Retail, Healthcare, Non-profit, Education, **Real Estate**, Financial services, Travel & Hospitality, Professional services, MICE, Manufacturing & Automotive. Verified [B2].
4. **Target users**: Salesforce admins/architects (AppExchange personas), front-desk/planners, staff, and external customers via widget or Experience Cloud. Verified [B4][B35].
5. **Problems solved**: double bookings, availability management, complex multi-resource planning, self-service booking, and occupancy/revenue optimisation with all data kept in Salesforce. Verified [B3][B4].
6. **Major functions**: calendars (vertical/horizontal/mobile), reservation form, dimensions (Resources, Staff, Groups, Contacts, any custom object), availability, conflict checking (double booking, capacity, availability), recurring reservations, schedules/templates, blueprints (parent-child), services and add-ons, pricing, check-in/out with QR, email/ICS flow templates, Outlook/Google sync, widget + JS SDK + REST API, Experience Cloud, Floorplan, Agentforce/MCP. Verified [B8][B20][B21][B22][B31][B33][B37].
7. **Differentiators**: the "Dimension" abstraction makes any object bookable; configurable hard/soft conflict rules; native data residency; Shield and Person Accounts compatible; unlimited reservations. Verified [B17][B14][B4].
8. **Native / integrated**: native managed package. Verified [B4].
9. **Editions / licences**: Enterprise, Unlimited, Developer. Required product: Platform Cloud. Tested with Sales, Service and Experience Cloud. Verified [B4]. Experience Cloud: Community Plus or Partner licences recommended [B35].
10. **Pricing**: AppExchange says "starts at €30 per user per month", with nonprofit discounts [B4]. G2/Software Advice snippets: "Essential" plan $795/month with 5 users included [B5][B7]. The website pricing page has no figures (Inferred: pricing differs by channel/plan).
11. **Managed / unmanaged**: managed package (namespace `B25`) [B4][B10]. Extensions such as Scheduler, Reservation Export and Floorplan Connector are **unmanaged** packages [B38]. Floorplan has its own namespace `FP25` [B40]. The Agentforce package uses `GMCopilot` [B37].
12. **Limitations & dependencies**: each sync licence includes 10 Sync Connections; only events organised by the synced calendar are synced [B32]. The widget works only with `B25__Resource__c` records that are API Visible [B34]. Custom price calculators receive only the default fields [B28]. The legacy "Final status" setting works only on old Visualforce calendars [B13]. No standalone mobile app, only the Salesforce mobile app [B46]. Verified.

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Resource hierarchy | Two parallel trees, Resource Types (e.g. Country > City > Building > Meeting Room) and Resources (instances). Each resource has one type; type flags Is Reservable / Allow Double Bookings / Default Reservation Type; timezone inherited | Admin | Resource, Resource Type, timezone, icon, currency, price defaults | Reservation, Availability, Service Availability | Setup | Verified | [B16][B8] |
| Dimensions | Registers any object (lookup or junction) as bookable: Resource, Staff, Group, Contact, custom (e.g. `Car__c`) | Admin | Dimension Object Name, Availability Lookup, Sync Field, MDA flag, grouping SObject | Conflict checking, calendars, availability | Setup | Verified | [B17] |
| Calendars | Lightning Vertical/Horizontal/Mobile calendar components driven by a Calendar config record and View records; Lightning Calendar and Staff Calendar tabs | Planners, staff | Calendar, Views, filters, colours | Reservation Types, Statuses, Colors | Daily use | Verified | [B19][B20] |
| Reservation form | Standalone/inline form; fields by field set per Reservation Type; JS hooks; flow-based forms | Planners, customers | Reservation fields | Reservation Type | Create/edit | Verified | [B12][B20][B22] |
| Reservation Types & Statuses | Categorise reservations (form layout, record type, fixed duration, super type) and status picklists per type; colours per type × status | Admin | Type, Status, Color | Calendar | Setup | Verified | [B12][B13] |
| Availability | Opening hours and unavailabilities per dimension; multi-dimensional availability (MDA) | Admin, staff | `B25__Availability__c` | Conflict checking, time-slot finding | Setup / ongoing | Verified | [B18][B17] |
| Conflict checking | Double booking, capacity and availability checks; None/Soft/Hard modes; status and custom-field exceptions; newer formula-based Conflict Rules | System | Conflict records (`B25__Conflict__c`) | Reservation save | On save | Verified | [B14][B15][B10] |
| Attendees | Reservation Contact junction (multiple contacts/leads per reservation), QR codes, check-in/out | Front desk | Reservation Contact, check-in/out datetimes | Contact, Lead | Event day | Verified | [B43][B26] |
| Recurrence & schedules | Recurring Reservation (daily, etc.) and Schedule → Reservation Templates → published Reservations | Planners | Recurrence settings, templates | Reservation | Series creation | Verified | [B11][B30][B20] |
| Blueprints / collections | Parent-child reservation bundles generated from a Reservation Blueprint; time-slot finding for collections | Planners, widget | Blueprint, parent/child reservations | TimeSlot APIs | Complex bookings | Verified | [B9][B25] |
| Services | Add-ons (F&B, AV, staff services) with Service Type and Service Availability (legacy) or Service Packages (new) | Planners | Service, quantity, price | Reservation | During booking | Verified | [B8][B42] |
| Pricing | Price per person / per time unit / per person per time unit / fixed; defaults on Resource Type, override on Resource; custom Apex calculator plugin; vouchers in widget | Admin | Price fields, subtotal | Reservation | On save | Verified | [B27][B28] |
| Notifications | Flow templates: confirmation (new/updated) with ICS, cancel email, QR email, register, reschedule | System | Email via templates "Reservation Details", "Reservation Updated", "Reservation Canceled" | Contact | After save/delete | Verified | [B22][B23][B24] |
| Calendar sync | Outlook (Office 365 / Azure AD auth) and Google sync per dimension record via Sync Connection; iCal feed | Admin, staff | Sync Connection, delta tokens, errors | Resource/Staff | Ongoing | Verified | [B31][B32][B36] |
| Web booking | GoMeddo Widget (script button or iframe), JavaScript SDK, REST API (Swagger), front-end builder; Experience Cloud (guest and authenticated) | Customers | Reservation, Reservation Contact, custom fields | Resource (API Visible) | Self-service | Verified | [B33][B34][B35][B2] |
| Floorplan | Visual floor plan of space occupancy; Area Occupancy object | Workplace mgmt | `FP25__Area_Occupancy__c` | Resource, Reservation | — | Verified | [B40][B3] |
| Reporting / occupancy | Occupancy component, Get Occupancy data action, pre-made reports and dashboards | Managers | Occupancy % | Resource | — | Verified | [B20][B21][B3] |
| AI | GoMeddo Agentforce package (`GMCopilot`) and a Salesforce-hosted MCP server exposing occupancy, timeslot and reservation-creation tools | Users via AI | Reservation | — | — | Verified | [B37][B2] |

## 4. Data model

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Reservation | `B25__Reservation__c` | Custom (core) | A booking between two date/times shown on calendars | `B25__StartLocal__c`, `B25__EndLocal__c` (input, resource-local time), `B25__Start__c`, `B25__End__c`, read-only `B25__Start_Date__c`, `B25__End_Date__c`, `B25__Local_Start_Time__c`, `B25__Local_End_Time__c`, formula `B25__Start_Local_DateTime__c`/`B25__End_Local_DateTime__c`, `B25__Title__c`, `B25__Resource__c`, `B25__Staff__c`, `B25__Reservation_Type__c`, `B25__Contact__c`, `B25__Quantity__c` (example capacity qty field). Status field API: Unknown (Proposed: `B25__Status__c`) | Resource, Staff, Reservation Type, Contact (lookups) | Reservation Contact, Conflict, Service reservations, child reservations | Verified (listed fields) | [B10][B11][B41][B14][B23][B37] |
| Resource | `B25__Resource__c` | Custom | Bookable place/asset in a hierarchy | Name, Timezone, parent, Resource Type, `B25__Capacity__c` (example), price fields, isActive/"API Visible" checkbox (labels), `Area__c` (Floorplan field) | Resource (parent) | Resource (children), Reservation, Availability, Sync Connection | Verified | [B10][B14][B16][B33][B34][B40] |
| Resource Type | Proposed: `B25__Resource_Type__c` | Custom | Level in the type hierarchy | Name, Icon, Currency, Is Reservable, Allow Double Bookings, Default Reservation Type, Parent (immutable), Default Price Calculation, Default Price, "Custom Fields" field set | Resource Type (parent) | Resource Type, Resource | Verified (object/fields) / Proposed (API) | [B16][B27] |
| Staff | `B25__Staff__c` | Custom | Bookable person; optional link to Contact or User | Contact, User (labels) | — | Reservation, Availability, Sync Connection | Verified | [B8][B10][B11] |
| Group | Unknown (Proposed: `B25__Group__c`) | Custom | Default dimension "Groups" | — | — | Reservation | Verified (exists) / Proposed | [B8][B17] |
| Contact | `Contact` | Standard | Customer/attendee; also a dimension | — | Account | Reservation (`B25__Contact__c`), Reservation Contact | Verified | [B8][B23] |
| Account | `Account` | Standard | Customer org | — | — | Reservation (Inferred field) | Verified (in model) | [B8] |
| Lead | `Lead` | Standard | Reservation Contact also relates to Lead (widget) | — | — | Reservation Contact | Verified | [B43] |
| Reservation Contact | `B25__ReservationContact__c` (relationship name `B25__ReservationContacts__r`) | Junction | Multiple attendees (Contact or Lead) per Reservation; stores widget custom-field input; QR code; check-in/out | Reservation, Contact, Lead, check-in/out datetimes | Reservation | — | Verified | [B43][B10][B26] |
| Dimension | Unknown (Proposed: `B25__Dimension__c`) | Config | Registers a bookable object | Dimension Object Name, Availability Lookup, Sync Field, MDA Applies To This Dimension Only, Dimension Grouping SObject Name | — | Dimension Field (Unknown) | Verified (fields) / Proposed (API) | [B17] |
| Dimension Junction | Unknown (customer-defined object) | Junction | Schedule several records of an object on one Reservation | Reservation, dimension | Reservation | — | Verified (concept) | [B8] |
| Availability | `B25__Availability__c` | Custom | Opening/closing times or unavailabilities for a dimension; MDA | lookup to dimension (Availability Lookup), type availability/unavailability | Resource/Staff/custom | — | Verified (API from Dimensions page) | [B17][B18][B8] |
| Reservation Type | Object API: Proposed `B25__Reservation_Type__c` (the **field** `B25__Reservation_Type__c` on Reservation is verified) | Config | Category: form field set, record type, fixed duration, super type | Name, Field Set to use, Record Type, Super Type (picklist), Duration (min) | — | Calendar Reservation Type, status links, Reservation Color | Verified (fields) | [B12][B11][B37] |
| Reservation Status | Proposed: `B25__Reservation_Status__c` | Config | Status definition; colour, logic trigger | Name, Default, Active, Allow Double Bookings, Allow Unavailable Bookings, (legacy) Final | — | Type–Status link (Order) | Verified (fields) / Proposed | [B13][B14][B44] |
| Reservation Type–Status link | Unknown | Junction | Valid statuses per type and picklist order | Order | Reservation Type, Status | — | Verified (concept) | [B12][B13] |
| Calendar | Unknown | Config | Calendar configuration record (component input = record name) | Show Unlinked Reservation Types | — | View, Calendar Reservation Type, Reservation Color | Verified (concept) | [B19][B12] |
| Calendar Reservation Type | Unknown | Junction | Types offered on a calendar | Default, Order | Calendar, Reservation Type | — | Verified (concept) | [B12] |
| Reservation Color | Unknown (Proposed: `B25__Reservation_Color__c`) | Config | Colour per status × type per calendar | background/text/border colour, HEX, opacity | Calendar | — | Verified (concept) | [B12][B13] (snippet) |
| View | Unknown | Config | Calendar views | — | Calendar | — | Verified (concept) | [B19] |
| Conflict | `B25__Conflict__c` | Custom | Why a Reservation conflicts (availability, double booking, capacity); soft conflicts are stored to resolve later | type, related reservation | Reservation | — | Verified | [B8][B10][B14] |
| Recurring Reservation | `B25__Recurring_Reservation__c` | Custom | Recurrence settings | `B25__Start_date__c`, `B25__End_date__c`, `B25__Recurrence_Type__c` (e.g. `DAILY`), `B25__Repeat_Interval__c`, `B25__End_Condition__c` (e.g. `NUMBER_OF_RESERVATIONS`), `B25__Number_Of_Reservations__c` | — | Reservation | Verified | [B11] |
| Schedule | `B25__Schedule__c` | Custom | Collection of Reservation Templates (abstract weekly pattern) | — | — | Reservation Template | Verified | [B20][B30] |
| Reservation Template | `B25__Reservation_Template__c` | Custom | Abstract recurring slot that publishes Reservations | `B25__Number_Of_Sessions__c` | Schedule | Reservation (published) | Verified | [B29][B30] |
| Reservation Display / Title Group | `B25__Reservation_Display__c`, `B25__Reservation_Title_Group__c` | Config | Hover definitions, reservation titles on calendar | — | — | — | Verified | [B20] |
| Service | Proposed: `B25__Service__c` | Custom | Bookable add-on (F&B, AV) | Service Type, Name, Default Quantity, Price | Service Type | Service Availability | Verified / Proposed | [B42][B8] |
| Service Type | Proposed: `B25__Service_Type__c` | Custom | Category of services | Name | — | Service | Verified / Proposed | [B42] |
| Service Availability | Proposed: `B25__Service_Availability__c` | Custom (legacy) | Service offered at a Resource with quantity | Service, Resource, Start/End Date, Quantity | Service, Resource | — | Verified / Proposed | [B42] |
| Service reservation line | Unknown (Proposed: `B25__Service_Reservation__c`) | Junction | Service booked on a Reservation | Quantity, price | Reservation, Service | — | Inferred (services are child records of reservations) | [B42][B8] |
| Reservation Blueprint | Unknown | Config | Pattern for parent/child reservation collections | — | — | — | Verified (concept) | [B9][B25] |
| Sync Connection | Unknown object API (fields: `B25__User_Id__c`, `B25__Resource__c`, `B25__Staff__c`, `B25__Valid__c`) | Integration | Link between an Outlook/Google calendar and a dimension record | User Id (email), Calendar Name, delta tokens, subscription id, Activate After Validation, Use Live Sync (deprecated) | Resource or Staff | Outlook Sync Error | Verified (fields) | [B31] (snippet) |
| System Setting | `B25__System_Setting__c` | Custom setting | Plugin registration and feature flags (e.g. "Template On Create Class", "Reservation Price Calculator Class", Reservation Pricing Unit) | Name, String Value | — | — | Verified | [B29][B28][B27] |
| Floorplan Status Mapping | Custom Metadata (label) | Config | Maps floorplan status | Label, Status Name | — | — | Verified | [B40] |
| Area Occupancy (Floorplan) | `FP25__Area_Occupancy__c` | Custom (FP25 package) | Occupancy of a floor-plan area | `Reservation__c` | — | — | Verified | [B40] |

**Relationships**
- Reservation → Resource / Staff / Reservation Type / Contact: **lookup** fields (`B25__Resource__c`, `B25__Staff__c`, `B25__Reservation_Type__c`, `B25__Contact__c`). Verified [B10][B11][B23]. Lookup vs master-detail is not stated; Inferred lookup because a reservation can exist without any one of them.
- Reservation Contact: "has a lookup to Reservation and to Contact" (and Lead). Verified [B43].
- Resource → parent Resource, Resource Type → parent Resource Type (self hierarchies with exactly one root each). Verified [B16].
- Availability → dimension via a configurable lookup (Availability Lookup). Verified [B17].
- Schedule → Reservation Template (collection). Verified [B30].
- Sync Connection → exactly one of Resource / Staff. Verified [B31].
- Dimension relationship types: Lookup or Junction. Verified [B17].

**Record types**: a Reservation Type can assign a Reservation record type. Verified [B12]. Shipped record types: Unknown.

**Picklist / config values**
- Reservation Status values are **data records, not a picklist**. Documented examples: **Optional**, **Definite** [B44], **Cancelled** (used in a conflict-exception example) [B14]. The default shipped status list is Unknown.
- Reservation Type default record: "Reservation" [B12].
- Conflict handling modes: None, Soft, Hard [B14]. Conflict types: Availability, Double Booking (with optional Matching Condition), Capacity [B14].
- Price calculation methods: Price per person, Price per time unit, Price per person per time unit, Fixed price [B27].
- Recurrence: `DAILY` recurrence type, `NUMBER_OF_RESERVATIONS` end condition (other values Unknown) [B11].

**Formulas / validation**: `B25__Start_Local_DateTime__c` and `B25__End_Local_DateTime__c` are text formulas [snippet B41]. Fixed duration per type auto-computes end time, with the custom permission "Override Reservation Duration" [B12]. Conflict checking is engine logic, not validation rules [B14].

**ERD edge list**
```
Resource Type -> Resource Type (self, Parent) [Verified]
Resource Type -> Resource (lookup) [Verified]
Resource -> Resource (self, parent) [Verified]
Resource -> Reservation (lookup B25__Resource__c) [Verified]
Staff -> Reservation (lookup B25__Staff__c) [Verified]
Contact -> Reservation (lookup B25__Contact__c) [Verified]
Reservation Type -> Reservation (lookup B25__Reservation_Type__c) [Verified]
Reservation Status -> Reservation (status reference; field API Unknown) [Inferred]
Reservation -> Reservation Contact <- Contact | Lead (junction B25__ReservationContact__c) [Verified]
Reservation -> Conflict (child, B25__Conflict__c) [Verified]
Recurring Reservation -> Reservation (generates series) [Verified]
Schedule -> Reservation Template (collection) [Verified]
Reservation Template -> Reservation (publish) [Verified]
Resource|Staff|custom dimension -> Availability (lookup, configurable) [Verified]
Reservation Type -> Calendar Reservation Type <- Calendar (junction) [Verified concept]
Reservation Type -> Type-Status link <- Reservation Status (junction) [Verified concept]
Calendar -> Reservation Color (child; keyed by Status x Type) [Verified concept]
Service Type -> Service (lookup) [Verified]
Service -> Service Availability <- Resource (junction, legacy) [Verified]
Reservation -> Service line (child) [Inferred]
Reservation (parent) -> Reservation (child) via Blueprint/ReservationCollection [Verified concept]
Resource|Staff -> Sync Connection -> Outlook Sync Error (child) [Verified]
Staff -> Contact | User (optional lookup) [Verified]
Reservation -> FP25__Area_Occupancy__c (Reservation__c) [Verified]
```

## 5. Technical components

**Global Apex API (namespace `B25`, Verified)** [B9][B10][B11]:
- `B25.BulkReservationValidator`: `global static B25.BulkReservationValidator.Result validate(B25.BulkReservationValidator.Context)`. Context has `List<List<B25.BulkReservationValidator.Reservation>> reservationSeries`. The inner `Reservation` has `B25__Reservation__c record`, `Map<String, List<SObject>> childRecords`, `List<B25__Conflict__c> softConflicts`, `List<B25__Conflict__c> hardConflicts`. Reservations in the same inner list can conflict with each other.
- `B25.RecurringReservations`: `generateRecurringReservationSeries(B25.RecurringReservations.Context)`. Context has `prototype`, `recurringReservation` and `skipUnavailabilityDimensions`. Result has `reservations`, which are built but not inserted or validated.
- `B25.Reservation` (wrapper: duration, the `B25__Reservation__c` record, child-records map) [B9] (snippet).
- Other documented classes (names exactly as listed; the namespace `B25.` is Inferred from the pattern above): AvailableDimensionIds, AvailableTimeRanges, DateRange, DimensionHierarchy, MdaLinkedDimensions, ReservationBlueprints, ReservationCollection, ReservationCollectionTimeSlotFinder, TimeSlotConfig, TimeSlotFinder, TimeSlotGenerator, TimeSlotWithReservationCollections [B9].
- Plugin interfaces: `B25.Util_PluginManager.ReservationPrice` (`void calculate(B25.Util_PluginManager.ReservationPriceData)`), `B25.Util_PluginManager.ReservationPriceFields`, and global method `B25.Util_PluginManager.applyDefaultPriceCalculation`, registered via System Setting "Reservation Price Calculator Class" [B28] (snippet). Template hook: a global class implementing `Callable`, action `'onCreateTemplate'`, registered via `B25__System_Setting__c` named "Template On Create Class" [B29].
- **The brief's guessed names `B25.ReservationValidator` and `B25.Api` were NOT found in the docs.** Treat them as Unknown/non-existent. The documented validator is `B25.BulkReservationValidator`.

**Invocable actions (Verified labels)** [B21]: Upsert Reservations; Send Emails with ICS Attachments; Get time slots for reservation collections; Create reservations from blueprint; Generate input timeslots; Get Occupancy data.

**Lightning components (Verified display names)** [B20]: Vertical Calendar, Horizontal Calendar, Mobile Calendar, Standalone Reservation Form, Occupancy, Time Slot Picker (record pages), Publish Related Templates (on `B25__Schedule__c`), Recurring Reservation (on `B25__Reservation__c`), Schedule, MultiSchedule, Hover Definition Editor (on `B25__Reservation_Display__c`), Reservation Title Editor (on `B25__Reservation_Title_Group__c`). Flow screen components: Send Email with ICS Attachment, Reservation time slot picker, Single dimension time slot picker, Record picker, Date Range Picker, Generic time slot picker. Developer (API) names: Unknown. Calendars can be wrapped in Aura for custom JS [B19].

**Flow templates (Verified names; shipped inactive, clone with Save As)** [B22][B23][B24]: Blueprint Time Slot Picker Flow; Send QR Email To Reservation Contact; Send New or Updated Reservation Confirmation; Send Cancel Email; Default Dynamic Hover Field Flow Template; Default Standalone Reservation Form Flow Template; Default Reservation Flow Template; GoMeddo - Register to Reservation; GoMeddo - Reschedule Reservation; GoMeddo - Time Slot Picker. Email Alert "Send Cancel Email". Email templates "Reservation Details", "Reservation Updated", "Reservation Canceled".

**Triggers**: Reservation Type and Calendar triggers auto-link new types to calendars (and can be disabled) [B12]. Trigger class names: Unknown.

**Security**: permission sets "GoMeddo Admin" [B16], "GoMeddo Floorplan Admin", "GoMeddo Floorplan User", "Booker25 to GoMeddo Floorplan User" [B40]. Custom permission "Override Reservation Duration" [B12]. Reservation Contact needs Contact read access because the package cannot grant standard-object permissions [B43]. AppExchange: security-reviewed, Shield compatible, ISO 27001 listed [B4][B3].

**APIs**: REST endpoints documented in Swagger at https://apidocs.gomeddo.com/#/reservations (create/modify reservations, find available times, check-in/out). Resources must be isActive and API Visible [B33][B26]. JavaScript SDK wraps the "Booking Engine API" [B34]. Endpoint paths: Unknown (the Swagger UI is JS-rendered and was not readable).

## 6. Business processes

### P1. Internal booking (planner books a room/resource/staff)
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

### P2. Self-service web booking (widget / Experience Cloud / API)
**Start trigger**: a visitor opens the GoMeddo widget (script button or iframe), a custom front end using the JS SDK, or an Experience Cloud page [B34][B35].
1. **Initiation**: the widget lists API-Visible, active Resources; the visitor picks a resource/service or blueprint. Verified [B34][B33].
2. **Data processing**: available time slots are computed (TimeSlotFinder / TimeSlotGenerator / "availability-based" model, widget only) from Availability and existing reservations. Verified [B9][B34] (snippet).
3. **Business operations**: the visitor enters contact details and custom fields (stored on Reservation Contact); vouchers and price are calculated. Verified [B43][B28].
4. **Decision**: conflict checking runs as in P1. Widget settings choose the default status and reservation type, so an "Optional/requested" status can be used for staff review (Inferred from [B34] default-status setting). Guest access needs Guest User sharing; Community Plus licences are recommended. Verified [B35].
5. **Completion**: Reservation and Reservation Contact are created (Contact or Lead matched or created); confirmation email with ICS and optional QR email. Verified [B24][B22][B43].
6. **Post-completion**: "GoMeddo - Register to Reservation" for joining group sessions; bookings can become leads for marketing follow-up; payments via partners (e.g. Asperato). Verified [B22][B3][B2].

### P3. Recurring / scheduled programmes (courses, classes, standing meetings)
**Start trigger**: a planner uses the Recurring Reservation component or builds a Schedule of Reservation Templates [B20][B30].
1. **Initiation**: create `B25__Recurring_Reservation__c` (recurrence type, interval, end condition) or `B25__Schedule__c` with templates; the onCreate hook can pre-fill templates. Verified [B11][B29].
2. **Data processing**: `B25.RecurringReservations.generateRecurringReservationSeries` clones the prototype per occurrence, optionally skipping unavailable dimensions. Verified [B11].
3. **Business operations**: the series is validated with `B25.BulkReservationValidator.validate`, which returns soft/hard conflicts per occurrence. Verified [B10][B11].
4. **Decision**: occurrences with hard conflicts must be resolved (move/skip); soft conflicts are kept as Conflict records. Verified [B10][B14].
5. **Completion**: "Publish Related Templates" generates actual Reservations from templates; a publish class is customisable ("Customize the Published Reservations"). Verified [B20][B30].
6. **Post-completion**: attendees register; check-in tracking; occupancy reporting. Verified [B22][B26].

### P4. Calendar synchronisation (Outlook / Google)
**Start trigger**: an admin creates a Sync Connection for a Resource or Staff record [B31].
1. Initiation: Office 365 authentication set up through Azure AD and the Outlook Settings tab; Google sync licences are requested from support. Verified [B31][B32] (snippet).
2. Data processing: `B25__User_Id__c` (Outlook mailbox), optional calendar name (defaults to primary), "Activate After Validation". Verified [B31].
3. Business operations: GoMeddo keeps delta tokens and subscription ids to sync changes; only events organised by the synced calendar are synced. Verified [B31][B32].
4. Decision: validation failures go to child Outlook Sync Error records; `B25__Valid__c` is maintained by GoMeddo. Verified [B31].
5. Completion: reservations appear in Outlook/Google calendars. Verified [B4] ("two-way Office 365 and Google calendar sync").
6. Post-completion: licensing gives 10 Sync Connections per GoMeddo licence. Verified [B32].

**Reservation status list (ordered, as far as documented)**: statuses are admin-defined records. Documented examples, in typical order: **Optional** (tentative; often flagged Allow Double Bookings) → **Definite** (confirmed) → **Cancelled** (flagged Allow Unavailable Bookings). Verified examples [B44][B14]. Additional states such as checked-in/checked-out are attendee-level datetimes, not statuses [B26]. Any other default status names are Unknown.

## 7. Automation table

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

## 8. UI / UX
- **Navigation**: GoMeddo app with tabs including Lightning Calendar, Staff Calendar, Calendars, Reservation Types, Reservation Status, Dimensions, GoMeddo Settings (Resource Types, Resources tree editor), and a Dashboard home page ("Assign the Dashboard Home Page") [B19][B12][B13][B16][B8].
- **Calendar views**: vertical (time down, dates/dimensions across), horizontal (time across, dimension rows), mobile day view; drag-to-create; hover definitions; reservation titles; colours by Status × Type; grey unavailability boxes [B19][B20][B18].
- **Record pages**: Calendar sub-tab on Resource and Staff record pages; Time Slot Picker; Occupancy bar chart; Recurring Reservation component [B19][B20].
- **Mobile**: Salesforce mobile app; Mobile Calendar; QR check-in buttons [B20][B26][B46].
- **Portals**: Experience Cloud (guest and authenticated), "Expose the calendar on an Experience Cloud site"; external widget; front-end builder [B35][B34][B2].
- **Floorplan**: visual occupancy floor plans [B40][B3].
- **Public media (URLs only, not downloaded)**:
  - https://www.youtube.com/watch?v=cszBT5PUXp0: linked from a GoMeddo demo-kit page; title/description not verified.
  - https://www.carahsoft.com/demo_viewer/31688-Transform%20Digital%20Public%20Services%20with%20Salesforce/513-gomeddoforimproveoperationscustomerexperiencecrmlicensepermitinspectionmanagement: GoMeddo demo for public-sector permit/inspection scheduling.
  - https://www.g2.com/products/gomeddo/reviews: G2 hosts demo videos (activity scheduling, personalised appointment scheduling, rooms and facilities booking) per snippet [B5].
  - https://gomeddo.atlassian.net/wiki/spaces/APC/pages/3392602113: "GoMeddo Demo Kit" (presales demo script).
  - https://presales.gomeddo.com/: "Solution Central" presales site [B33 nav].

## 9. Reporting
- Pre-made Salesforce reports and dashboards for occupancy rates and popular times [B3]. Verified.
- Occupancy component and "Get Occupancy data" invocable [B20][B21]. Verified.
- Check-in/check-out counts from Reservation Contact datetimes [B26]. Verified.
- Reservation Export unmanaged package [B38]. Verified.
- Specific report names/KPIs beyond these: Unknown. Likely KPIs (Inferred): utilisation % by resource, bookings by type/status, no-show rate (check-in vs registrations), revenue (price fields).

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Microsoft Outlook / Office 365 | Calendar sync for resources and staff | Bi (AppExchange "two-way") | Events ↔ Reservations | Changes; delta tokens | Azure AD app, Graph subscriptions (Inferred), Sync Connection | Verified | [B31][B4] |
| Google Calendar | Calendar sync | Bi | Events | Changes | Sync Connection (licence via support) | Verified | [B32][B4] |
| iCal feed | Subscribe to calendars | Out | ICS | Polling | iCal Feed | Verified | [B36] |
| Email ICS | Calendar invites | Out | .ics attachment | Flow | Invocable "Send Emails with ICS Attachments" | Verified | [B21][B24] |
| Website / apps | Self-service booking | In | Reservations, contacts | User | Widget, JS SDK, REST API (apidocs.gomeddo.com) | Verified | [B33][B34] |
| Experience Cloud | Portals | In | Reservations | User | Salesforce sites, guest user | Verified | [B35] |
| Payments (Asperato) | Online payment | Bi | Payments | Booking | Partner app | Verified (partner listed) | [B2] |
| Flair.hr | HR / staff absence | In (Inferred) | Staff availability | — | Integration page | Verified (page exists) | [B36] |
| PDF Butler | Documents | Out | Booking documents | — | Partner | Verified (page exists) | [B36] |
| Zoom / Microsoft Teams | Online meetings | Out | Meeting links | — | Unknown | Third-party claim | [B46] |
| Agentforce / MCP (e.g. Claude) | AI scheduling | Bi | Occupancy, timeslots, reservations | AI tool call | Salesforce hosted MCP server, GMCopilot package, External Client App OAuth | Verified | [B37][B2] |
| GoMeddo Floorplan | Space visualisation | Bi | Area occupancy | Reservation | FP25 package + "Bridge" connector | Verified | [B40][B38] |
| GoMeddo Subscription Management | Subscriptions/memberships | — | — | — | Separate package (FP25 space page title only) | Verified (exists) / Unknown (function) | [B40] |

## 11. Limitations & what would be hard to recreate
- **Generic dimension engine**: any object is bookable through lookup or junction, with per-dimension availability lookups, MDA, and shared vs unshared conflict checking. This is the core IP.
- **Time-zone-correct local time model** (StartLocal/EndLocal vs Start/End, derived read-only fields).
- **Conflict engine** with soft conflicts persisted as records, status-based exceptions and formula rules, plus bulk validation of series.
- **Time-slot generation** for multi-resource parent/child collections (blueprints).
- **Two-way Outlook/Google sync** with delta tokens.
- **Rich calendar LWCs** (horizontal/vertical/mobile) with hover/title editors.
- **Gaps / Unknown**: exact API names for Resource Type, Reservation Status, Service*, Calendar, Color, Dimension and Sync Connection objects; the Reservation status field API name; the shipped default status list; REST endpoint paths; approval workflow; payment data model; Subscription Management functionality.

### Relevance to real estate (for our TC Commercial Real Estate app)
- GoMeddo lists **Real Estate** as an industry, with use cases of co-working, flexible office space and meeting rooms, space occupancy (Floorplan), automated confirmations, QR access, and payment/subscription/invoice options. Customers: Tribes, Zoku, and EF (student housing). Verified [B3].
- **Property viewings are not mentioned** by the vendor. Inferred fit: a Property (or Space/Unit) object registered as a Dimension, Staff = brokers/agents, a Reservation Type "Viewing" with fixed duration, Reservation Contact = prospect/tenant contact, Availability = agent working hours, Hard double-booking on Staff and Soft on Property, a widget on listing pages for self-booking viewings, and Outlook sync for broker calendars. Inferred from [B17][B12][B14][B34][B31].
- Commercial leasing fit: flexible office or meeting-room rental with pricing per time unit and services (catering/AV) as add-ons. Verified capabilities [B27][B42].

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| B1 | Booker25 rebrands as GoMeddo (Silicon Canals, 2023-02-06) | https://siliconcanals.com/booker25-rebrands-as-gomeddo/ | third party (press) | 2026-11-12 |
| B2 | GoMeddo home page | https://www.gomeddo.com/ | vendor site | 2026-11-12 |
| B3 | GoMeddo – Real Estate industry page | https://www.gomeddo.com/industries/real-estate | vendor site | 2026-11-12 |
| B4 | AppExchange: GoMeddo listing (a0N30000009xLwiEAE) | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N30000009xLwiEAE | AppExchange | 2026-11-12 |
| B5 | G2 GoMeddo reviews / pricing | https://www.g2.com/products/gomeddo/reviews | review (snippet; 403) | 2026-11-12 |
| B6 | Capterra Booker25 / GoMeddo listings | https://www.capterra.com/p/182797/Booker25/ ; https://www.capterra.com/p/10026375/GoMeddo/ | review (snippet; 403) | 2026-11-12 |
| B7 | Software Advice GoMeddo | https://www.softwareadvice.com/product/525127-GoMeddo/ | review (snippet) | 2026-11-12 |
| B8 | GoMeddo Data Model | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1553596417/GoMeddo+Data+Model | help/docs | 2026-11-12 |
| B9 | Apex Classes (Reference) | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/4597907459/Apex+Classes ; https://documentation.gomeddo.com/gmd/apex-classes | developer docs | 2026-11-12 |
| B10 | BulkReservationValidator | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/940048546/BulkReservationValidator | developer docs | 2026-11-12 |
| B11 | RecurringReservations | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1118765057/RecurringReservations | developer docs | 2026-11-12 |
| B12 | Reservation Types | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/324993025/Reservation+Types | help/docs | 2026-11-12 |
| B13 | Reservation Statuses | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/210731009/Reservation+Statuses | help/docs | 2026-11-12 |
| B14 | Old Conflict Checking | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/936476721/Old+Conflict+Checking | help/docs | 2026-11-12 |
| B15 | Conflict Checking / Conflict Rules | https://gomeddo.atlassian.net/wiki/x/MYDRNw | help/docs (snippet; page rendered empty) | 2026-11-12 |
| B16 | Set up the Resource Types & Resources hierarchy | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/5766873089/Set+up+the+Resource+Types+Resources+hierarchy | help/docs | 2026-11-12 |
| B17 | Dimensions, and how to configure them | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/644186154/Dimensions+and+how+to+configure+them | help/docs | 2026-11-12 |
| B18 | Create Availabilities | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/4188176385/Create+Availabilities | help/docs | 2026-11-12 |
| B19 | Calendars | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/4086661266/Calendars | help/docs | 2026-11-12 |
| B20 | Lightning Components (Reference) | https://documentation.gomeddo.com/gmd/lightning-components | developer docs | 2026-11-12 |
| B21 | Invocable Actions (Reference) | https://documentation.gomeddo.com/gmd/invocable-actions | developer docs | 2026-11-12 |
| B22 | Flow Templates (Reference) | https://documentation.gomeddo.com/gmd/flow-templates | developer docs | 2026-11-12 |
| B23 | Flow template: Send Cancel Email | https://documentation.gomeddo.com/gmd/send-cancel-email | developer docs | 2026-11-12 |
| B24 | Flow template: Send New or Updated Reservation Confirmation | https://documentation.gomeddo.com/gmd/send-new-or-updated-reservation-confirmation | developer docs | 2026-11-12 |
| B25 | Flow Templates for reservations | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3289382913/Flow+Templates+for+reservations | help/docs | 2026-11-12 |
| B26 | Check-in and Check-out | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3244064769/Check-in+and+Check-out | help/docs | 2026-11-12 |
| B27 | Set Resource Pricing | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3314778113/Set+Resource+Pricing | help/docs | 2026-11-12 |
| B28 | Apply custom price calculations | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/42893313/Apply+custom+price+calculations | developer docs (snippet) | 2026-11-12 |
| B29 | Reservation Template Form onCreate Hook | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1278705754/Reservation+Template+Form+onCreate+Hook | developer docs | 2026-11-12 |
| B30 | Schedules / Reservation Templates / Customize the Published Reservations | https://gomeddo.atlassian.net/wiki/x/C4ChfQ | help/docs (snippet) | 2026-11-12 |
| B31 | Outlook Sync Object Reference; Connect Dimension records to Outlook calendars | https://gomeddo.atlassian.net/wiki/x/IYCySw ; https://gomeddo.atlassian.net/wiki/x/CwCkQ | help/docs (snippet) | 2026-11-12 |
| B32 | Outlook sync considerations / Google sync | https://gomeddo.atlassian.net/wiki/x/MAA-pQ | help/docs (snippet) | 2026-11-12 |
| B33 | REST Endpoints + Swagger | https://documentation.gomeddo.com/gmd/rest-endpoints ; https://apidocs.gomeddo.com/#/reservations | developer docs | 2026-11-12 |
| B34 | GoMeddo Widget / JavaScript SDK | https://gomeddo.atlassian.net/wiki/spaces/WID/pages/2057338881/GoMeddo+Widget | developer docs (snippet) | 2026-11-12 |
| B35 | GoMeddo in Experience Cloud | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/212631553/GoMeddo+in+Experience+Cloud | help/docs | 2026-11-12 |
| B36 | Integrations (iCal, Flair.hr, PDF Butler, MCP) | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1279852547/Integrations | help/docs | 2026-11-12 |
| B37 | Setting up a GoMeddo MCP server | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/5688590339/Setting+up+a+GoMeddo+MCP+server | developer docs | 2026-11-12 |
| B38 | Extension (Packages) | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3070787609/Extension+Packages | help/docs | 2026-11-12 |
| B39 | Install the latest GoMeddo version | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3371728897/Install+the+latest+GoMeddo+version | help/docs | 2026-11-12 |
| B40 | Floorplan: Integrate with GoMeddo | https://gomeddo.atlassian.net/wiki/spaces/FP25/pages/3154673748/Integrate+with+GoMeddo | help/docs | 2026-11-12 |
| B41 | GoMeddo Reservation Data Import Considerations | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1263534084 | help/docs | 2026-11-12 |
| B42 | Service (Type) and Service Availability (Legacy) | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/3368747009/Service+Type+and+Service+Availability+Legacy | help/docs | 2026-11-12 |
| B43 | Add Reservation Contact permissions / Add all Contacts belonging to the Account | https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1493794832 ; https://gomeddo.atlassian.net/wiki/spaces/BPD/pages/1969717253 | help/docs (snippet) | 2026-11-12 |
| B44 | Reservation Statuses (older Booker25 wording: Optional/Definite, Final) | https://gomeddo.atlassian.net/wiki/x/AYCPD | help/docs (snippet) | 2026-11-12 |
| B45 | CB Insights: GoMeddo (formerly Booker25) | https://www.cbinsights.com/company/booker25 | third party (snippet) | 2026-11-12 |
| B46 | Software Finder: GoMeddo | https://softwarefinder.com/customer-service-software/gomeddo | third party (snippet) | 2026-11-12 |
| B47 | GoMeddo Demo Kit | https://gomeddo.atlassian.net/wiki/spaces/APC/pages/3392602113 | vendor presales (snippet) | 2026-11-12 |
| B48 | GoMeddo changelog (rebrand entry 2023-01-20) | https://gomeddo.atlassian.net/wiki/x/IQCBz | release notes (snippet) | 2026-11-12 |
