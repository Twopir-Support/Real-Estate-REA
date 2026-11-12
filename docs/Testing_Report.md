# Testing Report — TC Commercial Real Estate

**Run date:** 2026-11-12. **Org:** `REA-Dev`.

**Result:** 61 of 61 Apex tests pass. Coverage of TC code is 93.4% (1,665 of
1,782 lines). The end-to-end check against live sample data passes all 23
assertions.

## 1. Apex tests

**How the tests were run:**
- Command: `scripts/run-tc-tests.sh`.
- Test level: `RunSpecifiedTests` with the TC test classes only. The org's 327
  existing SDO classes were not run.
- Total time: 48.7 seconds.

| Test class | Tests | What it covers |
|---|---|---|
| `TC_DealServiceTest` | 12 | Defaults, client auto-population, probability by stage and manual override. Fee methods: Percent, $ per SF, $ per SF rejected on sale deals. Lost reason required. Close Deal creating a lease and rent table, a sale or a listing, and closing the availability. No duplicate lease when a deal is re-won. Optional inside-broker-100% rule. Bulk insert of 200 deals. Financing value. Broker permissions (no House or Net). |
| `TC_CommissionServiceTest` | 7 | Co-broker and expense amounts come off the top, inside brokers split the net, house share and net commission. Recalculation when the fee changes, a commission is edited or a commission is deleted. Rejections: outside splits over 100%, inside splits over 100%, inside broker with no user, Amount method with no amount. Status follows Won, Lost and re-open. Bulk rows capped at 30. |
| `TC_RentTableServiceTest` | 5 | Schedule with escalation and free rent. Annual Ratio Rent vs Monthly Rate. Duration maths. Review warnings for gaps, overlaps and blank rent. Lease rent table generation and roll-up, with regenerate and keep-existing. Validation rules. Deal periods driving gross deal value. |
| `TC_LeaseServiceTest` | 8 | Unit occupancy sync and property roll-ups. Terminate frees the unit. Delete and undelete. Overlap prevention, including two overlapping leases in one transaction. Lease validation rules. Bypass setting. Daily sweep (Pending to Active, Active to Expired) through the scheduler. Availability roll-ups to property and listing. Owner portfolio square footage. Contact follow-up sequences. |
| `TC_InquiryServiceTest` | 5 | Listing on an inquiry becomes its primary prospective listing; only one primary. Convert creates Account, Contact and Deal. Second convert rejected. Warning when the listing is on another open deal. Find Matches scoring and de-duplication. Inquiry validation rules. |
| `TC_PlatformServicesTest` | 6 | Field mapping engine and value coercion. Settings and stage metadata. Naming service on and off. Term sheet inheritance. Primary prospective buyer fills the deal's buyer fields. Handler bypass. |
| `TC_UIControllerTest` | 8 | Property summary, scorecards on 5 objects, stacking plan, search by filters and radius, both dashboards, pipeline, stage update, Close Deal, rent table and commission grid (including the over-100% error path), term sheets, inquiry conversion and matching, images, relationships, PDF generation and the Visualforce controllers. |
| `TC_FlowAutomationTest` | 4 | New-inquiry follow-up task, bypass setting stops flows, deal stage tasks, and the commission flow hook setting the default house %. |

Negative scenarios are asserted with `Database.insert/update(..., false)`, or
with try/catch on the expected exception, followed by a check of the error
message. Bulk behaviour is tested with 200 deals in one transaction.

### Coverage by class

| Class / trigger | Lines covered | % |
|---|---|---|
| `TC_DealService` | 194/201 | 97% |
| `TC_LeaseService` | 89/90 | 99% |
| `TC_PropertyRollupService` | 49/50 | 98% |
| `TC_DocumentController` | 59/60 | 98% |
| `TC_CommissionService` | 108/112 | 96% |
| `TC_RentTableService` | 200/211 | 95% |
| `TC_FieldMappingService` | 35/37 | 95% |
| `TC_Settings` | 61/64 | 95% |
| `TC_DailyScheduler` | 28/30 | 93% |
| `TC_DealUIController` | 177/191 | 93% |
| `TC_PropertyUIController` | 198/214 | 93% |
| `TC_RecordHandlers` | 154/165 | 93% |
| `TC_NamingService` | 52/57 | 91% |
| `TC_InquiryService` | 141/161 | 88% |
| `TC_RecordUIController` | 71/82 | 87% |
| `TC_TriggerHandler` | 36/44 | 82% |
| 13 triggers | 1/1 each | 100% |
| **Total** | **1,665/1,782** | **93.4%** |

