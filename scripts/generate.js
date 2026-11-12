#!/usr/bin/env node
/*
 * Generates TC data-model metadata (SFDX source format), docs and the field inventory
 * from scripts/model/tc-model.js.   Usage:  node scripts/generate.js
 * Output is deterministic; re-run after editing the model and commit the result.
 */
const fs = require('fs');
const path = require('path');
const M = require('./model/tc-model');

const ROOT = path.resolve(__dirname, '..');
const SRC = path.join(ROOT, 'force-app', 'main', 'default');
const API = '64.0';
const NS = 'http://soap.sforce.com/2006/04/metadata';

// ---------- xml helpers ----------
const esc = s => String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&apos;');
function node(tag, val, ind) {
  const pad = '    '.repeat(ind);
  if (val === undefined || val === null) return '';
  if (Array.isArray(val)) return val.map(v => node(tag, v, ind)).join('');
  if (typeof val === 'object' && val.__raw) return `${pad}<${tag}>${val.__raw}</${tag}>\n`;
  if (typeof val === 'object') {
    const keys = Object.keys(val).sort((a, b) => (a === 'fullName' ? -1 : b === 'fullName' ? 1 : a.localeCompare(b)));
    return `${pad}<${tag}>\n${keys.map(k => node(k, val[k], ind + 1)).join('')}${pad}</${tag}>\n`;
  }
  return `${pad}<${tag}>${esc(val)}</${tag}>\n`;
}
function doc(root, body, extraNs = '') {
  const keys = Object.keys(body).sort((a, b) => (a === 'fullName' ? -1 : b === 'fullName' ? 1 : a.localeCompare(b)));
  return `<?xml version="1.0" encoding="UTF-8"?>\n<${root} xmlns="${NS}"${extraNs}>\n${keys.map(k => node(k, body[k], 1)).join('')}</${root}>\n`;
}
const written = [];
function write(rel, content) {
  const p = path.join(SRC, rel);
  fs.mkdirSync(path.dirname(p), { recursive: true });
  fs.writeFileSync(p, content);
  written.push(rel);
}
const short = api => api.replace(/^TC_/, '').replace(/__c$/, '');

// ---------- picklist helpers ----------
const gvsValues = name => M.globalValueSets[name].values;
function picklistValues(f) {
  if (f.gvs) return gvsValues(f.gvs);
  if (f.dependent) return [].concat(...Object.values(f.dependent));
  return f.values;
}
function valueSet(f) {
  if (f.gvs) return { restricted: true, valueSetName: f.gvs };
  const vs = {
    restricted: true,
    valueSetDefinition: { sorted: false, value: picklistValues(f).map(v => ({ fullName: v, default: f.defaultValue === v, label: v })) },
  };
  if (f.dependent) {
    vs.controllingField = f.controllingField;
    vs.valueSettings = [];
    for (const [ctrl, deps] of Object.entries(f.dependent)) deps.forEach(d => vs.valueSettings.push({ controllingFieldValue: ctrl, valueName: d }));
  }
  return vs;
}

