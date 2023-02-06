import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import delegateRequest from '@salesforce/apex/RequestController.delegateRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CustomLightningAction extends NavigationMixin(LightningElement) {
    isLoading = false;
    @api buttonLabel;
    @api objectApiName;
    @api btnVariant = 'Neutral';
    @api callApexOrLaunchComponent;
    @api apexMethodName;
    @api validate = false;
    @api validationMethod;
    @api componentName;
    @api componentLoadType;
    @api recordIdAttribute;
    @api componentAttributes;
    @api componentAttributesValues;
    @api redirectUrl;
    @api refreshPage;
    @api successMessage;
    @api failureMessage;

    @api apexClassName;
    @api recordId;
    @api variable;

    performTheRequiredAction() {
        if (this.callApexOrLaunchComponent == 'Component') {
           /* if (this.componentLoadType == 'Modal') {
                this[NavigationMixin.Navigate]({
                    "type": "standard__component",
                    "attributes": {
                        "componentName": this.componentName,
                    },
                    state: {
                        c__recordId: this.recordId
                    }
                });
            } else if (this.componentLoadType == 'Redirect') {
                console.log('Redirect');
                // Navigate to a URL
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: this.redirectUrl
                    }
                },
                    true // Replaces the current page in your browser history with the URL
                );
            }*/
            const selectedEvent = new CustomEvent("testevent");
          
              this.dispatchEvent(selectedEvent);
        } else if (this.callApexOrLaunchComponent == 'Apex') {
            this.isLoading = true;
            console.log('Record Id --> ' + this.recordId);
            delegateRequest({ className: this.apexClassName, methodName: this.apexMethodName, jsonParam: this.recordId, validationMethodName: this.validationMethod, bValidate: this.validate })
                .then(result => {
                    console.log(JSON.stringify(result));
                    let response = JSON.parse(result);
                    if (response.status == 'OK') {
                        this.isLoading = false;
                        const evt = new ShowToastEvent({ title: 'Success', message: response.data.successMessage, variant: 'success' });
                        this.dispatchEvent(evt);
                    } else if (response.errors && response.errors.length > 0) {
                        this.isLoading = false;
                        let errorMessage = response.errors.join('<br/>');
                        const evt = new ShowToastEvent({ title: 'Error', message: errorMessage, variant: 'error' });
                        this.dispatchEvent(evt);
                    }

                    if (response.data.redirect) {
                       
                        if(response.data.redirectType === 'standard__recordPage') {
                            this[NavigationMixin.Navigate]({
                                type: 'standard__recordPage',
                                attributes: response.data.redirectAttributes,
                            });   
                        }
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                    //this.variable = this.failureMessage;
                    const evt = new ShowToastEvent({ title: 'Error', message: error.stack, variant: 'error' });
                    this.dispatchEvent(evt);
                    //this.template.querySelector('c-custom-modal').show();
                });
        }
    }

    handleClick(event) {
        this.performTheRequiredAction();
    }

    closeModal() {
        this.template.querySelector('c-custom-modal').show();
        if (this.refreshPage) {
            // Navigate to a URL
            location.reload();
        }
    }
}