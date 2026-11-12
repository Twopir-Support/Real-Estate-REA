/**
 * Visualforce controller for the TC PDF documents (AscendixRE Composer equivalents):
 *  - TC_Property_Flyer: a property (or listing's property) with its available spaces
 *  - TC_Lease_Comp_Report: active and recent leases at a property, as lease comps
 *  - TC_Tour_Book: the listings proposed to an inquiry (prospective listings), one page each
 */
public with sharing class TC_DocumentController {
    public TC_Property__c property { get; private set; }
    public TC_Listing__c listing { get; private set; }
    public List<TC_Availability__c> spaces { get; private set; }
    public List<TC_Lease__c> leases { get; private set; }
    public TC_Inquiry__c inquiry { get; private set; }
    public List<TourStop> stops { get; private set; }
    public String generatedOn { get; private set; }
    public String company { get; private set; }

    public class TourStop {
        public Integer stopNumber { get; set; }
        public TC_Listing__c listing { get; set; }
        public TC_Property__c property { get; set; }
        public String notes { get; set; }
    }

    public TC_DocumentController() {
        generatedOn = Date.today().format();
        company = UserInfo.getOrganizationName();
        Id recordId = (Id) ApexPages.currentPage().getParameters().get('id');
        spaces = new List<TC_Availability__c>();
        leases = new List<TC_Lease__c>();
        stops = new List<TourStop>();
        if (recordId == null) {
            return;
        }
        SObjectType t = recordId.getSObjectType();
        Id propertyId;
        if (t == TC_Listing__c.SObjectType) {
            listing = [SELECT Id, Name, RecordType.Name, TC_Asking_Rate__c, TC_Asking_Price__c, TC_Rent_Type__c, TC_Description__c, TC_Property__c,
                              TC_Listing_Broker_Contact__r.Name, TC_Listing_Broker_Contact__r.Email, TC_Listing_Broker_Contact__r.Phone
                       FROM TC_Listing__c WHERE Id = :recordId WITH USER_MODE];
            propertyId = listing.TC_Property__c;
        } else if (t == TC_Property__c.SObjectType) {
            propertyId = recordId;
        } else if (t == TC_Inquiry__c.SObjectType) {
            loadTour(recordId);
        }
        if (propertyId != null) {
            property = loadProperty(propertyId);
            spaces = [SELECT Name, TC_Unit_Name__c, TC_Floor__c, TC_Size__c, TC_Lease_Rate__c, TC_Rent_Type__c, TC_Date_Available__c, TC_Availability_Type__c
                      FROM TC_Availability__c WHERE TC_Property__c = :propertyId AND TC_Status__c = 'Available' WITH USER_MODE ORDER BY TC_Floor__c, TC_Unit_Name__c];
            leases = [SELECT Name, TC_Tenant__r.Name, TC_Unit_Name__c, TC_Floor__c, TC_Size__c, TC_Lease_Rate__c, TC_Lease_Type__c, TC_Commencement_Date__c,
                             TC_Expiration_Date__c, TC_Term_Months__c, TC_Free_Rent_Months__c, TC_TI_Allowance__c, TC_Status__c
                      FROM TC_Lease__c WHERE TC_Property__c = :propertyId AND TC_Status__c IN ('Active', 'Holdover', 'Expired') WITH USER_MODE
                      ORDER BY TC_Commencement_Date__c DESC LIMIT 50];
        }
    }

    private static TC_Property__c loadProperty(Id propertyId) {
        return [SELECT Id, Name, TC_Property_Type__c, TC_Property_Subtype__c, TC_Building_Class__c, TC_Full_Address__c, TC_Market__c, TC_Submarket__c,
                       TC_Total_Size__c, TC_Number_of_Floors__c, TC_Year_Built__c, TC_Year_Renovated__c, TC_Parking_Spaces__c, TC_Available_SF__c,
                       TC_Occupancy__c, TC_Avg_Asking_Rate__c, TC_Description__c, TC_Location_Description__c, TC_Primary_Image_URL__c, TC_Owner_Landlord__r.Name
                FROM TC_Property__c WHERE Id = :propertyId WITH USER_MODE];
    }

    private void loadTour(Id inquiryId) {
        inquiry = [SELECT Id, Name, TC_First_Name__c, TC_Last_Name__c, TC_Company_Name__c, TC_Company__r.Name, TC_Inquiry_Type__c, TC_Size_Min__c, TC_Size_Max__c, TC_Max_Rate__c, TC_Date_Needed__c
                   FROM TC_Inquiry__c WHERE Id = :inquiryId WITH USER_MODE];
        List<TC_Prospective_Listing__c> pls = [SELECT TC_Listing__c, TC_Description__c FROM TC_Prospective_Listing__c WHERE TC_Inquiry__c = :inquiryId AND TC_Status__c != 'Not Interested'
                                               WITH USER_MODE ORDER BY TC_Primary__c DESC, TC_Match_Score__c DESC NULLS LAST LIMIT 12];
        Set<Id> listingIds = new Set<Id>();
        for (TC_Prospective_Listing__c pl : pls) { listingIds.add(pl.TC_Listing__c); }
        Map<Id, TC_Listing__c> listings = new Map<Id, TC_Listing__c>([SELECT Id, Name, RecordType.Name, TC_Asking_Rate__c, TC_Asking_Price__c, TC_Rent_Type__c, TC_Total_Available_SF__c, TC_Property__c FROM TC_Listing__c WHERE Id IN :listingIds WITH USER_MODE]);
        Set<Id> propIds = new Set<Id>();
        for (TC_Listing__c l : listings.values()) { propIds.add(l.TC_Property__c); }
        Map<Id, TC_Property__c> props = new Map<Id, TC_Property__c>([SELECT Id, Name, TC_Property_Type__c, TC_Building_Class__c, TC_Full_Address__c, TC_Submarket__c, TC_Total_Size__c, TC_Year_Built__c, TC_Primary_Image_URL__c, TC_Description__c FROM TC_Property__c WHERE Id IN :propIds WITH USER_MODE]);
        Integer n = 1;
        for (TC_Prospective_Listing__c pl : pls) {
            TC_Listing__c l = listings.get(pl.TC_Listing__c);
            if (l == null) { continue; }
            TourStop s = new TourStop();
            s.stopNumber = n++;
            s.listing = l;
            s.property = props.get(l.TC_Property__c);
            s.notes = pl.TC_Description__c;
            stops.add(s);
        }
    }
}
