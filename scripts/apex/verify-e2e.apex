// End-to-end verification against the loaded sample data (read-only).
// Run: sf apex run -o REA-Dev -f scripts/apex/verify-e2e.apex   — every line prints PASS or FAIL.
List<String> out = new List<String>();
void check(List<String> out, String label, Boolean ok, Object detail) { out.add((ok ? 'PASS ' : 'FAIL ') + label + ' -> ' + String.valueOf(detail)); }

final String MARK = '[TC Sample]';
Set<Id> props = new Map<Id, TC_Property__c>([SELECT Id FROM TC_Property__c WHERE TC_Owner_Landlord__r.Site = :MARK]).keySet();
check(out, '12 sample properties', props.size() == 12, props.size());

TC_Property__c uptown = [SELECT Id, TC_Leased_SF__c, TC_Available_SF__c, TC_Occupancy__c, TC_Active_Listings__c, TC_Avg_Asking_Rate__c FROM TC_Property__c WHERE Name = 'Uptown Commerce Tower'];
Decimal leased = (Decimal) [SELECT SUM(TC_Size__c) s FROM TC_Lease__c WHERE TC_Property__c = :uptown.Id AND TC_Status__c IN ('Active','Holdover')][0].get('s');
check(out, 'Uptown leased SF roll-up matches active leases', uptown.TC_Leased_SF__c == leased, uptown.TC_Leased_SF__c + ' vs ' + leased);
check(out, 'Uptown occupancy formula', uptown.TC_Occupancy__c != null && uptown.TC_Occupancy__c > 0, uptown.TC_Occupancy__c + '%');
check(out, 'Uptown has an active listing', uptown.TC_Active_Listings__c == 1, uptown.TC_Active_Listings__c);

Integer occupiedUnits = [SELECT COUNT() FROM TC_Unit__c WHERE TC_Property__c IN :props AND TC_Status__c = 'Occupied'];
Integer unitLeases = [SELECT COUNT() FROM TC_Lease__c WHERE TC_Property__c IN :props AND TC_Unit__c != null AND TC_Status__c = 'Active'];
check(out, 'Every active unit lease marks its unit Occupied', occupiedUnits == unitLeases, occupiedUnits + ' units / ' + unitLeases + ' leases');

Integer withoutPeriods = [SELECT COUNT() FROM TC_Lease__c WHERE TC_Property__c IN :props AND Id NOT IN (SELECT TC_Lease__c FROM TC_Lease_Period__c)];
check(out, 'Every lease has a rent table', withoutPeriods == 0, withoutPeriods + ' without');
TC_Lease__c anyLease = [SELECT Name, TC_Total_Rent__c FROM TC_Lease__c WHERE TC_Property__c IN :props AND TC_Unit__c != null LIMIT 1];
check(out, 'Lease named by name mapping and total rent rolled up', anyLease.Name != '-' && anyLease.TC_Total_Rent__c > 0, anyLease.Name + ' / ' + anyLease.TC_Total_Rent__c);

TC_Deal__c won = [SELECT Id, TC_Stage__c, TC_Probability__c, TC_Space__c FROM TC_Deal__c WHERE Name = 'Summit Learning - Domain Lease'];
check(out, 'Won deal moved to Executed at 100%', won.TC_Stage__c == 'Executed' && won.TC_Probability__c == 100, won.TC_Stage__c + ' ' + won.TC_Probability__c);
check(out, 'Won tenant rep deal created a lease with copied rent table', [SELECT COUNT() FROM TC_Lease_Period__c WHERE TC_Lease__r.TC_Deal__c = :won.Id] > 0, [SELECT COUNT() FROM TC_Lease__c WHERE TC_Deal__c = :won.Id] + ' lease');
check(out, 'Won seller rep deal created a sale', [SELECT COUNT() FROM TC_Sale__c WHERE TC_Deal__r.Name = 'Galleria West Pad - Sale'] == 1, 'sale');
check(out, 'Won listing pursuit created a listing', [SELECT COUNT() FROM TC_Listing__c WHERE TC_Deal__r.Name = 'Pinemont - Lease Listing Pitch'] == 1, 'listing');
Integer earned = [SELECT COUNT() FROM TC_Commission__c WHERE TC_Deal__c = :won.Id AND TC_Status__c = 'Earned'];
check(out, 'Won deal commissions all Earned (none left Projected)', earned > 0 && [SELECT COUNT() FROM TC_Commission__c WHERE TC_Deal__c = :won.Id AND TC_Status__c = 'Projected'] == 0, earned + ' earned');
check(out, 'Lost deal commissions are Cancelled', [SELECT COUNT() FROM TC_Commission__c WHERE TC_Deal__r.Name = 'Harbor Point Insurance - Galleria Office' AND TC_Status__c = 'Cancelled'] >= 1, 'cancelled');

