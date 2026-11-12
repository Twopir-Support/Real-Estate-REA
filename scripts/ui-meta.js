#!/usr/bin/env node
/*
 * Generates the TC app shell: Lightning record pages, app pages, app-page tabs and the
 * TC_Commercial_Real_Estate Lightning app (with record-page overrides scoped to the app only).
 * Usage: node scripts/ui-meta.js
 */
const fs = require('fs');
const path = require('path');
const SRC = path.join(__dirname, '..', 'force-app', 'main', 'default');
const NS = 'http://soap.sforce.com/2006/04/metadata';
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const out = (rel, xml) => { const p = path.join(SRC, rel); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, xml); };

// ---------- flexipage building blocks ----------
let idCounter = 0;
function comp(name, props = {}, lwc = false) {
  const id = (lwc ? 'c_' : '') + name.replace(/[^A-Za-z0-9]/g, '_') + (++idCounter);
  const p = Object.entries(props).map(([k, v]) => `                <componentInstanceProperties>\n                    <name>${k}</name>\n                    <value>${esc(v)}</value>\n                </componentInstanceProperties>\n`).join('');
  return `        <itemInstances>\n            <componentInstance>\n${p}                <componentName>${name}</componentName>\n                <identifier>${id}</identifier>\n            </componentInstance>\n        </itemInstances>\n`;
}
const lwc = (name, props) => comp(name, props, true);
const region = (name, items, type = 'Region') => `    <flexiPageRegions>\n${items.join('')}        <name>${name}</name>\n        <type>${type}</type>\n    </flexiPageRegions>\n`;

function recordPage({ name, label, object, top = [], sidebar = [], extraTabs = [] }) {
  idCounter = 0;
  const regions = [];
  regions.push(region('header', [comp('force:highlightsPanel', { collapsed: 'false', numVisibleActions: '4' })]));
  const facetDetails = `Facet-${name}-details`;
  const facetRelated = `Facet-${name}-related`;
  const facetTabs = `Facet-${name}-tabs`;
  regions.push(region(facetDetails, [comp('force:detailPanel')], 'Facet'));
  regions.push(region(facetRelated, [comp('force:relatedListContainer')], 'Facet'));
  const tabItems = [
    comp('flexipage:tab', { active: 'true', body: facetDetails, title: 'Standard.Tab.detail' }),
    comp('flexipage:tab', { body: facetRelated, title: 'Standard.Tab.relatedLists' }),
  ];
  extraTabs.forEach((t, i) => {
    const f = `Facet-${name}-x${i}`;
    regions.push(region(f, t.items, 'Facet'));
    tabItems.push(comp('flexipage:tab', { body: f, title: t.title }));
  });
  regions.push(region(facetTabs, tabItems, 'Facet'));
  regions.push(region('main', [...top, comp('flexipage:tabset', { tabs: facetTabs })]));
  regions.push(region('sidebar', [...sidebar, comp('runtime_sales_activities:activityPanel')]));
  return `<?xml version="1.0" encoding="UTF-8"?>\n<FlexiPage xmlns="${NS}">\n${regions.join('')}    <masterLabel>${esc(label)}</masterLabel>\n    <sobjectType>${object}</sobjectType>\n    <template>\n        <name>flexipage:recordHomeTemplateDesktop</name>\n    </template>\n    <type>RecordPage</type>\n</FlexiPage>\n`;
}

function appPage({ label, items }) {
  idCounter = 0;
  return `<?xml version="1.0" encoding="UTF-8"?>\n<FlexiPage xmlns="${NS}">\n${region('main', items)}    <masterLabel>${esc(label)}</masterLabel>\n    <template>\n        <name>flexipage:defaultAppHomeTemplate</name>\n    </template>\n    <type>AppPage</type>\n</FlexiPage>\n`;
}

