trigger AccTrigger on Account (before insert, before update) {
    if (DisableTrigger.isDisabled('AccTrigger')) return;
  if ((trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)){
        
        if (!(DisableTrigger.isDisabled('AccAssignPrimaryCommunityUser')))
          (new AssignPrimaryCommunityUser()).AccountTrigger();
    }
}