TC_Deal__c withCo = [SELECT Id, TC_Gross_Fee_Amount__c, TC_Net_Deal_Fee__c, (SELECT RecordType.DeveloperName, TC_Gross_Commission__c, TC_House__c FROM Commissions__r) FROM TC_Deal__c WHERE Name = 'Northgate Software - Uptown Expansion'];
Decimal coGross = 0, inGross = 0, house = 0;
for (TC_Commission__c c : withCo.Commissions__r) {
    if (c.RecordType.DeveloperName == 'TC_Co_Broker') { coGross += c.TC_Gross_Commission__c; }
    if (c.RecordType.DeveloperName == 'TC_Inside_Broker') { inGross += c.TC_Gross_Commission__c; house += c.TC_House__c; }
}
check(out, 'Co-broker takes 50% of gross fee', coGross == (withCo.TC_Gross_Fee_Amount__c * 0.5).setScale(2), coGross + ' of ' + withCo.TC_Gross_Fee_Amount__c);
check(out, 'Inside broker gets the net deal fee; house 30%', inGross == withCo.TC_Net_Deal_Fee__c && house == (inGross * 0.3).setScale(2), inGross + ' / house ' + house);

check(out, 'Inquiries have prospective listings from Find Matches', [SELECT COUNT() FROM TC_Prospective_Listing__c WHERE TC_Match_Score__c != null] > 0, [SELECT COUNT() FROM TC_Prospective_Listing__c]);
check(out, 'Converted inquiries link to deals', [SELECT COUNT() FROM TC_Inquiry__c WHERE TC_Status__c = 'Converted' AND TC_Converted_Deal__c != null] == 2, 'converted');
check(out, 'New inquiry flow created follow-up tasks', [SELECT COUNT() FROM Task WHERE Subject LIKE 'Follow up on %inquiry%'] >= 15, [SELECT COUNT() FROM Task WHERE Subject LIKE 'Follow up on %inquiry%']);
check(out, 'Deal stage flow / term sheet inheritance', [SELECT COUNT() FROM TC_Term_Sheet__c WHERE TC_Lender_Name__c != null AND TC_Deal__c != null] == 3, 'term sheets');

Map<String, Object> dash = TC_PropertyUIController.getDashboard(null, null);
check(out, 'Dashboard controller returns KPIs', (Integer) dash.get('properties') >= 12 && (Decimal) dash.get('pipelineFee') > 0, dash.get('properties') + ' properties, pipeline ' + dash.get('pipelineFee'));
Map<String, Object> plan = TC_PropertyUIController.getStackingPlan(uptown.Id);
check(out, 'Stacking plan builds 18 floors for Uptown', ((List<Object>) plan.get('floors')).size() == 18, ((List<Object>) plan.get('floors')).size());
TC_PropertyUIController.SearchCriteria c = new TC_PropertyUIController.SearchCriteria();
c.latitude = 32.7767; c.longitude = -96.7970; c.radiusMiles = 10;
check(out, 'Radius search: Dallas properties within 10 miles', TC_PropertyUIController.searchProperties(c).size() >= 3, TC_PropertyUIController.searchProperties(c).size());
check(out, 'Nightly job scheduled', [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'TC Daily Job'] == 1, 'cron');

Integer fails = 0;
for (String s : out) { if (s.startsWith('FAIL')) fails++; }
System.debug('E2E RESULT ' + (out.size() - fails) + '/' + out.size() + ' passed\n' + String.join(out, '\n'));
