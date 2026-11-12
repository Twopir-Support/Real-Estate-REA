# Salesforce Data Model — REA Commercial Real Estate CRM

Status: **PROPOSED, awaiting approval.** Nothing has been deployed.
The ERD is in [Salesforce_ERD.md](Salesforce_ERD.md). The module-level
reasoning is in [AscendixRE_Functional_Analysis.md](AscendixRE_Functional_Analysis.md).

## Design principles

1. **Reuse standard objects first.** Account holds companies and individuals:
   tenants, landlords, buyers, sellers, lenders, investors and brokerage firms.
   Contact holds people. Task and Event hold activities. Files hold documents.
   Users are internal brokers.
2. **Express a role as a field or junction, never as an object.** "Tenant",
   "Landlord", "Buyer" and "Seller" are roles an Account plays. They come from
   `Account.CRE_Roles__c` and from `Deal_Party__c.Role__c`, not from separate
   objects.
3. **Use a custom `Deal__c` object, not Opportunity** (decision D1 in the plan).
   Opportunity in this org already carries 578 SDO demo records, sales stages,
   record types and an active trigger. CRE deals need a different stage model
   (Touring → LOI → Lease/Contract), lease economics and fee calculations.
   Bending Opportunity would put the existing demo content at risk.
4. **Don't create a `Stacking_Plan__c` object** (decision D2). A stacking plan is
   a *view* of `Property_Unit__c` + `Lease__c` by floor, so storing it would
   duplicate data that then drifts. The Stacking Plan LWC works it out live.
5. Roll-ups between objects that aren't master-detail are handled in Apex
   service classes: bulk-safe, recursion-guarded, and run in system context only
   for the aggregate write-back.
6. All currency fields follow the record's `CurrencyIsoCode` (multi-currency is
   on). Area is stored in square feet (SF). Rents are stored as **annual $/SF**.

Legend: **R** = required, MD = master-detail, LK = lookup, F = formula,
RS = roll-up summary, A = maintained by Apex.

---

## Standard objects: additive fields only

### Account (fields added, existing ones untouched)

| Label | API name | Type | Notes |
|---|---|---|---|
| CRE Roles | `CRE_Roles__c` | Multi-select picklist | Tenant; Landlord / Owner; Buyer; Seller; Investor; Lender; Brokerage Firm; Property Manager; Developer; Service Provider |
| Portfolio Size (SF) | `Portfolio_SF__c` | Number(14,0), A | Sum of `Total_Building_SF__c` on owned properties |
| Leased Space (SF) | `Leased_SF_As_Tenant__c` | Number(14,0), A | Sum of active leases where the account is the tenant |

### Contact (fields added)

| Label | API name | Type | Notes |
|---|---|---|---|
| CRE Contact Role | `CRE_Contact_Role__c` | Multi-select picklist | Decision Maker; Influencer; Tenant Rep Broker; Listing Broker; Property Manager; Facilities; Attorney; Lender Rep; Investor Rep |
| Outside Broker | `Is_Outside_Broker__c` | Checkbox | Used to filter co-broker splits |

### Task / Event

Activities are enabled on every custom object below. Automation creates Tasks
with `Type`/`Subject` conventions. No new fields are added.

---

## Custom objects

### 1. Property — `Property__c`

