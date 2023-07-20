trigger OppTrigger on Opportunity (before insert, before update, after insert, after update) {
    if (DisableTrigger.isDisabled('OppTrigger')) return;
    
    if ((trigger.isAfter)&&(Trigger.isInsert || Trigger.isUpdate)){
        
        if (!(DisableTrigger.isDisabled('OppCreateInquiryActivity')))
          OppCreateInquiryActivity.OppTrigger();
        
        if (!(DisableTrigger.isDisabled('OppCreateSysAct')))
        (new OppSystemActivityHelper()).OppTrigger(!(DisableTrigger.isDisabled('OppCreateSysActFuture')));
        
        if (!(DisableTrigger.isDisabled('OppCreateOcc')))
            OccTrigHelper.OppTrigger(!(DisableTrigger.isDisabled('OppCreateOccFuture')));
    }
    else if ((trigger.isBefore)&&(Trigger.isInsert || Trigger.isUpdate)){
        
        if (!(DisableTrigger.isDisabled('OppAssignPrimaryCommunityUser')))
          (new AssignPrimaryCommunityUser()).OpportunityTrigger();
    }
    
    if ((trigger.isBefore)&&(Trigger.isInsert)){
        
        if (!(DisableTrigger.isDisabled('AssignOppHousehold ')))
          (new AssignOppHousehold ()).OpportunityTrigger();
    }

}