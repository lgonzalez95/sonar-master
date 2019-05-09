global class CollectionsCasesAssignmentUsersGroup {

    public String publicUserGroupName;
    public List<DealAutomaticUserGroup> daugList;
    public Map<Id, Integer> currentAssignedLoadMap;
    public Integer inflowLoadToBalance;
    public CollectionsCasesLoadBalanceByMax loadBalanceByMaxAlgorythm;
    public Map<Id, Long> loadBalancedMap;
    public Boolean isGroupEmpty;

    public CollectionsCasesAssignmentUsersGroup(String collectionsPublicUserGroupName) {
        this.currentAssignedLoadMap = new Map<Id, Integer>();
        this.inflowLoadToBalance = 0;
        this.publicUserGroupName = collectionsPublicUserGroupName;
        this.daugList = CaseAutomaticAssignmentUtils.getAllUsers(this.publicUserGroupName);
        this.isGroupEmpty = this.daugList == null || this.daugList.isEmpty();
    }

    public void loadBalanceByMaxAlgorythm(){
        this.loadBalanceByMaxAlgorythm = new CollectionsCasesLoadBalanceByMax(this.inflowLoadToBalance, this.currentAssignedLoadMap);
        this.loadBalancedMap = this.loadBalanceByMaxAlgorythm != null ? this.loadBalanceByMaxAlgorythm.individualFutureLoadMap : null;
    }

    public Id getIndividualIdForFutureAssignment(){
        Id nextAvailableCollectorId;
        if(this.loadBalancedMap == null || this.loadBalancedMap.isEmpty()){
            return nextAvailableCollectorId;
        }
        List<Id> idsList = new List<Id>(this.loadBalancedMap.keySet());
        Integer listItem = 0;
        Long load = 0;
        do{
            nextAvailableCollectorId = idsList.get(listItem);
            load = (Long) this.loadBalancedMap.get(nextAvailableCollectorId);
            listItem++;
        }while(listItem < idsList.size() && load == 0);
        if(load == 0){
            return this.loadBalanceByMaxAlgorythm.individualWithLowestFutureLoad;            
        }else{
            this.loadBalancedMap.remove(nextAvailableCollectorId);
            this.loadBalancedMap.put(nextAvailableCollectorId, load.intValue()-1);
            return nextAvailableCollectorId;
        }
    }
}