# Propertybase (Salesforce Edition) — public-source research

Researched 2026-11-12. Every claim carries one label and, for Verified/Observed, a source id like [S3].
- **Verified** — stated by the vendor (site, docs, help center, AppExchange, release notes).
- **Observed** — visible in an official demo video, screenshot or walkthrough (describe what was seen).
- **Inferred** — reasonable from behaviour, not confirmed. Say why.
- **Unknown** — nothing reliable found.
Never invent API names, Apex class names, Flow names or LWC names. If a vendor publishes them, quote exactly with source. Otherwise say Unknown and, separately, give a "Proposed (ours)" name prefixed `Proposed:`.

**Method note.** The Propertybase Help Center HTML pages (help.propertybase.com/hc/...) returned HTTP 403 to automated fetches. The same articles were read through the help center's public Zendesk JSON endpoint (`help.propertybase.com/api/v2/help_center/en-us/articles/<id>.json` and `.../articles/search.json?query=...`). That is still the vendor's public help content, so those facts are labelled Verified. Text inside screenshots was not readable. Several help articles are old (2017–2021, some "Classic"), so picklist values reflect the vendor's defaults/examples at that time and may differ in current orgs. No video was watched, so nothing is labelled Observed.

## 0. Identity and status

| Item | Finding | Label | Source |
|---|---|---|---|
| Product name (current) | "Propertybase Salesforce Edition" (also "Propertybase SE"); AppExchange title "Propertybase Real Estate Platform" | Verified | [S1][S3][S5] |
| Publisher today | Lone Wolf Technologies (brand "Propertybase by Lone Wolf"; site propertybase.lwolf.com) | Verified | [S1][S4] |
| Original company | Propertybase, Boulder, Colorado (US); also strong European presence (German, UK, Middle East portal integrations in help docs) | Verified (Boulder: PE Hub/Inman via search) / Inferred (Europe, from help articles on Rightmove, Idealista, UAE portals) | [S6][S33] |
| Ownership history | Boston Logic acquired Propertybase 1 June 2017 → Lone Wolf Technologies (Stone Point-backed) acquired Propertybase 25 Aug 2021 | Verified | [S4][S6] |
| AppExchange listing | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016ckJEAQ — listing id `a0N300000016ckJEAQ`; first listed 12/01/2008; listing "last updated" 03/02/2022; Managed Package; Lightning Ready; Editions: Enterprise, Unlimited, Force.com, Developer; languages EN/FR/DE/IT/PT/ES | Verified | [S3] |
| Namespace | `pba` (objects `pba__Listing__c` etc.; Apex REST path `/services/apexrest/pba/...`; VF page `pba.ClickToClaim`) | Verified | [S7][S8][S13][S23] |
| Add-on namespaces seen | `pbasr` (Sales Rotation add-on: `pbasr__Rotation_Name__c`), `pba_espfields` (Spanish energy fields), `pba_uaefields` (UAE/RERA fields), `pba_dl` (Dotloop field prefix), `pba_bl` (Boston Logic website field prefix) | Verified | [S24][S9][S33][S34][S32] |
| Current status of SE | **Active and sold.** Vendor page offers demos and prices it at "$89 per user per month, with the Force.com license included"; claims 20k+ users, 60+ countries, "Updated every 3–6 weeks through AgentExchange releases"; mentions Salesforce Agentforce and Flow | Verified | [S1] |
| Propertybase GO | A **separate, non-Salesforce** CRM + website product for brokerages/teams (2021 press release: "a CRM and website solution for brokerages and teams"). Renamed **Lone Wolf Front Office** (blog dated 29 Aug 2024), which "brings together Propertybase GO, Propertybase websites, and Propertybase marketing", sold inside Lone Wolf Foundation | Verified (rename, scope) | [S2][S4][S5] |
| Is GO on Salesforce? | Vendor never says GO runs on Salesforce. GO has its own REST API at apidocs.propertybase.com using header `X-BL-API-Key` (BL = Boston Logic) and resources like Offices/Agents/Leads/SavedSearches — not Salesforce sObjects. A competitor comparison states GO "is not built directly on the Salesforce platform". Login for SE is login.salesforce.com, GO/Front Office has no Salesforce login | Inferred (strong) — not on Salesforce | [S2][S39][S42] |
| Native vs integrated | **SE is 100% Salesforce-native** (managed package; "Required Salesforce products: None" because the Force.com/Platform licence is bundled) | Verified | [S1][S3] |

**Bottom line:** For a Salesforce mirror, the relevant product is **Propertybase Salesforce Edition** (namespace `pba`). Propertybase GO / Lone Wolf Front Office is a different, non-Salesforce platform and is out of scope except as an integration reference.

## 1. Ratings

| Platform | Supplied value | Verified value (date) | Review count | URL | Note |
|---|---|---|---|---|---|
| Capterra | 3.8/5, 51 reviews | 3.8/5 (search snippet, 2026-11-12; page "last updated March 13th, 2026") | 51 | https://www.capterra.com/p/122129/Propertybase/reviews/ | Direct fetch blocked (403). Value taken from search-engine snippet of the Capterra page and regional Capterra/GetApp pages, all 3.8 from 51. Capterra UK sub-ratings: Ease of Use 3.3, Customer Support 3.6, Value 3.4, Features 3.8. **Matches supplied.** [S40] |
| G2 | — | 2.7/5 (search snippet) | 33 | https://www.g2.com/sellers/propertybase | Direct fetch blocked (403); snippet only. [S41] |
| AppExchange | — | 4.78/5 (fetched 2026-11-12) | 369 | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016ckJEAQ | Vendor site quotes "4.77/5, 363+ verified reviews". [S1][S3] |
| Capterra (Propertybase GO / Front Office) | — | not checked | — | https://www.capterra.com/p/10020285/Propertybase-Go/reviews/ | Different (non-Salesforce) product; listed for disambiguation only. |

## 2. Overview (12 questions)

- **What it is** — Real-estate CRM and platform built as a managed package on Salesforce: contacts/leads, inquiries (buyer/renter search criteria), listings and properties, matching, offers, closings, transactions, marketing automation, portal syndication and website integration. Verified [S1][S3].
- **Developer** — Propertybase (Boulder, CO), now Lone Wolf Technologies. Verified [S4].
- **Industry** — Residential real estate brokerage (sales and rentals); also used for new developments and some commercial use (building stack/lease expiration settings exist). Verified [S1][S11]; commercial use Inferred from Building Stack settings.
- **Target users** — Agents, teams, brokerages, enterprises/franchises; "scales from 10 agents to 200+"; profiles named in docs: 'PB Administrator', 'PB Office Admin', 'PB Superuser'. Verified [S1][S9].
- **Problems solved** — Lead capture and routing, follow-up, buyer-to-listing matching, listing publishing to portals/websites, offer/closing tracking, commission and back-office, reporting. Verified [S1][S3][S23][S33].
- **Major functions** — Lead capture (Front Desk email parsing, WebToProspect REST API, webforms), Lead Routing / Sales Rotation, Inquiry matching ("Matching" / Listing Browser), Listing & Property management, Offers, Closings, Transactions (Workspace/BackAgent sync), Quicksend email, Drip Campaigns, Action Plans, Portal Syndication, Propertybase Websites (Boston Logic), Financial Add-On (Payments/Cash/Receipts), dashboards. Verified [S13][S14][S18][S23][S24][S25][S26][S27][S33][S35].
- **Differentiators** — "Most-reviewed real estate CRM on Salesforce"; built-in Authentisign e-signature ("built in — not bolted on"); international portal feeds; Agentforce AI lead scoring claimed. Verified [S1].
- **Native/integrated** — Native Salesforce managed package. Verified [S3].
- **Editions/licences required** — Bundles the Force.com (Salesforce Platform) licence; AppExchange lists Enterprise, Unlimited, Force.com, Developer editions. Historic plan names "Company Plan", "Enterprise", "Ultimate" (Financial Add-On is Enterprise/Ultimate only). Verified [S1][S3][S26].
- **Pricing & licensing** — From $89/user/month incl. Force.com licence (vendor, AppExchange). A third-party review cites $799/month for 10 users (older). Verified ($89) [S1][S3]; third-party figure unverified.
- **Managed/unmanaged** — Managed package, automatic upgrades; "Apps, tabs, and objects don't count against Salesforce org limits". Verified [S3].
- **Limitations & dependencies** — Platform licence (not Sales Cloud) limits standard Opportunity/Lead use (Inferred: Platform licence excludes Opportunities/Leads, which explains why Propertybase uses custom Inquiry/Offer objects instead of Lead/Opportunity); several features depend on a public Salesforce Site ("Webservices"/"Public API") and Propertybase Mailservice; Campaign ROI not available in Lightning; learning curve. Verified (Site, Mailservice, ROI) [S20][S23][S36]; licence reasoning Inferred.