// ---------- fields ----------
const objByApi = Object.fromEntries(M.objects.map(o => [o.api, o]));
function relNames(obj, f) {
  if (f.type === 'MasterDetail') return { relationshipName: obj.plural.replace(/[^A-Za-z0-9]+/g, '_'), relationshipLabel: obj.plural };
  const name = `${short(obj.api)}_${short(f.api)}`.slice(0, 38) + 's';
  const lbl = f.relLabel || `${obj.plural || obj.label} (${f.label})`;
  return { relationshipName: name.replace(/__+/g, '_'), relationshipLabel: lbl.slice(0, 80) };
}
function fieldXml(obj, f, { mdt = false } = {}) {
  const b = { fullName: f.api, label: f.label, externalId: undefined };
  if (f.desc) b.description = f.desc;
  if (f.help) b.inlineHelpText = f.help;
  if (mdt) b.fieldManageability = 'DeveloperControlled';
  const req = !!f.required;
  switch (f.type) {
    case 'Text': Object.assign(b, { type: 'Text', length: f.length, required: req, unique: false, externalId: false }); break;
    case 'LongTextArea': Object.assign(b, { type: 'LongTextArea', length: f.length, visibleLines: f.visibleLines }); break;
    case 'Number': case 'Currency': case 'Percent':
      Object.assign(b, { type: f.type, precision: f.precision, scale: f.scale, required: req });
      if (f.type === 'Number' && !mdt) b.externalId = false;
      if (f.defaultValue) b.defaultValue = f.defaultValue;
      break;
    case 'Date': Object.assign(b, { type: 'Date', required: req }); break;
    case 'Checkbox': Object.assign(b, { type: 'Checkbox', defaultValue: f.defaultValue || 'false' }); break;
    case 'Url': case 'Email': case 'Phone': Object.assign(b, { type: f.type, required: req }); if (f.type === 'Email') { b.unique = false; b.externalId = false; } break;
    case 'Picklist': Object.assign(b, { type: 'Picklist', required: req, valueSet: valueSet(f) }); break;
    case 'MultiselectPicklist': Object.assign(b, { type: 'MultiselectPicklist', required: req, visibleLines: f.visibleLines, valueSet: valueSet(f) }); break;
    case 'Lookup': {
      Object.assign(b, { type: 'Lookup', referenceTo: f.ref, required: req }, relNames(obj, f));
      if (f.ref !== 'User' || req) b.deleteConstraint = req ? 'Restrict' : 'SetNull';
      break;
    }
    case 'MasterDetail': Object.assign(b, { type: 'MasterDetail', referenceTo: f.ref, relationshipOrder: 0, reparentableMasterDetail: false, writeRequiresMasterRead: false }, relNames(obj, f)); break;
    case 'Formula': {
      Object.assign(b, { type: f.returnType, formula: f.formula, formulaTreatBlanksAs: 'BlankAsZero' });
      if (['Number', 'Currency', 'Percent'].includes(f.returnType)) { b.precision = 18; b.scale = f.scale !== undefined ? f.scale : (f.returnType === 'Number' ? 0 : 2); }
      if (f.returnType === 'Text' || f.returnType === 'Checkbox') b.formulaTreatBlanksAs = 'BlankAsBlank';
      if (f.returnType === 'Checkbox') b.formulaTreatBlanksAs = 'BlankAsZero';
      break;
    }
    case 'Summary': Object.assign(b, { type: 'Summary', summaryOperation: f.op, summarizedField: `${f.child}.${f.field}`, summaryForeignKey: `${f.child}.${f.fk}` }); break;
    case 'Location': Object.assign(b, { type: 'Location', displayLocationInDecimal: true, scale: 6, required: false }); break;
    default: throw new Error('Unknown type ' + f.type);
  }
  if (b.externalId === undefined) delete b.externalId;
  return doc('CustomField', b);
}

// ---------- classification ----------
const isReadOnly = f => f.auto || f.type === 'Formula' || f.type === 'Summary';
const isRequiredField = f => f.required || f.type === 'MasterDetail';
const permissible = f => !isRequiredField(f); // required/MD fields can't be in fieldPermissions

// ---------- objects ----------
const children = {}; // parent -> [{obj, field}]
for (const o of M.objects) for (const f of o.fields) if ((f.type === 'Lookup' || f.type === 'MasterDetail') && objByApi[f.ref]) (children[f.ref] = children[f.ref] || []).push({ obj: o, field: f });
for (const [std, fields] of Object.entries(M.standardFields)) void std, void fields;

