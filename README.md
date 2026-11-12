# TC Commercial Real Estate (Real Estate REA)

TC Commercial Real Estate is a commercial real estate CRM built natively on
Salesforce by Twopir Consulting. It mirrors the publicly documented functions
of AscendixRE and uses `TC_` naming throughout. It's deployed to the
`REA-Dev` demo org as the Lightning app **TC Commercial Real Estate**.

## What's in it

- **Data model:** 21 custom objects, 343 fields, 25 record types and 37
  validation rules.
- **Configuration:** custom metadata for automation toggles, record naming,
  field mappings, the stacking plan and deal stages.
- **Apex:** 18 classes and 13 triggers. There are 61 tests, all passing, with
  93% coverage of TC code.
- **UI:**
  - 18 Lightning Web Components, including property 360, stacking plan, deal
    pipeline Kanban, property radius search, rent tables, commission grid,
    Close Deal, Convert Inquiry, inquiry matching and dashboards.
  - 6 record pages and 4 app pages.
- **Automation:** 5 flows (including 18/12/6-month lease expiration reminders)
  and a nightly scheduled job.
- **Documents and reporting:**
  - 3 PDF documents: property flyer, lease comp report and tour book.
  - 8 report types, 11 reports and a dashboard.
- **Sample data:** repeatable, fictional sample data, plus an end-to-end
  verification script (23 of 23 checks pass).

## Repository layout

| Path | Contents |
|---|---|
| `force-app/main/default` | Salesforce source (SFDX format) |
| `scripts/model/tc-model.js` | Single source of truth for the data model |
| `scripts/generate.js`, `ui-meta.js`, `lwc-meta.js`, `reports-meta.js` | Metadata generators. Run them with `npm run generate`. |
| `scripts/inventory-xlsx.js` | Builds `docs/Object_Field_Inventory.xlsx`. Run it with `npm run inventory`. |
| `scripts/run-tc-tests.sh` | Deploys Apex and runs the TC tests with coverage |
| `scripts/apex/` | Sample data (4 steps plus cleanup), the scheduled job and end-to-end verification |
| `docs/` | Documentation (see below) |

## Documentation

1. [AscendixRE_Functional_Analysis.md](docs/AscendixRE_Functional_Analysis.md), with the sourced notes in [research/](docs/research/)
2. [Salesforce_Data_Model.md](docs/Salesforce_Data_Model.md) (generated)
3. [Salesforce_ERD.md](docs/Salesforce_ERD.md)
4. [Object_Field_Inventory.xlsx](docs/Object_Field_Inventory.xlsx) (generated)
5. [Apex_Implementation.md](docs/Apex_Implementation.md)
6. [LWC_Components.md](docs/LWC_Components.md)
7. [Automation_Documentation.md](docs/Automation_Documentation.md)
8. [Deployment_Guide.md](docs/Deployment_Guide.md)
9. [Testing_Report.md](docs/Testing_Report.md)
10. [Known_Limitations.md](docs/Known_Limitations.md)
11. [AscendixRE_vs_TC_Comparison.md](docs/AscendixRE_vs_TC_Comparison.md)

Also in `docs/`:
- [00_Org_Assessment.md](docs/00_Org_Assessment.md)
- [Implementation_Plan.md](docs/Implementation_Plan.md)

## Quick start

```bash
sf project deploy start -d force-app -o REA-Dev --test-level RunSpecifiedTests --tests TC_DealServiceTest --tests TC_CommissionServiceTest --tests TC_RentTableServiceTest --tests TC_LeaseServiceTest --tests TC_InquiryServiceTest --tests TC_PlatformServicesTest --tests TC_UIControllerTest --tests TC_FlowAutomationTest
```

The full steps are in the [Deployment Guide](docs/Deployment_Guide.md).

AscendixRE is a trademark of its owner. This project is an independent
implementation built from public documentation only. It contains no AscendixRE
code or assets.
