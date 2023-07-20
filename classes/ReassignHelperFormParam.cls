public without sharing class ReassignHelperFormParam {
    @AuraEnabled
    public list<ReassignHelperFormParamParamField> paramFields;
    @AuraEnabled
    public string message;
    @AuraEnabled
    public integer step;
    @AuraEnabled
    public ReassignHelperFormParam sourceParam;
    @AuraEnabled
    public string objectName;
    @AuraEnabled
    public string searchName;
    @AuraEnabled
    public boolean reassignActivitiesOnly;
    @AuraEnabled
    public string reassignToId;
    @AuraEnabled
    public string communityId;
    @AuraEnabled
    public string currentOwnerId;
    @AuraEnabled
    public string campaignId;
    @AuraEnabled
    public string ReassignmentBatchId;
    @AuraEnabled
    public string whereCondition;

    // public class ParamField{
    //     @AuraEnabled
    //     public string fieldName;
    //     @AuraEnabled
    //     public string fieldLabel;
    //     @AuraEnabled
    //     public string fieldType;// (BOOLEAN,PICKLIST,DATE,DATETIME,NUMBER,TEXT)
    //     @AuraEnabled
    //     public string operator;
    //     @AuraEnabled
    //     public list<ComboItem> picklistOptions;
    //     @AuraEnabled
    //     public string fieldValue;
    //     @AuraEnabled
    //     public string paramId;
    //     @AuraEnabled
    //     public Boolean isBOOLEAN;
    //     @AuraEnabled
    //     public Boolean isPICKLIST;
    //     @AuraEnabled
    //     public Boolean isDATE;
    //     @AuraEnabled
    //     public Boolean isNUMBER;
    //     @AuraEnabled
    //     public Boolean isTEXT;
    //     public void SetType(){
    //         isBOOLEAN=false;
    //         isPICKLIST=false;
    //         isDATE=false;
    //         isNUMBER=false;
    //         isTEXT=false;
    //         if (string.isBlank(fieldType)) isTEXT = true;
    //         else if (fieldType.equalsIgnoreCase('BOOLEAN')) isBOOLEAN = true;
    //         else if (fieldType.equalsIgnoreCase('PICKLIST')) isPICKLIST = true;
    //         else if (fieldType.equalsIgnoreCase('DATE')) isDATE = true;
    //         else if (fieldType.equalsIgnoreCase('DATETIME')) isDATE = true;
    //         else if (fieldType.equalsIgnoreCase('NUMBER')) isNUMBER = true;
    //         else isTEXT = true;
    //     }

    // }

    // public class ComboItem{
    //     @AuraEnabled
    //     public string label;
    //     @AuraEnabled
    //     public string value;
    //     public ComboItem(string plabel, string pvalue){
    //         this.label = plabel;
    //         this.value = pvalue;
    //     }
    // }
}