Two classes are below the 85% target, though both are above the 75% the
platform requires:
- `TC_TriggerHandler` (82%): its uncovered lines are the empty virtual
  before-delete and after-undelete hooks that no TC object uses.
- `TC_RecordUIController`: its uncovered lines are permission-denied branches.
  These only run for users without object access, which tests run as an admin
  don't exercise.

## 2. End-to-end verification on live data

`scripts/apex/verify-e2e.apex` is read-only. It ran against the loaded sample
data, and the output is saved in [generated/e2e-result.txt](generated/e2e-result.txt).

| Check | Result |
|---|---|
| 12 sample properties loaded | PASS |
| Uptown leased SF roll-up = sum of active leases (297,000) | PASS |
| Occupancy formula (Uptown 75.0%) | PASS |
| Active listing count on property | PASS |
| Every active unit lease marks its unit Occupied (92/92) | PASS |
| Every lease has a rent table (628 periods generated) | PASS |
| Lease named by the name-format metadata; total rent rolled up | PASS |
| Won deal moved to Executed at 100% | PASS |
| Won tenant rep deal created a lease with the copied rent table | PASS |
| Won seller rep deal created a sale | PASS |
| Won listing pursuit created a listing | PASS |
| Won deal commissions all Earned | PASS |
| Lost deal commissions Cancelled | PASS |
| Co-broker takes 50% of the gross fee | PASS |
| Inside broker gets the net deal fee, with house share at 30% | PASS |
| Find Matches created prospective listings (53) | PASS |
| Converted inquiries link to their deals | PASS |
| New-inquiry flow created 15 follow-up tasks | PASS |
| Term sheets inherit lender, capital source and deal | PASS |
| Dashboard controller returns KPIs (pipeline $5.26M) | PASS |
| Stacking plan builds 18 floors for Uptown | PASS |
| Radius search finds Dallas properties within 10 miles | PASS |
| Nightly job scheduled | PASS |

One assertion failed on the first run: it expected exactly one Earned
commission on a deal that also has a co-broker. Both commissions were
correctly Earned, so the assertion was corrected to check that none were left
Projected.

## 3. Defects found and fixed during the build

| Found by | Defect | Fix |
|---|---|---|
| Apex tests | The naming service compared a text Name to a record Id, throwing `Invalid id` on save | Compare as text |
| Apex tests | Close Deal query omitted Deal Sub Type and lease fields | Fields added to the dynamic query |
| Apex tests | Bulk test queried inside a loop (test defect) | Hoisted the queries |
| Apex tests | Commission dashboard test used a date that falls in next year | Pass the matching year |
| Deploy validation | User lookups cannot be required at the field level | Validation rule `TC_User_Required` |
| Deploy validation | Auto-number Name marked Required on layouts | Read-only |
| Deploy validation | Report columns on custom report types need `Object$Field` | Generator fixed |

## 4. Not verified

- **Visual check of the Lightning pages in a browser.** Every LWC compiled and
  deployed, and its Apex controller is covered by tests. Rendering, drag and
  drop, and the PDF layout have **not** been checked visually by the build.
  A click-through on the TC app is recommended. Start with the property record
  page (Property 360 and Stacking Plan tabs), Deal Pipeline, Property Search
  and Close Deal.
- **Scheduled flows.** The 18/12/6-month lease reminders and listing expiry
  first run on 2026-11-13. Their branch logic is the same pattern as the
  record-triggered flows, which are tested.
- **Flow emails.** These are subject to the org's email deliverability
  setting. Trial orgs often default to system emails only.
- **No LWC Jest tests.** Only Apex-level tests were written.