// ---------- record pages ----------
const recordPages = [
  { name: 'TC_Property_Record_Page', label: 'TC Property Record Page', object: 'TC_Property__c',
    top: [lwc('tcPropertyDetail')],
    extraTabs: [{ title: 'Stacking Plan', items: [lwc('tcStackingPlan')] }],
    sidebar: [lwc('tcImageViewer'), lwc('tcDocumentGenerator'), lwc('tcRelationshipGrid')] },
  { name: 'TC_Deal_Record_Page', label: 'TC Deal Record Page', object: 'TC_Deal__c',
    top: [lwc('tcScorecard')],
    extraTabs: [{ title: 'Rent Table', items: [lwc('tcRentTable')] }, { title: 'Commissions', items: [lwc('tcCommissionGrid')] }, { title: 'Term Sheets', items: [lwc('tcTermSheetCompare')] }],
    sidebar: [lwc('tcRelationshipGrid')] },
  { name: 'TC_Lease_Record_Page', label: 'TC Lease Record Page', object: 'TC_Lease__c',
    top: [lwc('tcScorecard')],
    extraTabs: [{ title: 'Rent Table', items: [lwc('tcRentTable')] }] },
  { name: 'TC_Listing_Record_Page', label: 'TC Listing Record Page', object: 'TC_Listing__c',
    top: [lwc('tcScorecard')],
    sidebar: [lwc('tcImageViewer'), lwc('tcDocumentGenerator'), lwc('tcRelationshipGrid')] },
  { name: 'TC_Inquiry_Record_Page', label: 'TC Inquiry Record Page', object: 'TC_Inquiry__c',
    extraTabs: [{ title: 'Matching Listings', items: [lwc('tcInquiryMatches')] }],
    sidebar: [lwc('tcDocumentGenerator')] },
  { name: 'TC_Availability_Record_Page', label: 'TC Availability Record Page', object: 'TC_Availability__c',
    sidebar: [lwc('tcImageViewer')] },
];
for (const rp of recordPages) out(`flexipages/${rp.name}.flexipage-meta.xml`, recordPage(rp));

// ---------- app pages + tabs ----------
const appPages = [
  { name: 'TC_Home', label: 'TC Home', tab: 'Home', motif: 'Custom24: Building', items: [lwc('tcPropertyDashboard')] },
  { name: 'TC_Deal_Pipeline', label: 'TC Deal Pipeline', tab: 'Deal Pipeline', motif: 'Custom48: Trophy', items: [lwc('tcDealPipeline')] },
  { name: 'TC_Property_Search', label: 'TC Property Search', tab: 'Property Search', motif: 'Custom68: Globe', items: [lwc('tcPropertySearch')] },
  { name: 'TC_Commission_Dashboard', label: 'TC Commission Dashboard', tab: 'Commission Dashboard', motif: 'Custom16: Bank', items: [lwc('tcCommissionDashboard')] },
];
for (const ap of appPages) {
  out(`flexipages/${ap.name}.flexipage-meta.xml`, appPage(ap));
  out(`tabs/${ap.name}.tab-meta.xml`, `<?xml version="1.0" encoding="UTF-8"?>\n<CustomTab xmlns="${NS}">\n    <flexiPage>${ap.name}</flexiPage>\n    <label>${esc(ap.tab)}</label>\n    <motif>${ap.motif}</motif>\n</CustomTab>\n`);
}

// ---------- the app ----------
const navTabs = ['TC_Home', 'TC_Property__c', 'TC_Listing__c', 'TC_Availability__c', 'TC_Inquiry__c', 'TC_Deal__c', 'TC_Deal_Pipeline',
  'TC_Lease__c', 'TC_Sale__c', 'TC_Commission__c', 'TC_Commission_Dashboard', 'TC_Property_Search', 'TC_Capital_Source__c', 'TC_Market_Rent__c',
  'TC_Unit__c', 'TC_Unit_Profile__c', 'standard-Account', 'standard-Contact', 'standard-report', 'standard-Dashboard'];
const overrides = recordPages.map(rp => `    <actionOverrides>\n        <actionName>View</actionName>\n        <comment>TC record page, active in the TC app only.</comment>\n        <content>${rp.name}</content>\n        <formFactor>Large</formFactor>\n        <skipRecordTypeSelect>false</skipRecordTypeSelect>\n        <type>Flexipage</type>\n        <pageOrSobjectType>${rp.object}</pageOrSobjectType>\n    </actionOverrides>\n`).join('');
out('applications/TC_Commercial_Real_Estate.app-meta.xml', `<?xml version="1.0" encoding="UTF-8"?>
<CustomApplication xmlns="${NS}">
${overrides}    <brand>
        <headerColor>#0F5F74</headerColor>
        <shouldOverrideOrgTheme>false</shouldOverrideOrgTheme>
    </brand>
    <description>TC Commercial Real Estate: properties, listings, availabilities, inquiries, deals, leases, sales, commissions and capital sources.</description>
    <formFactors>Small</formFactors>
    <formFactors>Large</formFactors>
    <isNavAutoTempTabsDisabled>false</isNavAutoTempTabsDisabled>
    <isNavPersonalizationDisabled>false</isNavPersonalizationDisabled>
    <isNavTabPersistenceDisabled>false</isNavTabPersistenceDisabled>
    <label>TC Commercial Real Estate</label>
    <navType>Standard</navType>
${navTabs.map(t => `    <tabs>${t}</tabs>\n`).join('')}    <uiType>Lightning</uiType>
</CustomApplication>
`);
console.log(`Generated ${recordPages.length} record pages, ${appPages.length} app pages + tabs, and the TC app.`);
