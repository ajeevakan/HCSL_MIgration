trigger CampTrigger on Campaign (before insert, before update) {
    if (DisableTrigger.isDisabled('CampTrigger')) return;
  if ((trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)){
        
        if (!(DisableTrigger.isDisabled('CampAssignPrimaryCommunityUser')))
          (new AssignPrimaryCommunityUser()).CampaignTrigger();
    }
}