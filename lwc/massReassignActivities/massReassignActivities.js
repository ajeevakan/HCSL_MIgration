import { LightningElement } from 'lwc';
import getUsers from '@salesforce/apex/MassReassignActivitiesController.getUsers'
import getCommunityNames from '@salesforce/apex/MassReassignActivitiesController.getCommunityNames';
import reassignActivities from '@salesforce/apex/MassReassignActivitiesController.reassignActivities';
import uId from '@salesforce/user/Id'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class MassReassignActivities extends LightningElement {
    processing = false;

    users = [];
    userOptions = [];
    selectedAssignedTo;
    selectedReassignTo;
    
    communities = [];
    communityOptions = [{label: 'All Communities', value: 'All Communities'}];
    selectedCommunity = 'All Communities';

    leadScoreOptions = [
        { label: 'All', value: 'All'},
        { label: 'Hot Lead', value: 'Hot Lead'},
        { label: 'Warm Lead', value: 'Warm Lead'},
        { label: 'Cool Lead', value: 'Cool Lead'}
    ];
    selectedLeadScore = 'All';

    selectedDateFrom;
    selectedDateTo;
    includeConsumer = false;
    includeOutreach = false;

    connectedCallback() {
        getUsers().then(result => {
            this.users = result;
            this.users.forEach(user => {
                const option = { label: user.userName, value: user.userId };
                this.userOptions = [ ...this.userOptions, option ];
            });
        });

        getCommunityNames().then(result => {
            this.communities = result;
            this.communities.forEach(community => {
                if (community !== 'ALL'){
                    const option = { label: community, value: community };
                    this.communityOptions = [ ...this.communityOptions, option ];
                }
            });
        });

        this.selectedAssignedTo = uId;
    }

    handleChange(event){
        if (event.target.name === 'assignedTo'){
            this.selectedAssignedTo = event.target.value;
        }
        else if (event.target.name === 'reassignTo'){
            this.selectedReassignTo = event.target.value;
        }
        else if (event.target.name === 'community'){
            this.selectedCommunity = event.target.value;
        }
        else if (event.target.name === 'leadScore'){
            this.selectedLeadScore = event.target.value;
        }
        else if (event.target.name === 'dateFrom'){
            this.selectedDateFrom = event.target.value;
        }
        else if (event.target.name === 'dateTo'){
            this.selectedDateTo = event.target.value;
        }
        else if (event.target.name === 'includeConsumer'){
            this.includeConsumer = event.target.checked;
        }
        else if (event.target.name === 'includeOutreach'){
            this.includeOutreach = event.target.checked;
        }
    }

    handleSubmit(event){
        if (this.selectedAssignedTo === undefined || this.selectedAssignedTo === null || this.selectedAssignedTo === ''){
            this.showToast('Error', 'Please select the user to whom the activities are currently assigned.', 'error');
            return;
        }
        if (this.selectedReassignTo === undefined || this.selectedReassignTo === null || this.selectedReassignTo === ''){
            this.showToast('Error', 'Please select the user to whom the activities will be reassigned.', 'error');
            return;
        } 
        if (this.selectedAssignedTo === this.selectedReassignTo){
            this.showToast('Error', 'The user to whom the activities will be reassigned cannot be the same as the user to whom the activities are currently assigned.', 'error');
            return;
        }

        if (this.selectedDateTo !== undefined && this.selectedDateTo !== null && this.selectedDateTo !== ''){
            if (this.selectedDateFrom !== undefined && this.selectedDateFrom !== null && this.selectedDateFrom !== ''){
                if (new Date(this.selectedDateFrom) > new Date(this.selectedDateTo)){
                    this.showNotification('Error', 'The Activity Date From must be earlier than the Activity Date To.', 'error');
                    return;
                }
            }
        }
        this.processing = true;
        reassignActivities({assignedTo: this.selectedAssignedTo, 
                            reassignTo: this.selectedReassignTo, 
                            community: this.selectedCommunity,
                            leadScore: this.selectedLeadScore,
                            dateFrom: this.selectedDateFrom,
                            dateTo: this.selectedDateTo,
                            includeConsumer: this.includeConsumer,
                            includeOutreach: this.includeOutreach}).then(result => {
            if (result === 'Success'){
            this.processing = false;
            this.showNotification('Success', 'The activities will be reassigned.', 'success');
            }
            else{
                this.processing = false;
                this.showNotification('Error', 'Error while reassigning activities', 'error');
            }
        }).catch(error => {
            this.processing = false;
            this.showNotification('Error', 'Error while reassigning activities', 'error');
        }
        );
    }

    showNotification(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}