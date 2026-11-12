#!/usr/bin/env node
/*
 * Generates TC custom report types, the TC Reports folder, standard reports and the
 * TC Brokerage Dashboard.  Usage: node scripts/reports-meta.js
 */
const fs = require('fs');
const path = require('path');
const M = require('./model/tc-model');
const SRC = path.join(__dirname, '..', 'force-app', 'main', 'default');
const NS = 'http://soap.sforce.com/2006/04/metadata';
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const out = (rel, xml) => { const p = path.join(SRC, rel); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, xml); };
const obj = api => M.objects.find(o => o.api === api);

// ---------- report types (one per core object; all TC fields available) ----------
const reportTypes = [
  { name: 'TC_Properties', base: 'TC_Property__c', label: 'TC Properties', desc: 'TC properties with size, occupancy and availability.' },
  { name: 'TC_Listings', base: 'TC_Listing__c', label: 'TC Listings', desc: 'TC listing agreements.' },
  { name: 'TC_Availabilities', base: 'TC_Availability__c', label: 'TC Availabilities', desc: 'Space on the market.' },
  { name: 'TC_Leases', base: 'TC_Lease__c', label: 'TC Leases', desc: 'Lease abstracts and expirations.' },
  { name: 'TC_Sales', base: 'TC_Sale__c', label: 'TC Sales', desc: 'Property sales and sale comps.' },
  { name: 'TC_Deals', base: 'TC_Deal__c', label: 'TC Deals', desc: 'Brokerage deals and fees.' },
  { name: 'TC_Inquiries', base: 'TC_Inquiry__c', label: 'TC Inquiries', desc: 'Inbound inquiries and requirements.' },
  { name: 'TC_Commissions', base: 'TC_Commission__c', label: 'TC Commissions', desc: 'Commission splits on deals.' },
];
const standardCols = ['Name', 'Id', 'CreatedDate', 'LastModifiedDate'];
for (const rt of reportTypes) {
  const o = obj(rt.base);
  const hasOwner = !o.fields.some(f => f.type === 'MasterDetail');
  const cols = [...standardCols, ...(hasOwner ? ['Owner'] : []), ...((o.recordTypes || []).length ? ['RecordType'] : []), ...o.fields.filter(f => f.type !== 'Location').map(f => f.api)];
  out(`reportTypes/${rt.name}.reportType-meta.xml`, `<?xml version="1.0" encoding="UTF-8"?>
<ReportType xmlns="${NS}">
    <baseObject>${rt.base}</baseObject>
    <category>other</category>
    <deployed>true</deployed>
    <description>${esc(rt.desc)}</description>
    <label>${esc(rt.label)}</label>
    <sections>
${cols.map(c => `        <columns>\n            <checkedByDefault>false</checkedByDefault>\n            <field>${c}</field>\n            <table>${rt.base}</table>\n        </columns>\n`).join('')}        <masterLabel>${esc(o.plural)}</masterLabel>
    </sections>
</ReportType>
`);
}

// ---------- folder ----------
out('reports/TC_Reports.reportFolder-meta.xml', `<?xml version="1.0" encoding="UTF-8"?>
<ReportFolder xmlns="${NS}">
    <folderShares>
        <accessLevel>View</accessLevel>
        <sharedTo>AllInternalUsers</sharedTo>
        <sharedToType>Organization</sharedToType>
    </folderShares>
    <name>TC Reports</name>
</ReportFolder>
`);
out('dashboards/TC_Dashboards.dashboardFolder-meta.xml', `<?xml version="1.0" encoding="UTF-8"?>
<DashboardFolder xmlns="${NS}">
    <folderShares>
        <accessLevel>View</accessLevel>
        <sharedTo>AllInternalUsers</sharedTo>
        <sharedToType>Organization</sharedToType>
    </folderShares>
    <name>TC Dashboards</name>
</DashboardFolder>
`);

