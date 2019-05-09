public class testT{
      public Void addLocation(Account objAccount) {
        Locations objLocation = new Locations();
        objLocation.accountId = objAccount.Id;
        objLocation.phone = objAccount.Phone;
        locationList.add(objLocation);
    }
}