## 3. Functional modules

| Module | What it does | Who uses it | Data captured | Interacts with | Before / after | Label | Source |
|---|---|---|---|---|---|---|---|
| Contact management | Individual vs Company contacts with shadow accounts; Stage path; duplicate finder | Agents | Contact, Account, `pba__Stage_pb__c`, Routing Source, Lead Rating, Last Attempted Contact | Inquiry, Offer, Owned Property, Drip, Action Plan | Spreadsheet/inbox leads → single client record with stage | Verified | [S7][S11][S21][S30] |
| Lead capture — Front Desk | Parses portal/email leads (Zillow/Trulia Premier Agent, Realtor.com, Facebook Lead Ads, XML-to-email webforms) | System / admins | New Contact (or existing) + new Inquiry; optional Linked Listing and email Task; `pba__TechnicalSourceSystem__c` | Lead Routing | Manual re-keying → automatic Contact+Inquiry | Verified | [S25] |
| Lead capture — WebToProspect REST API | Apex REST endpoint `/services/apexrest/pba/webtoprospect/v1/` creating/enriching Contact + new Inquiry + Linked Listings | Website developers | contact{}, request{}, favoriteListings[] | Sites guest user, dupe strategies | Custom web-to-lead → structured Contact/Inquiry | Verified | [S13] |
| Lead Routing | Routing Source → Team → Distributor (Click to Claim / Auto-Assign / Round Robin) | Admin, agents | Contact Routing Source, owner | Process Builder "Lead Routing - Contact"/"Lead Routing - Inquiry" | Manual assignment → automatic | Verified | [S23] |
| Sales Rotation (add-on, `pbasr`) | Roster-based rotation for web enquiries with working days and 4pm cut-off | Admin | `pbasr__Rotation_Name__c`, `pbasr__Portal_Listing_Id__c`, `pbasr__Front_Desk_Email__c`; Sales Rotation, Sales Rotation Member | Task, email | — | Verified | [S24] |
| Inquiry (Request) management | Captures buyer/renter criteria (type, beds, baths, budget, custom min/max fields); saved searches | Agents | `pba__Request__c` with `..._min__c`/`..._max__c` fields | Listing (Matching), Linked Listing, Contact | — | Verified | [S12][S14][S15] |
| Matching / Listing Browser | Finds Listings matching an Inquiry (and Contacts matching a Listing); send listings, PDF, create Linked Listings | Agents | Linked Listing (favorite) records with client rating/feedback | Quicksend, PDF | Manual search → rules-based match | Verified | [S11][S12][S14][S22] |
| Listing & Property management | Listing (sale/rent record types) as market event; Property as physical asset; Listing creates Property automatically; field sync | Listing agents | `pba__Listing__c`, `pba__Property__c`, PropertyMedia | Portals, Website, Offers | — | Verified | [S10][S22] |
| Building Stack / hierarchy | Master property → child properties (floors/units), colour by status/lease expiry/price | Developers, commercial/new-dev teams | `pba__Master_Property__c`, `pba__Floor__c`, `pba__Lease_Expiration__c` | Listing | — | Verified | [S11][S43] |
| Showings | Event record type "Showing" with Client Rating (1–5) and Client Feedback; mirrored to Favorites | Agents | Event fields `pba__Rating_pb__c`, `ClientFeedback__c` | Linked Listing (favorite) via `showingsFavoriteFieldMappings` | — | Verified | [S7][S37] |
| Offers | Tracks offers/counter-offers; Accept, Reservation, Cancel, Counter, New Closing; updates Listing status | Agents, managers | `pba__Offer__c` incl. `pba__OfferedAmount_pb__c`, `pba__SystemIsAccepted__c`, `pba__SystemIsActive__c` | Listing, Contact (buyer/seller), Closing | — | Verified | [S8][S18][S20] |
| Closings | Created from Offer (copies data) or manually; status, target/actual close date, commission overview, desk-fee deductions, checklist | Agents, back office | `pba__Closing__c` | Offer, Listing | — | Verified | [S7][S9][S17] |
| Transactions | Transactions + Transaction Members synced from Lone Wolf Workspace or BackAgent; 5 phases | Agents (read-only), back office | `pba__Transaction__c`, Transaction Member (Side, Role) | Contact, Listing | — | Verified | [S8][S27][S28] |
| Financial Add-On | Payment (Receivable/Payable), Cash (In/Out), Receipt allocation | Accounting | Net, VAT, Total, Allocated, Balance | Contact | — | Verified | [S26] |
| Email: Quicksend / Mass email / Templates | Email to multiple contacts with listing attachments; templates (email, listing, pdf, inline) | Agents | Email tracking (Tracking tab) | Contact, Listing | — | Verified | [S11][S21][S35] |
| Drip Campaigns | Scheduled email series from a Drip Campaign Template, started from Contact or Process Builder | Agents, marketing | `pba__DripCampaign__c` | Contact, templates | — | Verified | [S8][S35] |
| Action Plans | Task/plan sequences started from Contact, Inquiry, Listing | Agents | `pba__ActionPlan__c` | Contact | — | Verified (object/action); details Unknown | [S8][S14][S21][S22] |
| Portal Syndication | Publish listings to Rightmove, Zoopla, LonRes, OnTheMarket, Zillow, Idealista, Realogy etc.; feeds; field mapping; Auto Publish | Listing admin | Portal, "Listed on these portals" records | Listing | Manual uploads → feeds | Verified | [S22][S33] |
| Propertybase Websites (Boston Logic) | IDX/MLS website; visitor activity → CRM (views, favorites, saved searches) | Marketing, agents | Website Listing - View/Favorite/Note/Share/Request/Contact Form; Inquiry "Is Website Saved Search" | Contact, User sync | — | Verified | [S32] |
| Campaign ROI (Classic only) | Campaign Result → Offer amounts for ROI | Marketing | `CampaignResult` formulas | Offer | — | Verified | [S20] |
| Reports & Dashboards package | 2 dashboards, 34 reports + managed dashboard components | Managers | Transactions, Website objects, Contacts | — | — | Verified | [S29][S30] |
| Dotloop / Authentisign | E-sign/transaction docs: Dotloop two-way via buttons; Authentisign built in | Agents | Loop fields on Listing/Offer/Closing | — | — | Verified | [S1][S34] |

## 4. Data model