// ---------- reports ----------
function report({ name, label, type, base, desc, columns, groupBy, sums = [], filters = [], sortCol }) {
  const f = c => base + '$' + c; // custom report type columns use Object$Field
  const colXml = columns.filter(c => c !== groupBy).map(c => sums.includes(c)
    ? `    <columns>\n        <aggregateTypes>Sum</aggregateTypes>\n        <field>${f(c)}</field>\n    </columns>\n`
    : `    <columns>\n        <field>${f(c)}</field>\n    </columns>\n`).join('');
  const filterXml = filters.length ? `    <filter>\n${filters.map(([c, op, v]) => `        <criteriaItems>\n            <column>${f(c)}</column>\n            <columnToColumn>false</columnToColumn>\n            <isUnlocked>true</isUnlocked>\n            <operator>${op}</operator>\n            <value>${esc(v)}</value>\n        </criteriaItems>\n`).join('')}        <language>en_US</language>\n    </filter>\n` : '';
  const grp = groupBy ? `    <groupingsDown>\n        <dateGranularity>Day</dateGranularity>\n        <field>${f(groupBy)}</field>\n        <sortOrder>Asc</sortOrder>\n    </groupingsDown>\n` : '';
  out(`reports/TC_Reports/${name}.report-meta.xml`, `<?xml version="1.0" encoding="UTF-8"?>
<Report xmlns="${NS}">
${colXml}    <description>${esc(desc)}</description>
${filterXml}    <format>${groupBy ? 'Summary' : 'Tabular'}</format>
${grp}    <name>${esc(label)}</name>
    <params>
        <name>co</name>
        <value>1</value>
    </params>
    <reportType>${type}__c</reportType>
    <scope>organization</scope>
    <showDetails>${groupBy ? 'false' : 'true'}</showDetails>
    <showGrandTotal>true</showGrandTotal>
    <showSubTotals>true</showSubTotals>
${sortCol ? `    <sortColumn>${f(sortCol)}</sortColumn>\n    <sortOrder>Asc</sortOrder>\n` : ''}    <timeFrameFilter>
        <dateColumn>${f('CreatedDate')}</dateColumn>
        <interval>INTERVAL_CUSTOM</interval>
    </timeFrameFilter>
</Report>
`);
  return `TC_Reports/${name}`;
}

const R = {};
R.pipeline = report({ name: 'TC_Pipeline_by_Stage', label: 'TC Pipeline by Stage', type: 'TC_Deals', base: 'TC_Deal__c', desc: 'Open deals grouped by stage with gross and weighted fees.',
  columns: ['Name', 'TC_Deal_Type__c', 'TC_Client__c', 'TC_Gross_Fee_Amount__c', 'TC_Weighted_Fee__c', 'TC_Est_Close_Date__c', 'TC_Stage__c'], groupBy: 'TC_Stage__c', sums: ['TC_Gross_Fee_Amount__c', 'TC_Weighted_Fee__c'], filters: [['TC_Status__c', 'equals', 'Open']] });
R.byType = report({ name: 'TC_Pipeline_by_Deal_Type', label: 'TC Pipeline by Deal Type', type: 'TC_Deals', base: 'TC_Deal__c', desc: 'Open deal fees by business line.',
  columns: ['Name', 'TC_Stage__c', 'TC_Gross_Fee_Amount__c', 'TC_Deal_Type__c'], groupBy: 'TC_Deal_Type__c', sums: ['TC_Gross_Fee_Amount__c'], filters: [['TC_Status__c', 'equals', 'Open']] });
R.won = report({ name: 'TC_Deals_Won', label: 'TC Deals Won', type: 'TC_Deals', base: 'TC_Deal__c', desc: 'Deals closed as Won with actual close date, value and fee.',
  columns: ['Name', 'TC_Deal_Type__c', 'TC_Client__c', 'TC_Actual_Close_Date__c', 'TC_Actual_Value__c', 'TC_Gross_Fee_Amount__c'], filters: [['TC_Status__c', 'equals', 'Won']], sortCol: 'TC_Actual_Close_Date__c' });
