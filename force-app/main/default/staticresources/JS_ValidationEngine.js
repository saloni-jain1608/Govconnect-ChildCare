// Pradeep Ravi        10-03-2017        11246 - Adding new validator for Phone Extn/ Number field
// function to Test the validity of the field checks for the following cases:
// 1. required && valid
// 2. required
// 3. valid
var Validator = function (field) {
    this.id = field.id || null;;
    this.name = field.name;
    this.isValid = true;
    this.validator = field.validator
        ? field.validator
        : null;
    this.required = field.required;
    this.regex = field.regex
        ? field.regex
        : null;
    this.error = null;
    this.watch = field.watch
        ? field.watch
        : true;
    this._event = field.event
        ? field.event
        : 'blur';
    this._isTouched = false;
    this.engineScope = field.engineScope;
    this._isCustomValidation = false;

    field.element
      ? this.element = field.element
      : this.element = field._form
          ? field._form.find("[id$='" + this.id + "']")
          : $("[id$='" + this.id + "']")


    // private function to add the error class on the element based on the field validity
    this._applyStyle = function () {
      //  alert(this.isValid);
        this.isValid
            ? this.element.parent().removeClass("errorElement")
            : this.element.parent().addClass("errorElement");
    };

    if (field.applyCustomStyle && typeof field.applyCustomStyle === "function") {
        this.applyCustomStyle = field.applyCustomStyle;
    } else {
        this.applyCustomStyle = this._applyStyle;
    }

    var _this = this;

    if (this.watch) {
                //   alert(this._event);
        this.element.on(this._event, function (event) {

            this._isTouched = true;
            _this.validate();
        });
    }

    this.validate = function () {
        var fieldValue = this.element.val();
        if(this._isCustomValidation && this.required){
       
          this.customValidate(this);
          if (fieldValue == null || fieldValue == "") {
              this.error = this.name + " cannot be empty";
              this.isValid = false;

              // field is required and is not null run the test
          } else if (fieldValue != null) {
              this.customValidate(this);
          }
        } else if(this._isCustomValidation){
          this.customValidate(this);
          // Test if it is required and needs validation
        } else if (this.required && this.validator) {
            // console.log(`${this.id} is required and needs validation`); if field is required and is null its not valid
            if (fieldValue == null || fieldValue == "") {
                this.error = this.name + " cannot be empty";
                this.isValid = false;
                // field is required and is not null run the test
            } else if (fieldValue != null) {
                this.isValid = this.regex.test(fieldValue);
                this.isValid
                    ? this.error = null
                    : this.error = this.name + " is in an invalid format";
            } else {
                this.error = this.error = this.name + " is in an invalid format";
                this.isValid = false;
            }
            //Test if the field is required only
        } else if (this.required) {
            // console.log(`${this.id} is required `);
            if (fieldValue != "" && fieldValue != null) {
                this.error = null;
                this.isValid = true;
            } else {
                this.error = this.name + " cannot be empty";
                this.isValid = false;
            }

            //Test if the field is valid
        } else if (this.validator) {
            // console.log(`${this.id} needs validation`);
            if(fieldValue != ""){
                this.isValid = this.regex.test(fieldValue);
                this.isValid
                    ? this.error = null
                    : this.error = this.error = this.name + " is in an invalid format";
                } else {
                    this.isValid = true;
                    this.error = null;
                }
                
        } else {
          this.error = null;
        }



        // apply the appropriate style
        this.applyCustomStyle(this.element, this.isValid);
        // console.log(this);o
        return this.isValid;
    };

    if(field.customValidator && typeof field.customValidator === "function"){
      this.customValidate = field.customValidator
      this._isCustomValidation = true;
    } else {
      this.checkValidation = null;
      this._isCustomValidation = false;

    }

};