for (const o of M.objects) {
  const hasMD = o.fields.some(f => f.type === 'MasterDetail');
  const nameField = o.nameField.type === 'AutoNumber'
    ? { label: o.nameField.label, type: 'AutoNumber', displayFormat: o.nameField.format, trackHistory: false }
    : { label: o.nameField.label, type: 'Text', trackHistory: false };
  write(`objects/${o.api}/${o.api}.object-meta.xml`, doc('CustomObject', {
    deploymentStatus: 'Deployed', description: o.desc, enableActivities: true, enableBulkApi: true, enableFeeds: false,
    enableHistory: true, enableLicensing: false, enableReports: true, enableSearch: true, enableSharing: true,
    enableStreamingApi: true, label: o.label, nameField, pluralLabel: o.plural,
    sharingModel: hasMD ? 'ControlledByParent' : 'ReadWrite', externalSharingModel: hasMD ? 'ControlledByParent' : 'Private', visibility: 'Public',
  }));
  for (const f of o.fields) write(`objects/${o.api}/fields/${f.api}.field-meta.xml`, fieldXml(o, f));

  // record types
  for (const rt of o.recordTypes || []) {
    const pls = o.fields.filter(f => f.type === 'Picklist' || f.type === 'MultiselectPicklist').map(f => {
      const vals = (rt.restrict && rt.restrict[f.api]) || picklistValues(f);
      return { picklist: f.api, values: vals.map(v => ({ fullName: v, default: f.defaultValue === v || (rt.restrict && rt.restrict[f.api] && vals.length === 1) })) };
    });
    write(`objects/${o.api}/recordTypes/${rt.api}.recordType-meta.xml`, doc('RecordType', { fullName: rt.api, active: true, label: rt.label, description: rt.desc || `${rt.label} ${o.label.toLowerCase()} record type.`, picklistValues: pls }));
  }
  // validation rules
  for (const v of o.vrs || []) write(`objects/${o.api}/validationRules/${v.name}.validationRule-meta.xml`, doc('ValidationRule', {
    fullName: v.name, active: true, description: v.desc || v.msg,
    errorConditionFormula: `AND(\n    NOT($Setup.TC_Bypass_Settings__c.TC_Bypass_Validation_Rules__c),\n    ${v.formula}\n)`,
    errorDisplayField: v.field, errorMessage: v.msg,
  }));
  // list view
  const cols = ['NAME'].concat((o.listColumns || []).map(c => (c === 'RecordType' ? 'RECORDTYPE' : c)));
  write(`objects/${o.api}/listViews/All.listView-meta.xml`, doc('ListView', { fullName: 'All', columns: cols, filterScope: 'Everything', label: 'All' }));
  // tab
  if (!o.noTab) write(`tabs/${o.api}.tab-meta.xml`, doc('CustomTab', { customObject: true, motif: o.motif }));
  // layout
  const editable = o.fields.filter(f => !isReadOnly(f));
  const calc = o.fields.filter(isReadOnly);
  const item = f => ({ behavior: isRequiredField(f) ? 'Required' : isReadOnly(f) ? 'Readonly' : 'Edit', field: f.api });
  const twoCol = list => {
    const left = [], right = [];
    list.forEach((f, i) => (i % 2 === 0 ? left : right).push(item(f)));
    return [{ layoutItems: left.length ? left : undefined }, { layoutItems: right.length ? right : undefined }];
  };
  const head = [{ behavior: o.nameField.type === 'AutoNumber' ? 'Readonly' : 'Required', field: 'Name' }];
  if (!hasMD) head.push({ behavior: 'Edit', field: 'OwnerId' });
  if ((o.recordTypes || []).length) head.push({ behavior: 'Readonly', field: 'RecordTypeId' });
  const infoCols = twoCol(editable);
  infoCols[0].layoutItems = head.concat(infoCols[0].layoutItems || []);
  const sections = [{ customLabel: false, detailHeading: true, editHeading: true, label: 'Information', layoutColumns: infoCols, style: 'TwoColumnsLeftToRight' }];
  if (calc.length) sections.push({ customLabel: true, detailHeading: true, editHeading: false, label: 'Calculated', layoutColumns: twoCol(calc), style: 'TwoColumnsLeftToRight' });
  sections.push({ customLabel: false, detailHeading: true, editHeading: false, label: 'System Information', layoutColumns: [{ layoutItems: [{ behavior: 'Readonly', field: 'CreatedById' }] }, { layoutItems: [{ behavior: 'Readonly', field: 'LastModifiedById' }] }], style: 'TwoColumnsLeftToRight' });
  const rel = (children[o.api] || []).map(c => ({ fields: ['NAME'], relatedList: `${c.obj.api}.${c.field.api}` }));
  rel.push({ relatedList: 'RelatedActivityList' }, { relatedList: 'RelatedHistoryList' }, { relatedList: 'RelatedFileList' });
  let platformActionList;
  if ((o.quickActions || []).length) {
    for (const qa of o.quickActions) {
      write(`quickActions/${o.api}.${qa.name}.quickAction-meta.xml`, doc('QuickAction', { actionSubtype: 'ScreenAction', description: qa.desc, label: qa.label, lightningWebComponent: qa.lwc, optionsCreateFeedItem: false, type: 'LightningWebComponent' }));
    }
    const items = o.quickActions.map(qa => ({ actionName: `${o.api}.${qa.name}`, actionType: 'QuickAction' }))
      .concat(['Edit', 'Clone', 'Delete', 'ChangeOwnerOne'].filter(b => !(hasMD && b === 'ChangeOwnerOne')).map(b => ({ actionName: b, actionType: 'StandardButton' })));
    platformActionList = { actionListContext: 'Record', platformActionListItems: items.map((it, i) => ({ ...it, sortOrder: i })) };
  }
  write(`layouts/${o.api}-TC ${o.label} Layout.layout-meta.xml`, doc('Layout', { layoutSections: sections, platformActionList, relatedLists: rel, showEmailCheckbox: false, showHighlightsPanel: false, showInteractionLogPanel: false, showRunAssignmentRulesCheckbox: false, showSubmitAndAttachButton: false }));
}

