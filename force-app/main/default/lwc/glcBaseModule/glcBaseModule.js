/* eslint-disable no-debugger */
/* eslint-disable no-unused-vars */
/* eslint-disable dot-notation */
/* eslint-disable no-console */
//import logApplicationError from '@salesforce/apex/ISD_BaseSuperController.logApplicationError';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const label = {
    "GLC_ErrorMessageMasked": "No|An unexpected error occurred. Please contact your administrator",
    "GLC_ErrorLog": "No|No|Yes|Yes",
    "GLC_ConsoleLog": "Yes|Yes"
};

/**
 * To display message/error in browser console
 * @param {string} message - message to be displayed in the console
 * @param {object} params - list of params
 *                     (1). berror - indicates error message
 *                     (2). blogerror - indicates whether the error should be logged in Generic Log object
 * @return {void}
 * Author: John Wesly
 */
const consoleLog = (message, params) => {
    let berror = (params !== undefined && params.berror !== undefined) ? params.berror : false;
    let blogerror = (params !== undefined && params.blogerror !== undefined) ? params.blogerror : false;
    let sconsolelog = label.GLC_ConsoleLog;
    let [sshowerror, sshowmessage, slogerror] = sconsolelog.split("|");
    /* Show error in console */
    if(berror) {
        if(sshowerror === "Yes")
            console.error(message);
        /* Log error in the Generic Log object */
        if(blogerror && slogerror === "Yes")    {
            this.errorLogger();
        }
    }
    /* Show message in console (string or table) */
    else {
        if(sshowmessage === "Yes") {
            if (((Array.isArray(message) && typeof(message[0]) === "object")) && (console.table !== undefined)) {
                console.table(message);
            } else {
                console.log(message);
            }
        }
    }
};
/**
 * Reduces one or more LDS errors into a string[] of error messages.
 * @param {FetchResponse|FetchResponse[]} errors
 * @return {String[]} Error messages
 * Author: John Wesly 10-May-2019 (copied from LWC recipes)
 */
const reduceErrors = (errors) => {
    if (!Array.isArray(errors)) {
        errors = [errors];
    }

    return (
        errors
            // Remove null/undefined items
            .filter(error => !!error)
            // Extract an error message
            .map(error => {
                // UI API read errors
                if (Array.isArray(error.body)) {
                    return error.body.map(e => e.message);
                }
                // UI API DML, Apex and network errors
                else if (error.body && typeof error.body.message === 'string') {
                    return error.body.message;
                }
                // JS errors
                else if (typeof error.message === 'string') {
                    return error.message;
                }
                // Unknown error shape so try HTTP status text
                return error.statusText;
            })
            // Flatten
            .reduce((prev, curr) => prev.concat(curr), [])
            // Remove empty strings
            .filter(message => !!message)
    );
};

