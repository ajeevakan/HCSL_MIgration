trigger CreateOppContactsForOppFromPersonAcc on Opportunity (after insert) {
   // if (DisableTrigger.isDisabled('CreateOppContactsForOppFromPersonAcc')) return;
      if (trigger.isAfter)
         (new CreateOppContactFromPersonAccHelper()).CreateOppContactsForOpportunity(Trigger.new);
}