# Entity Relationship Diagram — TC Commercial Real Estate

This mirrors the AscendixRE object structure documented publicly. Field-level
detail is in [Salesforce_Data_Model.md](Salesforce_Data_Model.md).

How to read the diagram:
- **Solid lines** are master-detail relationships or required lookups.
- **Dotted lines** are optional lookups.
- Standard objects are in capitals.

## Core brokerage model

```mermaid
erDiagram
    ACCOUNT ||--o{ CONTACT : employs
    ACCOUNT |o..o{ TC_Property__c : "Owner/Landlord, Property Manager, Listing Broker Co."
    TC_Property__c ||--o{ TC_Unit__c : "MD: units / suites"
    TC_Unit_Profile__c |o..o{ TC_Unit__c : "template"
    TC_Property__c ||--o{ TC_Availability__c : "vacant space"
    TC_Unit__c |o..o{ TC_Availability__c : "offered as"
    TC_Property__c ||--o{ TC_Listing__c : "listing agreements"
    TC_Listing__c |o..o{ TC_Availability__c : "markets"
    TC_Property__c ||--o{ TC_Lease__c : "lease abstracts"
    TC_Unit__c |o..o{ TC_Lease__c : "occupied under"
    ACCOUNT ||--o{ TC_Lease__c : "tenant"
    TC_Lease__c ||--o{ TC_Lease_Period__c : "MD: rent table"
    TC_Property__c ||--o{ TC_Sale__c : "sale history / comps"
    TC_Property__c |o..o{ TC_Market_Rent__c : "benchmarks"

    TC_Inquiry__c ||--o{ TC_Prospective_Listing__c : "MD: listings proposed"
    TC_Listing__c ||--o{ TC_Prospective_Listing__c : "prospective inquiries"
    TC_Listing__c |o..o{ TC_Inquiry__c : "inquired about"
    TC_Inquiry__c |o..o| TC_Deal__c : "converts to"

    TC_Property__c |o..o{ TC_Deal__c : "subject property"
    TC_Availability__c |o..o{ TC_Deal__c : "space"
    ACCOUNT |o..o{ TC_Deal__c : "client / tenant / landlord / buyer / lender"
    TC_Deal__c ||--o{ TC_Deal_Period__c : "MD: rent table"
    TC_Deal__c ||--o{ TC_Commission__c : "MD: commissions"
    TC_Deal__c ||--o{ TC_Prospective_Buyer__c : "MD: buyers (seller rep)"
    TC_Deal__c ||--o{ TC_Offer__c : "MD: offers"
    TC_Prospective_Buyer__c |o..o{ TC_Offer__c : "made by"
    TC_Deal__c |o..o{ TC_Lease__c : "Won: creates"
    TC_Deal__c |o..o{ TC_Sale__c : "Won: creates"
    TC_Deal__c |o..o{ TC_Listing__c : "Listing Pursuit Won: creates"
    USER |o..o{ TC_Commission__c : "inside broker"
```

## Capital markets and relationships

```mermaid
erDiagram
    TC_Deal__c ||--o{ TC_Deal_Source__c : "MD: lenders approached"
    TC_Capital_Source__c ||--o{ TC_Deal_Source__c : "capital source"
    TC_Deal_Source__c ||--o{ TC_Term_Sheet__c : "MD: quotes"
    TC_Deal__c ||--o{ TC_Deal_Property__c : "MD: multiple properties"
    TC_Property__c ||--o{ TC_Deal_Property__c : "included in"
    ACCOUNT |o..o{ TC_Capital_Source__c : "institution"
    USER ||--o{ TC_Relationship__c : "internal user"
    TC_Relationship__c }o..o| ACCOUNT : "for"
    TC_Relationship__c }o..o| TC_Property__c : "for"
    TC_Relationship__c }o..o| TC_Listing__c : "for"
    TC_Relationship__c }o..o| TC_Deal__c : "for"
```

## Relationship summary

| Child | Parent | Type | On parent delete |
|---|---|---|---|
| TC_Unit__c | TC_Property__c | Master-detail | Cascade |
| TC_Deal_Period__c, TC_Commission__c, TC_Prospective_Buyer__c, TC_Offer__c, TC_Deal_Source__c, TC_Deal_Property__c | TC_Deal__c | Master-detail | Cascade |
| TC_Lease_Period__c | TC_Lease__c | Master-detail | Cascade |
| TC_Prospective_Listing__c | TC_Inquiry__c | Master-detail | Cascade |
| TC_Term_Sheet__c | TC_Deal_Source__c | Master-detail | Cascade |
| TC_Availability__c, TC_Listing__c, TC_Lease__c, TC_Sale__c | TC_Property__c | Required lookup | Delete blocked |
| TC_Lease__c | Account (Tenant) | Required lookup | Delete blocked |
| TC_Prospective_Listing__c | TC_Listing__c | Required lookup | Delete blocked |
| TC_Deal_Source__c | TC_Capital_Source__c | Required lookup | Delete blocked |
| All other lookups | – | Optional lookup | Field cleared |

## Automated data flows

```mermaid
flowchart LR
    INQ[Inquiry] -- "Convert" --> ACC[Account + Contact] & DEAL[Deal]
    INQ -- "Find Matches (TC extra)" --> PL[Prospective Listings]
    DEAL -- "Won · Tenant/Landlord Rep" --> LEASE[Lease + Lease Periods]
    DEAL -- "Won · Buyer/Seller Rep" --> SALE[Sale]
    DEAL -- "Won · Listing Pursuit" --> LIST[Listing]
    DEAL -- "Won" --> AV[Availability → Closed]
    DEAL -- "fee recalculated" --> COM[Commissions: gross, house, net]
    DP[Deal Periods] -- "total rent" --> DEAL
    LEASE -- "Active" --> UNIT[Unit: Occupied, current tenant]
    LEASE & AV -- "SF roll-up" --> PROP[Property: leased, available, occupancy]
    SCHED[Daily schedule] -- "18 / 12 / 6 months" --> TASK[Lease expiration tasks]
```

The field mappings used on deal close are records of
`TC_Object_Field_Mapping__mdt`, in the groups `DEAL_TO_LEASE`, `DEAL_TO_SALE`,
`DEAL_TO_LISTING`, `DEAL_TO_AVAILABILITY` and `PROPERTY_TO_LISTING`. An admin
can change them without editing code.