| Object label | API name (exact or `Proposed:`) | Type | Purpose | Key fields | Parent | Children | Label | Source |
|---|---|---|---|---|---|---|---|---|
| Contact | `Contact` | Standard | Person or company contact (record types Individual / Company) | `pba__Stage_pb__c` (Stage), `pba__SystemIsIndividual__c` (spelled `pba_SystemIsIndividual__c` in one article), `pba__SystemExternalId__c`, `pba__TechnicalSourceSystem__c`, `pba__hasoptoutpdf__c`, `LeadSource`, Routing Source, Lead Rating, Last Attempted Contact, Next Follow-up Date, Automated Email Opt Out | Account | Request, Offer, Drip Campaign, Action Plan, Transaction (via component), Payment, Cash | Verified (API names listed); Routing Source / Lead Rating / Next Follow-up API names Unknown | [S7][S9][S11][S13][S21][S23][S25][S30][S35] |
| Account (Company) | `Account` | Standard | Company or "shadow" individual account; record types `Company_pb`, `Individual_pb` | BillingStreet/City…, Phone, Website | — | Contact | Verified | [S7][S11] |
| Inquiry (Request) | `pba__Request__c` | Custom | Buyer/renter demand and search criteria; also website saved search | `pba__Contact__c` (relationship used in `forms_configuration`), `pba__Bedrooms_pb_min__c`, `pba__FullBathrooms_pb_min__c`, `pba__City_pb__c`, price min/max, `pbasr__Rotation_Name__c`, `pbasr__Portal_Listing_Id__c`, `pbasr__Front_Desk_Email__c`, status, "Is Website Saved Search" | Contact | Linked Listing (Favorite) | Verified | [S11][S12][S13][S24][S32] |
| Listing | `pba__Listing__c` | Custom | A sale or rent market event for a property; record types **Sale** and **Rent** (cannot be changed after creation) | `pba__Status__c`, `pba__ListingPrice_pb__c`, `pba__Address_pb__c`, `pba__City_pb__c`, `pba__PostalCode_pb__c`, `pba__Country_pb__c`, `pba__Bedrooms_pb__c`, `pba__FullBathrooms_pb__c`, `pba__TotalArea_pb__c`, `pba__LotSize_pb__c`, `pba__YearBuilt_pb__c`, `pba__PropertyType__c`, `pba__Description_pb__c`, `pba__Latitude_pb__c`, `pba__Longitude_pb__c`, `pba__Broker_s_Listing_ID__c`, `pba__Property__c` (lookup, via `pba__Property__r`), system flags `pba__SystemHasAcceptedOffer__c`, `pba__SystemHasExclusiveOffer__c`, `pba__SystemHasClosedClosing__c`, `pba__SystemAllowedForPortals__c`, `pba__SystemIsIDX__c`, `pba__SystemIsArchived__c`, `pba__SystemIsActive__c`, `pba__SystemIsPrivate__c`, `pba__SystemIDXPool__c`, `pba__SystemPoolId__c`, `pba__Lease_Expiration__c` | Property | Offer, Closing, Linked Listing, Showing (Event), Portal listings, Website Listing records | Verified (field names from [S9][S10][S11]; casing as published, some lower-case in settings) | [S9][S10][S11][S22] |
| Property | `pba__Property__c` | Custom | Physical asset and history across listings; auto-created with a Listing | Same address/size fields as Listing; `PropertyOwnerContactId__c` (Property Owner), `PropertyMediaCount__c` (roll-up example), `pba__Master_Property__c`, `pba__Floor__c` | Master Property (self) | Listing, Property Media, child Properties | Verified | [S9][S10][S11] |
| Property Media | `Proposed: pba__PropertyMedia__c` (API Unknown) | Custom | Images, documents, videos for a property (used on portals/website/exposé) | extensions settings `propertyMedia_*` | Property | — | Verified (object exists); API Unknown | [S9][S11][S36] |
| Linked Listing (Favorites) | `Proposed: pba__Favorite__c` (API **Unknown** — help calls the object "Favorite" and "Linked Listings (Favorites)"; no article shows the API name) | Junction | Links an Inquiry (and its Contact) to a Listing with client rating/feedback; created by Matching, Front Desk, WebToProspect `favoriteListings`, Sales Rotation "Enquiry Schedule" | rating, feedback, packaged `pba__` fields | Request, Listing | — | Verified (object & behaviour); API Unknown | [S7][S13][S14][S24][S36] |
| Offer | `pba__Offer__c` | Custom | Negotiation on a Listing by a buyer; counter-offers chain | `pba__OfferedAmount_pb__c`, `pba__SystemIsAccepted__c`, `pba__SystemIsActive__c`, Status, listing lookup, buyer/seller, target close date, Offer Date, Offer Expiration Date, Forecast Settlement Date (AUS add-on) | Listing, Contact | Closing, counter Offer, CampaignResult (`pba__Offer__r`) | Verified | [S8][S16][S18][S19][S20][S34] |
| Closing | `pba__Closing__c` | Custom | Closing process, commission, desk fees, checklist | `Closing_Status__c` and `ClosingDate__c` (unprefixed in vendor examples — likely org-level custom fields), `pba__Listing__c` (via `pba__Listing__r`), CurrencyIsoCode, system `pba__SystemIsXXX__c` flags; Dotloop fields: Sale Commission Rate/Total, splits buy/sell side, Earnest Money | Offer, Listing | — | Verified | [S7][S8][S9][S17][S34] |
| Transaction | `pba__Transaction__c` | Custom | Deal record synced from Lone Wolf Workspace / BackAgent; 5 phases | Property, Timeline, Financial, Commission sections; Listing lookup (matched by MLS Name + MLS ID) | Contact (owner/stakeholders) | Transaction Member | Verified (API from [S8]) | [S8][S27][S28] |
| Transaction Member | `Proposed: pba__TransactionMember__c` (API Unknown) | Junction | Contact/User on a transaction with Side and Role | Contact, User, Side (Seller, Buyer…), Role (Seller, Buyer, Title…) | Transaction | — | Verified (object); API Unknown | [S27][S28] |
| Drip Campaign | `pba__DripCampaign__c` | Custom | Running drip email series for a contact | `pba__Contact__c` | Contact | — | Verified | [S8] |
| Drip Campaign Template | `Proposed: pba__DripCampaignTemplate__c` (API Unknown) | Config | Template: name, From Address/Name, Drip Email Template Name(s), CC/BCC | — | — | Verified (object); API Unknown | [S35] |
| Action Plan | `pba__ActionPlan__c` | Custom | Planned task sequence for a contact | `pba__Contact__c` | Contact | Tasks (Inferred) | Verified | [S8] |
| Event (Showing) | `Event` (record type "Showing") | Standard | Showing with invitees, rating 1–5, client feedback | `pba__Rating_pb__c`, `ClientFeedback__c`, ActivityDate | Listing/Contact (WhatId/WhoId) | — | Verified | [S7][S37] |
| Task | `Task` | Standard | Follow-ups, routing tasks ("Call Regarding New Enquiry") | WhatId/WhoId | any | — | Verified | [S24][S30] |
| Campaign Result | `CampaignResult` | Custom (packaged, API as written; namespace not shown) | Campaign ↔ Offer ROI | Amount/Potential Amount/Effective Date formulas | Campaign, Offer | — | Verified (as published) | [S20] |
| Payment | `Proposed: Payment__c` (API Unknown) | Custom | Receivable/Payable | Net Amount, VAT, VAT Amount, Total, Allocated Cash, Balance, Type, Status, Due Date, Overdue | Contact | Receipt | Verified (object) | [S26] |
| Cash | `Proposed: Cash__c` (API Unknown) | Custom | Cash In / Cash Out | Amount, Date, Bank Account, Status, Allocated, Not Allocated, Allocated % | Contact | Receipt | Verified (object) | [S26] |
| Receipt | `Proposed: Receipt__c` (API Unknown) | Junction | Allocates Cash to Payment | Allocated Amount, Currency, To Payment, From Cash | Payment, Cash | — | Verified (object) | [S26] |
| Team / Office / Team Member / Office Member / MLS Membership | API Unknown | Custom | Org structure and MLS IDs (List Agent MLS ID, MLS Name) for website/IDX | Office (Lookup), Team (Lookup) | User/Contact | — | Verified (objects) | [S38] |
| Lead Routing Team | API Unknown | Config | Team with users, Routing Source assignment, Distributor | Distributor type, user status | — | — | Verified (concept) | [S23] |
| Sales Rotation / Sales Rotation Member | API Unknown (namespace `pbasr`) | Custom (add-on) | Rotation roster | Active, Working days | User | — | Verified (objects) | [S24] |
| Website Listing - View / Favorite / Note / Share / Request / Contact Form | prefix `pba__WebsiteListing...` (full API Unknown) | Custom | Website activity from Boston Logic sites | MLS ID, MLS Name, `BostonLogicId`, `pba_bl...` fields | Contact, Listing | — | Verified (labels + prefix) | [S32] |
| Portal / Portal listing ("Listed on these portals") | API Unknown | Config / Custom | Portal connection, feeds, mapping, Auto Publish Listing; per-listing publication record | Auto Publish Listing (Portal), Allowed for Auto Publish (Listing) | Listing | — | Verified (labels) | [S22][S33] |
| Settings (Propertybase settings) | API Unknown | Config | Key/value settings (e.g. `browsers_match_mapping`, `favorites_mode`, `webserviceWebToProspect_token`) | key, value | — | — | Verified (concept/keys) | [S11][S13][S36] |
| Template | API Unknown | Config | email/listing/pdf/inline templates; type values `email_template`, `listing_template`; "Is Quicksend template" | — | — | — | Verified | [S35] |

