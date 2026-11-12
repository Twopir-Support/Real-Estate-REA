# Phase 1 — Org and Access Assessment

Assessment date: 2026-11-12. Read-only: nothing was changed in the org.

## 1. Connected org

| Item | Value |
|---|---|
| CLI alias | `REA-Dev` (default target org for this project) |
| Username | `info@…​.demo` (masked: public repo) |
| Org ID | `00Dg8…` (masked) |
| Instance URL | `https://tw…​.my.salesforce.com` (masked), pod USA1142 |
| Edition / type | Enterprise Edition **trial** demo org (production-type, not sandbox, not scratch) |
| Trial expiry | 2026-12-13 |
| API version | 68.0 |
| Running user | System Administrator |
| Locale / time zone | en_US / America/Los_Angeles |
| Multi-currency | **Enabled** (`CurrencyIsoCode` exists on records) |
| Person Accounts | **Enabled** |

The org is a Salesforce Demo Org (SDO/XDO template): it carries a lot of
pre-built demo content for Sales, Service, Field Service, Commerce, Marketing,
Maps and Slack.

## 2. Is AscendixRE installed?

**No.** No installed package uses the `ascendix` namespace or is named
AscendixRE / Ascendix Search. Because it isn't installed, we have no access to its
metadata or source code. As instructed, we won't try to get the package or work
around its licensing. The functional analysis relies only on Ascendix's public
website, help centre and AppExchange listing.

## 3. Installed packages (51)

All 51 are Salesforce demo or utility packages. The ones that matter to this
project:

| Package | Namespace | Relevance |
|---|---|---|
| Salesforce Maps (Summer 26) | `maps` | Licensed (100 seats). Can plot geocoded Property records. Optional extra on top of our own map LWC. |
| Datatable v4 / FlowScreenComponentsBasePack / FlowActionsBasePack | – / `usf3` | Reusable Flow screen components (we won't depend on them) |
| Document Builder (PSL, 5 seats) | – | Possible native route for document generation (see Known Limitations) |
| CRM Analytics Plus (PSL) | – | Available, but we'll use standard Reports and Dashboards so the app stays portable |

Every other package (FSL, Pardot, Marketing Cloud, Quip, OMS, B2B and so on) is
unrelated, and we won't touch it.

Managed-package source is protected: we can see it only as metadata names and we
won't try to read it. Unmanaged packages are installed as editable metadata, but
none of them relate to real estate.

## 4. Existing unmanaged metadata (counts)

| Type | Count | Real-estate related? |
|---|---|---|
| Custom objects | 93 | None (SDO_*, xDO_*, CGC_*, B2B_*, AI_Agent*, etc.) |
| Apex classes | 327 | None named Property/Lease/Deal/Listing/Commission/CRE/REA |
| Apex triggers | 64 | See below |
| Lightning Web Components | 172 | None with property/lease/deal/cre/rea/commission prefixes (only `reactivityManager`) |
| Aura bundles | 143 | – |
| Visualforce pages | 74 | – |
| Flows (definitions) | 267 | – |
| Permission sets | 303 | – |
| Custom tabs | 58 | – |
| Custom apps | 11 | SDO_Sales_App, SDO_Maps, SDO_Sales_Console, ... (no CRE app) |

### Existing automation on standard objects we'll share

| Object | Existing triggers | Impact on us |
|---|---|---|
| Account | `SDO_Tool_SalesforceRewind_Account`, `LogAccountChange` (active) | We add fields only. No new Account trigger is needed. |
| Contact | `SDO_Tool_SalesforceRewind_Contact`, `LogContactChange` (active) | Same as Account |
| Opportunity | `SDO_Tool_SalesforceRewind_Opportunity` (active), 35 custom fields, record types `SimpleOpportunity` and `ChannelPartner`, standard sales stages | **Reason to keep CRE deals in their own `Deal__c` object** (see the architecture doc) |
| Task / Event | Rewind trigger on Task; `TR004_Event_*` and `AdvRouteEvents` on Event | Our Task automation must tolerate these triggers. Tests will create Tasks through the normal DML path. |

Existing data: 82 Accounts, 150 Contacts, 578 Opportunities. We will neither
change nor delete any existing records.

## 5. Naming-conflict check (planned names)

These names were checked against custom objects in every namespace, against
standard sObjects, and against unmanaged Apex and LWC names:

`Property, Listing, Lease, Deal, Availability, Inquiry, Capital_Source,
Commission, Commission_Plan, Property_Unit, Stacking_Plan, Deal_Party,
Commission_Split, Loan, Space, Comparable, Requirement`

**Result: no conflicts.** As an extra safeguard, all Apex classes, LWCs, Flows,
permission sets and the app will use an `REA_` / `rea` prefix, so nothing can
collide with the SDO content.

## 6. Constraints identified

1. It's a **trial org that expires 2026-12-13**. The GitHub repository is the
   system of record; the org is only a deployment target.
2. Multi-currency is on. Currency fields follow the record's currency, and
   commission maths assumes each deal uses a single currency.
3. Person Accounts are on. Tenants, buyers and landlords that are individuals
   can be Person Accounts, but the design centres on Business Accounts.
4. The deploy must be **additive only**: no destructive changes, and no changes
   to existing page layouts, profiles or the SDO apps. Access is granted through
   new permission sets.
