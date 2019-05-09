public with sharing class CaseAutomaticSummaryCtrl {
	public CaseAutomaticSummaryCtrl() {
	}

	/**
	* Get all users
	* @return List of DealAutomaticUserGroup
	*/
	@RemoteAction
	public static List<DealAutomaticUserGroup> getAllUsers() {
		return CaseAutomaticAssignmentUtils.getAllDataEntryUsers();
	}

	/**
	 * [saveUserOnlineMode description]
	 * @param userId   [description]
	 * @param isOnline [description]
	 */
	@RemoteAction
	public static void saveUserOnlineMode(String userId, Boolean isOnline) {
		AutomaticAssignmentUtils.saveUserOnlineMode(userId, isOnline);
	}
}