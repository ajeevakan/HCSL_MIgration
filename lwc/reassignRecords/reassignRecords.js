import { LightningElement } from 'lwc';
import GetFormParam from '@salesforce/apex/ReassignHelper.GetFormParam';
import { NavigationMixin } from 'lightning/navigation';

export default class ReassignRecords extends NavigationMixin(LightningElement) {

    paramObj = {step: 0};
    isshowSubmitButton = true;
    processing = false;

    get Formtitle() {
        if (this.paramObj===undefined) this.SubmitForm();
        else if (this.paramObj.step==0) this.SubmitForm();
        return "Reassign Records";
    }

    get showSubmitButton(){
        if (this.isshowSubmitButton){
            if (this.processing) return false;
            else return true;
        }
        else return false;
    }

    get ButtonName() {
        if (this.paramObj===undefined) return 'Next';
        else if (this.paramObj.step==4) return 'Submit';
        else return 'Next';
    }

    SubmitForm(){
        this.processing = true;
        GetFormParam({ wrapperText:JSON.stringify(this.paramObj) }) 
                .then((result) => {
                    //this.paramObj = result;
                    Object.assign(this.paramObj, result);
                    this.paramObj.paramFields = this.paramObj.paramFields.map(element => Object.assign({},element));
                    this.processing = false;
                    if (this.paramObj.step==99) isshowSubmitButton = false;
                    else if (this.paramObj.step==5) if (this.paramObj.ReassignmentBatchId){
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.paramObj.ReassignmentBatchId,
                                objectApiName: 'Reassignment_Batch__c',
                                actionName: 'view'
                            }
                        });
                        this.paramObj = {step: 99};
                        this.isshowSubmitButton = false;
                    }
                    
                }).catch((error) => {
                    console.log(error);
                });
    }

    navigateToHome() {
        this.paramObj = {step: 0};
        this.SubmitForm();
        this[NavigationMixin.Navigate]({
            // Pass in pageReference
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            }
        });
    }

    

    handleChange(event){
        let j=0;
        this.paramObj.paramFields.forEach(pf => {
            console.log(pf);
            if (pf.paramId === event.target.name){
                this.paramObj.paramFields[j].fieldValue = event.target.value;
            }
            j++;
        });

    }



}