/*
* Function to invoke Apex controller method to log the error in Generic Log record.
* @
*/
// eslint-disable-next-line no-unused-vars
const errorLogger = (source, component, apexmethod, callstack, request, response, state) => {
    try{
        let [smaskmsgtoui, smaskmsgtext]  = label.GLC_ErrorMessageMasked.split("|");
        let [sloglightningerrortoobject, sloglightningerrortoui, slogapexerrortoobject, slogapexerrortoui]  = label.GLC_ErrorLog.split("|");
        let slogerrortoobject = (source === "Lightning" ? sloglightningerrortoobject : (source === "Apex" ? slogapexerrortoobject : "No"));
        let slogerrortoui = (source === "Lightning" ? sloglightningerrortoui : (source === "Apex" ? slogapexerrortoui : "No"));
        
        if(slogerrortoobject === "Yes" || slogerrortoui === "Yes")  {
            let maperrorinfo = new Map();
            if(source === "Apex")   {
                let serror = '';
                switch(state)    {
                    case "success":
                        if(response.mapErrorInfo !== undefined)   {
                            maperrorinfo = response.mapErrorInfo;
                        }
                        maperrorinfo["Response JSON"] = JSON.stringify(response.objectData);
                        break;
                    case "error":
                        reduceErrors(response).forEach(element => {
                            serror += `${element} `;
                        });
                        maperrorinfo["Error Message"] = serror.trim();
                        maperrorinfo["Severity"] = "High";
                        break;
                    default:
                        break;
                }
                
                /* Get calling component name & method stack */
                maperrorinfo["Component Name"] = component.toString();
                maperrorinfo["Component Method"] = callstack;
                
                maperrorinfo["Class Method"] = apexmethod;
                maperrorinfo["Request JSON"] = JSON.stringify(request);
            }
            /*if(source === "Lightning")  {
                pending - might be introduced later 
            }*/
            
            /* Get device information */
            //var sDevice = $A.get("$Browser.formFactor");
            //maperrorinfo["Device"] = sDevice;
            
            /* Get browser information */
            //maperrorinfo["Browser"] = navigator.userAgent;
            //maperrorinfo["Language"] = navigator.language;
            
            consoleLog("maperrorinfo:" + JSON.stringify(maperrorinfo));
            /* Condition to avoid recursive server call */
            if(apexmethod !== "logApplicationError")    {
                /* Show error message in UI as toast notification */
                if(slogerrortoui === "Yes") {
                    let sfinalerrmsg = (smaskmsgtoui === "Yes") ? smaskmsgtext : maperrorinfo["Error Message"];
                    const evnt = new ShowToastEvent({
                        title: `${source} Error`,
                        message: sfinalerrmsg,
                        variant: "error",
                        mode: "pester"
                    });
                    dispatchEvent(evnt);
                }
                /* Create error log record through an async call */
                /*if(slogerrortoobject === "Yes") {
                    logApplicationError({"sErrorInfoFromComp" : JSON.stringify(maperrorinfo)})
                        .then(promiseresult => {
                            if(promiseresult.mapErrorInfo.length > 0)    {
                                let sactualerror = maperrorinfo["Error Message"];
                                let sinnererror = promiseresult.mapErrorInfo !== undefined ? promiseresult.mapErrorInfo["Error Message"] : "";
                                let sfinalerrmsg = `Actual Error: ${sactualerror} \n Inner Error: ${sinnererror}`;
                                const evnt = new ShowToastEvent({
                                    title: "Application Log Error",
                                    message: sfinalerrmsg,
                                    variant: "error",
                                    mode: "pester"
                                });
                                dispatchEvent(evnt);
                            }
                        })
                        .catch(promiseerror => {
                        });
                } */
            }
        }
    }
    catch(e){
        consoleLog(e.stack, {"berror":true});
    }
};

/**
* Function to invoke any Apex controller method imperatively.
* @param {string} lwccomponent - instance of the LWC component invoking the apex controller
* @param {string} apexmethod - name of the Apex controller @AuraEnabled method
* @param {object} apexmethodinputs - object containing the list of inputs to the Apex controller method
* @return {void}
* Author: John Wesly 10-May-2019
*/
const handleApexImpCall = (lwccomponent, apexmethod, callback, apexmethodinputs) =>  {
    try{
    /* Get the javascript call stack */
    let scallstack = "";
    try {   throw new Error();  }   catch(e)    {   scallstack = String(e.stack);   }
    let scallstackfinal = scallstack.slice(0, scallstack.indexOf("at callHook")).trim();
    
    /* Invoke the Apex controller method as promist */
    apexmethod(apexmethodinputs)
        .then(promiseresult => {
            console.log('returned from apex method');
            if(promiseresult.isSuccessful) {
                let promiseResponse = JSON.parse(JSON.stringify(promiseresult));
                callback(promiseResponse);
            }
            else{
                errorLogger('Apex', lwccomponent, apexmethod, scallstackfinal, apexmethodinputs, promiseresult, 'success');
            }
        })
        .catch(promiseerror => {
            errorLogger('Apex', lwccomponent, apexmethod, scallstackfinal, apexmethodinputs, promiseerror, 'error');
        });
    }
    catch(e){
        consoleLog(e.stack, {berror: true});
    }
};

export { 
    consoleLog, 
    handleApexImpCall
};