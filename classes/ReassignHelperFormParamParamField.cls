public without sharing class ReassignHelperFormParamParamField {
    @AuraEnabled
    public string fieldName;
    @AuraEnabled
    public string fieldLabel;
    @AuraEnabled
    public string fieldType;// (BOOLEAN,PICKLIST,DATE,DATETIME,NUMBER,TEXT)
    @AuraEnabled
    public string operator;
    @AuraEnabled
    public list<ReassignHelperFormParamComboItem> picklistOptions;
    @AuraEnabled
    public string fieldValue;
    @AuraEnabled
    public string paramId;
    //@AuraEnabled
    //public Boolean isBOOLEAN;
    @AuraEnabled
    public Boolean isPICKLIST;
    @AuraEnabled
    public Boolean isDATE;
    @AuraEnabled
    public Boolean isNUMBER;
    @AuraEnabled
    public Boolean isTEXT;
    public void SetType(){
        //isBOOLEAN=false;
        isPICKLIST=false;
        isDATE=false;
        isNUMBER=false;
        isTEXT=false;
        if (string.isBlank(fieldType)) isTEXT = true;
        else if (fieldType.equalsIgnoreCase('BOOLEAN')) isPICKLIST = true;
        else if (fieldType.equalsIgnoreCase('PICKLIST')) isPICKLIST = true;
        else if (fieldType.equalsIgnoreCase('DATETIME')) isDATE = true;
        else if (fieldType.equalsIgnoreCase('NUMBER')) isNUMBER = true;
        else if (fieldType.equalsIgnoreCase('DATE')) isDATE = true;
        else isTEXT = true;
    }
}