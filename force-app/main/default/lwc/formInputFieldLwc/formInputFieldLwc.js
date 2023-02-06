import { LightningElement, track, api } from "lwc";
//import getFieldOptions from '@salesforce/apex/vdssCommunityProgramsMain.getFieldOptions';

export default class FormInputFieldLwc extends LightningElement {
  @api field;
  mapOfOptions;
  isTextField;
  isPicklistField;
  isRadioField;
  isCheckboxField;
  isMultiPicklistField;
  isRadioField;
  isTextAreaField;
  isNumberField;
  isPhoneField;
  isLookupField;
  isEmailField

  connectedCallback() {
    if (this.field.Type == "Text" || this.field.Type == "Date") {
      this.isTextField = true;
      if (this.field.Validator == "Email") {
        this.isEmailField = true;
        this.isTextField = false;
      }
    } else if (this.field.Type == "Picklist") {
      this.isPicklistField = true;

      /*
            // Get dynamic picklist options
            getFieldOptions( { objectApi : 'CLQ_Program_Transaction__c', fieldApi: 'CLQ_ProgTrans_State__c'} )
            .then(data => {

                if(data) {
                    for(let key in data) {
                        // Preventing unexcepted data
                        if (data.hasOwnProperty(key)) { // Filtering the data in the loop
                            this.mapOfOptions.add({label:key,value:data[key]});
                        }
                    }
                    console.log(' ==== SUCCESS DATA FETCH PICKLIST =====');
                    console.log(this.mapOfOptions);
                    //console.log(JSON.stringify(data));
                }

                //this.all_programs = data;
            })
            .catch(error => {
                console.log("error", error);
            });
            */
    } else if (this.field.Type == "Radio") {
      this.isRadioField = true;
    } else if (this.field.Type == "Checkbox") {
      this.isCheckboxField = true;
    } else if (this.field.Type == "Multi-Select") {
      console.log("------" + JSON.stringify(this.field));
      this.isMultiPicklistField = true;
    } else if (this.field.Type == "TextArea") {
      this.isTextAreaField = true;
    } else if (this.field.Type == "Phone") {
      this.isPhoneField = true;
    } else if (this.field.Type == "Number") {
      this.isNumberField = true;
    } else if (this.field.Type == "Lookup") {
      console.log("LOOKUP" ,JSON.stringify(this.field));
      this.isLookupField = true;
    }
  }

  getOptionsForPickFields(event) {
    var objApi = event.currentTarget.dataset.objapi;

    alert(objApi);
  }

  SplitPhone(phnum){
    let y = phnum.toString();
    if(y.length==10){
    let splitted_phone = y.substr(0,3)+"-"+y.substr(3,3)+"-"+y.substr(6,10);
    return splitted_phone;
    }
    else{ 
      return y;
    }
  }

  getCountOfDigits(str) {
    return str.replace(/[^0-9]/g, '').length;
  }

  handleInputChange(event) {
    console.log("event++" + JSON.stringify(event.detail));
    console.log("label++" + event.target.dataset.id);
    this.field = JSON.parse(JSON.stringify(this.field));
    
    if(this.field.Type == 'Phone' && this.getCountOfDigits(event.target.value)==10){
      let ReturnedValue = this.SplitPhone(event.target.value);
      this.field.Value = ReturnedValue;
      const selectedEvent = new CustomEvent("valuechange", {
        detail: { value: ReturnedValue,checked:event.detail.checked, fieldname: event.target.dataset.id }
      });
      this.dispatchEvent(selectedEvent);

    }
    else{
      this.field.Value = event.target.value;
      const selectedEvent = new CustomEvent("valuechange", {
        detail: { value: event.target.value,checked:event.detail.checked, fieldname: event.target.dataset.id }
      });
      this.dispatchEvent(selectedEvent);
    }
    
    

    // Dispatches the event.
    //this.dispatchEvent(selectedEvent);
  }

  


  handlePicklistChange(event) {
    console.log("event++" + JSON.stringify(event.detail));
    console.log("label++" + event.target.dataset.id);
    this.field = JSON.parse(JSON.stringify(this.field));
    this.field.Value = event.target.value;
    const selectedEvent = new CustomEvent("valuechange", {
      detail: { value: event.target.value, fieldname: event.target.dataset.id }
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  /*handleRadioChange(event){
        console.log("event++"+JSON.stringify(event.detail));
        console.log("label++"+event.target.dataset.id); 
        this.field = JSON.parse(JSON.stringify(this.field));
        this.field.Value =  event.target.value;   
        const selectedEvent = new CustomEvent("valuechange", {
            detail: {value:event.target.value,fieldname: event.target.dataset.id}
          });
          
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
    }
    */
  handleCheckboxChange(event) {
    console.log("event handleCheckboxChange++" + JSON.stringify(event.detail));
    //console.log("label++"+event.target.dataset.id);

    /*
        this.field = JSON.parse(JSON.stringify(this.field));
        this.field.Value =  event.target.value;   
        const selectedEvent = new CustomEvent("valuechange", {
            detail: {value:event.target.value,fieldname: event.target.dataset.id}
          });

        */

    // Dispatches the event.
    //this.dispatchEvent(selectedEvent);
  }

  handleLookUpChange(event) {
    const selectedEvent = new CustomEvent("valuechange", {
      detail: { value: event.target.value, fieldname: event.target.dataset.id }
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  handleTextareaChange(event) {
    console.log("event++" + JSON.stringify(event.detail));
    console.log("label++" + event.target.dataset.id);
    this.field = JSON.parse(JSON.stringify(this.field));
    this.field.Value = event.target.value;
    const selectedEvent = new CustomEvent("valuechange", {
      detail: { value: event.target.value, fieldname: event.target.dataset.id }
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  @api validateInputs() {
    return [...this.template.querySelectorAll(".inputfields")].reduce(
      (allValid, inputCmp) => {
        /* AAkriti Zip code validation  22/03/21
        if (this.field.FieldApi === "CLQ_Mailing_ZipCode__c") {
          if (inputCmp.value.length !== 5 && inputCmp.value.length > 0) {
            inputCmp.setCustomValidity(
              "Zip Code should be 5 characters long."
            );
          } else {
            inputCmp.setCustomValidity("");
          }
        }*/
        inputCmp.reportValidity();
        if (inputCmp.checkValidity()) {
          return allValid;
        }
        return false;
      },
      true
    );
  }
  handleValueSelcted(event) {
    console.log("lokup++" + JSON.stringify(event.detail));
  }
}