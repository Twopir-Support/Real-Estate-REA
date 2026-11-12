# Entity Relationship Diagram — REA Commercial Real Estate CRM

Status: **PROPOSED.** Field-level detail is in [Salesforce_Data_Model.md](Salesforce_Data_Model.md).

- **Solid lines (`||--o{`)**: the child can't exist without its parent
  (master-detail, or a required lookup).
- **Dotted lines (`|o..o{`)**: optional lookups.
- Standard objects are written in CAPS.

```mermaid
erDiagram
    ACCOUNT ||--o{ CONTACT : "employs"
    ACCOUNT ||--o{ Capital_Source__c : "MD: lending/investing programs"
    ACCOUNT |o..o{ Property__c : "Owner / Property Manager"

    Property__c ||--o{ Property_Unit__c : "MD: suites / spaces"
    Property__c ||--o{ Listing__c : "marketed by"
    Property__c ||--o{ Availability__c : "has available space"
    Property__c ||--o{ Lease__c : "leased under"
    Property__c |o..o{ Deal__c : "subject of"
    Property__c |o..o{ Inquiry__c : "inquired about"

    Property_Unit__c |o..o{ Availability__c : "offered as"
    Property_Unit__c |o..o{ Lease__c : "occupied under"
    Listing__c |o..o{ Availability__c : "groups"
    Listing__c |o..o{ Deal__c : "generates"
    ACCOUNT ||--o{ Listing__c : "listing client"

    CONTACT ||--o{ Inquiry__c : "submits"
    Inquiry__c |o..o| Deal__c : "converts to"
    Availability__c |o..o{ Deal__c : "transacted in"

    ACCOUNT ||--o{ Deal__c : "client"
    Deal__c ||--o{ Deal_Party__c : "MD: parties & roles"
    ACCOUNT ||--o{ Deal_Party__c : "plays role"
    Deal__c ||--o{ Commission__c : "MD: broker splits"
    Commission_Plan__c |o..o{ Deal__c : "fee rules"
    Capital_Source__c |o..o{ Deal__c : "finances"
    Deal__c |o..o{ Lease__c : "results in"

    ACCOUNT ||--o{ Lease__c : "tenant / landlord"
    Lease__c ||--o{ Lease_Period__c : "MD: rent schedule"
    Property__c ||--o{ Sale__c : "sale history / comps"
    Deal__c |o..o{ Sale__c : "results in"
    Deal__c |o..o{ Listing__c : "Listing Pursuit won"
    Inquiry__c ||--o{ Inquiry_Match__c : "MD: prospective spaces"
    Availability__c |o..o{ Inquiry_Match__c : "proposed"
    Listing__c |o..o{ Inquiry_Match__c : "proposed"
    USER |o..o{ Commission__c : "internal broker"
    CONTACT |o..o{ Commission__c : "outside broker"

    Property__c {
        Text Name
        Picklist Property_Type__c
        Picklist Building_Class__c
        Geolocation Location__c
        Number Total_Building_SF__c
        Number Leased_SF__c "Apex rollup"
        Percent Occupancy_Pct__c "formula"
    }
    Property_Unit__c {
        Text Name "Suite #"
        MD Property__c
        Number Floor__c
        Number Area_SF__c
        Picklist Unit_Status__c
        Lookup Current_Lease__c "Apex"
    }
    Listing__c {
        Picklist Listing_Type__c
        Picklist Listing_Status__c
        Date Agreement_Expiration__c
        Currency Asking_Price__c
        Currency Asking_Rent_PSF__c
    }
    Availability__c {
        Picklist Status__c
        Number Available_SF__c
        Currency Asking_Rent_PSF__c
        Date Date_Available__c
    }
    Inquiry__c {
        Picklist Inquiry_Type__c
        Picklist Status__c
        Number Min_SF__c
        Number Max_SF__c
        Lookup Converted_Deal__c
    }
    Deal__c {
        Picklist Deal_Type__c
        Picklist Stage__c
        Currency Transaction_Value__c "Apex"
        Currency Gross_Fee__c "Apex"
        Date Est_Close_Date__c
    }
    Deal_Party__c {
        MD Deal__c
        Lookup Account__c
        Picklist Role__c
    }
    Lease__c {
        Picklist Lease_Type__c
        Picklist Status__c
        Date Commencement_Date__c
        Date Expiration_Date__c
        Number Leased_SF__c
        Currency Total_Lease_Value__c "Apex"
    }
    Commission__c {
        MD Deal__c
        Picklist Payee_Type__c
        Percent Split_Pct__c
        Currency Gross_Commission__c "Apex"
        Picklist Status__c
    }
    Commission_Plan__c {
        Picklist Default_Fee_Basis__c
        Percent Default_Fee_Pct__c
        Percent House_Split_Pct__c
    }
    Capital_Source__c {
        MD Account__c
        Picklist Source_Type__c
        MultiPicklist Capital_Types__c
        Currency Max_Deal_Size__c
    }
    Lease_Period__c {
        MD Lease__c
        Date Period_Start__c
        Date Period_End__c
        Currency Rate_PSF__c
        Currency Period_Rent__c "Apex"
    }
    Sale__c {
        Lookup Property__c
        Date Sale_Date__c
        Currency Sale_Price__c
        Percent Cap_Rate_Pct__c
    }
    Inquiry_Match__c {
        MD Inquiry__c
        Lookup Availability__c
        Number Match_Score__c
        Picklist Status__c
        Checkbox Is_Primary__c
    }
```

