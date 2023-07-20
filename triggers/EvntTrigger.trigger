trigger EvntTrigger on Event (Before Insert, After Update, After Insert, After Delete) {
  if (DisableTrigger.isDisabled('EvntTrigger')) return;
  if ((trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
      if (!(DisableTrigger.isDisabled('OppActivityRollUpEvent')))
          OppActivityRollup.handleActivityTrigger();
      if (Trigger.isInsert || Trigger.isUpdate)
          if (!(DisableTrigger.isDisabled('ActivityCreateCampaignMember')))
            (new CreateCampaignMemberHelper()).ActivityTrigger();
  }
  if (trigger.isBefore && Trigger.isInsert)
     EventSubject.handleActivityTrigger();
}