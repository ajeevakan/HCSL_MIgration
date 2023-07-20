trigger TskTrigger on Task (Before Insert, Before Update, After Update, After Insert, After Delete) {
  if (DisableTrigger.isDisabled('TskTrigger')) return;
  if ((trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
        if (!(DisableTrigger.isDisabled('OppActivityRollUpTask')))
          OppActivityRollup.handleActivityTrigger();
      if (Trigger.isInsert || Trigger.isUpdate)
          if (!(DisableTrigger.isDisabled('ActivityCreateCampaignMember')))
            (new CreateCampaignMemberHelper()).ActivityTrigger();
    }
  if (trigger.isBefore)
     TaskTriggerAssignOppsToTasks.handleActivityTrigger();
}