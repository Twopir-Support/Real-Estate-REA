// Removes the TC sample data set, and only that set: companies with Site = "[TC Sample]" and the TC
// records that hang off them. Records you created yourself are left alone unless they point to
// sample companies or sample properties.
// Run: sf apex run -o REA-Dev -f scripts/apex/sample-data-cleanup.apex
// Deletes go to the Recycle Bin (recoverable for 15 days).

final String MARK = '[TC Sample]';
Set<Id> accts = new Map<Id, Account>([SELECT Id FROM Account WHERE Site = :MARK]).keySet();
Set<Id> props = new Map<Id, TC_Property__c>([SELECT Id FROM TC_Property__c WHERE TC_Owner_Landlord__c IN :accts]).keySet();

// Flows and triggers off while deleting, so no tasks or roll-up churn are produced
TC_Bypass_Settings__c bypass = TC_Bypass_Settings__c.getInstance(UserInfo.getUserId());
Boolean created = bypass.Id == null;
bypass.SetupOwnerId = UserInfo.getUserId();
bypass.TC_Bypass_Triggers__c = true;
bypass.TC_Bypass_Flows__c = true;
upsert bypass;

delete [SELECT Id FROM TC_Relationship__c WHERE TC_Account__c IN :accts OR TC_Property__c IN :props OR TC_Deal__r.TC_Client__c IN :accts];
delete [SELECT Id FROM TC_Deal__c WHERE TC_Client__c IN :accts OR TC_Property__c IN :props];
delete [SELECT Id FROM TC_Inquiry__c WHERE TC_Company__c IN :accts OR TC_Property__c IN :props OR TC_Listing__r.TC_Property__c IN :props];
delete [SELECT Id FROM TC_Capital_Source__c WHERE TC_Account__c IN :accts];
delete [SELECT Id FROM TC_Market_Rent__c WHERE TC_Source__c = 'TC research'];
delete [SELECT Id FROM TC_Unit_Profile__c WHERE Name IN ('Standard Office Suite', 'Half-Floor Office', 'Inline Retail Shop')];
delete [SELECT Id FROM TC_Sale__c WHERE TC_Property__c IN :props];
delete [SELECT Id FROM TC_Lease__c WHERE TC_Property__c IN :props];
delete [SELECT Id FROM TC_Availability__c WHERE TC_Property__c IN :props];
delete [SELECT Id FROM TC_Listing__c WHERE TC_Property__c IN :props];
delete [SELECT Id FROM TC_Property__c WHERE Id IN :props];
delete [SELECT Id FROM Task WHERE WhoId IN (SELECT Id FROM Contact WHERE AccountId IN :accts)];
delete [SELECT Id FROM Contact WHERE AccountId IN :accts];
delete [SELECT Id FROM Account WHERE Id IN :accts];

if (created) { delete bypass; } else { bypass.TC_Bypass_Triggers__c = false; bypass.TC_Bypass_Flows__c = false; update bypass; }
System.debug('TC sample data removed: ' + accts.size() + ' companies, ' + props.size() + ' properties and their related records.');