The physical asset (building or land). It's the central object.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Property Name | `Name` | Text(80) | R | |
| Property Type | `Property_Type__c` | Picklist | R | Office; Retail; Industrial; Flex; Multifamily; Medical Office; Hospitality; Mixed Use; Land; Special Purpose |
| Property Subtype | `Property_Subtype__c` | Picklist (dependent on Type) | | e.g. Industrial → Warehouse/Distribution, Manufacturing, Cold Storage, Data Center; Retail → Strip Center, Power Center, Mall, Freestanding, Neighborhood Center; Office → CBD, Suburban, Creative/Loft |
| Building Class | `Building_Class__c` | Picklist | | A; B; C |
| Building Status | `Building_Status__c` | Picklist | R | Existing; Under Construction; Proposed; Under Renovation; Demolished |
| Street | `Street__c` | Text(255) | R | |
| City | `City__c` | Text(80) | R | |
| State / Province | `State__c` | Text(40) | | |
| Postal Code | `Postal_Code__c` | Text(20) | | |
| Country | `Country__c` | Text(80) | | default "United States" |
| Location | `Location__c` | Geolocation (6 decimals) | | used by map and radius search |
| Market | `Market__c` | Text(80) | | e.g. "Dallas–Fort Worth" |
| Submarket | `Submarket__c` | Text(80) | | e.g. "Uptown" |
| Owner | `Owner_Account__c` | LK Account | | landlord / owner |
| Property Manager | `Property_Manager__c` | LK Account | | |
| Year Built | `Year_Built__c` | Number(4,0) | | VR: 1800 to current year + 5 |
| Year Renovated | `Year_Renovated__c` | Number(4,0) | | VR: ≥ Year Built |
| Floors | `Floors__c` | Number(3,0) | | |
| Total Building Area (SF) | `Total_Building_SF__c` | Number(12,0) | R | > 0 |
| Land Area (Acres) | `Land_Area_Acres__c` | Number(8,2) | | |
| Parking Spaces | `Parking_Spaces__c` | Number(6,0) | | |
| Parking Ratio (/1,000 SF) | `Parking_Ratio__c` | F Number(4,2) | | `Parking_Spaces__c / (Total_Building_SF__c/1000)` |
| Zoning | `Zoning__c` | Text(40) | | |
| Parcel Number (APN) | `Parcel_Number__c` | Text(40) | | |
| Amenities | `Amenities__c` | Multi-select picklist | | Fitness Center; Conference Center; On-site Security; Food Service; EV Charging; Bike Storage; Dock-high Doors; Grade-level Doors; Rail Served; LEED Certified; Covered Parking |
| Leased Area (SF) | `Leased_SF__c` | Number(12,0) | A | sum of `Lease__c.Leased_SF__c` where Status = Active |
| Available Area (SF) | `Available_SF__c` | Number(12,0) | A | sum of `Availability__c.Available_SF__c` where Status = Available |
| Occupancy % | `Occupancy_Pct__c` | F Percent | | `Leased_SF__c / Total_Building_SF__c` |
| Vacancy % | `Vacancy_Pct__c` | F Percent | | `1 - Occupancy_Pct__c` |
| Active Listings | `Active_Listings__c` | Number(4,0) | A | count of Listing Status = Active |
| Avg Asking Rent ($/SF/yr) | `Avg_Asking_Rent_PSF__c` | Currency(8,2) | A | average across available spaces |
| Sale Price / Value | `Estimated_Value__c` | Currency(16,2) | | |
| Photo URL | `Photo_URL__c` | URL | | shown on card and detail |
| Description | `Description__c` | Long Text(32k) | | |

Validation rules: `REA_Property_Year_Built_Range`, `REA_Property_Renovated_After_Built`, `REA_Property_Area_Positive`.

### 2. Property Unit (Space / Suite) — `Property_Unit__c`

A leasable space inside a property. It drives the stacking plan.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Suite / Unit # | `Name` | Text(80) | R | |
| Property | `Property__c` | **MD Property__c** | R | |
| Floor | `Floor__c` | Number(3,0) | R | 0 = ground; negative = basement |
| Unit Type | `Unit_Type__c` | Picklist | | Office; Retail; Warehouse; Flex; Lab; Storage; Residential; Common Area |
| Area (SF) | `Area_SF__c` | Number(10,0) | R | > 0 |
| Unit Status | `Unit_Status__c` | Picklist | R | Vacant; Occupied; Occupied – Expiring; Under Renovation; Not Leasable (A sets Occupied/Vacant) |
| Position on Floor | `Stack_Position__c` | Number(3,0) | | left-to-right order in the stacking plan |
| Current Tenant | `Current_Tenant__c` | LK Account | A | from the active lease |
| Current Lease | `Current_Lease__c` | LK Lease__c | A | |
| Lease Expiration | `Current_Lease_Expiration__c` | Date | A | |
| Expiration Year | `Expiration_Year__c` | F Text | | `TEXT(YEAR(Current_Lease_Expiration__c))`: drives the stacking-plan colour key |

