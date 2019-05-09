@isTest public class CaseAutomaticAssignmentUtilsTest {

    @isTest static void gets_all_data_entry_users() {
        List<DealAutomaticUserGroup> result = CaseAutomaticAssignmentUtils.getAllDataEntryUsers();

        System.assert(result.size() > 0);
        System.assertNotEquals(null, result);
    }

    @isTest static void gets_all_customer_service_users() {
        List<DealAutomaticUserGroup> result = CaseAutomaticAssignmentUtils.getAllCustomerServiceUsers();

        System.assert(result.size() > 0);
        System.assertNotEquals(null, result);
    }

    @isTest static void gets_online_data_entry_users() {
        List<DealAutomaticUserGroup> result = CaseAutomaticAssignmentUtils.getOnlineDataEntryUsers();

        System.assert(result.size() > 0);
        System.assertNotEquals(null, result);
    }

    @isTest static void gets_online_customer_service_users() {
        List<DealAutomaticUserGroup> result = CaseAutomaticAssignmentUtils.getOnlineCustomerServiceUsers();

        System.assert(result.size() > 0);
        System.assertNotEquals(null, result);
    }

    @isTest static void gets_total_assigned_cases() {
        List<DealAutomaticUserGroup> userList = CaseAutomaticAssignmentUtils.getOnlineDataEntryUsers();
        Case newCase = new Case();
        newCase.Description = 'something to test test@lendingpoint.com test test test test258@mycompany.com test test test';
        newCase.SuppliedEmail = 'test@test.com';
        newCase.Origin = 'Email';
        newCase.Status = 'New';
        newCase.OwnerId = userList[0].userid;
        upsert newCase;
        Map<Id, Integer> result = CaseAutomaticAssignmentUtils.getTotalAssignedCases(userList);

        System.assert(result.values().size() > 0, 'No totals returned');
        System.assertNotEquals(null, result);
    }

    @isTest static void gets_next_data_entry_user_for_case() {
        Case newCase = new Case();
        newCase.Description = 'something to test test@lendingpoint.com test test test test258@mycompany.com test test test';
        newCase.SuppliedEmail = 'test@test.com';

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextDataEntryUserForCase(newCase);

        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.userId);

    }


    @isTest static void gets_next_customer_service_user_for_case() {
        Case newCase = new Case();
        newCase.Description = 'something to test test@lendingpoint.com test test test test258@mycompany.com test test test';
        newCase.SuppliedEmail = 'test@test.com';

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextCustomerServiceUserForCase(newCase);

        System.assertNotEquals(null, result);
        System.assertNotEquals(null, result.userId);
    }


    @isTest static void gets_Next_Collection_User_for_case() {

        Case newcase2 = new Case();
        newcase2.Description = 'APP-0002556353 Case Assigment Statements provided';
        newcase2.SuppliedEmail = 'customersuccess12@lendingpoint.com';
        newcase2.Subject = 'APP-0002556353 - Statements Available';
        insert newcase2;

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextCollectionUserForCase(newcase2, 0);

        CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId);

        System.assert(true, CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId));


    }

    @isTest static void Verify_Owner_Into_GroupById() {

        Case newcase2 = new Case();
        newcase2.Description = 'APP-0002556353 Case Assigment Statements provided';
        newcase2.SuppliedEmail = 'customersuccess12@lendingpoint.com';
        newcase2.Subject = 'APP-0002556353 - Statements Available';
        insert newcase2;

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextCustomerServiceUserForCase(newcase2);

        CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId);

        System.assert(true, CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId));
    }

    @isTest static void case_ItGroup() {

        Case newcase2 = new Case();
        newcase2.Description = 'APP-0002556353 Case Assigment Statements provided';
        newcase2.SuppliedEmail = 'customersuccess12@lendingpoint.com';
        newcase2.Subject = 'APP-0002556353 - Statements Available';
        insert newcase2;

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextCollectionITUserForCase(newcase2);

        CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId);

        System.assert(true, CaseAutomaticAssignmentUtils.checkOwnerExistanceIntoGroupById(result.userId));
    }

    @isTest static void assignUserByOverduedaysBucket(){

        loan__loan_Account__c cnt = LibraryTest.CreateContractTH();
        cnt.loan__Oldest_Due_Date__c = Date.today().adddays(-1);
        update cnt;

        Case newcase = new case();
        newcase.Description = 'Collection case has been created';
        newcase.Origin = 'Collection';
        newcase.CL_Contract__c = cnt.Id;
        newcase.Status = 'Recovered';
        insert newcase;


        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextCollectionITUserForCase(newcase);

        CaseAutomaticAssignmentUtils.checkOwnerExistanceInto1to29CollectionGroupById(result.userId);

        CaseAutomaticAssignmentUtils.assignUserByOverduedaysBucket(newcase.CL_Contract__c, 1);

        CaseAutomaticAssignmentUtils.closeAnyCasesByLoan(newcase.CL_Contract__c);

        Id ownerBefore = newcase.OwnerId;
        CaseAutomaticAssignmentUtils.assignUserByOverduedaysBucket(newcase.CL_Contract__c, 1, newcase);

        newcase = [Select Id, ownerId FROM Case where Id =: newcase.Id Limit 1];

        System.assertNotEquals(newcase.OwnerId, Null);
        System.assertNotEquals(ownerBefore,newcase.OwnerId);

    }

    @isTest static void closeAnyCasesByLoan(){

        loan__loan_Account__c cnt = LibraryTest.CreateContractTH();
        cnt.loan__Oldest_Due_Date__c = Date.today().adddays(-1);
        update cnt;

        Case newcase = new case();
        newcase.Description = 'Collection case has been created';
        newcase.Origin = 'Collection';
        newcase.CL_Contract__c = cnt.Id;
        insert newcase;

        CaseAutomaticAssignmentUtils.closeAnyCasesByLoan(newcase.CL_Contract__c);

    }

    @isTest static void getNextLPMSUserForCaseTest(){

        loan__loan_Account__c cnt = LibraryTest.CreateContractTH();
        cnt.loan__Oldest_Due_Date__c = Date.today().adddays(-1);
        update cnt;

        Case newcase = new case();
        newcase.Description = 'Next LMP User';
        newcase.Origin = 'Collection';
        newcase.CL_Contract__c = cnt.Id;
        insert newcase;

        CaseAutomaticAssignmentUtils.getNextLPMSUserForCase(newcase);

    }

    @isTest static void case_EzVerifyFS_Group() {

        Case newcase2 = new Case();
        newcase2.Description = 'This Opportunity has been sent to Credit Review. Please reach out the applicant immediately to resolve.Opportunity # APP-0005767802Customer Name:  Tom PerkinsCustomer Phone:';
        newcase2.Subject = 'Credit Review - Opportunity # APP-0005767802';
        insert newcase2;

        DealAutomaticUserGroup result = CaseAutomaticAssignmentUtils.getNextEzVerifyFSUserForCase(newcase2);

        System.assertNotEquals(null, result);
        System.assertEquals(true, result.isOnline);
    }

}
