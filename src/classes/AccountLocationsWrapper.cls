public class AccountLocationsWrapper {
        
    public List<Locations> locationList {get;set;}
    public boolean success {get;set;}
    public String message {get;set;}
    public string totalCount{get;set;}
     
    public class Locations {
        public String accountId;
        public String accountName;
        public String subSource;
        public String source;
        public String subProvider;
        public String phone;
        public String zipCode; //MER-134
    }   
    
    public AccountLocationsWrapper() {
        locationList = new List<Locations>();
    } 

    public Void addLocation(Account objAccount) {
        Locations objLocation = new Locations();
        objLocation.accountId = objAccount.Id;
        objLocation.phone = objAccount.Phone;
        locationList.add(objLocation);
    }
}