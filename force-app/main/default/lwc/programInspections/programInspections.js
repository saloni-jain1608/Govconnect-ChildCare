import { LightningElement } from 'lwc';
import delegateRequest from '@salesforce/apex/RequestController.delegateRequest';
import loginUserId from '@salesforce/user/Id';

const columns = [
    { label: 'Inspection#', fieldName: 'Name' },
    { label: 'Inspection Status#', fieldName: 'InspectionStatus' },
    { label: 'Visit Status', fieldName: 'VisitStatus' },
    {
        label: 'Action',
        fieldName: 'URL',
        type: 'url',
        typeAttributes: {
            label: {
                fieldName: 'UrlLabel'
            }
        }
    }
];

export default class ProgramInspections extends LightningElement {
    queryParams;
    programInspections;
    isLoading = false;
    columns = columns;

    connectedCallback() {
        this.queryParams = this.getQueryParameters();
        this.isLoading = true;

        let request = {
            userID: loginUserId,
            inspectionID: this.queryParams.inspectionId != null && this.queryParams.inspectionId != undefined ? this.queryParams.inspectionId : ''
        }

        delegateRequest({ className: 'CAPSummaryCtrl', methodName: 'getInspections', jsonParam: JSON.stringify(request), validationMethodName:'', bValidate: false })
            .then(result => {
                console.log(result);
                this.isLoading = false;
                let response = JSON.parse(result);

                this.programInspections = response.data.ProgramInspections;
            }).catch(error => {
                this.isLoading = false;
                console.log(error);
            });

    }

    /**
     * Obtains query parameters from window.location.search
     */
    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);

        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }

        return params;
    }

}