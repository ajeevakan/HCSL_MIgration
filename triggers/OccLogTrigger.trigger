trigger OccLogTrigger on Occupancy_Log__c (after delete, after insert, after update) {
    if (!(DisableTrigger.isDisabled('OccLogTrigger')))
		OccTrigHelper.OccLogTrigger(!(DisableTrigger.isDisabled('OccLogTriggerFuture')));
}