// standard object fields
for (const [std, fields] of Object.entries(M.standardFields)) for (const f of fields) write(`objects/${std}/fields/${f.api}.field-meta.xml`, fieldXml({ api: std, label: std, plural: std + 's' }, f));

// custom settings
for (const cs of M.customSettings) {
  write(`objects/${cs.api}/${cs.api}.object-meta.xml`, doc('CustomObject', { customSettingsType: 'Hierarchy', description: cs.desc, enableFeeds: false, label: cs.label, visibility: 'Public' }));
  for (const f of cs.fields) write(`objects/${cs.api}/fields/${f.api}.field-meta.xml`, fieldXml(cs, f));
}
// custom metadata types + records
for (const t of M.mdtTypes) {
  write(`objects/${t.api}/${t.api}.object-meta.xml`, doc('CustomObject', { description: t.desc, label: t.label, pluralLabel: t.plural, visibility: 'Public' }));
  for (const f of t.fields) write(`objects/${t.api}/fields/${f.api}.field-meta.xml`, fieldXml(t, f, { mdt: true }));
  const typeName = t.api.replace(/__mdt$/, '');
  for (const r of t.records) {
    const vals = Object.entries(r.values).map(([field, v]) => {
      if (v === '' || v === null || v === undefined) return `    <values>\n        <field>${field}</field>\n        <value xsi:nil="true"/>\n    </values>\n`;
      const xt = typeof v === 'boolean' ? 'xsd:boolean' : typeof v === 'number' ? 'xsd:double' : 'xsd:string';
      return `    <values>\n        <field>${field}</field>\n        <value xsi:type="${xt}">${esc(v)}</value>\n    </values>\n`;
    }).join('');
    const p = path.join(SRC, 'customMetadata', `${typeName}.${r.name}.md-meta.xml`);
    fs.mkdirSync(path.dirname(p), { recursive: true });
    fs.writeFileSync(p, `<?xml version="1.0" encoding="UTF-8"?>\n<CustomMetadata xmlns="${NS}" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">\n    <label>${esc(r.label.slice(0, 40))}</label>\n    <protected>false</protected>\n${vals}</CustomMetadata>\n`);
    written.push(`customMetadata/${typeName}.${r.name}`);
  }
}
// global value sets
for (const [name, g] of Object.entries(M.globalValueSets)) write(`globalValueSets/${name}.globalValueSet-meta.xml`, doc('GlobalValueSet', { customValue: g.values.map(v => ({ fullName: v, default: false, label: v })), masterLabel: g.label, sorted: false }));

// custom permission
write('customPermissions/TC_Commission_Privacy_Admin.customPermission-meta.xml', doc('CustomPermission', { description: 'Can see House and Net amounts on all commissions (mirrors the AscendixRE Commission Privacy Admin permission).', isLicensed: false, label: 'TC Commission Privacy Admin' }));

