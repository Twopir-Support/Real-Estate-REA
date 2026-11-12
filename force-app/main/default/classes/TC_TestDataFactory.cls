/** Builds consistent TC test data. Methods insert unless the name says "build". */
@IsTest
public class TC_TestDataFactory {

    public static Id rt(SObjectType t, String devName) {
        return TC_Settings.recordTypeId(t, devName);
    }

    public static Account account(String name, String roles) {
        Account a = new Account(Name = name, TC_CRE_Roles__c = roles);
        insert a;
        return a;
    }

    public static Contact contact(Id accountId, String lastName) {
        Contact c = new Contact(LastName = lastName, FirstName = 'Test', AccountId = accountId, Email = lastName.toLowerCase().replaceAll('[^a-z]', '') + '@example.com');
        insert c;
        return c;
    }

    public static TC_Property__c buildProperty(String name, Id ownerId) {
        return new TC_Property__c(
            Name = name, RecordTypeId = rt(TC_Property__c.SObjectType, 'TC_Office'), TC_Building_Class__c = 'A',
            TC_Street__c = '100 Main St', TC_City__c = 'Dallas', TC_State__c = 'TX', TC_Postal_Code__c = '75201',
            TC_Market__c = 'Dallas-Fort Worth', TC_Submarket__c = 'Uptown', TC_Total_Size__c = 100000,
            TC_Number_of_Floors__c = 10, TC_Average_Floor_Size__c = 10000, TC_Owner_Landlord__c = ownerId,
            TC_Location__Latitude__s = 32.7876, TC_Location__Longitude__s = -96.7994
        );
    }

    public static TC_Property__c property(String name, Id ownerId) {
        TC_Property__c p = buildProperty(name, ownerId);
        insert p;
        return p;
    }

    public static List<TC_Unit__c> units(Id propertyId, Integer floors, Integer perFloor) {
        List<TC_Unit__c> units = new List<TC_Unit__c>();
        for (Integer f = 1; f <= floors; f++) {
            for (Integer u = 1; u <= perFloor; u++) {
                units.add(new TC_Unit__c(Name = 'Suite ' + f + '0' + u, TC_Property__c = propertyId, TC_Floor__c = f, TC_Size__c = 2500, TC_Unit_Type__c = 'Office', TC_Status__c = 'Vacant', TC_Position__c = u));
            }
        }
        insert units;
        return units;
    }

    public static TC_Lease__c buildLease(Id propertyId, Id unitId, Id tenantId, Date commencement, Integer months) {
        return new TC_Lease__c(
            Name = '-', TC_Property__c = propertyId, TC_Unit__c = unitId, TC_Tenant__c = tenantId, TC_Lease_Type__c = 'NNN',
            TC_Status__c = 'Active', TC_Size__c = 2500, TC_Lease_Rate__c = 30, TC_Escalation__c = 3,
            TC_Commencement_Date__c = commencement, TC_Expiration_Date__c = commencement.addMonths(months).addDays(-1)
        );
    }

    public static TC_Availability__c availability(Id propertyId, Id unitId, Id listingId) {
        TC_Availability__c a = new TC_Availability__c(TC_Property__c = propertyId, TC_Unit__c = unitId, TC_Listing__c = listingId,
            TC_Availability_Type__c = 'Direct', TC_Status__c = 'Available', TC_Size__c = 2500, TC_Lease_Rate__c = 32, TC_Rent_Type__c = 'NNN');
        insert a;
        return a;
    }

    public static TC_Listing__c listing(Id propertyId, String recordTypeDev, String status) {
        TC_Listing__c l = new TC_Listing__c(Name = 'Test Listing', TC_Property__c = propertyId, RecordTypeId = rt(TC_Listing__c.SObjectType, recordTypeDev),
            TC_Status__c = status, TC_Asking_Rate__c = 32, TC_Asking_Price__c = 25000000, TC_Listing_Date__c = Date.today().addDays(-30),
            TC_Expiration_Date__c = Date.today().addMonths(6));
        insert l;
        return l;
    }

    public static TC_Deal__c buildLeaseDeal(Id clientId, Id propertyId) {
        return new TC_Deal__c(
            Name = 'Test Tenant Rep Deal', RecordTypeId = rt(TC_Deal__c.SObjectType, 'TC_Tenant_Representation'),
            TC_Client__c = clientId, TC_Property__c = propertyId, TC_Stage__c = 'Prospect', TC_Status__c = 'Open',
            TC_Size__c = 5000, TC_Lease_Rate__c = 30, TC_Escalation__c = 3, TC_Lease_Commencement__c = Date.today().addMonths(1).toStartOfMonth(),
            TC_Lease_Expiration__c = Date.today().addMonths(1).toStartOfMonth().addYears(5).addDays(-1),
            TC_Gross_Fee_Method__c = 'Percent', TC_Gross_Fee_Percent__c = 4, TC_Est_Close_Date__c = Date.today().addDays(60)
        );
    }

    public static TC_Deal__c buildSaleDeal(Id clientId, Id propertyId, String recordTypeDev) {
        return new TC_Deal__c(
            Name = 'Test Sale Deal', RecordTypeId = rt(TC_Deal__c.SObjectType, recordTypeDev), TC_Client__c = clientId,
            TC_Property__c = propertyId, TC_Stage__c = 'LOI', TC_Status__c = 'Open', TC_Sale_Price__c = 20000000,
            TC_Listing_Price__c = 21000000, TC_Size__c = 100000, TC_Gross_Fee_Method__c = 'Percent', TC_Gross_Fee_Percent__c = 3,
            TC_Est_Close_Date__c = Date.today().addDays(30)
        );
    }

    public static TC_Commission__c buildCommission(Id dealId, String recordTypeDev, Decimal pct) {
        TC_Commission__c c = new TC_Commission__c(TC_Deal__c = dealId, RecordTypeId = rt(TC_Commission__c.SObjectType, recordTypeDev),
            TC_Fee_Method__c = 'Percent', TC_Fee_Percent__c = pct);
        if (recordTypeDev == 'TC_Inside_Broker') {
            c.TC_Broker__c = UserInfo.getUserId();
            c.TC_House_Fee_Percent__c = 30;
        } else {
            c.TC_Account__c = [SELECT Id FROM Account LIMIT 1].Id;
        }
        return c;
    }

    /** A user with the TC CRE Broker permission set (for permission tests). */
    public static User brokerUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String unique = String.valueOf(Crypto.getRandomInteger()).replace('-', '');
        User u = new User(Alias = 'tcbrk', Email = 'tc.broker' + unique + '@example.com', EmailEncodingKey = 'UTF-8', LastName = 'Broker',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'tc.broker' + unique + '@example.com.tctest');
        insert u;
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name = 'TC_CRE_Broker'].Id);
        return u;
    }
}