Roll-ups onto Property (MD): `Unit_Count__c` (RS COUNT), `Total_Unit_SF__c` (RS SUM Area).
VR: `REA_Unit_Floor_Within_Building` (`Floor__c <= Property__r.Floors__c`).

### 3. Listing — `Listing__c`

A marketing assignment to lease or sell a property (or part of one).

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Listing Name | `Name` | Text(80) | R | |
| Property | `Property__c` | LK Property__c | R | (lookup, so listings can be re-parented and keep their own sharing) |
| Listing Type | `Listing_Type__c` | Picklist | R | For Lease; For Sale; For Sale or Lease; Sublease |
| Listing Status | `Listing_Status__c` | Picklist | R | Draft; Active; Under Contract; Leased; Sold; Expired; Withdrawn |
| Listing Client | `Client_Account__c` | LK Account | R | owner / landlord / sublessor |
| Listing Broker | `Listing_Broker__c` | LK User | R | default = owner |
| Agreement Start | `Agreement_Start__c` | Date | R | |
| Agreement Expiration | `Agreement_Expiration__c` | Date | R | VR > Start |
| Asking Price | `Asking_Price__c` | Currency(16,2) | | required when the type includes Sale (VR) |
| Asking Rent ($/SF/yr) | `Asking_Rent_PSF__c` | Currency(8,2) | | required when the type includes Lease (VR) |
| Lease Rate Type | `Lease_Rate_Type__c` | Picklist | | NNN; Gross; Modified Gross; Full Service; Industrial Gross |
| Listing Commission % | `Commission_Pct__c` | Percent(4,2) | | default fee for resulting deals |
| Total Available (SF) | `Total_Available_SF__c` | Number(12,0) | A | sum of linked available Availability |
| Price per SF | `Price_PSF__c` | F Currency | | `Asking_Price__c / Property__r.Total_Building_SF__c` |
| Days on Market | `Days_On_Market__c` | F Number | | `IF(ISPICKVAL(Status,'Active'), TODAY() - Agreement_Start__c, null)` |
| Days to Expiration | `Days_To_Expiration__c` | F Number | | `Agreement_Expiration__c - TODAY()` |
| Marketing Description | `Marketing_Description__c` | Rich Text | | used on the flyer |
| Public Listing | `Is_Public__c` | Checkbox | | |

VRs: `REA_Listing_Expiration_After_Start`, `REA_Listing_Sale_Requires_Price`, `REA_Listing_Lease_Requires_Rent`, `REA_Listing_Active_Requires_Broker`.

### 4. Availability — `Availability__c`

A specific space currently on the market (for lease or sale).

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Availability Name | `Name` | Auto Number `AV-{00000}` | | |
| Property | `Property__c` | LK Property__c | R | |
| Unit / Suite | `Property_Unit__c` | LK Property_Unit__c | | VR: the unit must belong to the same property |
| Listing | `Listing__c` | LK Listing__c | | |
| Availability Type | `Availability_Type__c` | Picklist | R | Direct Lease; Sublease; For Sale; Coworking |
| Space Use | `Space_Use__c` | Picklist | | Office; Retail; Industrial; Flex; Medical; Land |
| Status | `Status__c` | Picklist | R | Available; Pending; Leased; Sold; Off Market |
| Available (SF) | `Available_SF__c` | Number(10,0) | R | > 0 |
| Min Divisible (SF) | `Min_Divisible_SF__c` | Number(10,0) | | VR ≤ Available |
| Max Contiguous (SF) | `Max_Contiguous_SF__c` | Number(10,0) | | |
| Floor | `Floor__c` | Number(3,0) | | defaults from the unit (A) |
| Asking Rent ($/SF/yr) | `Asking_Rent_PSF__c` | Currency(8,2) | | |
| Lease Rate Type | `Lease_Rate_Type__c` | Picklist | | same values as Listing |
| Asking Price | `Asking_Price__c` | Currency(16,2) | | for sale |
| Date Available | `Date_Available__c` | Date | | |
| Min Term (months) | `Min_Term_Months__c` | Number(3,0) | | |
| Annual Asking Rent | `Annual_Asking_Rent__c` | F Currency | | `Available_SF__c * Asking_Rent_PSF__c` |
| Days Vacant | `Days_Vacant__c` | F Number | | `TODAY() - Date_Available__c` when Available |