R.expByYear = report({ name: 'TC_Lease_Expirations_by_Year', label: 'TC Lease Expirations by Year', type: 'TC_Leases', base: 'TC_Lease__c', desc: 'Active lease square footage expiring each year.',
  columns: ['Name', 'TC_Tenant__c', 'TC_Property__c', 'TC_Size__c', 'TC_Expiration_Date__c', 'TC_Expiration_Year__c'], groupBy: 'TC_Expiration_Year__c', sums: ['TC_Size__c'], filters: [['TC_Status__c', 'equals', 'Active,Holdover']] });
R.exp12 = report({ name: 'TC_Leases_Expiring_12_Months', label: 'TC Leases Expiring in 12 Months', type: 'TC_Leases', base: 'TC_Lease__c', desc: 'Active leases expiring within a year: prospecting list.',
  columns: ['Name', 'TC_Tenant__c', 'TC_Property__c', 'TC_Unit_Name__c', 'TC_Size__c', 'TC_Lease_Rate__c', 'TC_Expiration_Date__c', 'TC_Days_to_Expiration__c'], filters: [['TC_Status__c', 'equals', 'Active'], ['TC_Days_to_Expiration__c', 'lessOrEqual', '365'], ['TC_Days_to_Expiration__c', 'greaterOrEqual', '0']], sortCol: 'TC_Expiration_Date__c' });
R.avail = report({ name: 'TC_Availabilities_by_Property', label: 'TC Availabilities by Property', type: 'TC_Availabilities', base: 'TC_Availability__c', desc: 'Available space by property with asking rates.',
  columns: ['Name', 'TC_Unit_Name__c', 'TC_Size__c', 'TC_Lease_Rate__c', 'TC_Date_Available__c', 'TC_Property__c'], groupBy: 'TC_Property__c', sums: ['TC_Size__c'], filters: [['TC_Status__c', 'equals', 'Available']] });
R.inq = report({ name: 'TC_Inquiries_by_Source', label: 'TC Inquiries by Source', type: 'TC_Inquiries', base: 'TC_Inquiry__c', desc: 'Inquiries by source and status (foot traffic).',
  columns: ['Name', 'TC_Inquiry_Type__c', 'TC_Status__c', 'TC_Listing__c', 'TC_Source__c'], groupBy: 'TC_Source__c' });
R.com = report({ name: 'TC_Commissions_by_Broker', label: 'TC Commissions by Broker', type: 'TC_Commissions', base: 'TC_Commission__c', desc: 'Commission gross amounts by broker.',
  columns: ['Name', 'TC_Deal__c', 'TC_Commission_Type__c', 'TC_Status__c', 'TC_Gross_Commission__c', 'TC_Broker__c'], groupBy: 'TC_Broker__c', sums: ['TC_Gross_Commission__c'], filters: [['TC_Status__c', 'notEqual', 'Cancelled']] });
R.occ = report({ name: 'TC_Property_Occupancy', label: 'TC Property Occupancy', type: 'TC_Properties', base: 'TC_Property__c', desc: 'Properties with size, leased and available area and occupancy.',
  columns: ['Name', 'TC_Property_Type__c', 'TC_Building_Class__c', 'TC_City__c', 'TC_Total_Size__c', 'TC_Leased_SF__c', 'TC_Available_SF__c', 'TC_Occupancy__c'], sortCol: 'Name' });
R.sales = report({ name: 'TC_Sales_Comps', label: 'TC Sales Comps', type: 'TC_Sales', base: 'TC_Sale__c', desc: 'Property sales with price per SF and cap rate.',
  columns: ['Name', 'TC_Property__c', 'TC_Sale_Date__c', 'TC_Sale_Price__c', 'TC_Price_per_SF__c', 'TC_Cap_Rate__c', 'TC_Buyer__c', 'TC_Seller__c'], sortCol: 'TC_Sale_Date__c' });
