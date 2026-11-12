// Writes js-meta.xml for exposed TC LWCs (placement targets in one place).
const fs = require('fs'), path = require('path');
const dir = path.join(__dirname, '..', 'force-app', 'main', 'default', 'lwc');
const R = (objs) => ({ record: objs });
const spec = {
  tcPropertyDashboard: { label: 'TC Brokerage Overview', desc: 'KPIs and charts for properties, pipeline, expirations and inquiries.', app: true, home: true },
  tcCommissionDashboard: { label: 'TC Commission Dashboard', desc: 'Commission totals by broker and status, and payments due.', app: true, home: true },
  tcDealPipeline: { label: 'TC Deal Pipeline', desc: 'Kanban board of open deals by stage with drag and drop.', app: true, home: true },
  tcPropertySearch: { label: 'TC Property Search', desc: 'Search properties by criteria and radius, with a map.', app: true },
  tcStackingPlan: { label: 'TC Stacking Plan', desc: 'Floors, units, leases by expiration and vacancies for a property.', ...R(['TC_Property__c']) },
  tcPropertyDetail: { label: 'TC Property 360', desc: 'Property header with image, facts, occupancy and map.', ...R(['TC_Property__c']) },
  tcScorecard: { label: 'TC Scorecard', desc: 'Roll-up KPI tiles for the record.', ...R(['TC_Deal__c', 'TC_Property__c', 'TC_Lease__c', 'TC_Listing__c', 'Account']) },
  tcRentTable: { label: 'TC Rent Table', desc: 'Rent table periods with generation and review.', ...R(['TC_Deal__c', 'TC_Lease__c']) },
  tcCommissionGrid: { label: 'TC Commissions', desc: 'Deal commissions with totals and bulk entry.', ...R(['TC_Deal__c']) },
  tcTermSheetCompare: { label: 'TC Term Sheet Comparison', desc: 'Side-by-side lender quotes on a deal.', ...R(['TC_Deal__c']) },
  tcInquiryMatches: { label: 'TC Matching Listings', desc: 'Scores listings against an inquiry.', ...R(['TC_Inquiry__c']) },
  tcRelationshipGrid: { label: 'TC Relationships', desc: 'Internal users related to the record.', ...R(['TC_Property__c', 'TC_Listing__c', 'TC_Deal__c', 'Account', 'Contact']) },
  tcImageViewer: { label: 'TC Image Viewer', desc: 'Image gallery with upload.', ...R(['TC_Property__c', 'TC_Listing__c', 'TC_Availability__c']) },
  tcDocumentGenerator: { label: 'TC Documents', desc: 'Generate PDF flyers, lease comp reports and tour books.', ...R(['TC_Property__c', 'TC_Listing__c', 'TC_Inquiry__c']) },
  tcCloseDeal: { label: 'TC Close Deal', desc: 'Close a deal as Won or Lost.', action: ['TC_Deal__c'] },
  tcConvertInquiry: { label: 'TC Convert Inquiry', desc: 'Convert an inquiry to account, contact and deal.', action: ['TC_Inquiry__c'] },
};
for (const [name, s] of Object.entries(spec)) {
  const targets = [];
  if (s.app) targets.push('lightning__AppPage');
  if (s.home) targets.push('lightning__HomePage');
  if (s.record) targets.push('lightning__RecordPage');
  if (s.action) targets.push('lightning__RecordAction');
  let configs = '';
  if (s.record) configs += `        <targetConfig targets="lightning__RecordPage">\n            <objects>\n${s.record.map(o => `                <object>${o}</object>\n`).join('')}            </objects>\n        </targetConfig>\n`;
  if (s.action) configs += `        <targetConfig targets="lightning__RecordAction">\n            <actionType>ScreenAction</actionType>\n        </targetConfig>\n`;
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">\n    <apiVersion>64.0</apiVersion>\n    <isExposed>true</isExposed>\n    <masterLabel>${s.label}</masterLabel>\n    <description>${s.desc}</description>\n    <targets>\n${targets.map(t => `        <target>${t}</target>\n`).join('')}    </targets>\n${configs ? `    <targetConfigs>\n${configs}    </targetConfigs>\n` : ''}</LightningComponentBundle>\n`;
  fs.writeFileSync(path.join(dir, name, `${name}.js-meta.xml`), xml);
}
console.log('wrote', Object.keys(spec).length, 'meta files');
