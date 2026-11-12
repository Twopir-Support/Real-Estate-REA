/*
 * TC Commercial Real Estate — single source of truth for the data model.
 * Mirrors the publicly documented AscendixRE object structure, under TC_ naming.
 *
 * src: 'A' = documented by AscendixRE (public help centre / AppExchange)
 *      'T' = TC design (fills a gap the public docs leave open)
 *
 * Consumed by scripts/generate.js, which emits SFDX metadata, docs and the field inventory.
 */

// ---------- field helpers ----------
const F = (api, label, type, o = {}) => ({ api, label, type, src: 'T', ...o });
const Text = (api, label, length = 255, o) => F(api, label, 'Text', { length, ...o });
const LText = (api, label, o) => F(api, label, 'LongTextArea', { length: 32768, visibleLines: 5, ...o });
const Num = (api, label, precision = 12, scale = 0, o) => F(api, label, 'Number', { precision, scale, ...o });
const Cur = (api, label, precision = 16, scale = 2, o) => F(api, label, 'Currency', { precision, scale, ...o });
const Pct = (api, label, precision = 5, scale = 2, o) => F(api, label, 'Percent', { precision, scale, ...o });
const Dt = (api, label, o) => F(api, label, 'Date', o);
const Chk = (api, label, o) => F(api, label, 'Checkbox', { defaultValue: 'false', ...o });
const Url = (api, label, o) => F(api, label, 'Url', o);
const Email = (api, label, o) => F(api, label, 'Email', o);
const Phone = (api, label, o) => F(api, label, 'Phone', o);
const PL = (api, label, values, o) => F(api, label, 'Picklist', { values, ...o });
const GPL = (api, label, gvs, o) => F(api, label, 'Picklist', { gvs, ...o });
const MPL = (api, label, values, o) => F(api, label, 'MultiselectPicklist', { values, visibleLines: 5, ...o });
const GMPL = (api, label, gvs, o) => F(api, label, 'MultiselectPicklist', { gvs, visibleLines: 5, ...o });
const LK = (api, label, ref, o) => F(api, label, 'Lookup', { ref, ...o });
const MD = (api, label, ref, o) => F(api, label, 'MasterDetail', { ref, required: true, ...o });
const FX = (api, label, returnType, formula, o) => F(api, label, 'Formula', { returnType, formula, ...o });
const RS = (api, label, op, child, fk, field, o) => F(api, label, 'Summary', { op, child, fk, field, ...o });
const Geo = (api, label, o) => F(api, label, 'Location', o);
const A = { src: 'A' };   // shorthand: documented by AscendixRE
const AUTO = { auto: true }; // maintained by Apex (read-only on layouts)

// ---------- global value sets ----------
const globalValueSets = {
  TC_Property_Type: { label: 'TC Property Type', values: ['Office', 'Retail', 'Industrial', 'Multifamily', 'Land', 'Hospitality', 'Mixed Use', 'Special Purpose'] },
  TC_Building_Class: { label: 'TC Building Class', values: ['A', 'B', 'C'] },
  TC_Rent_Type: { label: 'TC Rent Type', values: ['NNN', 'Gross', 'Modified Gross', 'Full Service', 'Industrial Gross'] },
  TC_Lease_Type: { label: 'TC Lease Type', values: ['Gross', 'Modified Gross', 'NNN', 'Full Service', 'Ground', 'Percentage'] },
  TC_Total_Rent_Calculation: { label: 'TC Total Rent Calculation', values: ['Annual Ratio Rent', 'Monthly Rate'] },
};

const subtypeMap = {
  'Office': ['CBD', 'Suburban', 'Creative / Loft', 'Medical Office'],
  'Retail': ['Strip Center', 'Neighborhood Center', 'Power Center', 'Mall', 'Freestanding', 'Street Retail'],
  'Industrial': ['Warehouse / Distribution', 'Manufacturing', 'Flex / R&D', 'Cold Storage', 'Data Center'],
  'Multifamily': ['Garden', 'Mid-Rise', 'High-Rise', 'Student Housing', 'Senior Housing'],
  'Land': ['Commercial Land', 'Industrial Land', 'Residential Land', 'Agricultural'],
  'Hospitality': ['Full Service Hotel', 'Limited Service Hotel', 'Resort'],
  'Mixed Use': ['Office / Retail', 'Residential / Retail'],
  'Special Purpose': ['Self Storage', 'Healthcare', 'Education', 'Religious'],
};
const subtypeField = () => PL('TC_Property_Subtype__c', 'Property Sub Type', null, { ...A, controllingField: 'TC_Property_Type__c', dependent: subtypeMap });

const propertyRTs = globalValueSets.TC_Property_Type.values.map(v => ({ api: 'TC_' + v.replace(/ /g, '_'), label: v, restrict: { TC_Property_Type__c: [v] } }));

const dealRTs = [
  ['TC_Tenant_Representation', 'Tenant Representation'], ['TC_Landlord_Representation', 'Landlord Representation'],
  ['TC_Seller_Representation', 'Seller Representation'], ['TC_Buyer_Representation', 'Buyer Representation'],
  ['TC_Listing_Pursuit', 'Listing Pursuit'], ['TC_Capital_Markets', 'Capital Markets'],
  ['TC_Asset_Management', 'Asset Management'], ['TC_Consulting', 'Consulting'], ['TC_Financing', 'Financing'],
  ['TC_Lease_Administration', 'Lease Administration'], ['TC_Project_Management', 'Project Management'],
  ['TC_Property_Management', 'Property Management'],
].map(([api, label]) => ({ api, label }));

const RENT_TABLE_FIELDS = (parentApi, parentLabel) => [
  MD(parentApi, parentLabel, parentApi, A),
  Num('TC_Period_Number__c', 'Period Number', 3, 0, { required: false }),
  Dt('TC_From__c', 'From', { ...A, required: true }),
  Dt('TC_To__c', 'To', { ...A, required: true }),
  Num('TC_Duration_Months__c', 'Duration (Months)', 6, 2, { ...A, ...AUTO }),
  Cur('TC_Rate__c', 'Rate ($/SF/yr)', 10, 2, A),
  Cur('TC_Rent_Per_Month__c', 'Rent Per Month', 14, 2, A),
  Cur('TC_Total_Rent__c', 'Total Rent', 16, 2, { ...A, ...AUTO }),
  Chk('TC_Free_Rent__c', 'Free Rent'),
];
const RENT_TABLE_VRS = [
  { name: 'TC_Period_End_After_Start', formula: 'TC_To__c < TC_From__c', msg: 'The period end date (To) must be on or after the start date (From).', field: 'TC_To__c' },
  { name: 'TC_Prevent_Blank_Rate_And_Rent', src: 'A', formula: 'AND(NOT(TC_Free_Rent__c), ISBLANK(TC_Rate__c), ISBLANK(TC_Rent_Per_Month__c))', msg: 'Enter a Rate or a Rent Per Month, or mark the period as Free Rent.' },
];

