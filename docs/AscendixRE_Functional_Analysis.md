# AscendixRE — Functional Analysis

Date: 2026-11-12.

**Sources.** All findings come from public material:
- the Ascendix Help Center (help.ascendix.com);
- the AppExchange listing;
- search-engine snippets of ascendix.com pages. Direct fetches of ascendix.com
  returned HTTP 403, so those findings are marked *snippet*.

AscendixRE isn't installed in our org (see [00_Org_Assessment.md](00_Org_Assessment.md)).
No package source code was viewed or obtained. Each point cites its URL in the
full notes: [research/AscendixRE_Public_Research_Notes.md](research/AscendixRE_Public_Research_Notes.md).

**Labels**
- **[V]**: verified in Ascendix's public documentation.
- **[V-s]**: verified from a search snippet only.
- **[A]**: assumption or industry-standard pattern. It isn't documented by
  Ascendix, and it's our design choice.

## Product summary

AscendixRE is a managed package on Salesforce Enterprise and Unlimited editions
(namespace `ascendix`). It supports multi-currency and its objects don't count
against org limits [V].

**Core tabs [V]:** Inquiries, Contacts, Accounts, Deals, Properties,
Availabilities, Leases, Sales, Listings, Dashboards and Reports.

**Add-ons:**
- Ascendix Search: map search, saved searches and bulk actions [V].
- Composer: document generation [V].
- MarketSpace: listing portal [V-s].
- AI Suite [V].

Configuration lives in an admin console backed by Custom Metadata. It covers
object field mappings for deal close, automation and validation toggles, and
record-name formats [V].

**Central idea:** *Property is the hub.* Every other business record links to
it [V].

---

## Module analysis

Each module lists purpose, functionality, objects, fields, relationships,
processes, UI and reporting. "Our design" maps it to the proposed model in
[Salesforce_Data_Model.md](Salesforce_Data_Model.md).

### 1. Property Management

- **Purpose:** keep one record per building as the anchor for listings, leases,
  deals, availabilities and inquiries [V].
- **Functionality:**
  - A highlights view [V].
  - An image gallery [V].
  - One-click stacking plan [V].
  - A location map [V].
  - Quick actions: call, task, appointment, email [V].
  - Filtered related lists, such as leases expiring this year [V].
  - Bulk import with geocoding [V].
- **Fields:**
  - Documented: location, type and subtype (driven by record type), size,
    class, number of floors, average floor size, market, region, submarket,
    description, website, owner/landlord and contact, primary image [V].
  - Not documented: year built, land area, parking, zoning, APN [A].
- **Relationships:**
  - Accounts and Contacts in roles such as owner, finance, asset manager and
    property manager [V].
  - Children: Listings, Leases, Availabilities, Sales, Deals, Inquiries [V].
- **UI:** a 360° record page with gallery, map and stacking plan [V].
- **Reports:** properties by type, class and submarket; occupancy [A].
- **Our design:** `Property__c` with type/subtype picklists rather than record
  types, `Location__c` geolocation, and Apex-maintained Leased SF, Available SF
  and Occupancy %. `Property_Unit__c` (master-detail) holds suites.

### 2. Account and Contact Management

- **Purpose:** companies (Accounts) and people (Contacts) acting as prospects,
  clients and brokers [V].
- **Functionality:**
  - Relationship-type picklist on Contact (Partner, Vendor, Client, Prospect)
    [V].
  - Contact category marking Prospects [V].
  - A Relationship grid linking records to internal Users [V].
  - Automated follow-up task sequences on Contact [V].
  - 30-60-90 day drip-call workflows [V].
- **Deal-level roles:** Client Role and Client Contact Role default from the deal
  type (Tenant / Owner-Landlord / Seller) [V].
- **Our design:** standard Account and Contact, plus `Account.CRE_Roles__c`
  (multi-select) and `Contact.CRE_Contact_Role__c`. Deal roles live on
  `Deal__c.Client_Role__c` and the `Deal_Party__c` junction.
  - Follow-up sequences are partly covered: a Flow creates the first follow-up
    Task for new inquiries. A full drip sequence engine is a Known Limitation.

