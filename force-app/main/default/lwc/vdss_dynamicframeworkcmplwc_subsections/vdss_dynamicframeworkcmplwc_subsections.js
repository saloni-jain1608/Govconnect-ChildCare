import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import vdss_static_resources from '@salesforce/resourceUrl/VDSSPortalStaticResources';

export default class Vdss_dynamicframeworkcmplwc_subsections extends LightningElement {

    @api subsection;
    @api sectionId;
    @api jsonData;//this is just for testing purpose. can be removed later
    sectionsdata; subsectiondata;
    @api programId; @api programTransactionId;
    @api languageselected;
    @track LangMetaData;

    isTextBlock; isComponent; isFieldset;
    isTableTypeComp; isFileUploadComp; Signature;
    isSubsectionValid = false;
    tableJSON;

    

    connectedCallback() {
        //console.log('langaugedata:',JSON.stringify(this.languageMetadata));
        //console.log('SubSection Program Id --> ' +this.programId);
        

        if (this.subsection.Type == 'Fieldset') {
            this.isFieldset = true;
        }
        else if (this.subsection.Type == 'Textblock') {
            this.isTextBlock = true;
        }
        else if (this.subsection.Type == 'Component') {
            this.isComponent = true;

            if (this.subsection.ComponentType == 'TableComponent') {
                this.isTableTypeComp = true;
            }
            else if (this.subsection.ComponentType == 'FileUpload') {
                this.isFileUploadComp = true;
            }
            else if (this.subsection.ComponentType == 'Signature') {
                this.Signature = true;
            }
        }


    }

    @api getUpdatedSubSectionJson() {

        var getUpdatedSubSectionJsonArray = [];

        if (this.subsection.Type == 'Component') {
            if (this.subsection.ComponentType == 'TableComponent') {

                console.log('===calling dynamic table cmp=====');
                this.template.querySelectorAll('c-dynamic-table-form-cmp')
                    .forEach(element => {
                        console.log('===calling dynamic inside cmp=====');
                        element.getTableData();
                    });


                //getUpdatedSubSectionJsonArray[0] = this.subsection.Section;
                //getUpdatedSubSectionJsonArray[1] = this.subsection.Id;
                //getUpdatedSubSectionJsonArray[2] = this.template.querySelector('c-testlwcsave').fetchTableJSON();
            }
        }
        //return getUpdatedSubSectionJsonArray;
    }

    @api validateInputs() {
        let ValidInput=true;
        console.log('--- Validating Subsection--->' + this.subsection.Label);
        console.log('--- Validating Subsection Type--->' + this.subsection.Type + ' - ' + this.subsection.ComponentType);

        if (this.subsection.Type == 'Fieldset') {
            this.isSubsectionValid = [...this.template.querySelectorAll('c-form-input-field-lwc')]
                .reduce((allValid, childCmp) => {
                    if (childCmp.validateInputs()) {
                        ValidInput=true;
                        return allValid;
                    }
                    ValidInput=false;
                    return false;
                }, true);
        }
        else if (this.subsection.Type == 'Component') {
            if (this.subsection.ComponentType == 'TableComponent') {

                //this.isTableValid = JSON.parse(JSON.stringify(this.template.querySelector('c-dynamic-table-form-cmp').validateTable()));
                this.isSubsectionValid = true;
            }
            else if (this.subsection.ComponentType == 'FileUpload') {
                this.isSubsectionValid = true;
            }
            else if (this.subsection.ComponentType == 'Signature') {
                const SignatureModal = this.template.querySelector('c-signature');
                if(ValidInput){
                    SignatureModal.handleSaveClick();
                }
                this.isSubsectionValid = true;
            }
            else{
                this.isSubsectionValid = true;
            }
        }
        else {
            this.isSubsectionValid = true;
        }
        console.log('--- Validating Subsection Output --->' + this.isSubsectionValid);

        return (this.isSubsectionValid)
    }

    //on load
    renderedCallback() {
        Promise.all([
            loadStyle(this, vdss_static_resources + '/VDSS_StaticResources/css/styles_vdss.css') //specified filename
        ]).then(() => {
            window.console.log('Files loaded.');
            //console.log("renderedCallback ---> "+this.jsonBody);
            //initializeComp();

        }).catch(error => {
            window.console.log("Error " + error.body.message);
        });

        //this.activeSection = this.jsonData.Sections[0].Id;
    }

    handleValueChange(event) {
        console.log("handleValueChange======> " + JSON.stringify(event));
        console.log("handleValueChange2======> " + JSON.stringify(event.detail.value));
        console.log("subsectionid======> " + this.subsection.Id);


        const selectedEvent = new CustomEvent("valuechange", {
            detail: { value: event.detail.value,checked:event.detail.checked, fieldname: event.detail.fieldname, subsectionid: this.subsection.Id, bubbles: true }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

    }


}