// ---------- objects ----------
const objects = [
  {
    api: 'TC_Property__c', label: 'Property', plural: 'Properties', motif: 'Custom24: Building', src: 'A',
    desc: 'The physical building or land parcel. Hub of the CRE data model: listings, availabilities, leases, sales, deals and inquiries all relate to it.',
    nameField: { label: 'Property Name', type: 'Text' },
    recordTypes: propertyRTs,
    fields: [
      GPL('TC_Property_Type__c', 'Property Type', 'TC_Property_Type', { ...A, required: false, help: 'Set from the record type when blank.' }),
      subtypeField(),
      GPL('TC_Building_Class__c', 'Class', 'TC_Building_Class', A),
      PL('TC_Building_Status__c', 'Building Status', ['Existing', 'Under Construction', 'Proposed', 'Under Renovation']),
      Text('TC_Street__c', 'Street', 255, A), Text('TC_City__c', 'City', 80, A), Text('TC_State__c', 'State / Province', 40, A),
      Text('TC_Postal_Code__c', 'Postal Code', 20, A), Text('TC_Country__c', 'Country', 80, A),
      Geo('TC_Location__c', 'Geolocation', A),
      Text('TC_Market__c', 'Market', 80, A), Text('TC_Region__c', 'Region', 80, A), Text('TC_Submarket__c', 'Sub Market', 80, A),
      LK('TC_Owner_Landlord__c', 'Owner / Landlord', 'Account', A),
      LK('TC_Owner_Landlord_Contact__c', 'Owner / Landlord Contact', 'Contact', A),
      LK('TC_Listing_Broker_Company__c', 'Listing Broker Company', 'Account', A),
      LK('TC_Listing_Broker_Contact__c', 'Listing Broker Contact', 'Contact', A),
      LK('TC_Property_Manager__c', 'Property Manager', 'Account', A),
      Num('TC_Number_of_Floors__c', 'Number of Floors', 3, 0, A),
      Num('TC_Average_Floor_Size__c', 'Average Floor Size (SF)', 10, 0, A),
      Num('TC_Total_Size__c', 'Total Size (SF)', 12, 0, A),
      Num('TC_Land_Area_Acres__c', 'Land Area (Acres)', 8, 2),
      Num('TC_Year_Built__c', 'Year Built', 4, 0), Num('TC_Year_Renovated__c', 'Year Renovated', 4, 0),
      Num('TC_Parking_Spaces__c', 'Parking Spaces', 6, 0),
      Text('TC_Zoning__c', 'Zoning', 40), Text('TC_Parcel_Number__c', 'Parcel Number (APN)', 40),
      LText('TC_Description__c', 'Description', A), LText('TC_Location_Description__c', 'Location Description', A),
      Url('TC_Website__c', 'Website', A), Url('TC_Primary_Image_URL__c', 'Primary Image URL', A),
      Num('TC_Leased_SF__c', 'Leased Area (SF)', 12, 0, AUTO),
      Num('TC_Available_SF__c', 'Available Area (SF)', 12, 0, AUTO),
      Num('TC_Active_Listings__c', 'Active Listings', 4, 0, AUTO),
      Cur('TC_Avg_Asking_Rate__c', 'Avg Asking Rate ($/SF/yr)', 10, 2, AUTO),
      FX('TC_Occupancy__c', 'Occupancy %', 'Percent', 'IF(TC_Total_Size__c > 0, BLANKVALUE(TC_Leased_SF__c, 0) / TC_Total_Size__c, null)', { scale: 1 }),
      FX('TC_Vacancy__c', 'Vacancy %', 'Percent', 'IF(TC_Total_Size__c > 0, 1 - BLANKVALUE(TC_Leased_SF__c, 0) / TC_Total_Size__c, null)', { scale: 1 }),
      FX('TC_Full_Address__c', 'Full Address', 'Text', 'TC_Street__c & ", " & TC_City__c & IF(ISBLANK(TC_State__c), "", ", " & TC_State__c) & IF(ISBLANK(TC_Postal_Code__c), "", " " & TC_Postal_Code__c)'),
    ],
    vrs: [
      { name: 'TC_Year_Built_Range', formula: 'AND(NOT(ISBLANK(TC_Year_Built__c)), OR(TC_Year_Built__c < 1800, TC_Year_Built__c > YEAR(TODAY()) + 5))', msg: 'Year Built must be between 1800 and five years from now.', field: 'TC_Year_Built__c' },
      { name: 'TC_Renovated_After_Built', formula: 'AND(NOT(ISBLANK(TC_Year_Renovated__c)), NOT(ISBLANK(TC_Year_Built__c)), TC_Year_Renovated__c < TC_Year_Built__c)', msg: 'Year Renovated cannot be before Year Built.', field: 'TC_Year_Renovated__c' },
      { name: 'TC_Total_Size_Positive', formula: 'AND(NOT(ISBLANK(TC_Total_Size__c)), TC_Total_Size__c <= 0)', msg: 'Total Size must be greater than zero.', field: 'TC_Total_Size__c' },
    ],
    listColumns: ['TC_Property_Type__c', 'TC_City__c', 'TC_Building_Class__c', 'TC_Total_Size__c', 'TC_Occupancy__c'],
  },
  {
    api: 'TC_Unit_Profile__c', label: 'Unit Profile', plural: 'Unit Profiles', motif: 'Custom18: Form', src: 'A',
    desc: 'Reusable unit-type template (e.g. a standard office suite or a 2-bed apartment). Named by AscendixRE; fields are TC design.',
    nameField: { label: 'Unit Profile Name', type: 'Text' },
    fields: [
      PL('TC_Unit_Type__c', 'Unit Type', ['Office', 'Retail', 'Warehouse', 'Flex', 'Lab', 'Storage', 'Residential']),
      Num('TC_Typical_Size__c', 'Typical Size (SF)', 10, 0),
      Num('TC_Bedrooms__c', 'Bedrooms', 2, 0), Num('TC_Bathrooms__c', 'Bathrooms', 3, 1),
      Cur('TC_Typical_Rate__c', 'Typical Rate ($/SF/yr)', 10, 2),
      LText('TC_Description__c', 'Description'),
    ],
    listColumns: ['TC_Unit_Type__c', 'TC_Typical_Size__c', 'TC_Typical_Rate__c'],
  },
  {
    api: 'TC_Unit__c', label: 'Unit', plural: 'Units', motif: 'Custom57: Building Block', src: 'A',
    desc: 'A leasable unit or suite in a property. Named by AscendixRE; fields are TC design. Drives the stacking plan.',
    nameField: { label: 'Unit Name / Number', type: 'Text' },
    fields: [
      MD('TC_Property__c', 'Property', 'TC_Property__c'),
      Num('TC_Floor__c', 'Floor', 3, 0, { required: true }),
      PL('TC_Unit_Type__c', 'Unit Type', ['Office', 'Retail', 'Warehouse', 'Flex', 'Lab', 'Storage', 'Residential', 'Common Area']),
      Num('TC_Size__c', 'Size (SF)', 10, 0, { required: true }),
      PL('TC_Status__c', 'Status', ['Vacant', 'Occupied', 'Under Renovation', 'Not Leasable'], { required: true, defaultValue: 'Vacant' }),
      Num('TC_Position__c', 'Position on Floor', 3, 0, { help: 'Left-to-right order in the stacking plan.' }),
      LK('TC_Unit_Profile__c', 'Unit Profile', 'TC_Unit_Profile__c'),
      LK('TC_Current_Tenant__c', 'Current Tenant', 'Account', AUTO),
      LK('TC_Current_Lease__c', 'Current Lease', 'TC_Lease__c', AUTO),
      Dt('TC_Lease_Expiration__c', 'Lease Expiration', AUTO),
    ],
    vrs: [{ name: 'TC_Unit_Size_Positive', formula: 'TC_Size__c <= 0', msg: 'Unit size must be greater than zero.', field: 'TC_Size__c' }],
    listColumns: ['TC_Property__c', 'TC_Floor__c', 'TC_Size__c', 'TC_Status__c', 'TC_Current_Tenant__c'],
  },
  {
    api: 'TC_Availability__c', label: 'Availability', plural: 'Availabilities', motif: 'Custom79: Measuring Tape', src: 'A',
    desc: 'A vacant unit or suite in a property that is on the market. Status becomes Closed when the related deal closes.',
    nameField: { label: 'Availability Name', type: 'Text' },
    fields: [
      LK('TC_Property__c', 'Property', 'TC_Property__c', { ...A, required: true }),
      LK('TC_Unit__c', 'Unit', 'TC_Unit__c', A),
      LK('TC_Listing__c', 'Listing', 'TC_Listing__c'),
      Text('TC_Unit_Name__c', 'Unit Name / Number', 80, A),
      PL('TC_Availability_Type__c', 'Availability Type', ['Direct', 'Sublease', 'For Sale', 'Coworking'], { required: true, defaultValue: 'Direct' }),
      PL('TC_Space_Use__c', 'Space Use', ['Office', 'Retail', 'Industrial', 'Flex', 'Medical', 'Land'], A),
      PL('TC_Status__c', 'Status', ['Available', 'Pending', 'Closed', 'Off Market'], { ...A, required: true, defaultValue: 'Available' }),
      Num('TC_Size__c', 'Size (SF)', 10, 0, { ...A, required: true }),
      Num('TC_Min_Divisible__c', 'Min Divisible (SF)', 10, 0),
      Num('TC_Max_Contiguous__c', 'Max Contiguous (SF)', 10, 0),
      Num('TC_Floor__c', 'Floor', 3, 0, A),
      Cur('TC_Lease_Rate__c', 'Lease Rate ($/SF/yr)', 10, 2, A),
      GPL('TC_Rent_Type__c', 'Rent Type', 'TC_Rent_Type'),
      Cur('TC_Asking_Price__c', 'Asking Price', 16, 2),
      Dt('TC_Date_Available__c', 'Date Available'),
      Num('TC_Min_Term_Months__c', 'Min Term (Months)', 3, 0),
      Url('TC_Primary_Image_URL__c', 'Primary Image URL', A),
      FX('TC_Annual_Asking_Rent__c', 'Annual Asking Rent', 'Currency', 'TC_Size__c * TC_Lease_Rate__c'),
      FX('TC_Days_Vacant__c', 'Days Vacant', 'Number', 'IF(AND(ISPICKVAL(TC_Status__c, "Available"), NOT(ISBLANK(TC_Date_Available__c)), TC_Date_Available__c <= TODAY()), TODAY() - TC_Date_Available__c, null)'),
    ],
    vrs: [
      { name: 'TC_Min_Divisible_Within_Size', formula: 'AND(NOT(ISBLANK(TC_Min_Divisible__c)), TC_Min_Divisible__c > TC_Size__c)', msg: 'Min Divisible cannot be larger than the available Size.', field: 'TC_Min_Divisible__c' },
      { name: 'TC_Unit_Same_Property', formula: 'AND(NOT(ISBLANK(TC_Unit__c)), TC_Unit__r.TC_Property__c <> TC_Property__c)', msg: 'The selected Unit belongs to a different Property.', field: 'TC_Unit__c' },
      { name: 'TC_Size_Positive', formula: 'TC_Size__c <= 0', msg: 'Size must be greater than zero.', field: 'TC_Size__c' },
    ],
    listColumns: ['TC_Property__c', 'TC_Unit_Name__c', 'TC_Size__c', 'TC_Lease_Rate__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Listing__c', label: 'Listing', plural: 'Listings', motif: 'Custom53: Bell', src: 'A',
    desc: 'The listing agreement a broker holds to lease or sell a property. Anchor for marketing and inbound inquiries.',
    nameField: { label: 'Listing Name', type: 'Text' },
    recordTypes: [{ api: 'TC_Lease', label: 'Lease' }, { api: 'TC_Sale', label: 'Sale' }, { api: 'TC_Sale_or_Lease', label: 'Sale or Lease' }],
    fields: [
      LK('TC_Property__c', 'Property', 'TC_Property__c', { ...A, required: true }),
      Chk('TC_Exclusive__c', 'Exclusive', A), Chk('TC_Sublease__c', 'Sublease', A),
      PL('TC_Status__c', 'Status', ['Draft', 'Active', 'Under Contract', 'Closed', 'Expired', 'Withdrawn'], { required: true, defaultValue: 'Draft' }),
      LK('TC_Listing_Broker_Company__c', 'Listing Broker Company', 'Account', A),
      LK('TC_Listing_Broker_Contact__c', 'Listing Broker Contact', 'Contact', A),
      LK('TC_Listing_Broker__c', 'Listing Broker (User)', 'User'),
      LK('TC_Owner_Landlord__c', 'Owner / Landlord', 'Account', A),
      LK('TC_Owner_Landlord_Contact__c', 'Owner / Landlord Contact', 'Contact', A),
      Text('TC_Market__c', 'Market', 80, A), Text('TC_Region__c', 'Region', 80, A), Text('TC_Submarket__c', 'Sub Market', 80, A),
      GPL('TC_Property_Type__c', 'Property Type', 'TC_Property_Type', A), subtypeField(),
      LText('TC_Description__c', 'Description', A), LText('TC_Location_Description__c', 'Location Description', A),
      Url('TC_Website__c', 'Website', A), Url('TC_Primary_Image_URL__c', 'Primary Image URL', A),
      Dt('TC_Listing_Date__c', 'Listing Date'), Dt('TC_Expiration_Date__c', 'Expiration Date'),
      Cur('TC_Asking_Price__c', 'Asking Price', 16, 2), Cur('TC_Asking_Rate__c', 'Asking Rate ($/SF/yr)', 10, 2),
      GPL('TC_Rent_Type__c', 'Rent Type', 'TC_Rent_Type'),
      LK('TC_Deal__c', 'Listing Pursuit Deal', 'TC_Deal__c', A),
      Num('TC_Total_Available_SF__c', 'Total Available (SF)', 12, 0, AUTO),
      FX('TC_Days_on_Market__c', 'Days on Market', 'Number', 'IF(AND(ISPICKVAL(TC_Status__c, "Active"), NOT(ISBLANK(TC_Listing_Date__c))), TODAY() - TC_Listing_Date__c, null)'),
      FX('TC_Days_to_Expiration__c', 'Days to Expiration', 'Number', 'IF(ISBLANK(TC_Expiration_Date__c), null, TC_Expiration_Date__c - TODAY())'),
    ],
    vrs: [
      { name: 'TC_Expiration_After_Listing_Date', formula: 'AND(NOT(ISBLANK(TC_Expiration_Date__c)), NOT(ISBLANK(TC_Listing_Date__c)), TC_Expiration_Date__c <= TC_Listing_Date__c)', msg: 'Expiration Date must be after the Listing Date.', field: 'TC_Expiration_Date__c' },
      { name: 'TC_Active_Sale_Requires_Price', formula: 'AND(ISPICKVAL(TC_Status__c, "Active"), OR($RecordType.DeveloperName = "TC_Sale", $RecordType.DeveloperName = "TC_Sale_or_Lease"), ISBLANK(TC_Asking_Price__c))', msg: 'An active Sale listing needs an Asking Price.', field: 'TC_Asking_Price__c' },
      { name: 'TC_Active_Lease_Requires_Rate', formula: 'AND(ISPICKVAL(TC_Status__c, "Active"), OR($RecordType.DeveloperName = "TC_Lease", $RecordType.DeveloperName = "TC_Sale_or_Lease"), ISBLANK(TC_Asking_Rate__c))', msg: 'An active Lease listing needs an Asking Rate.', field: 'TC_Asking_Rate__c' },
    ],
    listColumns: ['TC_Property__c', 'RecordType', 'TC_Status__c', 'TC_Asking_Rate__c', 'TC_Expiration_Date__c'],
  },
  {
    api: 'TC_Deal__c', label: 'Deal', plural: 'Deals', motif: 'Custom48: Trophy', src: 'A',
    desc: 'A brokerage revenue opportunity, typed by business line (12 record types). Closing a deal as Won can create a Lease, Sale or Listing.',
    nameField: { label: 'Deal Name', type: 'Text' },
    recordTypes: dealRTs,
    fields: [
      LK('TC_Property__c', 'Property', 'TC_Property__c', A),
      LK('TC_Space__c', 'Space', 'TC_Availability__c', A),
      LK('TC_Listing__c', 'Listing', 'TC_Listing__c', A),
      LK('TC_Inquiry__c', 'Inquiry', 'TC_Inquiry__c'),
      LK('TC_Capital_Source__c', 'Capital Source', 'TC_Capital_Source__c'),
      PL('TC_Deal_Sub_Type__c', 'Deal Sub Type', ['Lease Listing - Exclusive', 'Lease Listing - Non Exclusive', 'Sale Listing - Exclusive', 'Sale Listing - Non-Exclusive', 'Sale or Lease', 'Sublease', 'New Lease', 'Renewal', 'Expansion', 'Relocation', 'Acquisition', 'Disposition', 'Refinance'], A),
      PL('TC_Stage__c', 'Stage', ['Prospect', 'Pitch / Proposal', 'Touring', 'LOI', 'Negotiation', 'Lease / PSA Out', 'Executed'], { ...A, required: true, defaultValue: 'Prospect', help: 'AscendixRE has a Stage field but does not publish its values; these are TC design.' }),
      PL('TC_Status__c', 'Deal Status', ['Open', 'Won', 'Lost'], { ...A, required: true, defaultValue: 'Open' }),
      Pct('TC_Probability__c', 'Probability', 3, 0, { help: 'Defaulted from the stage (TC Deal Stage Setting); can be overridden.' }),
      LK('TC_Client__c', 'Client', 'Account', A),
      LK('TC_Client_Contact__c', 'Client Contact', 'Contact', A),
      PL('TC_Client_Role__c', 'Client Role', ['Tenant', 'Owner/Landlord', 'Buyer', 'Seller', 'Borrower', 'Other'], A),
      PL('TC_Client_Contact_Role__c', 'Client Contact Role', ['Tenant', 'Owner/Landlord', 'Buyer', 'Seller', 'Borrower', 'Other'], A),
      LK('TC_Tenant__c', 'Tenant', 'Account', A), LK('TC_Tenant_Contact__c', 'Tenant Contact', 'Contact', A),
      LK('TC_Owner_Landlord__c', 'Owner / Landlord', 'Account', A), LK('TC_Owner_Landlord_Contact__c', 'Owner / Landlord Contact', 'Contact', A),
      LK('TC_Buyer__c', 'Buyer', 'Account', A), LK('TC_Buyer_Contact__c', 'Buyer Contact', 'Contact', A),
      LK('TC_Lender__c', 'Lender', 'Account', A), LK('TC_Lender_Contact__c', 'Lender Contact', 'Contact', A),
      LK('TC_Lead_Broker__c', 'Lead Broker', 'User'),
      PL('TC_Lead_Broker_Role__c', 'Lead Broker Role', ['Lead', 'Co-Lead', 'Support'], A),
      PL('TC_Source__c', 'Deal Source', ['Referral', 'Existing Client', 'Inquiry', 'Cold Call', 'Website', 'Event', 'Other'], A),
      LK('TC_Primary_Connection__c', 'Primary Connection', 'Contact', A),
      Cur('TC_Allowances__c', 'Allowances', 14, 2, A),
      Chk('TC_Multiple_Properties__c', 'Multiple Properties', A),
      Num('TC_Size__c', 'Size (SF)', 10, 0, A),
      Cur('TC_Lease_Rate__c', 'Lease Rate ($/SF/yr)', 10, 2, A),
      GPL('TC_Rent_Type__c', 'Rent Type', 'TC_Rent_Type', A),
      Dt('TC_Lease_Commencement__c', 'Lease Commencement', A),
      Dt('TC_Lease_Expiration__c', 'Lease Expiration', A),
      Num('TC_Period_Length_Months__c', 'Period Length (Months)', 3, 0, { ...A, defaultValue: '12' }),
      GPL('TC_Total_Rent_Calculation__c', 'Total Rent Calculation', 'TC_Total_Rent_Calculation', A),
      Pct('TC_Escalation__c', 'Annual Escalation %', 5, 2),
      Num('TC_Free_Rent_Months__c', 'Free Rent (Months)', 3, 0),
      Cur('TC_Listing_Price__c', 'Listing Price', 16, 2, A),
      Cur('TC_Sale_Price__c', 'Sale Price', 16, 2, A),
      Cur('TC_Loan_Amount__c', 'Loan Amount', 16, 2),
      Cur('TC_Gross_Deal_Value__c', 'Gross Deal Value', 16, 2, { ...A, ...AUTO, help: 'Lease: total rent over the term (from the rent table). Sale: sale price. Financing: loan amount.' }),
      PL('TC_Gross_Fee_Method__c', 'Gross Fee Method', ['Percent', 'Amount', 'By $ per SF'], { ...A, defaultValue: 'Percent' }),
      Pct('TC_Gross_Fee_Percent__c', 'Gross Fee Percent', 6, 3, A),
      Cur('TC_Gross_Fee_Rate_per_UOM__c', 'Gross Fee Rate per SF', 10, 2, A),
      Cur('TC_Gross_Fee_Amount__c', 'Gross Fee Amount', 14, 2, { ...A, help: 'Calculated for Percent and $ per SF; entered directly for Amount.' }),
      Cur('TC_Net_Deal_Fee__c', 'Net Deal Fee', 14, 2, { ...AUTO, help: 'Gross fee less co-broker and expense commissions.' }),
      Dt('TC_Est_Close_Date__c', 'Estimated Close Date'),
      Dt('TC_Actual_Close_Date__c', 'Actual Close Date', A),
      Cur('TC_Actual_Value__c', 'Actual Value', 16, 2, A),
      PL('TC_Lost_Reason__c', 'Lost Reason', ['Lost to Competitor', 'Client Stayed / Renewed', 'Pricing', 'Timing', 'Deal Fell Through', 'Other']),
      Num('TC_Total_Commission_Split__c', 'Inside Broker Split Total %', 6, 2, AUTO),
      FX('TC_Weighted_Fee__c', 'Weighted Fee', 'Currency', 'TC_Gross_Fee_Amount__c * TC_Probability__c'),
      FX('TC_Is_Closed__c', 'Closed', 'Checkbox', 'OR(ISPICKVAL(TC_Status__c, "Won"), ISPICKVAL(TC_Status__c, "Lost"))'),
      FX('TC_Deal_Type__c', 'Deal Type', 'Text', 'RecordType.Name'),
    ],
    vrs: [
      { name: 'TC_Lost_Reason_Required', formula: 'AND(ISPICKVAL(TC_Status__c, "Lost"), ISBLANK(TEXT(TC_Lost_Reason__c)))', msg: 'Choose a Lost Reason when closing a deal as Lost.', field: 'TC_Lost_Reason__c' },
      { name: 'TC_Close_Date_Not_Future', formula: 'TC_Actual_Close_Date__c > TODAY()', msg: 'Actual Close Date cannot be in the future.', field: 'TC_Actual_Close_Date__c' },
      { name: 'TC_Gross_Fee_Rate_per_UOM', src: 'A', formula: 'AND(ISPICKVAL(TC_Gross_Fee_Method__c, "By $ per SF"), OR(ISBLANK(TC_Size__c), ISBLANK(TC_Gross_Fee_Rate_per_UOM__c)))', msg: 'The $ per SF fee method needs both Size and Gross Fee Rate per SF.', field: 'TC_Gross_Fee_Rate_per_UOM__c' },
      { name: 'TC_Per_SF_Fee_Lease_Deals_Only', src: 'A', formula: 'AND(ISPICKVAL(TC_Gross_Fee_Method__c, "By $ per SF"), $RecordType.DeveloperName <> "TC_Tenant_Representation", $RecordType.DeveloperName <> "TC_Landlord_Representation")', msg: 'The $ per SF fee method is only available for Tenant and Landlord Representation deals.', field: 'TC_Gross_Fee_Method__c' },
      { name: 'TC_Lease_Expiration_After_Commencement', formula: 'AND(NOT(ISBLANK(TC_Lease_Expiration__c)), NOT(ISBLANK(TC_Lease_Commencement__c)), TC_Lease_Expiration__c <= TC_Lease_Commencement__c)', msg: 'Lease Expiration must be after Lease Commencement.', field: 'TC_Lease_Expiration__c' },
      { name: 'TC_Percent_Method_Requires_Percent', formula: 'AND(ISPICKVAL(TC_Gross_Fee_Method__c, "Percent"), ISPICKVAL(TC_Status__c, "Won"), ISBLANK(TC_Gross_Fee_Percent__c))', msg: 'Enter the Gross Fee Percent before closing the deal as Won.', field: 'TC_Gross_Fee_Percent__c' },
    ],
    listColumns: ['RecordType', 'TC_Stage__c', 'TC_Status__c', 'TC_Client__c', 'TC_Gross_Fee_Amount__c', 'TC_Est_Close_Date__c'],
  },
  {
    api: 'TC_Deal_Period__c', label: 'Deal Period', plural: 'Deal Periods', motif: 'Custom25: Alarm clock', src: 'A', noTab: true,
    desc: 'One row of the rent table on a Deal.',
    nameField: { label: 'Deal Period', type: 'AutoNumber', format: 'DP-{00000}' },
    fields: RENT_TABLE_FIELDS('TC_Deal__c', 'Deal'),
    vrs: RENT_TABLE_VRS,
    listColumns: ['TC_Deal__c', 'TC_From__c', 'TC_To__c', 'TC_Rate__c', 'TC_Total_Rent__c'],
  },
  {
    api: 'TC_Lease__c', label: 'Lease', plural: 'Leases', motif: 'Custom76: Keys', src: 'A',
    desc: 'Lease abstract: a tenant occupying space in a property. Serves as a lease comp and drives expiration prospecting.',
    nameField: { label: 'Lease Name', type: 'Text' },
    fields: [
      LK('TC_Property__c', 'Property', 'TC_Property__c', { ...A, required: true }),
      LK('TC_Unit__c', 'Unit', 'TC_Unit__c'),
      Text('TC_Unit_Name__c', 'Unit Name / Number', 80, A),
      PL('TC_Unit_Type__c', 'Unit Type', ['Office', 'Retail', 'Warehouse', 'Flex', 'Lab', 'Storage', 'Residential'], A),
      Num('TC_Floor__c', 'Floor', 3, 0, A),
      LK('TC_Tenant__c', 'Tenant', 'Account', { ...A, required: true }),
      LK('TC_Tenant_Contact__c', 'Tenant Contact', 'Contact'),
      LK('TC_Owner_Landlord__c', 'Owner / Landlord', 'Account'),
      LK('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      GPL('TC_Lease_Type__c', 'Lease Type', 'TC_Lease_Type', { ...A, required: true }),
      PL('TC_Status__c', 'Status', ['Pending', 'Active', 'Holdover', 'Expired', 'Terminated'], { required: true, defaultValue: 'Active' }),
      Num('TC_Size__c', 'Size (SF)', 10, 0, { ...A, required: true }),
      Cur('TC_Lease_Rate__c', 'Lease Rate ($/SF/yr)', 10, 2, A),
      GPL('TC_Rent_Type__c', 'Rent Type', 'TC_Rent_Type', A),
      Dt('TC_Commencement_Date__c', 'Commencement Date', { ...A, required: true }),
      Dt('TC_Expiration_Date__c', 'Expiration Date', { ...A, required: true }),
      Num('TC_Period_Length_Months__c', 'Period Length (Months)', 3, 0, { ...A, defaultValue: '12' }),
      GPL('TC_Total_Rent_Calculation__c', 'Total Rent Calculation', 'TC_Total_Rent_Calculation', A),
      Pct('TC_Escalation__c', 'Annual Escalation %', 5, 2),
      Num('TC_Free_Rent_Months__c', 'Free Rent (Months)', 3, 0),
      Cur('TC_TI_Allowance__c', 'TI Allowance ($/SF)', 10, 2),
      Cur('TC_Security_Deposit__c', 'Security Deposit', 14, 2),
      Chk('TC_Sublease__c', 'Sublease'),
      Chk('TC_Renewal_Option__c', 'Renewal Option'),
      Dt('TC_Option_Notice_Date__c', 'Option Notice Date'),
      RS('TC_Total_Rent__c', 'Total Rent', 'sum', 'TC_Lease_Period__c', 'TC_Lease__c', 'TC_Total_Rent__c', A),
      FX('TC_Term_Months__c', 'Term (Months)', 'Number', '(YEAR(TC_Expiration_Date__c) - YEAR(TC_Commencement_Date__c)) * 12 + MONTH(TC_Expiration_Date__c) - MONTH(TC_Commencement_Date__c) + IF(DAY(TC_Expiration_Date__c) >= DAY(TC_Commencement_Date__c) - 1, 1, 0)'),
      FX('TC_Annual_Rent__c', 'Annual Base Rent', 'Currency', 'TC_Size__c * TC_Lease_Rate__c'),
      FX('TC_Monthly_Rent__c', 'Monthly Base Rent', 'Currency', 'TC_Size__c * TC_Lease_Rate__c / 12'),
      FX('TC_Days_to_Expiration__c', 'Days to Expiration', 'Number', 'TC_Expiration_Date__c - TODAY()'),
      FX('TC_Expiration_Bucket__c', 'Expiration Bucket', 'Text', 'IF(TC_Expiration_Date__c < TODAY(), "Expired", IF(TC_Expiration_Date__c <= ADDMONTHS(TODAY(), 6), "0-6 Months", IF(TC_Expiration_Date__c <= ADDMONTHS(TODAY(), 12), "6-12 Months", IF(TC_Expiration_Date__c <= ADDMONTHS(TODAY(), 24), "12-24 Months", "24+ Months"))))'),
      FX('TC_Expiration_Year__c', 'Expiration Year', 'Text', 'TEXT(YEAR(TC_Expiration_Date__c))'),
    ],
    vrs: [
      { name: 'TC_Expiration_After_Commencement', formula: 'TC_Expiration_Date__c <= TC_Commencement_Date__c', msg: 'Expiration Date must be after Commencement Date.', field: 'TC_Expiration_Date__c' },
      { name: 'TC_Unit_Same_Property', formula: 'AND(NOT(ISBLANK(TC_Unit__c)), TC_Unit__r.TC_Property__c <> TC_Property__c)', msg: 'The selected Unit belongs to a different Property.', field: 'TC_Unit__c' },
      { name: 'TC_Option_Notice_Before_Expiration', formula: 'AND(NOT(ISBLANK(TC_Option_Notice_Date__c)), TC_Option_Notice_Date__c >= TC_Expiration_Date__c)', msg: 'Option Notice Date must be before the Expiration Date.', field: 'TC_Option_Notice_Date__c' },
      { name: 'TC_Size_Positive', formula: 'TC_Size__c <= 0', msg: 'Size must be greater than zero.', field: 'TC_Size__c' },
    ],
    listColumns: ['TC_Tenant__c', 'TC_Property__c', 'TC_Size__c', 'TC_Lease_Rate__c', 'TC_Expiration_Date__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Lease_Period__c', label: 'Lease Period', plural: 'Lease Periods', motif: 'Custom25: Alarm clock', src: 'A', noTab: true,
    desc: 'One row of the rent table on a Lease. Copied from the Deal when the deal closes, or generated from the lease terms.',
    nameField: { label: 'Lease Period', type: 'AutoNumber', format: 'LP-{00000}' },
    fields: RENT_TABLE_FIELDS('TC_Lease__c', 'Lease'),
    vrs: RENT_TABLE_VRS,
    listColumns: ['TC_Lease__c', 'TC_From__c', 'TC_To__c', 'TC_Rate__c', 'TC_Total_Rent__c'],
  },
  {
    api: 'TC_Sale__c', label: 'Sale', plural: 'Sales', motif: 'Custom40: Credit card', src: 'A',
    desc: "A property's sale history (sale comps). Created when a Buyer or Seller Representation deal closes as Won, or entered as a comp.",
    nameField: { label: 'Sale Name', type: 'Text' },
    fields: [
      LK('TC_Property__c', 'Property', 'TC_Property__c', { ...A, required: true }),
      LK('TC_Deal__c', 'Deal', 'TC_Deal__c'),
      Dt('TC_Sale_Date__c', 'Sale Date', { ...A, required: true }),
      Cur('TC_Listing_Price__c', 'Listing Price', 16, 2, A),
      Cur('TC_Sale_Price__c', 'Sale Price', 16, 2, { ...A, required: true }),
      LK('TC_Buyer__c', 'Buyer', 'Account', A), LK('TC_Buyer_Contact__c', 'Buyer Contact', 'Contact', A),
      LK('TC_Seller__c', 'Seller', 'Account', A), LK('TC_Seller_Contact__c', 'Seller Contact', 'Contact', A),
      PL('TC_Sale_Type__c', 'Sale Type', ['Investment', 'Owner-User', 'Portfolio', 'Land', 'Sale-Leaseback', 'Distressed']),
      Num('TC_Size__c', 'Size (SF)', 12, 0),
      Pct('TC_Cap_Rate__c', 'Cap Rate', 5, 2),
      Cur('TC_NOI__c', 'Net Operating Income', 14, 2),
      Chk('TC_Comp_Only__c', 'Comp Only', { help: 'Checked when the sale was not brokered by us.' }),
      FX('TC_Price_per_SF__c', 'Price per SF', 'Currency', 'IF(TC_Size__c > 0, TC_Sale_Price__c / TC_Size__c, null)'),
    ],
    vrs: [{ name: 'TC_Sale_Price_Positive', formula: 'TC_Sale_Price__c <= 0', msg: 'Sale Price must be greater than zero.', field: 'TC_Sale_Price__c' }],
    listColumns: ['TC_Property__c', 'TC_Sale_Date__c', 'TC_Sale_Price__c', 'TC_Buyer__c', 'TC_Seller__c'],
  },
  {
    api: 'TC_Inquiry__c', label: 'Inquiry', plural: 'Inquiries', motif: 'Custom15: People', src: 'A',
    desc: 'An unqualified lead about leasing or buying space, arriving by phone, email, portal or web form. Converts to Account, Contact and Deal.',
    nameField: { label: 'Inquiry Number', type: 'AutoNumber', format: 'INQ-{00000}' },
    fields: [
      PL('TC_Inquiry_Type__c', 'Inquiry Type', ['Lease', 'Sale'], { ...A, required: true, defaultValue: 'Lease' }),
      PL('TC_Status__c', 'Status', ['New', 'Active', 'Converted', 'Disqualified'], { required: true, defaultValue: 'New' }),
      PL('TC_Disqualified_Reason__c', 'Disqualified Reason', ['No Budget', 'No Longer Looking', 'Not Reachable', 'Duplicate', 'Spam', 'Other']),
      Text('TC_First_Name__c', 'First Name', 40, A), Text('TC_Last_Name__c', 'Last Name', 80, A),
      Email('TC_Email__c', 'Email', A), Phone('TC_Phone__c', 'Phone', A), Text('TC_Company_Name__c', 'Company Name', 255, A),
      LK('TC_Contact__c', 'Contact', 'Contact', A),
      LK('TC_Company__c', 'Company', 'Account', A),
      LK('TC_Broker_Company__c', 'Broker Company', 'Account', A),
      LK('TC_Broker_Contact__c', 'Broker Contact', 'Contact', A),
      LK('TC_Listing__c', 'Listing', 'TC_Listing__c', A),
      LK('TC_Property__c', 'Property', 'TC_Property__c'),
      PL('TC_Source__c', 'Source', ['Phone', 'Email', 'Website', 'Listing Portal', 'Sign Call', 'Referral', 'Outside Broker', 'Event'], A),
      GPL('TC_Property_Type__c', 'Property Type Requirement', 'TC_Property_Type', A),
      Num('TC_Size_Min__c', 'Size Min (SF)', 10, 0, A), Num('TC_Size_Max__c', 'Size Max (SF)', 10, 0, A),
      Cur('TC_Price_Min__c', 'Price Min', 16, 2, A), Cur('TC_Price_Max__c', 'Price Max', 16, 2, A),
      Cur('TC_Max_Rate__c', 'Max Rate ($/SF/yr)', 10, 2),
      Dt('TC_Date_Needed__c', 'Move-in / Purchase Date', A),
      Text('TC_Preferred_Market__c', 'Preferred Market', 80), Text('TC_Preferred_City__c', 'Preferred City', 80),
      LK('TC_Converted_Deal__c', 'Converted Deal', 'TC_Deal__c', { ...A, ...AUTO }),
      Dt('TC_Converted_Date__c', 'Converted Date', AUTO),
      LText('TC_Notes__c', 'Notes'),
      FX('TC_Days_Open__c', 'Days Open', 'Number', 'IF(OR(ISPICKVAL(TC_Status__c, "New"), ISPICKVAL(TC_Status__c, "Active")), TODAY() - DATEVALUE(CreatedDate), null)'),
    ],
    vrs: [
      { name: 'TC_Size_Max_Above_Min', formula: 'AND(NOT(ISBLANK(TC_Size_Min__c)), NOT(ISBLANK(TC_Size_Max__c)), TC_Size_Max__c < TC_Size_Min__c)', msg: 'Size Max must be greater than or equal to Size Min.', field: 'TC_Size_Max__c' },
      { name: 'TC_Price_Max_Above_Min', formula: 'AND(NOT(ISBLANK(TC_Price_Min__c)), NOT(ISBLANK(TC_Price_Max__c)), TC_Price_Max__c < TC_Price_Min__c)', msg: 'Price Max must be greater than or equal to Price Min.', field: 'TC_Price_Max__c' },
      { name: 'TC_Disqualified_Reason_Required', formula: 'AND(ISPICKVAL(TC_Status__c, "Disqualified"), ISBLANK(TEXT(TC_Disqualified_Reason__c)))', msg: 'Choose a Disqualified Reason.', field: 'TC_Disqualified_Reason__c' },
      { name: 'TC_Contact_Info_Required', formula: 'AND(ISBLANK(TC_Contact__c), ISBLANK(TC_Last_Name__c))', msg: 'Enter the inquirer\'s Last Name or pick an existing Contact.', field: 'TC_Last_Name__c' },
    ],
    listColumns: ['TC_Inquiry_Type__c', 'TC_Last_Name__c', 'TC_Company_Name__c', 'TC_Listing__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Prospective_Listing__c', label: 'Prospective Listing', plural: 'Prospective Listings', motif: 'Custom55: Books', src: 'A', noTab: true,
    desc: 'Links an Inquiry to the Listings proposed to it. One may be marked Primary; shown on the Listing as Prospective Inquiries.',
    nameField: { label: 'Prospective Listing', type: 'AutoNumber', format: 'PL-{00000}' },
    fields: [
      MD('TC_Inquiry__c', 'Inquiry', 'TC_Inquiry__c', A),
      LK('TC_Listing__c', 'Listing', 'TC_Listing__c', { ...A, required: true, relLabel: 'Prospective Inquiries' }),
      PL('TC_Status__c', 'Status', ['New', 'Sent to Client', 'Touring', 'Interested', 'Not Interested'], { ...A, required: true, defaultValue: 'New' }),
      Chk('TC_Primary__c', 'Primary', A),
      Text('TC_Description__c', 'Description', 255, A),
      Num('TC_Match_Score__c', 'Match Score', 3, 0, { ...AUTO, help: 'TC extra: set by Find Matches.' }),
    ],
    listColumns: ['TC_Inquiry__c', 'TC_Listing__c', 'TC_Status__c', 'TC_Primary__c'],
  },
  {
    api: 'TC_Prospective_Buyer__c', label: 'Prospective Buyer', plural: 'Prospective Buyers', motif: 'Custom15: People', src: 'A', noTab: true,
    desc: 'A potential buyer on a Seller Representation deal. The primary buyer fills the Deal Buyer fields.',
    nameField: { label: 'Prospective Buyer', type: 'AutoNumber', format: 'PB-{00000}' },
    fields: [
      MD('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      LK('TC_Account__c', 'Account', 'Account', A),
      LK('TC_Contact__c', 'Contact', 'Contact', { ...A, required: true }),
      Chk('TC_Primary__c', 'Primary', A),
      PL('TC_Status__c', 'Status', ['Prospect', 'Interested', 'Toured', 'Offer Submitted', 'Declined'], { defaultValue: 'Prospect' }),
      LText('TC_Notes__c', 'Notes'),
    ],
    listColumns: ['TC_Deal__c', 'TC_Contact__c', 'TC_Account__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Offer__c', label: 'Offer', plural: 'Offers', motif: 'Custom83: Pencil', src: 'A', noTab: true,
    desc: 'An offer received on a Landlord or Seller Representation deal. AscendixRE documents offer tracking but not its fields.',
    nameField: { label: 'Offer', type: 'AutoNumber', format: 'OF-{00000}' },
    fields: [
      MD('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      LK('TC_Prospective_Buyer__c', 'Prospective Buyer', 'TC_Prospective_Buyer__c'),
      LK('TC_Account__c', 'Offering Party', 'Account'),
      Dt('TC_Offer_Date__c', 'Offer Date', { required: true }),
      Cur('TC_Offer_Amount__c', 'Offer Amount', 16, 2),
      Cur('TC_Offer_Rate__c', 'Offered Rate ($/SF/yr)', 10, 2),
      PL('TC_Status__c', 'Status', ['Submitted', 'Countered', 'Accepted', 'Rejected', 'Withdrawn'], { required: true, defaultValue: 'Submitted' }),
      LText('TC_Terms__c', 'Key Terms'),
    ],
    listColumns: ['TC_Deal__c', 'TC_Account__c', 'TC_Offer_Date__c', 'TC_Offer_Amount__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Commission__c', label: 'Commission', plural: 'Commissions', motif: 'Custom16: Bank', src: 'A',
    desc: 'A share of a deal fee: inside broker, analyst, co-broker or expense.',
    nameField: { label: 'Commission Number', type: 'AutoNumber', format: 'COM-{00000}' },
    recordTypes: [{ api: 'TC_Inside_Broker', label: 'Inside Broker' }, { api: 'TC_Analyst', label: 'Analyst' }, { api: 'TC_Co_Broker', label: 'Co-Broker' }, { api: 'TC_Expense', label: 'Expense' }],
    fields: [
      MD('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      LK('TC_Broker__c', 'Broker (User)', 'User', A),
      LK('TC_Account__c', 'Account', 'Account', A),
      LK('TC_Contact__c', 'Contact', 'Contact', A),
      PL('TC_Fee_Method__c', 'Fee Method', ['Percent', 'Amount'], { ...A, defaultValue: 'Percent' }),
      Pct('TC_Fee_Percent__c', 'Fee Percent', 6, 3, A),
      Cur('TC_Fee_Amount__c', 'Fee Amount', 14, 2, { help: 'Used when Fee Method is Amount.' }),
      Pct('TC_House_Fee_Percent__c', 'Fee Percent (House)', 5, 2, A),
      Cur('TC_Gross_Commission__c', 'Gross Commission', 14, 2, { ...A, ...AUTO }),
      Cur('TC_House__c', 'House', 14, 2, { ...A, ...AUTO, sensitive: true }),
      Cur('TC_Direct_Expenses__c', 'Direct Expenses', 14, 2, A),
      FX('TC_Net_Commission__c', 'Net Commission', 'Currency', 'BLANKVALUE(TC_Gross_Commission__c, 0) - BLANKVALUE(TC_House__c, 0) - BLANKVALUE(TC_Direct_Expenses__c, 0)', { ...A, sensitive: true }),
      Text('TC_Description__c', 'Description', 255, A),
      PL('TC_Status__c', 'Status', ['Projected', 'Earned', 'Invoiced', 'Paid', 'Cancelled'], { required: true, defaultValue: 'Projected' }),
      Dt('TC_Due_Date__c', 'Due Date'), Dt('TC_Paid_Date__c', 'Paid Date'),
      Cur('TC_Amount_Paid__c', 'Amount Paid', 14, 2),
      FX('TC_Balance_Due__c', 'Balance Due', 'Currency', 'BLANKVALUE(TC_Gross_Commission__c, 0) - BLANKVALUE(TC_Amount_Paid__c, 0)'),
      FX('TC_Commission_Type__c', 'Commission Type', 'Text', 'RecordType.Name'),
    ],
    vrs: [
      { name: 'TC_Inside_Broker_Requires_User', formula: 'AND($RecordType.DeveloperName = "TC_Inside_Broker", ISBLANK(TC_Broker__c))', msg: 'Choose the Broker (User) for an Inside Broker commission.', field: 'TC_Broker__c' },
      { name: 'TC_Co_Broker_Requires_Party', formula: 'AND(OR($RecordType.DeveloperName = "TC_Co_Broker", $RecordType.DeveloperName = "TC_Analyst"), ISBLANK(TC_Account__c), ISBLANK(TC_Contact__c), ISBLANK(TC_Broker__c))', msg: 'Choose an Account or Contact for this commission.', field: 'TC_Contact__c' },
      { name: 'TC_Amount_Method_Requires_Amount', formula: 'AND(ISPICKVAL(TC_Fee_Method__c, "Amount"), ISBLANK(TC_Fee_Amount__c))', msg: 'Enter a Fee Amount when the Fee Method is Amount.', field: 'TC_Fee_Amount__c' },
      { name: 'TC_Percent_Method_Requires_Percent', formula: 'AND(ISPICKVAL(TC_Fee_Method__c, "Percent"), ISBLANK(TC_Fee_Percent__c))', msg: 'Enter a Fee Percent when the Fee Method is Percent.', field: 'TC_Fee_Percent__c' },
      { name: 'TC_Paid_Requires_Date', formula: 'AND(ISPICKVAL(TC_Status__c, "Paid"), ISBLANK(TC_Paid_Date__c))', msg: 'Enter the Paid Date when marking a commission as Paid.', field: 'TC_Paid_Date__c' },
    ],
    listColumns: ['TC_Deal__c', 'RecordType', 'TC_Broker__c', 'TC_Fee_Percent__c', 'TC_Gross_Commission__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Capital_Source__c', label: 'Capital Source', plural: 'Capital Sources', motif: 'Custom37: Bridge', src: 'A',
    desc: 'A lender or capital provider. Lending criteria fields are TC design.',
    nameField: { label: 'Capital Source Name', type: 'Text' },
    fields: [
      LK('TC_Account__c', 'Institution', 'Account'),
      LK('TC_Contact__c', 'Primary Contact', 'Contact'),
      PL('TC_Source_Type__c', 'Source Type', ['Bank', 'Life Company', 'CMBS Lender', 'Debt Fund', 'Agency', 'Credit Union', 'Private Equity', 'REIT', 'Family Office', 'Private Investor', 'Pension Fund']),
      MPL('TC_Capital_Types__c', 'Capital Types', ['Senior Debt', 'Construction Loan', 'Bridge Loan', 'Mezzanine', 'Preferred Equity', 'Joint Venture Equity', 'Acquisition Equity']),
      GMPL('TC_Property_Types__c', 'Property Types', 'TC_Property_Type'),
      Text('TC_Target_Markets__c', 'Target Markets', 255),
      Cur('TC_Min_Deal_Size__c', 'Min Deal Size', 16, 2), Cur('TC_Max_Deal_Size__c', 'Max Deal Size', 16, 2),
      Pct('TC_Max_LTV__c', 'Max LTV', 5, 2), Num('TC_Min_DSCR__c', 'Min DSCR', 4, 2),
      Pct('TC_Target_Rate__c', 'Target Rate', 5, 3), Num('TC_Typical_Term_Years__c', 'Typical Term (Years)', 3, 0),
      PL('TC_Status__c', 'Status', ['Active', 'Paused', 'Inactive'], { defaultValue: 'Active' }),
    ],
    vrs: [{ name: 'TC_Max_Deal_Size_Above_Min', formula: 'AND(NOT(ISBLANK(TC_Min_Deal_Size__c)), NOT(ISBLANK(TC_Max_Deal_Size__c)), TC_Max_Deal_Size__c < TC_Min_Deal_Size__c)', msg: 'Max Deal Size must be greater than or equal to Min Deal Size.', field: 'TC_Max_Deal_Size__c' }],
    listColumns: ['TC_Account__c', 'TC_Source_Type__c', 'TC_Min_Deal_Size__c', 'TC_Max_Deal_Size__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Deal_Source__c', label: 'Deal Source', plural: 'Deal Sources', motif: 'Custom68: Globe', src: 'A', noTab: true,
    desc: 'A capital source interested in lending on a Capital Markets deal.',
    nameField: { label: 'Deal Source', type: 'AutoNumber', format: 'DS-{00000}' },
    fields: [
      MD('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      LK('TC_Capital_Source__c', 'Capital Source', 'TC_Capital_Source__c', { ...A, required: true }),
      LK('TC_Contact__c', 'Lender Contact', 'Contact'),
      PL('TC_Status__c', 'Status', ['Contacted', 'Interested', 'Term Sheet Received', 'Declined', 'Selected'], { defaultValue: 'Contacted' }),
      Dt('TC_Date_Contacted__c', 'Date Contacted'),
      LText('TC_Notes__c', 'Notes'),
    ],
    listColumns: ['TC_Deal__c', 'TC_Capital_Source__c', 'TC_Status__c'],
  },
  {
    api: 'TC_Term_Sheet__c', label: 'Term Sheet', plural: 'Term Sheets', motif: 'Custom18: Form', src: 'A', noTab: true,
    desc: 'A lender quote under a Deal Source; compared side by side on the deal.',
    nameField: { label: 'Term Sheet Name', type: 'Text' },
    fields: [
      MD('TC_Deal_Source__c', 'Deal Source', 'TC_Deal_Source__c'),
      LK('TC_Capital_Source__c', 'Capital Source', 'TC_Capital_Source__c', { ...A, ...AUTO }),
      LK('TC_Deal__c', 'Deal', 'TC_Deal__c', AUTO),
      Dt('TC_Quote_Date__c', 'Quote Date', A),
      Text('TC_Lender_Name__c', 'Lender Name', 255, { ...A, ...AUTO }),
      Cur('TC_Loan_Amount__c', 'Loan Amount', 16, 2), Pct('TC_Interest_Rate__c', 'Interest Rate', 5, 3),
      PL('TC_Rate_Type__c', 'Rate Type', ['Fixed', 'Floating']),
      Num('TC_Term_Years__c', 'Term (Years)', 3, 0), Num('TC_Amortization_Years__c', 'Amortization (Years)', 3, 0),
      Pct('TC_LTV__c', 'LTV', 5, 2), Num('TC_DSCR__c', 'DSCR', 4, 2),
      PL('TC_Recourse__c', 'Recourse', ['Full Recourse', 'Partial Recourse', 'Non-Recourse']),
      Pct('TC_Origination_Fee__c', 'Origination Fee', 5, 3),
      Text('TC_Prepayment__c', 'Prepayment Terms', 255),
    ],
    listColumns: ['TC_Deal_Source__c', 'TC_Lender_Name__c', 'TC_Loan_Amount__c', 'TC_Interest_Rate__c'],
  },
  {
    api: 'TC_Deal_Property__c', label: 'Deal Property', plural: 'Deal Properties', motif: 'Custom24: Building', src: 'A', noTab: true,
    desc: 'Links several properties to one Capital Markets deal (Multiple Properties).',
    nameField: { label: 'Deal Property', type: 'AutoNumber', format: 'DPR-{00000}' },
    fields: [
      MD('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      LK('TC_Property__c', 'Property', 'TC_Property__c', { ...A, required: true }),
      Cur('TC_Allocated_Value__c', 'Allocated Value', 16, 2),
      Chk('TC_Primary__c', 'Primary'),
    ],
    listColumns: ['TC_Deal__c', 'TC_Property__c', 'TC_Allocated_Value__c'],
  },
  {
    api: 'TC_Relationship__c', label: 'Relationship', plural: 'Relationships', motif: 'Custom47: Chess piece', src: 'A', noTab: true,
    desc: 'Links a record to an internal user in a named role (relationship grid). Extend by adding lookups.',
    nameField: { label: 'Relationship', type: 'AutoNumber', format: 'REL-{00000}' },
    fields: [
      LK('TC_User__c', 'User', 'User', A),
      PL('TC_Relationship_Type__c', 'Relationship Type', ['Account Manager', 'Listing Agent', 'Analyst', 'Marketing', 'Transaction Coordinator', 'Property Manager'], { ...A, required: true }),
      LK('TC_Account__c', 'Account', 'Account', A), LK('TC_Contact__c', 'Contact', 'Contact', A),
      LK('TC_Property__c', 'Property', 'TC_Property__c', A), LK('TC_Listing__c', 'Listing', 'TC_Listing__c', A),
      LK('TC_Deal__c', 'Deal', 'TC_Deal__c', A),
      Dt('TC_Start_Date__c', 'Start Date'),
    ],
    vrs: [{ name: 'TC_User_Required', formula: 'ISBLANK(TC_User__c)', msg: 'Choose the internal User for this relationship.', field: 'TC_User__c' }],
    listColumns: ['TC_User__c', 'TC_Relationship_Type__c', 'TC_Account__c', 'TC_Property__c'],
  },
  {
    api: 'TC_Market_Rent__c', label: 'Market Rent', plural: 'Market Rents', motif: 'Custom64: Compass', src: 'A',
    desc: 'Market rent benchmark by market, property type and class. Named by AscendixRE; fields are TC design.',
    nameField: { label: 'Market Rent Name', type: 'Text' },
    fields: [
      Text('TC_Market__c', 'Market', 80, { required: true }), Text('TC_Submarket__c', 'Sub Market', 80),
      GPL('TC_Property_Type__c', 'Property Type', 'TC_Property_Type', { required: true }),
      GPL('TC_Building_Class__c', 'Class', 'TC_Building_Class'),
      GPL('TC_Rent_Type__c', 'Rent Type', 'TC_Rent_Type'),
      Dt('TC_Effective_Date__c', 'Effective Date', { required: true }),
      Cur('TC_Low_Rate__c', 'Low Rate ($/SF/yr)', 10, 2), Cur('TC_High_Rate__c', 'High Rate ($/SF/yr)', 10, 2),
      Cur('TC_Average_Rate__c', 'Average Rate ($/SF/yr)', 10, 2),
      Pct('TC_Vacancy_Rate__c', 'Market Vacancy', 5, 2),
      LK('TC_Property__c', 'Property', 'TC_Property__c'),
      Text('TC_Source__c', 'Data Source', 120),
    ],
    vrs: [{ name: 'TC_High_Rate_Above_Low', formula: 'AND(NOT(ISBLANK(TC_Low_Rate__c)), NOT(ISBLANK(TC_High_Rate__c)), TC_High_Rate__c < TC_Low_Rate__c)', msg: 'High Rate must be greater than or equal to Low Rate.', field: 'TC_High_Rate__c' }],
    listColumns: ['TC_Market__c', 'TC_Property_Type__c', 'TC_Building_Class__c', 'TC_Average_Rate__c', 'TC_Effective_Date__c'],
  },
];

// ---------- fields added to standard objects ----------
const standardFields = {
  Account: [
    MPL('TC_CRE_Roles__c', 'CRE Roles', ['Tenant', 'Owner/Landlord', 'Buyer', 'Seller', 'Investor', 'Lender', 'Brokerage Firm', 'Property Manager', 'Developer', 'Service Provider']),
    Num('TC_Portfolio_SF__c', 'Portfolio Size (SF)', 14, 0, AUTO),
  ],
  Contact: [
    PL('TC_Relationship_Type__c', 'Relationship Type', ['Client', 'Prospect', 'Partner', 'Vendor', 'Broker', 'Investor'], A),
    PL('TC_Contact_Category__c', 'Contact Category', ['Prospect', 'Client', 'Broker', 'Vendor', 'Other'], A),
    Chk('TC_Automated_Follow_up_Tasks__c', 'Automated Follow-up Tasks', A),
    PL('TC_Follow_up_Sequence__c', 'Follow-up Sequence', ['30-60-90 Days', 'Monthly', 'Quarterly'], A),
    Num('TC_Follow_up_Step__c', 'Follow-up Step', 3, 0, AUTO),
    Dt('TC_Next_Follow_up_Date__c', 'Next Follow-up Date', AUTO),
  ],
};

// ---------- settings ----------
const customSettings = [{
  api: 'TC_Bypass_Settings__c', label: 'TC Bypass Settings', src: 'A',
  desc: 'Switch off TC automation for data loads (mirrors AscendixRE BypassValidationRules__c).',
  fields: [Chk('TC_Bypass_Triggers__c', 'Bypass Triggers'), Chk('TC_Bypass_Validation_Rules__c', 'Bypass Validation Rules'), Chk('TC_Bypass_Flows__c', 'Bypass Flows')],
}];

const mdtTypes = [
  {
    api: 'TC_Automation_Setting__mdt', label: 'TC Automation Setting', plural: 'TC Automation Settings', src: 'A',
    desc: 'Turns individual TC automations and validations on or off (mirrors AscendixRE AutomationSetting__mdt).',
    fields: [Chk('TC_Active__c', 'Active'), Text('TC_Record_Types__c', 'Record Types', 255, { help: 'Comma-separated DeveloperNames; blank = all.' }), Text('TC_Description__c', 'Description', 255)],
    records: [
      ['TC_AUTO_Client_Field_Population', 'Populate client, tenant, landlord and buyer fields on new deals', true, ''],
      ['TC_AUTO_Close_Deal_Create_Records', 'Create Lease, Sale or Listing when a deal closes Won', true, ''],
      ['TC_AUTO_Lease_Rent_Table_From_Deal', 'Copy the deal rent table to the lease created on close', true, ''],
      ['TC_AUTO_Generate_Rent_Table', 'Generate rent table periods from lease terms when none exist', true, ''],
      ['TC_AUTO_Record_Naming', 'Build record names from TC Object Name Mapping', true, ''],
      ['TC_VAL_Commission_Split_100', 'Co-broker, analyst and expense splits may not exceed 100%', true, ''],
      ['TC_VAL_Inside_Broker_100', 'Inside broker fee percents must total 100% on Won deals (disabled by default)', false, ''],
      ['TC_VAL_Unit_Lease_Overlap', 'Prevent overlapping active leases on the same unit', true, ''],
    ].map(([name, desc, active, rts]) => ({ name, label: name.replace(/^TC_/, '').replace(/_/g, ' '), values: { TC_Active__c: active, TC_Description__c: desc, TC_Record_Types__c: rts } })),
  },
  {
    api: 'TC_Object_Name_Mapping__mdt', label: 'TC Object Name Mapping', plural: 'TC Object Name Mappings', src: 'A',
    desc: 'Format of auto-populated record names (mirrors AscendixRE Object Name Mapping).',
    fields: [Text('TC_Object__c', 'Object', 80), Text('TC_Source_Fields__c', 'Source Fields', 255), Text('TC_Format__c', 'Format', 255), Chk('TC_Overwrite__c', 'Overwrite'), Text('TC_Default_Value__c', 'Default Value', 80), Chk('TC_Active__c', 'Active')],
    records: [
      ['TC_Availability', 'TC_Availability__c', 'TC_Property__r.Name,TC_Unit_Name__c,TC_Size__c', '{0} - {1} ({2} SF)'],
      ['TC_Lease', 'TC_Lease__c', 'TC_Tenant__r.Name,TC_Property__r.Name,TC_Unit_Name__c', '{0} - {1} {2}'],
      ['TC_Sale', 'TC_Sale__c', 'TC_Property__r.Name,TC_Sale_Date__c', '{0} - Sale {1}'],
      ['TC_Listing', 'TC_Listing__c', 'TC_Property__r.Name,RecordType.Name', '{0} - {1} Listing'],
    ].map(([name, obj, src, fmt]) => ({ name, label: name.replace(/^TC_/, '') + ' Name', values: { TC_Object__c: obj, TC_Source_Fields__c: src, TC_Format__c: fmt, TC_Overwrite__c: false, TC_Default_Value__c: '', TC_Active__c: true } })),
  },
  {
    api: 'TC_Object_Field_Mapping__mdt', label: 'TC Object Field Mapping', plural: 'TC Object Field Mappings', src: 'A',
    desc: 'Source-to-target field mapping used when a deal closes and when listings are created (mirrors AscendixRE Object Field Mapping).',
    fields: [Text('TC_Mapping_Group__c', 'Mapping Group', 80), Text('TC_Source_Object__c', 'Source Object', 80), Text('TC_Target_Object__c', 'Target Object', 80), Text('TC_Record_Types__c', 'Source Record Types', 255), Text('TC_Source_Field__c', 'Source Field', 80), Text('TC_Target_Field__c', 'Target Field', 80), Text('TC_Static_Value__c', 'Static Value', 255), Chk('TC_Active__c', 'Active')],
    records: (() => {
      const rows = [];
      const add = (group, srcObj, tgtObj, rts, pairs) => pairs.forEach(([s, t, stat], i) => rows.push({ name: `${group}_${String(i + 1).padStart(2, '0')}`, label: `${group.replace(/_/g, ' ')} ${i + 1}`, values: { TC_Mapping_Group__c: group, TC_Source_Object__c: srcObj, TC_Target_Object__c: tgtObj, TC_Record_Types__c: rts, TC_Source_Field__c: s || '', TC_Target_Field__c: t, TC_Static_Value__c: stat || '', TC_Active__c: true } }));
      add('DEAL_TO_LEASE', 'TC_Deal__c', 'TC_Lease__c', 'TC_Tenant_Representation,TC_Landlord_Representation', [
        ['TC_Property__c', 'TC_Property__c'], ['TC_Tenant__c', 'TC_Tenant__c'], ['TC_Tenant_Contact__c', 'TC_Tenant_Contact__c'], ['TC_Owner_Landlord__c', 'TC_Owner_Landlord__c'],
        ['Id', 'TC_Deal__c'], ['TC_Size__c', 'TC_Size__c'], ['TC_Lease_Rate__c', 'TC_Lease_Rate__c'], ['TC_Rent_Type__c', 'TC_Rent_Type__c'],
        ['TC_Lease_Commencement__c', 'TC_Commencement_Date__c'], ['TC_Lease_Expiration__c', 'TC_Expiration_Date__c'], ['TC_Period_Length_Months__c', 'TC_Period_Length_Months__c'],
        ['TC_Total_Rent_Calculation__c', 'TC_Total_Rent_Calculation__c'], ['TC_Escalation__c', 'TC_Escalation__c'], ['TC_Free_Rent_Months__c', 'TC_Free_Rent_Months__c'],
        [null, 'TC_Status__c', 'Active'], [null, 'TC_Lease_Type__c', 'NNN']]);
      add('DEAL_TO_SALE', 'TC_Deal__c', 'TC_Sale__c', 'TC_Seller_Representation,TC_Buyer_Representation', [
        ['TC_Property__c', 'TC_Property__c'], ['Id', 'TC_Deal__c'], ['TC_Actual_Close_Date__c', 'TC_Sale_Date__c'], ['TC_Listing_Price__c', 'TC_Listing_Price__c'],
        ['TC_Sale_Price__c', 'TC_Sale_Price__c'], ['TC_Buyer__c', 'TC_Buyer__c'], ['TC_Buyer_Contact__c', 'TC_Buyer_Contact__c'], ['TC_Size__c', 'TC_Size__c']]);
      add('DEAL_TO_LISTING', 'TC_Deal__c', 'TC_Listing__c', 'TC_Listing_Pursuit', [
        ['TC_Property__c', 'TC_Property__c'], ['Id', 'TC_Deal__c'], ['TC_Client__c', 'TC_Owner_Landlord__c'], ['TC_Client_Contact__c', 'TC_Owner_Landlord_Contact__c'],
        ['TC_Actual_Close_Date__c', 'TC_Listing_Date__c'], ['TC_Listing_Price__c', 'TC_Asking_Price__c'], ['TC_Lease_Rate__c', 'TC_Asking_Rate__c'], [null, 'TC_Status__c', 'Draft']]);
      add('DEAL_TO_AVAILABILITY', 'TC_Deal__c', 'TC_Availability__c', '', [[null, 'TC_Status__c', 'Closed']]);
      add('PROPERTY_TO_LISTING', 'TC_Property__c', 'TC_Listing__c', '', [
        ['TC_Listing_Broker_Company__c', 'TC_Listing_Broker_Company__c'], ['TC_Listing_Broker_Contact__c', 'TC_Listing_Broker_Contact__c'], ['TC_Owner_Landlord__c', 'TC_Owner_Landlord__c'],
        ['TC_Owner_Landlord_Contact__c', 'TC_Owner_Landlord_Contact__c'], ['TC_Market__c', 'TC_Market__c'], ['TC_Region__c', 'TC_Region__c'], ['TC_Submarket__c', 'TC_Submarket__c'],
        ['TC_Property_Type__c', 'TC_Property_Type__c'], ['TC_Property_Subtype__c', 'TC_Property_Subtype__c'], ['TC_Description__c', 'TC_Description__c'],
        ['TC_Location_Description__c', 'TC_Location_Description__c'], ['TC_Website__c', 'TC_Website__c'], ['TC_Primary_Image_URL__c', 'TC_Primary_Image_URL__c']]);
      return rows;
    })(),
  },
  {
    api: 'TC_Stacking_Plan_Setting__mdt', label: 'TC Stacking Plan Setting', plural: 'TC Stacking Plan Settings', src: 'A',
    desc: 'Which property record types show the stacking plan, and its colours (mirrors the AscendixRE Stacking Plan metadata record).',
    fields: [Text('TC_Record_Types__c', 'Property Record Types', 255), Text('TC_Vacancy_Color__c', 'Vacancy Colour', 20), Chk('TC_Active__c', 'Active')],
    records: [{ name: 'TC_Default', label: 'Default', values: { TC_Record_Types__c: 'TC_Office,TC_Retail,TC_Mixed_Use,TC_Multifamily', TC_Vacancy_Color__c: '#F4D03F', TC_Active__c: true } }],
  },
  {
    api: 'TC_Deal_Stage_Setting__mdt', label: 'TC Deal Stage Setting', plural: 'TC Deal Stage Settings', src: 'T',
    desc: 'Default probability for each deal stage.',
    fields: [Text('TC_Stage__c', 'Stage', 80), Num('TC_Probability__c', 'Probability', 3, 0), Num('TC_Sort_Order__c', 'Sort Order', 3, 0)],
    records: [['Prospect', 10], ['Pitch / Proposal', 20], ['Touring', 30], ['LOI', 50], ['Negotiation', 70], ['Lease / PSA Out', 90], ['Executed', 100]]
      .map(([s, p], i) => ({ name: 'TC_' + s.replace(/[^A-Za-z]+/g, '_').replace(/_+$/, ''), label: s, values: { TC_Stage__c: s, TC_Probability__c: p, TC_Sort_Order__c: i + 1 } })),
  },
];

module.exports = { objects, standardFields, customSettings, mdtTypes, globalValueSets, subtypeMap };