### 3. Listing Management

- **Purpose:** record the listing agreement a broker holds for a property, and
  anchor marketing and inbound inquiries ("foot traffic" reporting to owners)
  [V].
- **Types:**
  - Lease, Sale, and Sale or Lease [V].
  - Exclusive and Sublease flags [V].
- **Fields:**
  - Copied from the Property when the listing is created: broker company and
    contact, owner/landlord and contact, market, region, submarket, property
    type and subtype, description, website [V].
  - Not documented: listing status, asking price and rent, agreement dates [A].
- **Processes:**
  - Closing a *Listing Pursuit* deal as Won creates a Listing, through a
    configurable field mapping [V].
  - Prospective Inquiries related list [V].
- **Our design:**
  - `Listing__c` with type and status picklists, agreement dates, asking
    price/rent, broker and client.
  - Apex copies defaults from the Property and creates a Listing when a Listing
    Pursuit deal closes Won.
  - A scheduled Flow expires listings past their agreement date.

### 4. Lease Management

- **Purpose:** lease abstracts of tenants in properties. They serve as comps and
  drive prospecting around expirations [V].
- **Fields:** unit name/number, unit type, property, lease type, size, rate/SF,
  floor, tenant, commencement and expiration dates [V].
- **Rent Table [V]:**
  - Period rows (from, to, duration, rate, monthly and total rent), generated in
    12-month periods.
  - Two calculation methods: annual-ratio or monthly.
  - Gap and overlap review.
- **Processes:**
  - A Tenant or Landlord Representation deal closed Won creates a Lease and
    copies the rent table [V].
  - A "Lease expiration" Flow creates Tasks for the owner 18, 12 and 6 months
    before expiry [V].
  - A Lease Comp Report is generated through Composer [V].
  - Escalations, free rent, TI and options [A].
- **Our design:**
  - `Lease__c` with economics fields, plus a `Lease_Period__c` rent schedule
    generated by `REA_LeaseCalculator`.
  - A deal closed Won creates the lease.
  - A scheduled Flow sends reminders at 18, 12 and 6 months and marks expired
    leases.
  - A Visualforce PDF lease comp report.

### 5. Deal Management

- **Purpose:** the pipeline of revenue events across business lines [V].
- **Deal types [V]:** 12 record types:
  - Tenant, Landlord, Seller and Buyer Representation
  - Listing Pursuit
  - Capital Markets
  - Asset Management
  - Consulting
  - Financing
  - Lease Administration
  - Project Management
  - Property Management
- **Fields:**
  - Property, Space (Availability), Stage, Client, Client Role, and
    tenant/landlord/buyer parties with their contacts [V].
  - Lender, allowances, lead broker role, source [V].
  - Gross Deal Value and Gross Fee Method (Percent, Amount, $ per SF) [V].
  - Close fields: Status, Actual Close Date, Actual Value [V].
  - Stage values aren't published [V]; ours are an assumption [A].
- **Processes:**
  - Client and party fields auto-populate from the deal type [V].
  - Prospective Buyers on Seller Rep deals [V].
  - Offer tracking [V].
  - A **Close Deal** dialog [V]:
    - Won Tenant/Landlord Rep → Lease.
    - Won Buyer/Seller Rep → Sale.
    - Won Listing Pursuit → Listing.
    - The linked Availability is set to Closed.
  - Optional validation: inside-broker splits must total 100% [V].
  - Stage-based client emails, for example at LOI [V-s].
- **UI:** Kanban pipeline with stage totals [V], scorecard KPI tiles [V],
  editable grids [V].
- **Our design:**
  - `Deal__c` with 8 deal types and the Ascendix-style fee methods.
  - The `Deal_Party__c` junction covers tenant, landlord, buyer, prospective
    buyer (with an offer amount), lender and outside broker.
  - Apex close logic creates the Lease, Sale or Listing and closes the
    Availability.
  - The `reaDealPipeline` Kanban LWC with drag-and-drop stage changes.
  - Asset Management, Lease Administration, Project Management and Property
    Management deal types are left out of scope (Known Limitations).

