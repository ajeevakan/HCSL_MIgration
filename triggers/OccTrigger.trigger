trigger OccTrigger on Occupancy__c (after insert, after update, before insert, before update, after delete){
// PLEASE USE FOLLOWING RECORD NAMES FOR DISABLING SOME FEATURES OF THE TRIGGER
//To disable whole trigger create Disable Trigger custom setting record with name: OccTrigger
//To disable future method calling from trigger: OccTriggerFuture
//To disable Occupancy Log creating: trigOccupancyCreateOccLog
//To disable updating unit status: trigOccupancyUpdateUnitStatus
	if (!(DisableTrigger.isDisabled('OccTrigger')))
		OccTrigHelper.OccTrigger(!(DisableTrigger.isDisabled('OccTriggerFuture')));
}