// permission sets
function permSet(name, label, desc, broker) {
  const objectPermissions = M.objects.map(o => {
    const readOnly = broker && ['TC_Market_Rent__c', 'TC_Capital_Source__c'].includes(o.api);
    const noDelete = broker && ['TC_Commission__c', 'TC_Deal__c', 'TC_Lease__c', 'TC_Sale__c', 'TC_Property__c'].includes(o.api);
    return { allowCreate: !readOnly, allowDelete: !readOnly && !noDelete, allowEdit: !readOnly, allowRead: true, modifyAllRecords: !broker, object: o.api, viewAllRecords: !broker };
  });
  const fieldPermissions = [];
  const addF = (objApi, f) => {
    if (!permissible(f)) return;
    if (broker && f.sensitive) return;
    const ro = f.type === 'Formula' || f.type === 'Summary' || (broker && f.auto);
    fieldPermissions.push({ editable: !ro, field: `${objApi}.${f.api}`, readable: true });
  };
  for (const o of M.objects) o.fields.forEach(f => addF(o.api, f));
  for (const [std, fields] of Object.entries(M.standardFields)) fields.forEach(f => addF(std, f));
  fieldPermissions.sort((a, b) => a.field.localeCompare(b.field));
  const tabSettings = M.objects.filter(o => !o.noTab).map(o => ({ tab: o.api, visibility: 'Visible' }))
    .concat(['TC_Home', 'TC_Deal_Pipeline', 'TC_Property_Search', 'TC_Commission_Dashboard'].map(t => ({ tab: t, visibility: 'Visible' })));
  const recordTypeVisibilities = [];
  for (const o of M.objects) for (const rt of o.recordTypes || []) recordTypeVisibilities.push({ recordType: `${o.api}.${rt.api}`, visible: true });
  const classAccesses = ['TC_PropertyUIController', 'TC_DealUIController', 'TC_RecordUIController', 'TC_DocumentController'].map(c => ({ apexClass: c, enabled: true }));
  const pageAccesses = ['TC_Property_Flyer', 'TC_Lease_Comp_Report', 'TC_Tour_Book'].map(p => ({ apexPage: p, enabled: true }));
  const applicationVisibilities = [{ application: 'TC_Commercial_Real_Estate', visible: true }];
  const body = { description: desc, hasActivationRequired: false, label, objectPermissions, fieldPermissions, tabSettings, recordTypeVisibilities, classAccesses, pageAccesses, applicationVisibilities };
  if (!broker) body.customPermissions = [{ enabled: true, name: 'TC_Commission_Privacy_Admin' }];
  write(`permissionsets/${name}.permissionset-meta.xml`, doc('PermissionSet', body));
}
permSet('TC_CRE_Admin', 'TC CRE Admin', 'Full access to the TC Commercial Real Estate app, including commission House and Net amounts.', false);
permSet('TC_CRE_Broker', 'TC CRE Broker', 'Day-to-day broker access to the TC Commercial Real Estate app. No access to House or Net commission amounts.', true);

// ---------- manifest (data layer) ----------
const members = {};
const add = (type, m) => (members[type] = members[type] || new Set()).add(m);
for (const o of M.objects) {
  add('CustomObject', o.api); add('Layout', `${o.api}-TC ${o.label} Layout`); add('ListView', `${o.api}.All`);
  if (!o.noTab) add('CustomTab', o.api);
  o.fields.forEach(f => add('CustomField', `${o.api}.${f.api}`));
  (o.recordTypes || []).forEach(rt => add('RecordType', `${o.api}.${rt.api}`));
  (o.vrs || []).forEach(v => add('ValidationRule', `${o.api}.${v.name}`));
}
for (const [std, fields] of Object.entries(M.standardFields)) fields.forEach(f => add('CustomField', `${std}.${f.api}`));
for (const cs of M.customSettings) { add('CustomObject', cs.api); cs.fields.forEach(f => add('CustomField', `${cs.api}.${f.api}`)); }
for (const t of M.mdtTypes) { add('CustomObject', t.api); t.fields.forEach(f => add('CustomField', `${t.api}.${f.api}`)); t.records.forEach(r => add('CustomMetadata', `${t.api.replace(/__mdt$/, '')}.${r.name}`)); }
Object.keys(M.globalValueSets).forEach(g => add('GlobalValueSet', g));
add('CustomPermission', 'TC_Commission_Privacy_Admin');
add('PermissionSet', 'TC_CRE_Admin'); add('PermissionSet', 'TC_CRE_Broker');
const pkg = `<?xml version="1.0" encoding="UTF-8"?>\n<Package xmlns="${NS}">\n${Object.keys(members).sort().map(t => `    <types>\n${[...members[t]].sort().map(m => `        <members>${esc(m)}</members>\n`).join('')}        <name>${t}</name>\n    </types>\n`).join('')}    <version>${API}</version>\n</Package>\n`;
fs.mkdirSync(path.join(ROOT, 'manifest'), { recursive: true });
fs.writeFileSync(path.join(ROOT, 'manifest', 'package-p1-data-model.xml'), pkg);