### 5. Inquiry — `Inquiry__c`

An inbound request or tenant/buyer requirement. It's matched against availabilities.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Inquiry # | `Name` | Auto Number `INQ-{00000}` | | |
| Contact | `Contact__c` | LK Contact | R | |
| Company | `Account__c` | LK Account | | defaults from the contact's account (A) |
| Inquiry Type | `Inquiry_Type__c` | Picklist | R | Lease; Purchase; Investment; General Information |
| Source | `Source__c` | Picklist | R | Website; Phone; Email; Sign Call; Referral; Outside Broker; Listing Portal; Event; Cold Outreach |
| Status | `Status__c` | Picklist | R | New; Contacted; Qualified; Touring; Converted; Closed – No Deal |
| Property Type Wanted | `Property_Type__c` | Picklist | | same values as Property Type |
| Min Size (SF) | `Min_SF__c` | Number(10,0) | | |
| Max Size (SF) | `Max_SF__c` | Number(10,0) | | VR ≥ Min |
| Max Rent ($/SF/yr) | `Max_Rent_PSF__c` | Currency(8,2) | | |
| Max Purchase Price | `Max_Price__c` | Currency(16,2) | | |
| Preferred City | `Preferred_City__c` | Text(80) | | |
| Preferred Submarket | `Preferred_Submarket__c` | Text(80) | | |
| Date Needed | `Date_Needed__c` | Date | | |
| Property of Interest | `Property__c` | LK Property__c | | |
| Listing of Interest | `Listing__c` | LK Listing__c | | |
| Converted Deal | `Converted_Deal__c` | LK Deal__c | | A on conversion |
| Days Open | `Days_Open__c` | F Number | | `TODAY() - DATEVALUE(CreatedDate)` while open |
| Notes | `Notes__c` | Long Text | | |

### 6. Deal — `Deal__c`

A brokerage transaction (lease, sale, sublease, financing, investment).

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Deal Name | `Name` | Text(120) | R | |
| Deal Type | `Deal_Type__c` | Picklist | R | Tenant Representation; Landlord Representation; Buyer Representation; Seller Representation; Sublease; Listing Pursuit; Capital Markets; Consulting |
| Client Role | `Client_Role__c` | Picklist | | Tenant; Owner / Landlord; Buyer; Seller; Sublessor; Borrower; Other (A: defaulted from Deal Type when blank) |
| Stage | `Stage__c` | Picklist | R | Prospecting; Qualification; Touring; Proposal / LOI; Negotiation; Under Contract / Lease Out; Closed Won; Closed Lost |
| Probability % | `Probability__c` | Percent | A | defaults by stage (10/20/30/50/70/90/100/0) and can be overridden |
| Client | `Client_Account__c` | LK Account | R | the party we represent |
| Client Contact | `Client_Contact__c` | LK Contact | | |
| Lead Broker | `Lead_Broker__c` | LK User | R | default = owner |
| Property | `Property__c` | LK Property__c | | |
| Listing | `Listing__c` | LK Listing__c | | |
| Availability | `Availability__c` | LK Availability__c | | |
| Source Inquiry | `Inquiry__c` | LK Inquiry__c | | |
| Capital Source | `Capital_Source__c` | LK Capital_Source__c | | for financing deals |
| Size (SF) | `Size_SF__c` | Number(10,0) | | |
| Lease Term (months) | `Lease_Term_Months__c` | Number(3,0) | | required for lease types when the stage is ≥ Proposal (VR) |
| Rate ($/SF/yr) | `Rate_PSF__c` | Currency(8,2) | | |
| Annual Escalation % | `Escalation_Pct__c` | Percent(4,2) | | |
| Sale Price | `Sale_Price__c` | Currency(16,2) | | required for sale types when the stage is ≥ Proposal (VR) |
| Loan Amount | `Loan_Amount__c` | Currency(16,2) | | financing |
| Transaction Value | `Transaction_Value__c` | Currency(16,2) | A | lease: total escalated rent over the term; sale: price; financing: loan amount (`REA_DealCalculator`) |
| Gross Fee Method | `Fee_Basis__c` | Picklist | | Percent; Amount; $ per SF ($ per SF is valid only for lease types) |
| Fee % | `Fee_Pct__c` | Percent(5,3) | | defaults from the Commission Plan or Listing |
| Flat Fee / $ per SF | `Fee_Amount_Input__c` | Currency(12,2) | | |
| Gross Fee | `Gross_Fee__c` | Currency(14,2) | A | calculated by the commission engine |
| Weighted Fee | `Weighted_Fee__c` | F Currency | | `Gross_Fee__c * Probability__c` |
| Commission Plan | `Commission_Plan__c` | LK Commission_Plan__c | | |
| Est. Close Date | `Est_Close_Date__c` | Date | R | |
| Actual Close Date | `Actual_Close_Date__c` | Date | | A set at Closed Won; VR not in the future |
| Lease Commencement | `Lease_Commencement__c` | Date | | used when the lease is generated |
| Lost Reason | `Lost_Reason__c` | Picklist | | Lost to Competitor; Client Stayed / Renewed; Pricing; Timing; Deal Fell Through; Other. VR: required when Closed Lost |
| Is Lease Deal | `Is_Lease_Deal__c` | F Checkbox | | type in (Tenant Representation, Landlord Representation, Sublease) |
| Is Closed | `Is_Closed__c` | F Checkbox | | |

