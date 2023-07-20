trigger createStatuses on Campaign (after Insert){

List<CampaignMemberStatus> lstCampaignMemberStatus = new List<CampaignMemberStatus> ();

for (Campaign c: trigger.new){
CampaignMemberStatus cms1 = new CampaignMemberStatus(CampaignId=c.Id, HasResponded=true, Label='Attended', SortOrder=3); 
CampaignMemberStatus cms2 = new CampaignMemberStatus(CampaignId=c.Id,  HasResponded=true, Label= 'Cancelled', SortOrder=4); 
CampaignMemberStatus cms3 = new CampaignMemberStatus(CampaignId=c.Id,  HasResponded=true, Label='No Show', SortOrder=5);
lstCampaignMemberStatus.add(cms1);
lstCampaignMemberStatus.add(cms2);
lstCampaignMemberStatus.add(cms3);
}
If(lstCampaignMemberStatus.size() > 0)
{
    
    insert lstCampaignMemberStatus;
}
}