global class  BatchCollectionCases  implements Database.Batchable<sObject>,Schedulable, Database.Stateful{

    global Integer count = 0, iRecovered = 0, iAssigned = 0 ;

    
    public void execute(SchedulableContext sc) { 
       BatchCollectionCases  batchapex = new BatchCollectionCases();
       id batchprocessid = Database.executebatch(batchapex,10);
       system.debug('Process ID: ' + batchprocessid);
    }   

     global Database.QueryLocator start(Database.BatchableContext BC){    
       String status1 = 'Active - Marked for Closure', status2 = 'Closed - Obligations met', status3 = 'Closed- Written Off', status4 = 'Canceled';               
       String query = 'SELECT Id, loan__Contact__r.Work_Phone_Number__c, loan__OT_ACH_Debit_Date__c, loan__Oldest_Due_Date__c, Overdue_Days__c, loan_Active_Payment_Plan__c, DMC__c FROM loan__Loan_Account__c WHERE ' +
                       ' ((Overdue_Days__c >=1 AND Overdue_Days__c < 90) OR (Overdue_Days__c = 0 AND ' +
                       ' Collection_Case_Owner__r.Name != \'HAL\' AND Collection_Case_Owner__c != null ) ) ' +
                        'AND loan__Loan_Status__c NOT IN (: status1 ,: status2 ,: status3, : status4 ) AND Charge_Off_Sold_To__c = null AND Outside_Collection_Agency__c = null AND Is_Payment_Pending__c = false AND loan_Active_Payment_Plan__c = false ';
       System.debug('Query = ' + query);

       return Database.getQueryLocator(query);
    }

    public BatchCollectionCases() {

    }

    global void execute(Database.BatchableContext BC, List<loan__Loan_Account__c > scope){
        Map<String, Object> myMap = new Map<String, Object>();
        Set<Id> loans = new Set<id>(), casesUpdated = new Set<id>(), loansToUpdate = new Set<id>();
        for(loan__loan_Account__c CL : scope){
            loans.add(CL.id);
        }
        Id theOwner = [Select Id from User where LastName = 'HAL' LIMIT 1].Id;
        List < DealAutomaticUserGroup > userGroupList1_29 = CaseAutomaticAssignmentUtils.getAllUsers(CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From1to29) ;
        List < DealAutomaticUserGroup > userGroupList30_59 = CaseAutomaticAssignmentUtils.getAllUsers(CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From30to59) ;
        List < DealAutomaticUserGroup > userGroupList60_119 = CaseAutomaticAssignmentUtils.getAllUsers(CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From60to119) ;
        List<Case> cToUpdate = new List<Case>();
        Map<Id, loan__Loan_Account__c> loansUpdted = new   Map<Id, loan__Loan_Account__c>();
            
        List<loan_Plan_Payment__c> plans = [SELECT Id, Loan_Account__c, CreatedById FROM loan_Plan_Payment__c WHERE Loan_Account__c IN :loans];
        List<Case> css =  [SELECT Id, OwnerId, Status, isClosed, CreatedById, CL_Contract__c
                            FROM Case
                            WHERE CL_Contract__c in : loans
                            AND RecordTypeId =: Label.RecordType_Collections_Id
                            ORDER BY CreatedDate DESC  ] ;
        
        List<loan__Loan_Account__History> history = [ select ParentID, CreatedDate
                                                from loan__Loan_Account__History 
                                                where Field = 'loan__OT_ACH_Debit_Date__c' and
                                                    ParentId in : loans
                                                order by CreatedDate asc];


        for(loan__loan_Account__c CL : scope){
            String currentGroup = '';
            DateTime lastOTDate = null;
            Case theC = null;

            count++;
            loan_Plan_Payment__c thePlan = null;
            for (Case ca : css) {
                if (ca.CL_Contract__c == CL.Id) {
                    theC = ca;
                    break;
                }
            }
            for (loan__Loan_Account__History his : history){
                if (his.ParentId == CL.ID && (lastOTDate == null || lastOTDate < his.CreatedDate )) lastOTDate = his.CreatedDate;
            }

            for (loan_Plan_Payment__c plan : plans){
                if (plan.Loan_Account__c == CL.Id) {
                    thePlan = plan;
                    break;
                }
            }
            
            for (DealAutomaticUserGroup ug : userGroupList1_29) {
                if (theC != null && theC.OwnerId == ug.Userid ) currentGroup = CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From1to29;
            }
            for (DealAutomaticUserGroup ug : userGroupList30_59) {
                if (theC != null && theC.OwnerId == ug.Userid ) currentGroup = CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From30to59;
            }
            for (DealAutomaticUserGroup ug : userGroupList60_119) {
                if (theC != null && theC.OwnerId == ug.Userid ) currentGroup = CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From60to119;
            }

            if (theC != null && CL.Overdue_Days__c == 0) {
                theC.OwnerId = theOwner; iRecovered++;
                loansToUpdate.add(CL.Id);
                cToUpdate.add(theC);
            } else  if (!string.IsBlank(CL.DMC__c) && CL.Overdue_Days__c  > 0){
                if (theC == null) {
                    myMap.put('CLContractId',CL.Id);
                    myMap.put('EmployerPhoneNumber',CL.loan__Contact__r.Work_Phone_Number__c);
                    Flow.Interview.Collection_Case_Creation myFlow = new Flow.Interview.Collection_Case_Creation(myMap);
                    myFlow.start();
                
                    for (Case c : [SELECT Id, OwnerId, Status, isClosed, CreatedById, CL_Contract__c  FROM Case                             WHERE CL_Contract__c = : CL.Id  AND RecordTypeId =: Label.RecordType_Collections_Id ORDER BY CreatedDate DESC LIMIT 1  ] ) {
                        theC = c;
                    }
                    iAssigned++;
                } else 
	                CaseAutomaticAssignmentUtils.assignUserByOverduedaysBucket(CL.Id, 60, theC); // Keep on 60
                loansToUpdate.add(CL.Id);
            } else if (CL.Overdue_Days__c  > 0 && (CL.loan__OT_ACH_Debit_Date__c == null || lastOTDate == null || Date.Today().DaysBetween(lastOTDate.date()) * -1 < CL.Overdue_Days__c ) ) { 
                if (theC == null ) {
                    myMap.put('CLContractId',CL.Id);
                    myMap.put('EmployerPhoneNumber',CL.loan__Contact__r.Work_Phone_Number__c);
                    Flow.Interview.Collection_Case_Creation myFlow = new Flow.Interview.Collection_Case_Creation(myMap);
                    myFlow.start();
                    loansToUpdate.add(CL.Id);
                    iAssigned++;
                }  else if (
                    (
                        (currentGroup == CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From1to29 && CL.Overdue_Days__c > 29) ||
                        (currentGroup == CaseAutomaticAssignmentUtils.COLLECTION_GROUP_From30to59 && CL.Overdue_Days__c > 59) ||
                        String.isEmpty(currentGroup)
                    )
                )  {
                     CaseAutomaticAssignmentUtils.assignUserByOverduedaysBucket(CL.Id, CL.Overdue_Days__c, theC);             
                     loansToUpdate.add(CL.Id);
                     iAssigned++;
                } else if (String.isNotEmpty(currentGroup))  {
                            loansToUpdate.add(CL.Id);
                } 
            }
            myMap.clear();

        }

        if (cToUpdate.size() > 0) update cToUpdate;
        for (Case c : cToUpdate) {
            casesUpdated.add(c.Id);
        }

        css =  [SELECT Id, OwnerId, CL_Contract__c
                            FROM Case
                            WHERE CL_Contract__c in : loansToUpdate
                            AND RecordTypeId =: Label.RecordType_Collections_Id 
                            ORDER BY CreatedDate DESC  ] ;

        for (Case c : css ) {
            if (!loansUpdted.containsKey(c.CL_Contract__c)) loansUpdted.put(c.CL_Contract__c, new loan__Loan_Account__c(id = c.CL_Contract__c, Collection_Case_Owner__c = c.OwnerId));
        }
        if (loansUpdted.size() > 0) update loansUpdted.values();
        
    }

    global void finish(Database.BatchableContext BC){        
            WebToSFDC.notifyDev('Collections Cases Batch Completed', 'Collections Cases batch completed for Today. \n\nTotal processed = ' + count + '\nTotal recovered = ' + iRecovered + '\nAttempted to Assign = ' + iAssigned + '\n\n');        

    }
}