## Relationship summary

| Child | Parent | Type | Delete behaviour |
|---|---|---|---|
| Property_Unit__c | Property__c | Master-detail | Cascade |
| Deal_Party__c | Deal__c | Master-detail | Cascade |
| Commission__c | Deal__c | Master-detail | Cascade (the Closed Won lock stops accidental deletes) |
| Capital_Source__c | Account | Master-detail | Cascade |
| Lease_Period__c | Lease__c | Master-detail | Cascade |
| Inquiry_Match__c | Inquiry__c | Master-detail | Cascade |
| Sale__c | Property__c | Lookup (required) | Restrict |
| Listing__c, Availability__c, Lease__c | Property__c | Lookup (required) | Restrict delete: a property with leases or listings can't be deleted |
| Availability__c, Lease__c | Property_Unit__c | Lookup | Clear |
| Deal__c | Property / Listing / Availability / Inquiry / Capital Source / Commission Plan | Lookup | Clear |
| Lease__c | Deal__c | Lookup | Clear |
| Inquiry__c | Contact | Lookup (required) | Restrict |
| Deal__c, Listing__c, Lease__c | Account (client / tenant / landlord) | Lookup | Restrict on required lookups |

## Key automated data flows

```mermaid
flowchart LR
    INQ[Inquiry] -- "Find Matches (Apex)" --> IM[Inquiry Match rows] --> AV[Availability]
    INQ -- "Convert (Apex)" --> DEAL[Deal]
    DEAL -- "Closed Won + lease type" --> LEASE[Lease + rent schedule]
    DEAL -- "Closed Won + buyer/seller rep" --> SALE[Sale]
    DEAL -- "Closed Won + listing pursuit" --> LIST[Listing]
    DEAL -- "Closed Won" --> AVS[Availability → Leased/Sold]
    DEAL -- "fee recalculated" --> COM[Commission splits]
    LEASE -- "Active" --> UNIT[Unit: Occupied, current tenant]
    LEASE -- "SF rollup" --> PROP[Property: Leased SF / Occupancy]
    AV -- "SF rollup" --> PROP
    SCHED[Scheduled Flow daily] -- "18/12/6 months before expiry" --> TASK[Follow-up Tasks + email alert]
```