// ---------- inventory + docs ----------
const typeLabel = f => {
  switch (f.type) {
    case 'Text': return `Text(${f.length})`;
    case 'LongTextArea': return 'Long Text Area';
    case 'Number': case 'Currency': case 'Percent': return `${f.type}(${f.precision - f.scale},${f.scale})`;
    case 'Picklist': return f.dependent ? `Picklist (dependent on ${f.controllingField})` : f.gvs ? `Picklist (global: ${f.gvs})` : 'Picklist';
    case 'MultiselectPicklist': return f.gvs ? `Multi-select (global: ${f.gvs})` : 'Multi-select Picklist';
    case 'Lookup': return `Lookup(${f.ref})`;
    case 'MasterDetail': return `Master-Detail(${f.ref})`;
    case 'Formula': return `Formula (${f.returnType})`;
    case 'Summary': return `Roll-up Summary (${f.op.toUpperCase()})`;
    case 'Location': return 'Geolocation';
    default: return f.type;
  }
};
const details = f => {
  if (f.type === 'Formula') return f.formula;
  if (f.type === 'Summary') return `${f.op.toUpperCase()} ${f.child}.${f.field}`;
  if (f.type === 'Picklist' || f.type === 'MultiselectPicklist') return picklistValues(f).join('; ');
  return f.help || '';
};
const rows = [];
const pushRows = (objApi, objLabel, fields, objSrc) => fields.forEach(f => rows.push({
  object: objApi, objectLabel: objLabel, field: f.api, label: f.label, type: typeLabel(f), required: isRequiredField(f) ? 'Yes' : '',
  details: details(f), source: f.src === 'A' ? 'AscendixRE documented' : 'TC design', maintainedBy: f.auto ? 'Apex' : (f.type === 'Formula' || f.type === 'Summary') ? 'Platform' : 'User',
  objectSource: objSrc,
}));
M.objects.forEach(o => pushRows(o.api, o.label, o.fields, 'AscendixRE documented'));
Object.entries(M.standardFields).forEach(([s, fs2]) => pushRows(s, s, fs2, 'Standard'));
M.customSettings.forEach(c => pushRows(c.api, c.label, c.fields, 'AscendixRE documented'));
M.mdtTypes.forEach(t => pushRows(t.api, t.label, t.fields, t.src === 'A' ? 'AscendixRE documented' : 'TC design'));
fs.mkdirSync(path.join(ROOT, 'docs', 'generated'), { recursive: true });
const csvCell = v => `"${String(v).replace(/"/g, '""')}"`;
const header = ['Object API', 'Object Label', 'Field API', 'Field Label', 'Type', 'Required', 'Values / Formula / Help', 'Source', 'Maintained By'];
fs.writeFileSync(path.join(ROOT, 'docs', 'generated', 'Object_Field_Inventory.csv'),
  [header.map(csvCell).join(',')].concat(rows.map(r => [r.object, r.objectLabel, r.field, r.label, r.type, r.required, r.details, r.source, r.maintainedBy].map(csvCell).join(','))).join('\r\n'));
fs.writeFileSync(path.join(ROOT, 'docs', 'generated', 'inventory.json'), JSON.stringify({ rows, objects: M.objects.map(o => ({ api: o.api, label: o.label, plural: o.plural, desc: o.desc, recordTypes: (o.recordTypes || []).map(r => r.label), vrs: (o.vrs || []).map(v => ({ name: v.name, msg: v.msg, src: v.src || 'T' })) })) }, null, 1));

// data model markdown
const mdCell = s => String(s).replace(/\|/g, '\\|').replace(/\n/g, ' ');
let md = `# Salesforce Data Model — TC Commercial Real Estate\n\n` +
  `> Generated by \`node scripts/generate.js\` from \`scripts/model/tc-model.js\`. Do not edit by hand.\n\n` +
  `The model mirrors the publicly documented AscendixRE object structure, renamed to the **TC_** convention. ` +
  `Each field is tagged **A** (documented by AscendixRE) or **T** (TC design, filling a gap the public docs leave open). ` +
  `"Apex" in the Maintained column means the value is calculated by TC Apex services and read-only on layouts.\n\n`;
