trigger CaseTrigger on Case (before insert,after insert, before update, after update) {
    TriggerFactory.createandexecuteHandler(caseHandler.class);
}