### Relationships
- Property (parent) → Listing (child): lookup `pba__Property__c` on Listing (relationship `pba__Property__r` used in formulas); creating a Listing auto-creates a Property; one Property, many Listings over time. Verified [S9][S10]. Lookup vs master-detail: Inferred lookup (Listings can be deleted independently and Property delete is offered when only one Listing remains [S22]).
- Property → Property (Master Property, building stack / Project-Building-Property hierarchy): `pba__Master_Property__c`. Verified [S11][S43].
- Contact → Request: `pba__Contact__c` on Request (used in `forms_configuration`). Verified [S11]. Contact delete deletes "abandoned requests" (packaged trigger). Verified [S7].
- Request ↔ Listing via Linked Listing/Favorite (many-to-many). Verified [S7][S13][S14].
- Listing → Offer; Offer → Closing (Closing copies Listing link + CurrencyIsoCode from Offer); Closing → Listing lookup `pba__Listing__c`. Verified [S7][S9].
- Offer → counter Offer (self link to original). Verified [S18].
- Contact → Drip Campaign / Action Plan via `pba__Contact__c`. Verified [S8].
- Transaction → Transaction Member; Transaction → Listing (matched by MLS Name + MLS ID). Verified [S27].
- CampaignResult → Offer (`pba__Offer__r`). Verified [S20].
- Payment ← Receipt → Cash (junction). Verified [S26].

### Record types (found)
- Account: `Company_pb`, `Individual_pb`; Contact: `Individual_pb`, `Company_pb`. Verified [S11].
- Listing: Sale, Rent (layouts "Sales Compact Layout" / "Rent Compact Layout"). Verified [S22].
- Event: Showing. Verified [S37].
- Payment: Receivable, Payable; Cash: Cash In, Cash Out. Verified [S26].

### Picklist values (found — vendor examples, may be customised per org)
- **Listing `pba__Status__c`** (union across articles): In Preparation, Private, Off-Market (default for new listings), Active, Available, Published, Under Offer, Pending, Reserved, Under Contract, Sold, Archived. Verified [S9][S18][S34]. Note: not one canonical list; values appear in different articles/eras.
- **Offer Status**: Active (Reservation), Accepted, Cancelled, Inactive (original after counter). Initial value Unknown. Verified [S18].
- **Closing `Closing_Status__c`**: Closed, Canceled (others Unknown). Verified [S9].
- **Contact `pba__Stage_pb__c`**: "Contacted Lead" (example); grouped into Leads and Clients in dashboard. Full list Unknown. Verified [S9][S30].
- **Transaction phases**: Start, Contract, Showing, Pre-Closing, Post-Closing. Verified [S27].
- **Payment Status**: Planned, Pending, Paid, Cancelled; **Cash Status**: Not Allocated, Partially Allocated, Fully Allocated. Verified [S26].
- **Routing Source** examples: Web Leads, SOI Leads, Open House Leads, Portals, Leads Over a Million, Family Houses, Regional. Verified [S23].
- **Lead Routing user status**: Active, Inactive, Opt-Out, Disabled. Verified [S23].
- **WebToProspect dupe behaviour**: none, enrich (default), override; strategies externalid, email, phone, plugin. Verified [S13].
- Energy rating `pba_espfields__Energy__c`: A–G. Verified [S9].

### Roll-ups, formulas, validation, external IDs
- System flag pattern: packaged triggers set `pba__SystemHasXXX__c` on Listing from `pba__SystemIsXXX__c` on Offer/Closing, and on Offer from Closing. Verified [S7]. Known instances: `pba__SystemHasAcceptedOffer__c`, `pba__SystemHasExclusiveOffer__c`, `pba__SystemHasClosedClosing__c`, `pba__SystemIsAccepted__c`, `pba__SystemIsActive__c`. Verified [S9][S11][S20].
- External ID: `pba__SystemExternalId__c` (default for WebToProspect). Verified [S11][S13].
- Vendor example validation rules: lock Published listings except PB Administrator/PB Office Admin; require ClosingDate when Closed; portal mandatory fields when Active/Under Offer; at least one image before Active (`pba__Property__r.PropertyMediaCount__c = 0`); block a second closing when `pba__Listing__r.pba__SystemHasAcceptedOffer__c`/`...ExclusiveOffer__c` and status not Canceled. Verified [S9]. These are examples, not shipped rules (Inferred from article framing).
- Campaign ROI formulas on CampaignResult copied by workflow to packaged roll-up targets. Verified [S20].
- Listing↔Property field sync by identical API name with blacklist/additional mapping settings. Verified [S10][S11].

### Compact ERD edge list
```
Account -> Contact (lookup, std) [Verified]
Contact -> pba__Request__c (lookup pba__Contact__c) [Verified]
pba__Property__c -> pba__Listing__c (lookup pba__Property__c) [Verified]
pba__Property__c -> pba__Property__c (lookup pba__Master_Property__c) [Verified]
pba__Property__c -> Property Media (MD|lookup unknown) [Verified object, Unknown type]
pba__Request__c -> Linked Listing/Favorite (junction) [Verified object, API Unknown]
pba__Listing__c -> Linked Listing/Favorite (junction) [Verified object, API Unknown]
pba__Listing__c -> pba__Offer__c (lookup) [Verified]
Contact -> pba__Offer__c (lookup buyer/seller) [Verified concept, field API Unknown]
pba__Offer__c -> pba__Offer__c (counter offer link) [Verified concept]
pba__Offer__c -> pba__Closing__c (lookup) [Verified]
pba__Listing__c -> pba__Closing__c (lookup pba__Listing__c) [Verified]
pba__Offer__c -> CampaignResult (lookup pba__Offer__c) [Verified]
Contact -> pba__DripCampaign__c (lookup pba__Contact__c) [Verified]
Contact -> pba__ActionPlan__c (lookup pba__Contact__c) [Verified]
pba__Transaction__c -> Transaction Member (MD|lookup unknown) [Verified object]
pba__Listing__c -> pba__Transaction__c (lookup, MLS match) [Verified]
Contact -> Transaction Member (lookup) [Verified]
Payment -> Receipt <- Cash (junction) [Verified objects, API Unknown]
pba__Listing__c -> Event[Showing] (WhatId) [Verified]
Contact -> Website Listing-* (lookup) [Verified objects, API Unknown]
pba__Listing__c -> Portal listing (lookup) [Verified concept]
```

## 5. Technical components