VRs: `REA_Deal_Lost_Reason_Required`, `REA_Deal_Lease_Terms_Required`, `REA_Deal_Sale_Price_Required`, `REA_Deal_Close_Date_Not_Future`, `REA_Deal_Closed_Won_Locked` (economics locked after close, except for admins).

### 7. Deal Party — `Deal_Party__c` (junction)

Every party to a deal and the role it plays: tenant, landlord, buyer, seller,
lender, outside broker, attorney.

| Label | API name | Type | R | Values |
|---|---|---|---|---|
| Name | `Name` | Auto Number `DP-{00000}` | | |
| Deal | `Deal__c` | **MD Deal__c** | R | |
| Account | `Account__c` | LK Account | R | |
| Contact | `Contact__c` | LK Contact | | |
| Role | `Role__c` | Picklist | R | Tenant; Landlord; Buyer; Prospective Buyer; Seller; Sublessor; Sublessee; Lender; Investor; Outside Broker; Attorney; Property Manager; Other |
| Offer Amount | `Offer_Amount__c` | Currency(16,2) | | for Prospective Buyer offers (Seller / Landlord Rep) |
| Offer Date | `Offer_Date__c` | Date | | |
| Primary | `Is_Primary__c` | Checkbox | | at most one primary per role (A) |

### 8. Lease — `Lease__c`

