({
    init: function (component, event, helper) {
        console.log('init method');

        helper.eraseHelper(component, event, helper);

    },

    erase: function (component, event, helper) {
        console.log('erase called');
        helper.eraseHelper(component, event, helper);
    },

    save: function (component, event, helper) {
        console.log('Save Method Called');

        helper.saveHelper(component, event, helper);

    },
    onNext: function (component, event, helper) {
        component.set("v.showSign", true);
    },
    closeModal: function (component, event, helper) {
        helper.closeAndNavigate(component, false);
    },
    cancelModal: function (component, event, helper) {
        console.log('Cancel Modal Called');
        helper.closeAndNavigate(component, false);
    },
    showSpinner: function (component, event, helper) {
        component.set("v.Spinner", true);
    },
    hideSpinner: function (component, event, helper) {
        component.set("v.Spinner", false);
    }
})