### 6. Availability Management

- **Purpose:** vacant suites in a property, which are browsed, updated and
  imported [V].
- **Fields:**
  - Status, including "Closed", which deal close sets [V].
  - Primary image [V].
  - Size, floor, rate, date available, divisibility, sublease [A].
- **Relationships:** child of Property; Deal looks up to it [V].
- **Stacking plan:** availabilities shown in yellow [V-s].
- **Our design:**
  - `Availability__c` with status Available, Pending, Leased, Sold or Off
    Market (our equivalent of "Closed"), SF, rate, divisibility and dates.
  - Optional link to a `Property_Unit__c`.
  - The `reaAvailabilityManager` LWC: property-scoped grid with inline edit.

### 7. Inquiry Management

- **Purpose:** capture unqualified inbound interest from phone, email, portal or
  web form. It can be about a listing or a general requirement [V].
- **Types:** Lease and Sale [V].
- **Fields:**
  - Contact, company, broker company and contact [V].
  - Price min/max, space and property-type requirements, move-in date [V].
  - Listing [V].
- **Processes:**
  - Many listings per inquiry through *Prospective Listings* (status, one
    Primary) [V].
  - **Convert** to Account, Contact and Deal [V].
  - Disqualify [V].
  - Web-to-Inquiry form [V].
  - **No automated requirement-to-availability matching is documented.**
    Matching is done by searching [V].
- **Our design:**
  - `Inquiry__c` plus the `Inquiry_Match__c` junction (status, Primary).
  - **Find Matches**: our own scoring engine over available spaces by type, size
    band, rent and city. It goes beyond what's documented.
  - **Convert to Deal** and a disqualify path through Status.
  - A Flow creates a follow-up Task on a new inquiry.
  - Web-to-Inquiry is out of scope (needs an Experience Cloud site).

### 8. Capital Sources

- **Purpose:** capital markets deals put a financing to several lenders [V].
- **Objects:** Deal Source (child of Deal, looks up to Capital Source), Capital
  Source (lender master), Term Sheet (quotes, with side-by-side comparison) and
  Deal Property (multi-property deals) [V].
- **Not documented:** a loan object; investor criteria such as LTV, DSCR and
  deal size [A].
- **Our design:**
  - `Capital_Source__c`, master-detail to the lender Account, holds the lending
    and investing criteria (type, capital types, property types, deal-size band,
    LTV, DSCR, rate).
  - Deals look up a Capital Source, and lenders also appear as Deal Party rows.
  - Deal Source, Term Sheet and Deal Property are deferred (Known Limitations).

### 9. Commission Calculations

- **Deal fee:**
  - Gross Deal Value is total rent for a lease, or the sale price [V].
  - Gross Fee Method: Percent, Amount, or $ per SF. $ per SF is leases only and
    requires Size and Rate [V].
- **Commission records (child of Deal) [V]:**
  - Inside Broker: User, broker fee %, house fee %.
  - Analyst and Co-Broker: Account/Contact, fee method, fee %.
  - Expense.
  - Gross, net and house amounts.
- **Rules:**
  - Splits can't exceed 100% [V].
  - Optional rule: inside-broker splits total 100% [V].
  - Commission privacy, so brokers see only their own gross [V].
  - Custom logic through a Flow hook [V].
- **Claims without documentation:** tiered payouts, payment schedules, invoices
  [V-s, undocumented].
- **Our design:**
  - `Commission_Plan__c` (default fee method/%, house split %, payment terms) and
    `Commission__c` (payee types Inside Broker, Analyst, Co-Broker, Referral,
    Expense).
  - `REA_CommissionService` calculates deal transaction value → gross fee →
    split gross → house share → net.
  - It enforces the ≤100% total and advances commission status when the deal
    closes.
  - Privacy is handled by field-level security.
  - The `reaCommissionDashboard` LWC.
  - Tiered plans and installments are deferred.

### 10. Stacking Plans

