public without sharing class ReassignHelperFormParamComboItem {
    @AuraEnabled
    public string label;
    @AuraEnabled
    public string value;
    public ReassignHelperFormParamComboItem(string plabel, string pvalue){
        this.label = plabel;
        this.value = pvalue;
    }
}