An executed or pending lease of space in a property.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Lease Name | `Name` | Text(120) | R | default "{Tenant} – {Property} {Suite}" |
| Property | `Property__c` | LK Property__c | R | |
| Unit / Suite | `Property_Unit__c` | LK Property_Unit__c | | VR same property |
| Tenant | `Tenant_Account__c` | LK Account | R | |
| Landlord | `Landlord_Account__c` | LK Account | | defaults from the property owner (A) |
| Originating Deal | `Deal__c` | LK Deal__c | | |
| Lease Type | `Lease_Type__c` | Picklist | R | NNN; Gross; Modified Gross; Full Service; Percentage; Ground Lease |
| Status | `Status__c` | Picklist | R | Draft; Pending Execution; Active; Holdover; Expired; Terminated (A: Active → Expired on the scheduled run) |
| Commencement Date | `Commencement_Date__c` | Date | R | |
| Expiration Date | `Expiration_Date__c` | Date | R | VR > Commencement |
| Term (months) | `Term_Months__c` | F Number | | months between the dates |
| Leased Area (SF) | `Leased_SF__c` | Number(10,0) | R | > 0 |
| Base Rent ($/SF/yr) | `Base_Rent_PSF__c` | Currency(8,2) | R | ≥ 0 |
| Annual Base Rent | `Annual_Base_Rent__c` | F Currency | | `Leased_SF__c * Base_Rent_PSF__c` |
| Monthly Base Rent | `Monthly_Base_Rent__c` | F Currency | | `/12` |
| Escalation Type | `Escalation_Type__c` | Picklist | | None; Fixed %; Fixed $ per SF; CPI |
| Escalation Rate | `Escalation_Rate__c` | Number(6,3) | | % or $/SF depending on type |
| Free Rent (months) | `Free_Rent_Months__c` | Number(3,0) | | |
| TI Allowance ($/SF) | `TI_Allowance_PSF__c` | Currency(8,2) | | |
| Security Deposit | `Security_Deposit__c` | Currency(12,2) | | |
| Total Lease Value | `Total_Lease_Value__c` | Currency(16,2) | A | escalated rent over the term, minus free rent (`REA_LeaseCalculator`) |
| Renewal Option | `Has_Renewal_Option__c` | Checkbox | | |
| Option Notice Date | `Option_Notice_Date__c` | Date | | VR < Expiration |
| Days to Expiration | `Days_To_Expiration__c` | F Number | | |
| Expiration Bucket | `Expiration_Bucket__c` | F Text | | Expired; 0–6 mo; 6–12 mo; 12–24 mo; 24+ mo |

