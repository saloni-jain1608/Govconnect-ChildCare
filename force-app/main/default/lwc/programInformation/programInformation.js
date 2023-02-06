import { LightningElement, track } from 'lwc';

export default class ProgramInformation extends LightningElement {
    @track strDSS;
    @track strOtherPrgms;
    @track strBldngChildCare;
    @track strCurrentBldng;
    strNameofFacility;
    intPhonNum;
    intFaxNum;
    strPhyAddress;
    strPhyCity;
    strPhyState;
    strPhyZipCd;
    strMailAddress;
    strMailCity;
    strMailState;
    strMailZipCd;
    strEmail;
    intNumBuildings;
    intNumHrs;
    strOvernightCare;
    strEveCare;
    intMinAge;
    intMaxAge;
    strNameofDirec;
    valueMon;
    valueDay;

    //Options for Yes/No Radio Buttons
    get options() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    //Option sfor Monthly Checkboxes
    value = [];

    get optionsMonths() {
        return [
            { label: 'Year End', value: 'Year End' },
            { label: 'January', value: 'January' },
             { label: 'February', value: 'February' },
             { label: 'March', value: 'March' },
            { label: 'April', value: 'April' },
             { label: 'May', value: 'May' },
            { label: 'June', value: 'June' },
            { label: 'July', value: 'July' },
            { label: 'August', value: 'August' },
            { label: 'September', value: 'September' },
            { label: 'October', value: 'October' },
            { label: 'November', value: 'November' },
            { label: 'December', value: 'December' }
        ];
    }

    // get optionsDays() {
    //     return [
    //         { label: 'Monday', value: 'Monday' },
    //         { label: 'Tuesday', value: 'Tuesday' },
    //         { label: 'Wednesday', value: 'Wednesday' },
    //         { label: 'Thursday', value: 'Thursday' },
    //         { label: 'Friday', value: 'Friday' },
    //         { label: 'Saturday', value: 'Saturday' },
    //         { label: 'Sunday', value: 'Sunday' },
    //     ];
    // }

   // value = [];

    get optionsDays() {
        return [
            { label: 'Monday', value: 'Monday' },
                { label: 'Tuesday', value: 'Tuesday' },
                { label: 'Wednesday', value: 'Wednesday' },
            { label: 'Thursday', value: 'Thursday' },
            { label: 'Friday', value: 'Friday' },
            { label: 'Saturday', value: 'Saturday' },
            { label: 'Sunday', value: 'Sunday' }
        ];
    }

    // get selectedValues() {
    //     return this.value.join(',');
    // }

    //Method for on Change of the Checkbox
    handleChange(e) {
        this.valueMon = e.detail.value;
    }

    handleDayChange() {
        this.valueDay = e.detail.value;
    }
}