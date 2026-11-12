# Deployment Guide — TC Commercial Real Estate

Every TC component is additive and `TC_`-prefixed. Deploying it never modifies
or deletes existing org metadata. The only additions to standard objects are
new `TC_` fields on Account and Contact.

## Prerequisites

- Salesforce CLI (`sf`) v2. The build used 2.152.
- Node 18 or later, for the generators and the Excel inventory.
- A target org on Enterprise or Unlimited edition with an admin user.
  Multi-currency is supported.

## Deploy to a new org

```bash
sf org login web --alias TARGET
```

```bash
npm install
```

```bash
npm run generate
```

```bash
sf project deploy start -d force-app -o TARGET --test-level RunSpecifiedTests --tests TC_DealServiceTest --tests TC_CommissionServiceTest --tests TC_RentTableServiceTest --tests TC_LeaseServiceTest --tests TC_InquiryServiceTest --tests TC_PlatformServicesTest --tests TC_UIControllerTest --tests TC_FlowAutomationTest --wait 60
```

```bash
sf org assign permset -n TC_CRE_Admin -o TARGET
```

```bash
sf apex run -o TARGET -f scripts/apex/schedule-daily-job.apex
```

Notes on these commands:
- `npm run generate` is optional; the generated files are already committed.
- The deploy runs the TC tests only; the target org's own tests are not run.
- Give day-to-day users `TC_CRE_Broker` instead of `TC_CRE_Admin`.

**Validate without deploying:** add `--dry-run` to the deploy command.

## Phases used for REA-Dev

| Phase | Source | Result |
|---|---|---|
| P1 data model | `manifest/package-p1-data-model.xml` | 596/596 |
| P2 Apex | `classes`, `triggers` | 47 tests passed |
| P3 UI | `lwc`, `pages`, `components`, `flexipages`, `tabs`, `applications`, `quickActions`, `layouts`, `permissionsets` | 18 LWCs and 52 UI components |
| P4 automation | `flows` + scheduled job | 5 flows active |
| P5 reporting | `reportTypes`, `reports`, `dashboards` | 22/22 |
| P6 data | `scripts/apex/sample-data-*.apex` | Loaded; 23/23 end-to-end checks |

## Sample data

```bash
sf apex run -o TARGET -f scripts/apex/sample-data-1-accounts-properties.apex
```

```bash
sf apex run -o TARGET -f scripts/apex/sample-data-2-listings-leases.apex
```

```bash
sf apex run -o TARGET -f scripts/apex/sample-data-3-deals.apex
```

```bash
sf apex run -o TARGET -f scripts/apex/sample-data-4-inquiries-capital-comps.apex
```

```bash
sf apex run -o TARGET -f scripts/apex/verify-e2e.apex
```

- **Remove the sample set** with `scripts/apex/sample-data-cleanup.apex`. It
  deletes only records linked to companies whose Site is `[TC Sample]`, and
  the deleted records go to the Recycle Bin.
- **The scripts refuse to run twice.** Run the cleanup script before reloading.

## Changing the model

1. Edit `scripts/model/tc-model.js`.
2. Run `npm run generate` and `npm run inventory`.
3. Review the diff, then deploy.

The generator also rewrites `docs/Salesforce_Data_Model.md` and the field
inventory, so the docs never drift from the metadata.

## Using the app

1. Open the App Launcher and choose **TC Commercial Real Estate**.
2. The navigation bar has these tabs:
   - Home
   - Properties, Listings, Availabilities, Inquiries
   - Deals, Deal Pipeline
   - Leases, Sales
   - Commissions, Commission Dashboard
   - Property Search
   - Capital Sources, Market Rents, Units, Unit Profiles
   - Accounts, Contacts
   - Reports, Dashboards
3. For reports and dashboards, open the **TC Reports** folder and the
   **TC Dashboards → TC Brokerage Dashboard**.

## Rollback

- To turn automation off, set `TC_Bypass_Settings__c` at org level.
- To remove the app entirely, remove these in reverse order:
  1. dashboards, reports and report types
  2. the app, flexipages, tabs and quick actions
  3. flows
  4. Apex and LWCs
  5. permission sets
  6. objects and the Account/Contact `TC_` fields

  No existing component depends on TC metadata.