- **Apex (packaged, names not published)** — Packaged triggers exist on Contact, Event, Request, Favorite, Listing, Offer, Closing; custom triggers can be ordered before/after packaged code since v3.5.0.0. Trigger class names Unknown. Verified [S7].
- **Apex REST** — `/services/apexrest/pba/webtoprospect/v1/` (anonymous via Site with token, or OAuth session). Verified [S13].
- **Apex extension interface** — `pba.WebserviceProspectRest.DuplicateFinder2` (custom duplicate plugin; class name set in `webserviceWebToProspect_pluginDuplicateFinder`). Verified [S13].
- **Visualforce** — `pba.ClickToClaim` (lead routing claim page), `pba.Unsubscribe` (drip unsubscribe); "Portal Syndication" VF component on Listing; "New Transaction" VF component on Contact. Verified [S23][S32][S35][S27].
- **Lightning UI** — Control Center app/page (Record Managers, Dashboard Components, Portal Mapping, Front Desk, Websites Integration, Propertybase Services, BackAgent Login); Listing Manager, Contact Manager, Listing Browser/Matching (SPA, settings `spa_fields_whitelist`); managed dashboard components "PB Marketing Health", "PB Contact Database Health", "PB Last Attempted Contact", "PB Follow-up Calendar", Activity Overview; Building Stack. LWC/Aura component API names Unknown. Verified (labels) [S11][S22][S30][S33].
- **Process Builder (packaged/template)** — "Lead Routing - Contact", "Lead Routing - Inquiry"; "Offer Automation" and "Closing Automation" (set listing system checkboxes); "1.1 Update Contact based off Call Outcomes"; drip campaign process on Contact (v1.551+). Verified (names as quoted) [S9][S23][S30][S35]. Current Flow equivalents Unknown; vendor now says automation is "built on Salesforce Flow" [S1].
- **Workflow** — Campaign ROI field-update workflow on CampaignResult (Classic). Verified [S20].
- **Scheduler** — "Email Scheduler" / Automated Emails (restartable in Propertybase Services). Verified [S35].
- **Custom settings / config** — Propertybase Settings key/value store; keys listed in [S11] (e.g. `browsers_match_mapping`, `browsers_match_active_field`, `browsers_match_blacklist`, `browsers_match_whitelist`, `favorites_mode` (default `strict`), `favorites_synchronous_limit`, `loewy_token`, `loewy_config`, `listingToPropertySync_*`, `propertyToListingSync_*`, `account_*`, `contact_*`, `listingNewWizard_*`, `webserviceWebToProspect_*`, `propertyMedia_*`, `googleMap_*`, `building_stack_*`, `mailserviceVisibilityScope`, `showingsFavoriteFieldMappings`, `sales_rotation_listing_match_fields`, `pbasr_Task_Subject`, `dotloop_*`, `portal_mapping_active`). Verified [S7][S11][S24][S32][S34].
- **Apps** — "PB Agent" (`Propertybase_Agent`), "PB Manager" (`Propertybase_Manager`), "PB Admin" (`Propertybase_Administrator`), "PB Leads" (`Leads`), "PB Transactions" (`Transactions`). Verified [S31].
- **Security** — Profiles referenced: PB Administrator, PB Office Admin, PB Superuser. Permission sets: "Propertybase Webservices V2" (`PropertybaseWebservicesV2`), legacy "Propertybase Webservices". Site "Webservices"/"Public API" with guest user, criteria-based guest sharing rules "Allow Webservices Access". Verified [S9][S36].
- **Mapping** — OpenStreetMaps provider (settings still prefixed googleMap_). Verified [S11].
- **Mobile** — Propertybase mobile app (iOS/Android) with Chatter push for lead routing. Verified [S1][S23].
- **AI** — Vendor claims Agentforce lead scoring and deal predictions. Verified claim [S1]; implementation Unknown.

## 6. Business processes

### P1. Lead capture → routing → qualification
**Start trigger:** Portal email lead, website visitor registration/saved search, Facebook Lead Ad, webform/REST call, or manual entry.
1. **Initiation**
   - Front Desk receives a portal email at the customer's Front Desk address and parses it (Verified [S25]); or WebToProspect REST is called with `prospect{contact, request, favoriteListings}` (Verified [S13]); or a Boston Logic website login creates a Contact with Lead Source "BostonLogic" (Verified [S32]).
   - `pba__TechnicalSourceSystem__c` / Lead Source set (e.g. "Zillow", "Facebook", "FrontDesk"). Verified [S25].
2. **Data processing**
   - Duplicate check: existing Contact found (Record ID → External ID → Plugin → Email → Phone) → `enrich` fills only null fields; a **new Inquiry is always created** and linked. Verified [S13][S25].
   - Optional Linked Listing created when the message carries a listing reference or `favoriteListings`. Verified [S13][S25].
3. **Business operations (routing)**
   - Process Builder "Lead Routing - Contact"/"Lead Routing - Inquiry" sets Contact Routing Source → Team → Distributor: Click to Claim (email all; first click wins via `pba.ClickToClaim`), Auto-Assign, or Round Robin ("Next Up", "Restart Rotation"). Verified [S23].
   - Alternative add-on: Sales Rotation by `pbasr__Rotation_Name__c`, working days, after-4pm → next day, Listing Owner Priority, FrontDesk Priority; Task "Call Regarding New Enquiry" + email. Verified [S24].
4. **Decision/approval**
   - Returning lead → previous owner (not configurable in Lead Routing; options in Sales Rotation: Assign to Contact Owner / Previous Rotation Member / Reallocate). Verified [S23][S24].
   - No active members → Default Rotation User; failure → admin emails. Verified [S24].
5. **Completion**
   - Agent contacts lead; Contact Stage path moves (e.g. "Contacted Lead" → "Active"; full list Unknown). Verified (values as examples) [S9][S21].
   - "Last Attempted Contact" updated by Process Builder "1.1 Update Contact based off Call Outcomes". Verified [S30].
6. **Post-completion**
   - Contact enrolled in Drip Campaign / Action Plan / recurring email; Marketing Health dashboard tracks coverage. Verified [S30][S35].
   - **Alternate paths:** User Opt-Out/Disabled skips user (Verified [S23]); Click-to-Claim unclaimed timeout/escalation — Unknown [S23].

### P2. Buyer inquiry → matching → showings → favourites
**Start trigger:** New Inquiry (`pba__Request__c`) from P1 or "New Inquiry" on Contact.
1. **Initiation** — Agent records criteria (property type, beds, baths, budget, custom `_min`/`_max` fields) on the Inquiry. Verified [S12][S15].
2. **Data processing** — "Matching"/"Find Matching Listing" opens the Listing Browser with filters auto-built from same-named fields (Inquiry `X_min__c`/`X_max__c` ↔ Listing `X__c`), honouring `browsers_match_mapping`, `browsers_match_active_field`, blacklist (system fields) and whitelist. Verified [S11][S12].
3. **Business operations** — Agent selects listings and (a) sends them via Quicksend, (b) creates a PDF, (c) creates Linked Listings ("Add to client favorites"). Reverse: Listing "Matching" tab finds Contacts whose Inquiries match. Verified [S14][S22][S44].
4. **Decision/approval** — Client gives feedback/rating on Linked Listing; Showings (Event record type "Showing", rating 1–5, Client Feedback) are mirrored to Favorites by packaged Event trigger via `showingsFavoriteFieldMappings`. Verified [S7][S37].
5. **Completion** — Buyer chooses a listing → P3 (New Offer from Contact or Listing). Verified [S21][S22].
6. **Post-completion** — Inquiry status updated (values Unknown); website favourites/saved searches keep flowing from Boston Logic (Website Listing - Favorite; Inquiry "Is Website Saved Search"). Verified [S32]; Inquiry status values Unknown.
   - **Alternate:** Inquiry reassigned to another Contact → packaged trigger updates its Favorites. Verified [S7]. Contact deleted → abandoned Requests deleted. Verified [S7].

### P3. Listing intake → publication (seller side)
**Start trigger:** Seller/owner engagement; "New Listing" or Listing Wizard.
1. **Initiation** — New Listing (record type Sale or Rent, fixed). Listing Wizard checks duplicate Properties (`listingNewWizard_duplicateCheckCommand` address/city/name) and links or creates Property. Verified [S10][S11][S22].
2. **Data processing** — Property auto-created; Listing→Property sync of same-name fields (ongoing); Property→Listing once at creation. Media uploaded (Property Media). Verified [S10].
3. **Business operations** — Status typically In Preparation/Off-Market → Active (example validation: requires price, portal fields, ≥1 image). Verified [S9][S34].
4. **Decision/approval** — Publishing controls: lock when "Published" for non-admin profiles (example rule); Auto Publish requires Portal.Auto Publish Listing + Listing.System Allowed for Portals + Allowed for Auto Publish. Verified [S9][S33].
5. **Completion** — Listing exported to portal feeds (Rightmove, Zoopla, Zillow, Idealista…) and to Propertybase Websites (pocket/coming-soon listings via Boston Logic). "Listed on these portals" records created. Verified [S33][S38].
6. **Post-completion** — Listing activity reported (Website Listing views/favorites; marketing reports); unpublish = deactivate in Portal Syndication; published listings cannot be deleted until all portal entries removed. Verified [S22][S29].
   - **Alternate:** Manually unpublished listings are not auto-republished. Verified [S33]. Dotloop: "LOOP IT" creates a loop from Listing. Verified [S34].

### P4. Offer → counter → acceptance → closing → transaction/commission
**Start trigger:** "New Offer" on Contact or Listing (Offer Creation Wizard: pick or create Listing, then relate Contact). Verified [S19][S21][S22].
1. **Initiation** — `pba__Offer__c` created with offered amount (`pba__OfferedAmount_pb__c`), buyer, target close date, conditions in internal notes. Verified [S16][S18][S20].
2. **Data processing** — Offer history related list records buyer/seller offers and counters. Verified [S18].
3. **Business operations** —
   - "Create Counter Offer": new Offer linked to original; original Status → "Inactive"; listing unchanged. Verified [S18].
   - "Reservation": Offer → "Active (Reservation)"; Listing → "Reserved". Verified [S18].
