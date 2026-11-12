# Known Limitations — TC Commercial Real Estate

## Access and fidelity to AscendixRE

- **AscendixRE is not installed, and its source was not used.** The TC build
  is based only on AscendixRE's public help centre and AppExchange listing.
  ascendix.com blocked direct access, so facts from those pages come from
  search snippets only.
- **About 30% of the data model's detail is documented publicly.**

  | Part of the data model | Documented publicly |
  |---|---|
  | Objects | about 95% |
  | Fields | about 30% |
  | Picklist values | about 25% |
  | API names | about 2% |

  Everything else is TC design. Of the 343 fields on TC objects, 181 (53%) map
  to fields AscendixRE documents. The per-field source is in
  `Object_Field_Inventory.xlsx`.
- **Undocumented picklists are TC design.** These include deal stages, lease
  types, property types and classes, availability statuses (except Closed),
  and rent types.
- **Objects named but not described are TC design.** Unit, Unit Profile,
  Market Rent and Offer have no published fields, so their fields are TC's own.
- **API names differ.** TC uses the `TC_` prefix; AscendixRE uses the
  `ascendix__` namespace.

## Functional gaps against AscendixRE

| Area | Gap | Possible next step |
|---|---|---|
| Ascendix Search | No polygon, circle or rectangle drawing; no Google Maps or OpenStreetMap; no ad-hoc lists; no mass email (150 per send); no Mailchimp | Salesforce Maps is licensed in the org and supports shapes and territories |
| Composer | Three fixed PDF templates; no template designer, microsites, HTML email or bulk tour books | Document Builder (5 licences in org) or a template designer |
| Web-to-Inquiry | Not built; it needs an Experience Cloud site and guest user | Screen flow on an Experience site |
| MarketSpace / listing portals | No portal and no LoopNet or Crexi feeds | Integration project |
| AI Suite | No AI Agent, Harvest, Composer AI or xRE Connector | Agentforce or Claude integration |
| Commissions | No tiered payout plans or payment instalment schedules; AscendixRE claims these in marketing but does not document them | `TC_Commission_Payment__c` child object |
| Commission privacy | Field-level security hides House and Net from brokers, but brokers can still see other brokers' gross on deals they can access | Sharing on Commission (needs a lookup instead of master-detail) |
| Stacking plan | PDF and Excel export are not implemented in the component | Visualforce PDF and CSV export |
| Admin Console | Settings are edited in Setup (custom metadata) rather than in a custom console app | Admin LWC |
| Deal record types | Asset Management, Lease Administration, Project Management and Property Management exist, but have no special behaviour | Per-type logic once requirements are known |
| Relationship Type | A picklist rather than custom metadata | Move to metadata if admins need it |

## Platform and environment

- **TC objects count against the org's custom-object limit.** Only certified
  AppExchange packages get the exemption.
- **REA-Dev is a trial that expires on 2026-12-13.** The GitHub repository is
  the source of truth, and the deploy is repeatable (see the Deployment Guide).
- **Multi-currency.** Calculations stay in each record's currency. Dashboard
  aggregates sum raw amounts in the corporate currency without conversion.
- **Flow emails** depend on the org's deliverability setting; trial orgs often
  default to system emails only.
- **Scheduled flows** first run on 2026-11-13.
- **Visual verification.** The Lightning UI compiled, deployed and has
  controller tests. It was not checked visually by the build, so a
  click-through is recommended.
- **Testing scope.** Only one internal user exists, so broker-level
  dashboards show a single broker, and permission tests use a test-only user.
- **Images.** Sample properties have no images (we did not hotlink third-party
  photos). Upload images with the Image Viewer, or set Primary Image URL.
