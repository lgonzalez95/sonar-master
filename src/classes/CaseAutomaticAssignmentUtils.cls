public class CaseAutomaticAssignmentUtils {

    private static final String DATA_ENTRY_GROUP = 'DataEntryGroup';
    private static final String CUSTOMER_SERVICE_GROUP = 'CustomerServiceGroup';
    private static final String COLLECTION_GROUP = 'CollectionGroup';
    public static final String COLLECTION_GROUP_From1to29 = 'CollectionGroupFrom1to29';
    public static final String COLLECTION_GROUP_From30to59 = 'CollectionGroupFrom30to59';
    public static final String COLLECTION_GROUP_From60to119 = 'CollectionGroupFrom60to119';
    private static final String Collection_IT_Group = 'CollectionITGroup';
    private static final String LPMS_Customer_Service_Group = 'LPMS_Welcome';
    private static final String EZVERIFY_FS_Group = 'EzVerify_FS_Group';

public void t(){


}

string sdhjbjsq;

    /**
     * Get all the data entry users for the Data Entry tab in Deal Automatic Assignment
     * @return [description]
     */
    public static List < DealAutomaticUserGroup > getAllDataEntryUsers() {

        return getAllUsers(DATA_ENTRY_GROUP);
    }

        public static List < DealAutomaticUserGroup > getAllDataEntryUsers() {

        return getAllUsers(DATA_ENTRY_GROUP);
    }
        public static List < DealAutomaticUserGroup > getAllDataEntryUsers() {

        return getAllUsers(DATA_ENTRY_GROUP);
    }

    public static List < DealAutomaticUserGroup > getAllCustomerServiceUsers() {

        return getAllUsers(CUSTOMER_SERVICE_GROUP);
    

    public static List < DealAutomaticUserGroup > getAllUsers(String groupName) {

        String GroupId = '';

        if (groupName.equalsIgnoreCase(DATA_ENTRY_GROUP)) {
            GroupId = Label.DataEntry_Group_Id;
        } else if (groupName.equalsIgnoreCase(CUSTOMER_SERVICE_GROUP)) {
            GroupId = Label.Customer_Service_Group_Id;
        } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP)) {
            GroupId = Label.Collections_Group_Id;
        } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From1to29)) {
            GroupId = Label.CollectionGroup_From1to29_Id;
        } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From30to59)) {
            GroupId = Label.CollectionGroup_From30to59_Id;
        } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From60to119)) {
            GroupId = Label.CollectionGroup_From60to119_Id;
        } else if (groupName.equalsIgnoreCase(CollectionsCasesAssignmentUsersStructure.COLLECTION_GROUP_From60plus)) {
            GroupId = Label.COLLECTION_GROUP_FROM_60_PLUS;
        } else if (groupName.equalsIgnoreCase(CollectionsCasesAssignmentUsersStructure.DMC_1_TO_29)) {
            GroupId = Label.DMC_1_TO_29;
        }else if (groupName.equalsIgnoreCase(CollectionsCasesAssignmentUsersStructure.DMC_30_TO_59)) {
            GroupId = Label.DMC_30_TO_59;
        }else if (groupName.equalsIgnoreCase(CollectionsCasesAssignmentUsersStructure.DMC_60_PLUS)) {
            GroupId = Label.DMC_60_PLUS;
        }else if (groupName.equalsIgnoreCase(CollectionsCasesAssignmentUsersStructure.LMS_GROUP)) {
            GroupId = Label.COLLECTION_LMS_GROUP;
        }else if (groupName.equalsIgnoreCase(Collection_IT_Group)) {
            GroupId = Label.CollectionITGroup;
        } else if (groupName.equalsIgnoreCase(LPMS_Customer_Service_Group)) {
            GroupId = Label.LPMSGroup_id;
        } else if (groupName.equalsIgnoreCase(EZVERIFY_FS_Group)) {
            GroupId = Label.EzVerifyFSGroup_Id;
        } else {
            GroupId = Label.DataEntry_Group_Id;
        }

        List < GroupMember > dataEntries = [SELECT Id, UserOrGroupId, GroupId
        FROM GroupMember
        WHERE GroupId =: GroupId
        ];

        List < DealAutomaticUserGroup > userGroup = new List < DealAutomaticUserGroup > ();

        Set < Id > userIds = new Set < Id > ();

        for (GroupMember member: dataEntries) {
            userIds.add(member.UserOrGroupId);
        }

        Map < Id, User > userMap = new Map < Id, User > (
        [SELECT Id, Name, isOnline__c
        FROM User
        WHERE Id In: userIds
        AND IsActive = true
        ]);

        for (GroupMember member: dataEntries) {
            if (userMap.containsKey(member.UserOrGroupId)) {

                userGroup.add(new DealAutomaticUserGroup(userMap.get(member.UserOrGroupId).Id,
                        userMap.get(member.UserOrGroupId).Name,
                        member.GroupId,
                        groupName,
                        false,
                        userMap.get(member.UserOrGroupId).isOnline__c));
            }
        }

        return userGroup;
    }

    /**
     * Get only the current data entry online users to assigned the cases
     * @return [description]
     */
    public static List < DealAutomaticUserGroup > getOnlineDataEntryUsers() {

        return getOnlineUsers(DATA_ENTRY_GROUP);
    }

    /**
     * Get only the current customer service online users to assigned the cases
     * @return [description]
     */
    public static List < DealAutomaticUserGroup > getOnlineCustomerServiceUsers() {

        return getOnlineUsers(CUSTOMER_SERVICE_GROUP);
    }

    private static List < DealAutomaticUserGroup > getOnlineUsers(String groupName) {

        List < DealAutomaticUserGroup > result = new List < DealAutomaticUserGroup > ();
        List < DealAutomaticUserGroup > userGroupList = getAllUsers(groupName);

        for (DealAutomaticUserGroup user: userGroupList) {
            if (user.isOnline) result.add(user);
        }

        return result;
    }

    /**
     * [getTotalAssignedCases description]
     * @param  userGroupList [description]
     * @return               [description]
     */
    public static Map < Id, Integer > getTotalAssignedCases(List < DealAutomaticUserGroup > userGroupList) {

        Map < Id, Integer > result = new Map < Id, Integer > ();
        Set<Id> users = new Set<Id>();
        for (DealAutomaticUserGroup currentUser: userGroupList) {
            users.add(currentUser.UserId);
        }

        List < AggregateResult > totals = [SELECT OwnerId, COUNT(id) total
        FROM Case
        WHERE OwnerId IN: users
        AND Origin = 'Email'
        AND Status
                IN('New', 'Working')
        Group by OwnerId
        ];

        for (AggregateResult ar : totals) {
            result.put( (Id) ar.get('OwnerId'), (Integer) ar.get('total'));
        }

        return result;
    }

    public static Map < Id, Integer > getTotalAssignedCollectionCases(List < DealAutomaticUserGroup > userGroupList) {

        Map < Id, Integer > result = new Map < Id, Integer > ();
        Set<Id> users = new Set<Id>();
        for (DealAutomaticUserGroup currentUser: userGroupList) {
            users.add(currentUser.UserId);
        }

        List < AggregateResult > totals = [SELECT OwnerId, COUNT(id) total, Max(LastModifiedDate) LastDate
        FROM Case
        WHERE OwnerId IN: users
        AND Overdue_Days__c > 0
        AND RecordTypeId =: Label.RecordType_Collections_Id
        AND Status NOT IN('Canceled')
        Group by OwnerId
        order by Max(LastModifiedDate) asc
        ];

        for (AggregateResult ar : totals) {
            result.put( (Id) ar.get('OwnerId'), (Integer) ar.get('total'));
        }

        return result;
    }

    public static DealAutomaticUserGroup getNextDataEntryUserForCase(Case newCase) {

        return getNextUserForCase(newCase, DATA_ENTRY_GROUP);
    }

    public static DealAutomaticUserGroup getNextCustomerServiceUserForCase(Case newCase) {

        return getNextUserForCase(newCase, CUSTOMER_SERVICE_GROUP);
    }

    public static String getCollectionGroupName(decimal upTo) {
        if (upTo == null) upTo = 0;
        if (upTo > 0 && upTo <= 29)
            return  COLLECTION_GROUP_From1to29;
        if (upTo >= 30 && upTo <= 59)
            return  COLLECTION_GROUP_From30to59;
        if (upTo >= 60 && upTo <= 119)
            return COLLECTION_GROUP_From60to119;

        return COLLECTION_GROUP;

    }

    public static DealAutomaticUserGroup getNextCollectionUserForCase(Case newCase, decimal upTo) {

        return getNextUserForCase(newCase, getCollectionGroupName(upTo));
    }

    public static DealAutomaticUserGroup getNextLPMSUserForCase(Case newCase) {

        return getNextUserForCase(newCase, LPMS_Customer_Service_Group);
    }

    public static DealAutomaticUserGroup getNextCollectionITUserForCase(Case newCase) {

        return getNextUserForCase(newCase, Collection_IT_Group);
    }

    public static DealAutomaticUserGroup getNextEzVerifyFSUserForCase(Case newCase) {

        return getNextUserForCase(newCase, EZVERIFY_FS_Group);
    }

    /**
     * [getNextUserForCase description]
     * @param  newCase [description]
     * @return         [description]
     */
    private static DealAutomaticUserGroup getNextUserForCase(Case newCase, String groupName) {

        List < DealAutomaticUserGroup > userGroupList = getOnlineUsers(groupName), existUserGr = new  List<DealAutomaticUserGroup>();
        Map < Id, Integer > userTotalMap = null;
        if (groupName == COLLECTION_GROUP || groupName == COLLECTION_GROUP_From1to29 || groupName == COLLECTION_GROUP_From30to59 || groupName == COLLECTION_GROUP_From60to119)
            userTotalMap = getTotalAssignedCollectionCases(userGroupList);
        else
            userTotalMap = getTotalAssignedCases(userGroupList);

        DealAutomaticUserGroup result = new DealAutomaticUserGroup(), existinG = null;
        if (newCase != null) {

            for (DealAutomaticUserGroup dg : userGroupList) {
                if (dg.Userid == newCase.OwnerId) {
                    existinG = dg;
                    break;
                }
            }

            if (groupName.equalsIgnoreCase(DATA_ENTRY_GROUP)) {

                if (newCase.Opportunity__c != null) {
                    Opportunity app = [SELECT Id, DE_Assigned_To_Doc__c FROM Opportunity WHERE Id =: newCase.Opportunity__c LIMIT 1];

                    if (!String.isEmpty(app.DE_Assigned_To_Doc__c)) {
                        result = AutomaticAssignmentUtils.getUserFromGroupByName(app.DE_Assigned_To_Doc__c, userGroupList);
                    }
                }

                if (result == null || result.userId == null)
                    result = AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(CUSTOMER_SERVICE_GROUP)) {

                result = AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP)) {

                result = existinG != null ? existinG : AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From1to29)) {

                result = existinG != null ? existinG : AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From30to59)) {

                result = existinG != null ? existinG : AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(COLLECTION_GROUP_From60to119)) {

                result = existinG != null ? existinG : AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(Collection_IT_Group)) {
                result = AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(LPMS_Customer_Service_Group)) {
                result = AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);

            } else if (groupName.equalsIgnoreCase(EZVERIFY_FS_Group)) {
                result = AutomaticAssignmentUtils.getNextUser(userTotalMap, userGroupList);
            }
        }

        return result;
    }

    public static Boolean checkOwnerExistanceIntoGroupById(String userId) {
        List < DealAutomaticUserGroup > allUsers = getAllUsers(DATA_ENTRY_GROUP);
        for (DealAutomaticUserGroup user: allUsers) {
            if (userId == user.userId)
                return true;
        }
        allUsers = getAllUsers(CUSTOMER_SERVICE_GROUP);
        for (DealAutomaticUserGroup user: allUsers) {
            if (userId == user.userId)
                return true;
        }
        return false;
    }

    public static Boolean checkOwnerExistanceInto1to29CollectionGroupById(String userId) {
        return checkOwnerExistanceInGroupById(userId, COLLECTION_GROUP_From1to29) ;
    }

    public static Boolean checkOwnerExistanceInGroupById(String userId, String groupName) {
        List < DealAutomaticUserGroup > allUsers = getAllUsers(groupName);
        for (DealAutomaticUserGroup user: allUsers) {
            if (userId == user.userId)
                return true;
        }
        return false;
    }

    public static void assignUserByOverduedaysBucket(String contractId, Decimal dueDays, Case theCase) {
        try {
            Boolean needUpdate = false;
            if (theCase != null) {

                if (dueDays == 1 || theCase.IsClosed) {
                    needUpdate = false;
                    if (theCase.isClosed){
                        for (CaseHistory csh : [SELECT Id, CaseId, Field, OldValue, NewValue
                        FROM CaseHistory
                        WHERE CaseId =: theCase.Id
                        AND Field = 'Status'
                        ORDER BY CreatedDate DESC
                        LIMIT 1 ]){
                            theCase.Status = String.valueOf(csh.OldValue);
                        }
                        needUpdate = true;
                    }

                }
                Id newOwner = getNextCollectionUserForCase(theCase, dueDays).userId;
                if (theCase.OwnerId != newOwner) {theCase.OwnerId = newOwner; needUpdate = true;}

                if (needUpdate) upsert theCase;
            }
        } catch (Exception e) {}
    }

    public static void assignUserByOverduedaysBucket(String contractId, Decimal dueDays){
        try {
            for (case cs : [SELECT Id, OwnerId, Status, isClosed
            FROM Case
            WHERE CL_Contract__c =: contractId
            AND RecordTypeId =: Label.RecordType_Collections_Id
            ORDER BY CreatedDate DESC
            LIMIT 1]){
                assignUserByOverduedaysBucket(contractid, dueDays, cs);
            }
        } catch (Exception e) {}
    }

    public static void closeAnyCasesByLoan(String contractId){

        List<Case> caseListToUpsert = new List<Case>();

        for (case cs : [SELECT Id, Status
        FROM Case
        WHERE CL_Contract__c =: contractId
        AND RecordTypeId =: Label.RecordType_Collections_Id
        AND isClosed = false]){

            cs.Status = 'Recovered';
            caseListToUpsert.add(cs);
        }

        if (caseListToUpsert.size() > 0) upsert caseListToUpsert;
    }
}