4. **Decision/approval** —
   - "Accept Offer": Offer → "Accepted"; Listing → "Sold" (vendor default; other versions use "Under Offer"/"Under Contract"/"Pending"). Packaged Offer trigger sets `pba__SystemHasAcceptedOffer__c` / `...ExclusiveOffer__c` on Listing. Verified [S7][S9][S18].
   - "Cancel Offer": Offer → "Cancelled"; Listing → "Available". Verified [S18].
   - No approval process found. Unknown.
5. **Completion** — "New Closing" from Offer copies data (Listing link, CurrencyIsoCode); Closing tracks status, target/actual date, commission overview, desk fee deductions, closing checklist; Closing trigger sets `pba__SystemHasXXX__c` on Offer and `pba__SystemHasClosedClosing__c` on Listing (Inferred from naming + [S7] pattern). Example rule: Closed requires ClosingDate; a second non-cancelled Closing blocked. Verified [S7][S9][S17].
6. **Post-completion** — Transactions synced from Workspace/BackAgent (phases Start → Contract → Showing → Pre-Closing → Post-Closing) with Transaction Members (Side/Role); Financial Add-On Payments/Cash/Receipts (Payment → Paid automatically when fully allocated); Campaign ROI counts accepted/closed offers; dashboards "All Closed Transactions YTD" etc. Verified [S20][S26][S27][S29].
   - **Alternate/cancel:** Closing status "Canceled" (Verified [S9]); Transaction report "All Cancelled Transactions YTD" (Verified [S29]); reopen behaviour Unknown.

### Status lists (ordered, best evidence)
- **Listing** (typical lifecycle, union of vendor values): In Preparation / Off-Market → Private (optional) → Active / Available / Published → Under Offer / Reserved / Pending / Under Contract → Sold (or Leased mapped to Sold for Dotloop) → Archived. Verified values [S9][S18][S34]; order Inferred.
- **Offer:** (initial Unknown) → Active (Reservation) → Accepted | Cancelled | Inactive (superseded by counter). Verified [S18].
- **Closing:** (open values Unknown) → Closed | Canceled. Verified [S9].
- **Transaction phase:** Start → Contract → Showing → Pre-Closing → Post-Closing. Verified [S27].
- **Contact stage:** includes "Contacted Lead", "Active"; grouped Leads vs Clients. Partial. Verified [S9][S30].
- **Payment:** Planned → Pending → Paid | Cancelled. Verified [S26].

## 7. Automation table

| Automation | Trigger | Object | Action | Outcome | Likely tech | Label |
|---|---|---|---|---|---|---|
| Shadow account + individual flag sync | Contact insert/update | Contact/Account | Create/maintain individual account, sync `pba__SystemIsIndividual__c`, record types | 1:1 person accounts without Person Accounts | Apex trigger (packaged) | Verified [S7] |
| Delete abandoned requests | Contact delete | Request | Delete orphan Requests | Clean data | Apex trigger | Verified [S7] |
| Showing ↔ Favorite feedback mirror | Event insert/update | Event, Favorite | Copy mapped fields | Feedback on Linked Listing | Apex trigger + setting | Verified [S7] |
| Request reassign → Favorites | Request contact change | Favorite | Update contact on favourites | Consistency | Apex trigger | Verified [S7] |
| Listing → Property sync | Listing insert/update | Property | Create Property; copy same-name fields | Property history | Apex trigger + settings | Verified [S7][S10] |
| Offer system flags | Offer insert/update | Listing | Set `pba__SystemHasXXX__c` | Listing knows accepted/exclusive offer | Apex trigger | Verified [S7] |
| Closing system flags + copy | Closing insert/update | Offer, Closing | Set flags; copy Listing + CurrencyIsoCode | Consistency | Apex trigger | Verified [S7] |
| Offer buttons | User click | Offer, Listing | Set Offer status & Listing status | Lifecycle | Apex/VF or quick actions (Unknown) | Verified behaviour [S18] |
| Offer Automation / Closing Automation | Offer/Closing change | Listing | Tick listing system checkboxes | Used by validation | Process Builder | Verified (name) [S9] |
| Lead Routing - Contact / - Inquiry | New Contact / Inquiry | Contact | Set Routing Source → distributor assigns owner, notify (email, Chatter, SMS) | Lead ownership | Process Builder + Apex + VF | Verified [S23] |
| Sales Rotation | New enquiry with Rotation Name | Request, Task | Assign member, create Task, email | Rotation | Apex (add-on) | Verified [S24] |
| Front Desk parsing | Inbound email | Contact, Request, Linked Listing, Task | Parse + upsert | Lead in CRM | External service + REST | Verified [S25] |
| WebToProspect | HTTP POST | Contact, Request, Linked Listing | Dedupe + create | Lead in CRM | Apex REST | Verified [S13] |
| Drip campaign | Start Drip Campaign button or Process Builder on Contact | Drip Campaign | Scheduled emails | Nurture | Scheduled Apex / Email Scheduler | Verified [S35] |
| Update Contact based off Call Outcomes | Call logged | Contact | Set Last Attempted Contact | Dashboard | Process Builder "1.1 ..." | Verified [S30] |
| Auto Publish | Listing/Portal criteria true | Portal listing | Publish once (async) | Syndication | Apex async | Verified [S33] |
| Website activity sync | Website event | Website Listing-*, Contact, Request | Create records immediately | Behaviour tracking | External (Boston Logic) → API | Verified [S32] |
| Transaction sync | Save in Workspace/BackAgent | Transaction, Member, Contact | Upsert (one-way into CRM) | Back-office visibility | External integration | Verified [S27][S28] |
| Payment overdue / paid | Due date passed / full allocation | Payment | Set Overdue / Status Paid | AR tracking | Formula / Apex | Verified behaviour [S26]; tech Inferred |
| Campaign ROI copy | CampaignResult update | CampaignResult | Field updates from formulas | Roll-ups | Workflow | Verified [S20] |
| Website user sync | "sync users" button | User → Boston Logic | Push users | Agent pages | External | Verified [S32] |

## 8. UI / UX

- **Apps:** PB Agent, PB Manager, PB Admin, PB Leads, PB Transactions (Lightning). Verified [S31].
- **Tabs observed in docs:** Contacts, Inquiries, Listings, Properties, Offers, Closings, Transactions, Teams (Lead Router), Campaign ROI (Classic), Drip Campaigns app, Control Center. Verified [S16][S17][S20][S23][S27][S35].
- **Contact record page:** Stage Path; tabs Related (Inquiries, Offers, Owned Properties), Activity (Calls, Tasks, Events, Showings; Next Steps/Past Activities), Tracking (Quicksend emails), Saved Searches; actions Follow, Send Email, Edit, New Inquiry, Start Drip Campaign, Start Action Plan, New Offer, Add Owned Property, Change Record Type, Delete. Verified [S21].
- **Inquiry record page:** Details, Related (Linked Listings with client rating), Activity; actions Follow, Send Email (Quicksend), Edit, New Linked Listing, Start Action Plan, Matching (new window), Delete; compact layout "Request Compact Layout". Verified [S14].
- **Listing record page:** actions Follow, Send Email, Edit, New Offer, New Closing, Start Action Plan, Create PDF, Email All Linked Contacts, Matching, Delete; tabs Details, Related (Offers, "Linked To", "Listed on these portals"), Images and Media, Matching, Email (Quicksend), Activity. Verified [S22].
- **Offer / Closing pages:** Path (mark status as complete), Details, Related, Activity, Chatter; Closing details tab includes commission overview and closing checklist. Verified [S16][S17].
- **Managers:** Listing Manager (with Listing Favorites star), Contact Manager, Activity Manager; Listing Browser filters. Verified [S11][S44].
- **Views:** list views; map via OpenStreetMaps; Building Stack (colour-coded stacking view); Follow-up Calendar component. Kanban not documented (Unknown). Verified [S11][S30].
- **Mobile:** native iOS/Android app; Chatter push for routing. Verified [S1][S23].
- **Portals/websites:** Propertybase Websites (Boston Logic) with logged-in visitor accounts; guest-user Site for webservices. Verified [S32][S36].
- **Public screenshots/demo URLs (not downloaded):**
  - https://propertybase.lwolf.com/ — vendor product page with product imagery (hubfs images) of SE dashboards/records.
  - https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016ckJEAQ — AppExchange listing (screenshots carousel).
  - https://help.propertybase.com/hc/en-us/categories/360002553640-Training-Video — vendor training video category (dashboards, reporting).
  - https://www.lwolf.com/training-resources/propertybase-se — Lone Wolf training resources for Propertybase SE.
  - https://help.propertybase.com/hc/en-us/articles/360014144399 — "Drip Campaigns" (embedded video).
  - https://www.youtube.com/getlwolf — Lone Wolf YouTube channel (no specific Propertybase SE demo identified).
  - No YouTube demo was verified; nothing Observed.