const objSummary = M.objects.map(o => {
  const n = o.fields.length, a = o.fields.filter(f => f.src === 'A').length;
  return { o, n, a, pct: Math.round((a / n) * 100) };
});
const totF = objSummary.reduce((s, x) => s + x.n, 0), totA = objSummary.reduce((s, x) => s + x.a, 0);
md += `## Summary\n\n| Object | API name | Fields | AscendixRE-documented fields | Record types |\n|---|---|---|---|---|\n` +
  objSummary.map(x => `| ${x.o.label} | \`${x.o.api}\` | ${x.n} | ${x.a} (${x.pct}%) | ${(x.o.recordTypes || []).length || '–'} |`).join('\n') +
  `\n| **Total** | | **${totF}** | **${totA} (${Math.round(totA / totF * 100)}%)** | |\n\n` +
  `Standard objects get ${Object.values(M.standardFields).flat().length} \`TC_\` fields (Account, Contact). Settings: ${M.customSettings.length} custom setting, ${M.mdtTypes.length} custom metadata types.\n\n` +
  `Global value sets: ${Object.entries(M.globalValueSets).map(([k, g]) => `\`${k}\` (${g.values.join(', ')})`).join('; ')}.\n\n`;
for (const o of M.objects) {
  md += `## ${o.label} — \`${o.api}\`\n\n${o.desc}\n\n`;
  md += `- **Name field:** ${o.nameField.label} (${o.nameField.type === 'AutoNumber' ? 'Auto Number ' + o.nameField.format : 'Text'})\n`;
  if ((o.recordTypes || []).length) md += `- **Record types:** ${o.recordTypes.map(r => `${r.label} (\`${r.api}\`)`).join(', ')}\n`;
  if (o.noTab) md += `- Shown as a related list (no tab)\n`;
  md += `\n| Label | API name | Type | Req | Values / formula | Src | Maintained |\n|---|---|---|---|---|---|---|\n`;
  md += o.fields.map(f => `| ${mdCell(f.label)} | \`${f.api}\` | ${mdCell(typeLabel(f))} | ${isRequiredField(f) ? 'Y' : ''} | ${mdCell(details(f))} | ${f.src} | ${f.auto ? 'Apex' : (f.type === 'Formula' || f.type === 'Summary') ? 'Platform' : 'User'} |`).join('\n') + '\n\n';
  if ((o.vrs || []).length) md += `**Validation rules**\n\n` + o.vrs.map(v => `- \`${v.name}\`${v.src === 'A' ? ' (A)' : ''}: ${v.msg}`).join('\n') + '\n\n';
}
md += `## Standard object fields\n\n`;
for (const [s, fs2] of Object.entries(M.standardFields)) md += `### ${s}\n\n| Label | API name | Type | Values | Src |\n|---|---|---|---|---|\n` + fs2.map(f => `| ${f.label} | \`${f.api}\` | ${typeLabel(f)} | ${mdCell(details(f))} | ${f.src} |`).join('\n') + '\n\n';
md += `## Settings\n\n`;
for (const c of M.customSettings) md += `### ${c.label} — \`${c.api}\` (hierarchy custom setting)\n\n${c.desc}\n\nFields: ${c.fields.map(f => `\`${f.api}\``).join(', ')}. Every TC validation rule checks \`TC_Bypass_Validation_Rules__c\`; every TC trigger checks \`TC_Bypass_Triggers__c\`.\n\n`;
for (const t of M.mdtTypes) md += `### ${t.label} — \`${t.api}\`\n\n${t.desc}\n\nFields: ${t.fields.map(f => `\`${f.api}\``).join(', ')}. Records shipped: ${t.records.length} (${t.records.slice(0, 8).map(r => `\`${r.name}\``).join(', ')}${t.records.length > 8 ? ', …' : ''}).\n\n`;
md += `## Objects deliberately not created\n\n| AscendixRE item | Why not | TC approach |\n|---|---|---|\n` +
  `| Commission Privacy object | Implementation detail of AscendixRE; not needed on the platform | Field-level security: \`TC_CRE_Broker\` cannot see House/Net; \`TC_Commission_Privacy_Admin\` custom permission |\n` +
  `| Stacking Plan object | AscendixRE builds the plan from Property floors, leases and availabilities | \`tcStackingPlan\` LWC renders live from Units, Leases and Availabilities |\n` +
  `| Ad-Hoc List (Ascendix Search) | Part of the proprietary Search add-on | Out of scope (see Known Limitations) |\n`;
fs.writeFileSync(path.join(ROOT, 'docs', 'Salesforce_Data_Model.md'), md);

console.log(`Generated ${written.length} metadata files, ${rows.length} inventory rows. Objects: ${M.objects.length}; fields on TC objects: ${totF} (${totA} AscendixRE-documented).`);