var ValidationEngine = function (validationFieldObject) {

    // region Constructor
    this.name = validationFieldObject.name || null;
    this.error = null;
    this._validationFields = validationFieldObject.fields;
    this._validators = [];
    this._validatorsMap = {};
    this._runOnLoad = false;
    this._defaultEvent = validationFieldObject.defaultEvent || null;
    this._form = validationFieldObject.form || null;

    if (typeof validationFieldObject.defaultStyle === "function") {
        this._validationFields = this._validationFields.map(function (e) {
            if (e.applyCustomStyle && typeof e.applyCustomStyle === "function") {
                return e
            };
            e.applyCustomStyle = validationFieldObject.defaultStyle;
            return e;
        })
    };

    if (this._defaultEvent) {
        this._validationFields = this._validationFields.map(function (e) {
            if (e.event) {
                return e
            };
            e.event = this._defaultEvent;
        })
    }

    var _this = this;

    if (this._form) {
        this.validationFields = this._validationFields.map(function (e) {
            e._form = _this._form;
            return e;
        })
    }

    // This Mapper has the validation regex rules Any new regex for a particular validator goes here
    // Adding phone extn for 11246 - To prevent users from entering anything other than numbers
    this._regexMap = {
        Phone: /^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$/,
        PhoneExtn: /^[0-9,\.]+$/, 
        Email: /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/,
        SSN: /^(\d{3}-?\d{2}-?\d{4}|XXX-XX-XXXX|\*\*\*\*\*)$/,
        Date: /^((0?[13578]|10|12)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[01]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1}))|(0?[2469]|11)(-|\/)(([1-9])|(0[1-9])|([12])([0-9]?)|(3[0]?))(-|\/)((19)([2-9])(\d{1})|(20)([01])(\d{1})|([8901])(\d{1}))|(07\/07\/1777))$/,
        Number: /^(\d+(\.\d{1,2})?|\.\d{1,2})$/,
        Zip: /^[0-9]{5}(?:-[0-9]{4})?$/,
       // SSN_LastFour: /^[*]{5}\d{4}$/,  // To validate last 4 of SSN
       "Text-Only" : /^[A-z ]+$/     
    };
    // endregion

    this._buildValidators = function () {
        var _this = this;
        this._validators = [];
        this._validatorsMap = {};
        for (var i = 0; i < this._validationFields.length; i++) {
            var field = this._validationFields[i];
            field.engineScope = this;
            field.validator
                ? field.regex = _this._regexMap[field.validator]
                : field.regex = null;
            var validator = new Validator(field);
            _this._validators.push(validator);
            _this._validatorsMap[validator.id] = validator;
        }
    }

    this._buildValidators();

    // Valdion engine
    this.runValidations = function () {
        for (var i = 0; i < this._validators.length; i++) {
            var validator = this._validators[i];
            validator.validate();

        }
    };

    this.checkRequiredFields = function () {
        console.log('coming here');
        var isSuccess = true;
        $.each($('input,textarea,select').filter('[required]:visible'), function () {
            if ($(this).val() == '') {
                isSuccess = false;
            }
        });
        return isSuccess;
    }

    // returns the list of validators
    this.validators = function () {
        this.runValidations();
        return this._validators;
    };

    // region helpers
    this.validatorsMap = function () {
        this.runValidations();
        return this._validatorsMap;
    }

    this.errors = function () {
        this.runValidations();
        return this._validators.map(function (e) {
            return e;
        }).filter(function (e) {
            return !e.isValid
        })
    }

    this.errorHtml = function () {
        return "<ul>" + this.errors().map(function (e) {
            return "<li>" + e.error + "</li>"
        }).join("") + "</ul>";
    };

    this.performValidation = function () {
        if (this.errors().length <= 0) {

            this._onSucess();
        } else {
            this._onFailure()
        }
    }

    this.displayErrorModal = function () {
        //event.preventDefault();
        OH_MODAL_UTILITY.errorMessageModal(this.errorHtml());
    };

    this._onSucess = validationFieldObject.onValidationSuccess || null;
    this._onFailure = validationFieldObject.onValidationFailure || this.displayErrorModal;

    // this.performValidation = new Promise() endRegion

};

var ValidationManager = function(obj){
  this.validationEngines = [];
  this.validationEnginesMap = {};

  this._engineKeys = [];

  this._buildEngines = function(){
    for(var i = 0 ; i < obj.validators.length; i++){
      var engine = new ValidationEngine(obj.validators[i]);
      this.validationEngines.push(engine);
      this.validationEnginesMap[engine.name] = obj.validators[i];
    }
  }

  this.addEngine = function(engine){

  };

  this.removeEngine = function(){


  }

  this._testDupes = function(engine){
    if(this._engineKeys.indexOf(engine.name) > -1){
      throw "Cannot add validation engine with the same name as previously defined"
      return false;
    } else {
      return true;
    }
  }

  this._buildEngines();

};