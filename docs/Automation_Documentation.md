# Automation — TC Commercial Real Estate

## Flows

All five flows are active in `REA-Dev`. Each one stops immediately when
`TC_Bypass_Settings__c.TC_Bypass_Flows__c` is set.

| Flow | Type / trigger | Behaviour |
|---|---|---|
| `TC_Lease_Expiration_Reminders` | Scheduled, daily 06:00 UTC, on Active leases | Creates a task for the lease owner when the lease expires exactly 18, 12 or 6 months from today; these are the thresholds AscendixRE documents. At 6 months the task is High priority and the owner is also emailed. To change the thresholds, edit the `Date_18`, `Date_12` and `Date_6` formulas. |
| `TC_Listing_Expiration` | Scheduled, daily 06:15 UTC, on Active listings with an expiration date | Creates a task 30 days before the agreement expires. Sets the listing to Expired once the date has passed, which also updates the property's active listing count. |
| `TC_Inquiry_New_Follow_Up` | Record-triggered, after create, on Inquiry | Creates a High-priority call task for the owner, due tomorrow |
| `TC_Deal_Stage_Tasks` | Record-triggered, after update on Deal, when Stage or Status changes | LOI: task "Send the LOI to the client". Lease / PSA Out: task "Collect executed documents". Won: email to the lead broker. |
| `TC_Commission_Trigger` | Autolaunched hook | Runs for every commission saved from the commission grid, with input and output variable `commission`. It mirrors AscendixRE's Commission_Trigger flow. By default it sets a 30% house share on an inside broker who has none. |

## Apex automation (triggers)

| Object | On save |
|---|---|
| Property | Property Type is set from the record type; the owner's portfolio SF is updated |
| Listing | Prefilled from the Property (blank fields only, via `PROPERTY_TO_LISTING` mappings); named; property active-listing count updated |
| Availability | Unit, floor and size defaults; named; property and listing available SF updated |
| Lease | Landlord defaults to the property owner; unit details copied; overlap check; named; rent table generated; unit marked Occupied or Vacant; property leased SF updated |
| Lease Period / Deal Period | Duration, rent per month and total rent calculated. Deal periods also recalculate the deal value and fee. |
| Deal | Defaults, probability, client fields, gross value and fee. On Won: creates the Lease, Sale or Listing, closes the Availability and marks commissions Earned. On Lost: commissions Cancelled. |
| Commission | Record type, method and status defaults; split validation; all of the deal's commissions recalculated |
| Inquiry | Company and contact details defaulted; the Listing becomes the primary prospective listing |
| Prospective Listing / Prospective Buyer | A single primary per parent. The primary buyer fills the deal's buyer fields. |
| Term Sheet | Inherits deal, capital source and lender name from its deal source |
| Sale | Named |

## Scheduled Apex

`TC_DailyScheduler` is scheduled as **TC Daily Job** at 02:00 every day.
- **Lease status sweep:** Pending leases that have commenced become Active, and
  Active leases past their expiration become Expired. The unit and property
  roll-ups recalculate as a result.
- **Contact follow-up sequences:** contacts with "Automated Follow-up Tasks"
  ticked get the next task in their 30-60-90 day, monthly or quarterly sequence.

## Validation rules

There are 37 validation rules, all prefixed `TC_` and all switchable off with
the bypass setting. They are listed in the data model doc and in the
"Validation Rules" sheet of `Object_Field_Inventory.xlsx`. They cover:
- date order
- positive sizes and prices
- unit and property consistency
- lost and disqualified reasons
- fee method requirements
- commission payee requirements
- AscendixRE's documented rules `GrossFeeRatePerUOM` and
  `PreventBlankRateAndRentPerMonth`.

## Formula fields

The formula fields include:
- occupancy and vacancy %
- full address
- days on market and days to expiration
- term in months
- annual and monthly rent
- expiration bucket and expiration year
- weighted fee
- deal type
- net commission and balance due
- price per SF
- days vacant and days open.

## Configuration switches (custom metadata)

| Setting | Default |
|---|---|
| `TC_AUTO_Client_Field_Population` | on |
| `TC_AUTO_Close_Deal_Create_Records` | on |
| `TC_AUTO_Lease_Rent_Table_From_Deal` | on |
| `TC_AUTO_Generate_Rent_Table` | on |
| `TC_AUTO_Record_Naming` | on |
| `TC_VAL_Commission_Split_100` | on |
| `TC_VAL_Inside_Broker_100` | **off**, as in AscendixRE |
| `TC_VAL_Unit_Lease_Overlap` | on |