R.listExp = report({ name: 'TC_Listings_Expiring_90_Days', label: 'TC Listings Expiring in 90 Days', type: 'TC_Listings', base: 'TC_Listing__c', desc: 'Active listing agreements expiring within 90 days.',
  columns: ['Name', 'TC_Property__c', 'TC_Status__c', 'TC_Listing_Date__c', 'TC_Expiration_Date__c', 'TC_Days_to_Expiration__c', 'TC_Total_Available_SF__c'], filters: [['TC_Status__c', 'equals', 'Active'], ['TC_Days_to_Expiration__c', 'lessOrEqual', '90']], sortCol: 'TC_Expiration_Date__c' });

// ---------- dashboard ----------
function component(report, type, header, col, row, colSpan = 4, rowSpan = 8) {
  return `        <dashboardGridComponents>
            <colSpan>${colSpan}</colSpan>
            <columnIndex>${col}</columnIndex>
            <dashboardComponent>
                <autoselectColumnsFromReport>true</autoselectColumnsFromReport>
                <chartAxisRange>Auto</chartAxisRange>
                <componentType>${type}</componentType>
                <displayUnits>Auto</displayUnits>
                <drillEnabled>false</drillEnabled>
                <drillToDetailEnabled>false</drillToDetailEnabled>
                <enableHover>true</enableHover>
                <expandOthers>false</expandOthers>
                <header>${esc(header)}</header>
                <legendPosition>Bottom</legendPosition>
                <report>${report}</report>
                <showPercentage>false</showPercentage>
                <showValues>true</showValues>
                <sortBy>RowLabelAscending</sortBy>
                <useReportChart>false</useReportChart>
            </dashboardComponent>
            <rowIndex>${row}</rowIndex>
            <rowSpan>${rowSpan}</rowSpan>
        </dashboardGridComponents>
`;
}
out('dashboards/TC_Dashboards/TC_Brokerage_Dashboard.dashboard-meta.xml', `<?xml version="1.0" encoding="UTF-8"?>
<Dashboard xmlns="${NS}">
    <backgroundEndColor>#FFFFFF</backgroundEndColor>
    <backgroundFadeDirection>Diagonal</backgroundFadeDirection>
    <backgroundStartColor>#FFFFFF</backgroundStartColor>
    <chartTheme>light</chartTheme>
    <colorPalette>unity</colorPalette>
    <dashboardChartTheme>light</dashboardChartTheme>
    <dashboardColorPalette>unity</dashboardColorPalette>
    <dashboardGridLayout>
${component(R.pipeline, 'Bar', 'Open pipeline by stage', 0, 0)}${component(R.byType, 'Donut', 'Pipeline by deal type', 4, 0)}${component(R.expByYear, 'Column', 'Lease expirations by year (SF)', 8, 0)}${component(R.avail, 'Bar', 'Available space by property', 0, 8)}${component(R.inq, 'Donut', 'Inquiries by source', 4, 8)}${component(R.com, 'Bar', 'Commissions by broker', 8, 8)}        <numberOfColumns>12</numberOfColumns>
        <rowHeight>36</rowHeight>
    </dashboardGridLayout>
    <dashboardType>LoggedInUser</dashboardType>
    <description>TC brokerage KPIs: pipeline, deal mix, lease expirations, available space, inquiry sources and commissions.</description>
    <isGridLayout>true</isGridLayout>
    <textColor>#000000</textColor>
    <title>TC Brokerage Dashboard</title>
    <titleColor>#000000</titleColor>
    <titleSize>12</titleSize>
</Dashboard>
`);
console.log(`Generated ${reportTypes.length} report types, ${Object.keys(R).length} reports and 1 dashboard.`);