VRs: `REA_Lease_Expiration_After_Commencement`, `REA_Lease_Unit_Same_Property`, `REA_Lease_Option_Notice_Before_Expiration`, `REA_Lease_Area_Positive`.
Apex rule (cross-record, so it can't be a VR): no two **Active** leases on the same unit with overlapping dates.

### 9. Capital Source — `Capital_Source__c`

The lending or investment criteria of a lender or investor Account.

| Label | API name | Type | R | Values |
|---|---|---|---|---|
| Name | `Name` | Text(80) | R | e.g. "Acme Life – Core Debt Program" |
| Institution | `Account__c` | **MD Account** | R | |
| Primary Contact | `Contact__c` | LK Contact | | |
| Source Type | `Source_Type__c` | Picklist | R | Bank; Life Company; CMBS Lender; Debt Fund; Agency (Fannie/Freddie); Credit Union; Private Equity; REIT; Family Office; Private Investor; Pension Fund; Sovereign Wealth |
| Capital Type | `Capital_Types__c` | Multi-select | R | Senior Debt; Construction Loan; Bridge Loan; Mezzanine; Preferred Equity; Joint Venture Equity; Acquisition Equity |
| Property Types | `Property_Types__c` | Multi-select | | same values as Property Type |
| Target Markets | `Target_Markets__c` | Text(255) | | |
| Min Deal Size | `Min_Deal_Size__c` | Currency(16,2) | | |
| Max Deal Size | `Max_Deal_Size__c` | Currency(16,2) | | VR ≥ Min |
| Max LTV % | `Max_LTV_Pct__c` | Percent(5,2) | | |
| Min DSCR | `Min_DSCR__c` | Number(4,2) | | |
| Target Return / Rate % | `Target_Rate_Pct__c` | Percent(5,3) | | |
| Typical Term (years) | `Typical_Term_Years__c` | Number(3,0) | | |
| Status | `Status__c` | Picklist | R | Active; Paused; Inactive |
| Last Contacted | `Last_Contacted__c` | Date | | |

Because it's master-detail to Account, the lender or investor Account gets a
roll-up count: `Account.Capital_Programs__c` (RS COUNT).

### 10. Commission Plan — `Commission_Plan__c`

Default fee and split rules that a deal inherits.

| Label | API name | Type | R | Values |
|---|---|---|---|---|
| Plan Name | `Name` | Text(80) | R | |
| Applies To | `Applies_To__c` | Multi-select | R | the Deal Type values |
| Default Fee Method | `Default_Fee_Basis__c` | Picklist | R | Percent; Amount; $ per SF |
| Default Fee % | `Default_Fee_Pct__c` | Percent(5,3) | | e.g. 6% sale, 4% lease |
| House Split % | `House_Split_Pct__c` | Percent(5,2) | R | company share of the internal-broker gross (e.g. 30%) |
| Outside Broker Default % | `Outside_Broker_Pct__c` | Percent(5,2) | | default co-broker share of the gross fee |
| Payment Terms | `Payment_Terms__c` | Picklist | | 100% at Execution; 50% Execution / 50% Occupancy; 100% at Closing |
| Active | `Is_Active__c` | Checkbox | | |
| Effective Date | `Effective_Date__c` | Date | | |

### 11. Commission (Broker Split) — `Commission__c`

One payee's share of a deal's gross fee.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Commission # | `Name` | Auto Number `COM-{00000}` | | |
| Deal | `Deal__c` | **MD Deal__c** | R | |
| Payee Type | `Payee_Type__c` | Picklist | R | Inside Broker; Analyst; Co-Broker; Referral; Expense |
| Broker (Internal) | `Broker_User__c` | LK User | | VR: required for Inside Broker and Analyst |
| Broker (Outside) | `Broker_Contact__c` | LK Contact | | VR: required for Co-Broker and Referral |
| Split % | `Split_Pct__c` | Percent(5,2) | R | > 0. Apex: total across the deal ≤ 100% |
| Gross Commission | `Gross_Commission__c` | Currency(14,2) | A | `Deal.Gross_Fee__c * Split_Pct__c` |
| House Share | `House_Share__c` | Currency(14,2) | A | Inside Broker and Analyst only: Gross × plan House Split % |
| Net to Broker | `Net_Commission__c` | F Currency | | `Gross_Commission__c - House_Share__c` |
| Status | `Status__c` | Picklist | R | Projected; Earned; Invoiced; Paid; Cancelled (A: Projected → Earned when the deal is Closed Won; Cancelled when Closed Lost) |
| Due Date | `Due_Date__c` | Date | | from the plan's payment terms |
| Paid Date | `Paid_Date__c` | Date | | VR: required when Paid |
| Amount Paid | `Amount_Paid__c` | Currency(14,2) | | |
| Balance Due | `Balance_Due__c` | F Currency | | `Gross_Commission__c - Amount_Paid__c` |

Roll-ups onto Deal (MD): `Total_Split_Pct__c` (RS SUM Split %), `Total_Commission_Paid__c` (RS SUM Amount Paid), `Commission_Count__c`.

### 12. Lease Period (Rent Schedule) — `Lease_Period__c`

One row of a lease's rent table. This mirrors AscendixRE's documented Rent
Table on leases. Rows are generated by `REA_LeaseCalculator` from the lease's
term, rate, escalation and free-rent fields, and can be edited afterwards.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Period # | `Name` | Auto Number `LP-{00000}` | | |
| Lease | `Lease__c` | **MD Lease__c** | R | |
| Period Number | `Period_Number__c` | Number(3,0) | R | 1..n |
| From | `Period_Start__c` | Date | R | |
| To | `Period_End__c` | Date | R | VR ≥ From |
| Rate ($/SF/yr) | `Rate_PSF__c` | Currency(8,2) | R | |
| Free Rent | `Is_Free_Rent__c` | Checkbox | | |
| Duration (months) | `Duration_Months__c` | F Number | | |
| Monthly Rent | `Monthly_Rent__c` | F Currency | | `IF(Is_Free_Rent__c, 0, Rate_PSF__c * Lease__r.Leased_SF__c / 12)` |
| Period Rent | `Period_Rent__c` | Currency(14,2) | A | Annual-ratio method: (days in period ÷ 365) × annual rent |

Roll-up onto Lease (MD): `Total_Scheduled_Rent__c` (RS SUM Period Rent). When
periods exist, `Total_Lease_Value__c` uses this sum.

### 13. Sale — `Sale__c`

A recorded sale of a property: brokered by us, or a market comp. It's created
automatically when a Buyer or Seller Representation deal closes Won, or entered
by hand as a comp.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Sale Name | `Name` | Text(120) | R | default "{Property} – {Sale Date}" |
| Property | `Property__c` | LK Property__c | R | |
| Deal | `Deal__c` | LK Deal__c | | originating deal |
| Sale Date | `Sale_Date__c` | Date | R | |
| Listing Price | `Listing_Price__c` | Currency(16,2) | | |
| Sale Price | `Sale_Price__c` | Currency(16,2) | R | > 0 |
| Buyer | `Buyer_Account__c` | LK Account | | |
| Buyer Contact | `Buyer_Contact__c` | LK Contact | | |
| Seller | `Seller_Account__c` | LK Account | | |
| Seller Contact | `Seller_Contact__c` | LK Contact | | |
| Sale Type | `Sale_Type__c` | Picklist | | Investment; Owner-User; Portfolio; Land; Sale-Leaseback; Distressed |
| Cap Rate % | `Cap_Rate_Pct__c` | Percent(5,2) | | |
| Net Operating Income | `NOI__c` | Currency(14,2) | | |
| Price per SF | `Price_PSF__c` | F Currency | | `Sale_Price__c / Property__r.Total_Building_SF__c` |
| Is Comp Only | `Is_Comp_Only__c` | Checkbox | | true when we didn't broker it |

### 14. Inquiry Match (Prospective Space) — `Inquiry_Match__c`

The junction between an Inquiry and the spaces or listings proposed to it. This
mirrors AscendixRE's documented "Prospective Listings" (status, one Primary).
Rows are created by the **Find Matches** action (`REA_InquiryMatchService`) or
added by hand.

| Label | API name | Type | R | Values / formula |
|---|---|---|---|---|
| Match # | `Name` | Auto Number `IM-{00000}` | | |
| Inquiry | `Inquiry__c` | **MD Inquiry__c** | R | |
| Availability | `Availability__c` | LK Availability__c | | one of Availability or Listing is required (VR) |
| Listing | `Listing__c` | LK Listing__c | | |
| Property | `Property__c` | LK Property__c | | A: derived from the Availability or Listing |
| Match Score | `Match_Score__c` | Number(3,0) | | 0–100, calculated |
| Status | `Status__c` | Picklist | R | Suggested; Sent to Client; Touring; Shortlisted; Rejected; Selected |
| Primary | `Is_Primary__c` | Checkbox | | at most one per Inquiry (A); passed to the Deal on conversion |
| Notes | `Notes__c` | Text(255) | | |

---

## Objects considered and rejected

| Candidate | Decision | Reason |
|---|---|---|
| `Stacking_Plan__c` | Not created | A derived view of Unit + Lease; stored copies would drift. Rendered by the `reaStackingPlan` LWC. AscendixRE likewise builds it from Property floors plus leases and availabilities. |
| Separate Tenant / Landlord / Buyer / Seller objects | Not created | Roles on Account (`CRE_Roles__c`) and on Deal Party |
| `Opportunity` for deals | Not used | Avoids colliding with SDO demo stages, record types and the trigger (D1) |
| `Deal_Period__c` (rent table on the deal) | Deferred | The deal carries rate and escalation. The rent table is generated on the Lease when the deal closes. |
| `Deal_Source__c` / `Term_Sheet__c` (capital markets lender quotes) | Deferred | Capital Source plus the Deal lookup and Deal Party (Lender) cover the basics; see Known Limitations |
| `Commission_Payment__c` (installments) | Deferred | `Due_Date__c`/`Amount_Paid__c` cover a single payment; installments are in Known Limitations |
| Commission Privacy object | Not created | Field-level security does the job instead: only the `REA_CRE_Admin` permission set can read `House_Share__c` and `Net_Commission__c` |
| `Unit_Profile__c` / `Market_Rent__c` | Not created | Not described publicly. `Property_Unit__c` covers units. |

## Object count

**14 new custom objects:**
- From the brief's list: Property, Property Unit, Listing, Availability,
  Inquiry, Deal, Lease, Capital Source, Commission Plan and Commission. Stacking
  Plan is dropped, for the reason in the table above.
- Junctions: Deal Party and Inquiry Match.
- Added to match documented AscendixRE features: Lease Period (rent tables) and
  Sale (sale history and comps).

**6 fields added to standard objects:** 4 on Account (`CRE_Roles__c`,
`Portfolio_SF__c`, `Leased_SF_As_Tenant__c`, `Capital_Programs__c`) and 2 on
Contact.