## 9. Reporting

- **Reports & Dashboards package:** dashboards "Agent Performance" (My … reports) and "Company Performance" (All … reports); 22 transaction reports (e.g. "All Closed Transactions YTD", "All Closed Transactions by Side & Month", "My Pending Seller Transactions"); Website Audit reports ("Website Views/Favorites/Showings/Inquiries created Last Week", "Pocket Listing Website Audit", "User - Display on Website Audit"); Back Office Audit "Transactions Imported Last 7 Days". Verified [S29].
- **Managed dashboard components:** PB Marketing Health (% of contacts on drips/action plans/recurring emails), PB Contact Database Health (field completeness by `pba__Stage_pb__c`), Activity Overview, PB Last Attempted Contact (by Lead Rating, frequency bands A–D on User), PB Follow-up Calendar (birthdays, events, next follow-ups, 7 days). Verified [S30].
- **Other:** Showings Report Template (ActivityDate, `pba__Rating_pb__c`, `ClientFeedback__c`, 30 days); Website Activity reports via custom report type "Contacts with Website Views"; Campaign ROI (Classic); Sales Rotation member assignment history. Verified [S20][S24][S37][S38].
- **KPIs implied:** closed/pending volume by side, YTD, by month; lead coverage; data completeness; follow-up compliance; website engagement. Verified (from report names) [S29][S30].

## 10. Integrations

