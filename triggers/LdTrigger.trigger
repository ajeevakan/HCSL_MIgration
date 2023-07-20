trigger LdTrigger on Lead (before insert, before update) {
    if (DisableTrigger.isDisabled('LdTrigger')) return;
  if ((trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)){
        
        if (!(DisableTrigger.isDisabled('LdAssignPrimaryCommunityUser')))
          (new AssignPrimaryCommunityUser()).LeadTrigger();
    }
}