- **Purpose:** a visual of tenants and vacancy by floor [V].
- **Behaviour:**
  - Built from Property floors and average floor size, then leases and
    availabilities [V-s].
  - Availabilities are yellow; leases are coloured by expiration date [V-s].
  - Export to PDF or Excel [V].
- **Not documented:** interactions and colour thresholds [A].
- **Our design:**
  - The `reaStackingPlan` LWC on the Property page: floors top-down, units sized
    in proportion to SF.
  - Colours by status and expiration year, with a legend and an expiration-year
    filter.
  - Clicking a unit opens its lease or availability.
  - Print-friendly view; there's no Excel export (Known Limitations).
  - Data comes from `Property_Unit__c` and `Lease__c`.

### 11. Property Search and Mapping

- **Documented [V]:**
  - Global and filtered search.
  - Ascendix Search: map search with polygon, circle, rectangle and radius;
    customizable pins; saved and shared searches; ad-hoc lists.
  - Bulk update, tasks and mass email.
- **Our design:**
  - The `reaPropertySearch` LWC with filters (type, class, city/submarket, SF
    range, rent range, has availability) and a **radius search** from a chosen
    property or lat/long.
  - Results shown in a datatable plus the base `lightning-map` with markers.
  - Search criteria saved per user.
  - Polygon drawing, ad-hoc lists and mass email are out of scope. Salesforce
    Maps, which is licensed in the org, can cover polygon and territory use
    cases.

### 12. Dashboards and Reports

- **Documented [V]:** standard Salesforce reports and dashboards, record-level
  scorecards, lease comp reports. Prebuilt report names aren't published.
- **Our design:**
  - Custom report types.
  - About 10 reports:
    - Pipeline by Stage
    - Weighted Pipeline by Broker
    - Lease Expirations by Year
    - Availabilities by Property
    - Inquiries by Source
    - Commissions by Broker
    - Closed Deals YTD
    - Occupancy by Property Type
    - Listings Expiring 90 days
    - Sales Comps
  - One "REA Brokerage Overview" dashboard.
  - LWC KPI dashboards: `reaPropertyDashboard` and `reaCommissionDashboard`.

### 13. Document Generation

- **Documented [V]:** Composer generates PDF, HTML email and microsites from
  templates, for example tour books, flyers and lease comp reports.
- **Our design:** Visualforce `renderAs="pdf"` templates:
  - **Property Flyer**
  - **Lease Comp Report**
  - **Deal Summary / Commission Statement**

  A Quick Action on each record saves the PDF as a File on that record. A
  WYSIWYG template designer, microsites and bulk tour books are out of scope.

### 14. Activity Tracking and Follow-ups

- **Documented [V]:**
  - Standard Tasks, Events, Notes and Chatter.
  - Quick actions on every record.
  - Lease expiration reminder Flow (18/12/6 months).
  - Automated follow-up sequences.
  - Drip workflows.
  - Bulk task creation through Search.
- **Our design:**
  - Activities enabled on all objects.
  - Flows:
    - Follow-up Task on a new Inquiry.
    - Task on a deal stage change to Proposal / LOI and to Under Contract.
    - Scheduled lease-expiry Tasks with an email alert.
    - Scheduled listing-expiry Task 30 days out.
    - Stale-inquiry reminder after 14 days without activity.

---

## Verified vs. assumed: summary

| Area | What we know is verified | What we had to assume |
|---|---|---|
| Object model | Object names and the parent/child chain (Property hub; Commission → Deal; Lease Period → Lease; Deal Source → Capital Source) | API names; lookup vs master-detail choices |
| Picklists | Deal types (12), fee methods, commission payee types, listing types, inquiry types | Deal stages, lease types, property types and classes, availability statuses |
| Automation | Deal close creates Lease/Sale/Listing, closes the Availability, 18/12/6-month expiry tasks, split ≤ 100% | Stage-based probability, inquiry matching scoring, escalation maths |
| UI | Kanban pipeline, scorecards, stacking plan colour concept, map search shapes | Exact layouts, stacking plan interactions |
| Reporting | Uses standard reports and dashboards | All specific report names |