| External system | Purpose | Direction | Data | Trigger | Technology | Label | Source |
|---|---|---|---|---|---|---|---|
| Front Desk (Propertybase service) | Lead capture from portals/email | In | Contact, Inquiry, Linked Listing, Task | Inbound email | Email parsing service → Propertybase webservice | Verified | [S25] |
| Zillow/Trulia Premier Agent, Realtor.com, Facebook Lead Ads | Lead sources | In | Leads | Real time | Via Front Desk | Verified | [S25] |
| Custom websites | Web-to-lead | In | Contact, Inquiry, favourites | HTTP POST | Apex REST WebToProspect v1 | Verified | [S13] |
| Propertybase Websites (Boston Logic) | IDX/MLS website, visitor tracking | In (activity) / Out (users, pocket listings) | Contacts, saved searches, website activity, users, listings | Immediate / button / sync | Boston Logic integration (`pba_bl` fields, `BostonLogicId`) | Verified | [S32][S38] |
| MLS (via websites / Workspace) | Listing data, MLS IDs, field-value import | In | Listings (IDX flags `pba__SystemIsIDX__c`, pools), MLS Membership | Sync (website every 10 min mentioned) | Websites/Workspace; RETS/RESO not documented | Verified (partial); provider tech Unknown | [S11][S38] |
| Portals (Rightmove, Zoopla, LonRes, OnTheMarket, Zillow, Idealista, Realogy/Sotheby's, Boomin; UAE/Australian portals) | Listing syndication | Out | Listings, media | Auto Publish / manual | Portal Syndication feeds with field mapping | Verified | [S33] |
| Lone Wolf Workspace (Transact) | Transaction management | In (one-way) | Transactions, Members, Contacts | Save in Workspace; SSO from Contact | SSO + API | Verified | [S27] |
| BackAgent (Lone Wolf back office) | Back office | In | Transactions, Members, optional Contacts | SSO; first transaction triggers backfill | SSO + API | Verified | [S28] |
| Dotloop | E-sign / transaction docs | Two-way | Listing, Offer, Closing loop fields | Buttons "LOOP IT", "Update Loop", "Copy from Dotloop" | API (`pba_dl` fields, `dotloop_*` settings) | Verified | [S34] |
| Authentisign (Lone Wolf) | E-signature for offers | Within CRM | Offer documents | User action | Built-in | Verified (claim) | [S1] |
| Propertybase Mailservice / email scheduler | Quicksend, mass email, drips, notifications | Out | Emails, tracking | User / schedule | Propertybase service (`loewy_token`) | Verified | [S11][S35] |
| SMS (North America, Australia) | Lead routing alerts | Out | Text | Routing | Service (unnamed) | Verified | [S23] |
| EstateMaster (AUS) | Sales mapping/forecast | Unknown | Accepted offers, Forecast Settlement Date | Unknown | Unknown | Verified (exists; article "EstateMaster Overview (AUS)" 115002975292, search snippet) | [S47] |
| OpenStreetMaps | Map display | Out (query) | Address/lat/long | View | Map component | Verified | [S11] |
| Agentforce | AI lead scoring | Within Salesforce | — | — | Salesforce AI | Verified claim only | [S1] |

## 11. Limitations & what would be hard to recreate

- **Matching engine** — dynamic filter generation from same-named Inquiry `_min/_max` fields to Listing fields, with mapping/black/whitelists and an SPA Listing Browser. Requires a metadata-driven Apex/LWC matcher. Verified concept [S11][S12].
- **System-flag denormalisation** — `pba__SystemIsXXX__c` → `pba__SystemHasXXX__c` cascade across Closing → Offer → Listing; must be reproduced with ordered triggers. Verified [S7].
- **Shadow individual accounts** — custom alternative to Person Accounts (record types `Individual_pb`). Verified [S7][S11].
- **Lead routing with Click-to-Claim** — needs a public Site, VF page, email/SMS service and round-robin state. Verified [S23].
- **Front Desk** — proprietary email-parsing service with per-portal parsers created by Support; cannot be recreated from public docs. Verified [S25].
- **Portal syndication** — per-portal feed formats and mapping tables; external feed hosting. Verified [S33].
- **Website/IDX** — depends on Boston Logic (now Lone Wolf Front Office) platform outside Salesforce. Verified [S32]; Inferred that a clone would need its own IDX vendor.
- **Transaction sync** — depends on Lone Wolf Workspace/BackAgent proprietary APIs and SSO. Verified [S27][S28].
- **Data-model gaps (Unknown):** exact API names for Linked Listing/Favorite, Property Media, Transaction Member, Payment/Cash/Receipt, Portal objects, Website Listing objects, Settings; full picklists for Inquiry status, Contact stage, Offer initial status, Closing open statuses; commission object design (appears to be fields on Closing rather than a separate object — Inferred from [S17][S34]).
- **Documentation age** — many help articles are Classic-era (2017–2021); AppExchange listing "last updated 03/02/2022" while the vendor says releases ship every 3–6 weeks. Current Flow/LWC internals are not publicly documented. Verified [S1][S3].
- **Product confusion risk** — Propertybase GO/Front Office ≠ Salesforce Edition; reviews and pricing on third-party sites mix them. Verified [S2][S5].

## 12. Sources

| id | Title | URL | Type | Accessed |
|---|---|---|---|---|
| S1 | Propertybase by Lone Wolf (Salesforce Edition product page) | https://propertybase.lwolf.com/ (redirect from https://www.propertybase.com/real-estate-crm/salesforce-edition) | vendor site | 2026-11-12 |
| S2 | Propertybase — choose your solution (SE vs Front Office) | https://propertybase.lwolf.com/choose | vendor site | 2026-11-12 |
| S3 | AppExchange: Propertybase Real Estate Platform | https://appexchange.salesforce.com/appxListingDetail?listingId=a0N300000016ckJEAQ | AppExchange | 2026-11-12 |
| S4 | Lone Wolf acquires Propertybase (press release, 25 Aug 2021) | https://lwolf.com/press-releases/lone-wolf-acquires-propertybase-to-complete-real-estates-ultimate-technology-platform-for-agents-and-brokers | vendor site | 2026-11-12 |
| S5 | ICYMI: Propertybase GO is now Lone Wolf Front Office (29 Aug 2024) | https://www.lwolf.com/blog/icymi-propertybase-now-lone-wolf-front-office | vendor site | 2026-11-12 |
| S6 | Boston Logic buys Propertybase (Inman, 1 Jun 2017); PE Hub on Lone Wolf deal (search snippets) | https://www.inman.com/2017/06/01/boston-logic-buys-propertybase-with-more-acquisitions-in-sight/ ; https://pehub.com/stone-point-backed-lone-wolf-technologies-acquires-propertybase | third party | 2026-11-12 |
| S7 | Considerations for Custom Triggers (203188053) | https://help.propertybase.com/hc/en-us/articles/203188053-Considerations-for-Custom-Triggers | help | 2026-11-12 |
| S8 | Delete the demo/sample data from the trial phase out of your ORG (203978856) | https://help.propertybase.com/hc/en-us/articles/203978856 | help | 2026-11-12 |
| S9 | Validation Example Rules (115000302912) | https://help.propertybase.com/hc/en-us/articles/115000302912-Validation-Example-Rules | help | 2026-11-12 |
| S10 | Listing and Property Relationship (202898886) | https://help.propertybase.com/hc/en-us/articles/202898886-Listing-and-Property-Relationship | help | 2026-11-12 |
| S11 | Setting Configurations (209034637) | https://help.propertybase.com/hc/en-us/articles/209034637-Setting-Configurations | help | 2026-11-12 |
| S12 | Customize how to Find Matching Listings (Object: pba__Request__c) (203187423) | https://help.propertybase.com/hc/en-us/articles/203187423 | help | 2026-11-12 |
| S13 | WebToProspect REST API (360003180752) | https://help.propertybase.com/hc/en-us/articles/360003180752-WebToProspect-REST-API | help | 2026-11-12 |
| S14 | Core Feature: Inquiry Management (360005051331) | https://help.propertybase.com/hc/en-us/articles/360005051331 | help | 2026-11-12 |
| S15 | Getting Started Series: Managing Inquiries (115001914111) | https://help.propertybase.com/hc/en-us/articles/115001914111 | help | 2026-11-12 |
| S16 | Getting Started Series: Managing Offers (115002223592) | https://help.propertybase.com/hc/en-us/articles/115002223592 | help | 2026-11-12 |
| S17 | Getting Started Series: Managing Closings (115002218091) | https://help.propertybase.com/hc/en-us/articles/115002218091 | help | 2026-11-12 |
| S18 | All about Offers (202898996) | https://help.propertybase.com/hc/en-us/articles/202898996 | help | 2026-11-12 |
| S19 | Offer Creation Wizard (202898986) | https://help.propertybase.com/hc/en-us/articles/202898986-Offer-Creation-Wizard | help | 2026-11-12 |
| S20 | Campaigns ROI Setup (202899026) | https://help.propertybase.com/hc/en-us/articles/202899026-Campaigns-ROI-Setup | help | 2026-11-12 |
| S21 | Core Feature: Contact Management (360004395212) | https://help.propertybase.com/hc/en-us/articles/360004395212 | help | 2026-11-12 |
| S22 | Core Feature: Listing Management (360005560211) | https://help.propertybase.com/hc/en-us/articles/360005560211 | help | 2026-11-12 |
| S23 | How to Use Lead Routing (360003066252) | https://help.propertybase.com/hc/en-us/articles/360003066252 | help | 2026-11-12 |
| S24 | The Sales Rotation Overview (210398417) | https://help.propertybase.com/hc/en-us/articles/210398417 | help | 2026-11-12 |
| S25 | Front Desk article set: Overview (115000633191), Adding a New Portal Lead Source (360001815131), Facebook (217195167), Realtor.com (115000382408), Zillow & Trulia (204828838), XML-to-Email Webforms (360003180872) — via help-center search API | https://help.propertybase.com/api/v2/help_center/articles/search.json?query=Front%20Desk%20sources | help | 2026-11-12 |
| S26 | Financial Add On (203247903) | https://help.propertybase.com/hc/en-us/articles/203247903-Financial-Add-On | help | 2026-11-12 |
| S27 | Using Transactions (360030780531) | https://help.propertybase.com/hc/en-us/articles/360030780531 | help | 2026-11-12 |
| S28 | Back Office Overview (BackAgent) (360016102711) | https://help.propertybase.com/hc/en-us/articles/360016102711 | help | 2026-11-12 |
| S29 | Propertybase Reports and Dashboards Package (360010820179) | https://help.propertybase.com/hc/en-us/articles/360010820179 | help | 2026-11-12 |
| S30 | Dashboard Components (360033394711) | https://help.propertybase.com/hc/en-us/articles/360033394711-Dashboard-Components | help | 2026-11-12 |
| S31 | Creating and Modifying Apps (203187143) | https://help.propertybase.com/hc/en-us/articles/203187143 | help | 2026-11-12 |
| S32 | Websites Overview (360016188271) | https://help.propertybase.com/hc/en-us/articles/360016188271-Websites-Overview | help | 2026-11-12 |
| S33 | Portal Syndication for the US and Europe (360007169231) | https://help.propertybase.com/hc/en-us/articles/360007169231-Portal-Syndication-for-the-US-and-Europe | help | 2026-11-12 |
| S34 | Dotloop Overview (360000441111) | https://help.propertybase.com/hc/en-us/articles/360000441111-Dotloop-Overview | help | 2026-11-12 |
| S35 | Drip campaign articles: Drip Campaigns (360014144399), Configuring (115002642171), Using (115002642351), Propertybase Services (360011220560), Understanding Templates (360013857972) | https://help.propertybase.com/hc/en-us/articles/115002642351 | help | 2026-11-12 |
| S36 | Updating Permission Sets and Sharing Rules for Guest Users (360016765600) | https://help.propertybase.com/hc/en-us/articles/360016765600 | help | 2026-11-12 |
| S37 | Showings in Propertybase (203187543); Calendar Management (360004222711); Showings Report Template (203248023) — search API snippets | https://help.propertybase.com/hc/en-us/articles/203187543 | help | 2026-11-12 |
| S38 | Using Teams and Offices (360030451572); Importing MLS Field Values (360024690852); Website Listings Sync (360016465791); Building Website Activity Reports (360020872831) — search API snippets | https://help.propertybase.com/hc/en-us/articles/360030451572 | help | 2026-11-12 |
| S39 | Propertybase GO API documentation | https://apidocs.propertybase.com | vendor docs (GO) | 2026-11-12 |
| S40 | Capterra — Propertybase Salesforce Edition reviews (search snippet; page 403) | https://www.capterra.com/p/122129/Propertybase/reviews/ | review | 2026-11-12 |
| S41 | G2 — Propertybase seller page (search snippet; page 403) | https://www.g2.com/sellers/propertybase | review | 2026-11-12 |
| S42 | AscendixRE vs Propertybase comparison (competitor; search snippet) ; FitSmallBusiness Propertybase review | https://ascendix.com/blog/ascendixre-vs-propertybase/ ; https://fitsmallbusiness.com/propertybase-review | third party | 2026-11-12 |
| S43 | Multi level hierarchy for Properties (202964956) — search snippet | https://help.propertybase.com/hc/en-us/articles/202964956 | help | 2026-11-12 |
| S44 | Using the Listing Manager (360018651651); The Listing Browser (Classic) (203187453) — search snippets | https://help.propertybase.com/hc/en-us/articles/360018651651-Using-the-Listing-Manager | help | 2026-11-12 |
| S45 | Training Video category | https://help.propertybase.com/hc/en-us/categories/360002553640-Training-Video | help | 2026-11-12 |
| S46 | Lone Wolf training resources — Propertybase SE | https://www.lwolf.com/training-resources/propertybase-se | vendor site | 2026-11-12 |
| S47 | EstateMaster Overview (AUS) (115002975292) — search API snippet | https://help.propertybase.com/hc/en-us/articles/115002975292 | help | 2026-11-12 |
