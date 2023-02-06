//****************************************************************************************************************************
//*    DATE    * DEV NAME *                                    TFS NUMBER / DESC
//****************************************************************************************************************************
//* 06/07/2017 *  AndrewL * TFS_9666 - if PGFQuestionsComp component questions, add in asterisk to beginning of question as 
//*			   *		  *            they are required.
//10/23/2018	Rohit Gowrishetty		- CR #14585 - Added new Question type like instruction 
//12/7/2018 	Rohit Gowrishetty		- CR #14913 - Added Astrisk symbol for Text box too. 
//07/11/2019 	Vijay Gurusamy			- CR #9480 - OCLQS Provider Portal fields asking for numbers allows any character. 
//09/21/2019 	Sujith Balakrishnan	    - CR #15121 - Changing the default site questions to "Select"
//**************************************************************************************************************************** 
// Global variables
var domainArray = {};
var otherCheckboxArray = [];

// Questions Component Namespace
;QUESTIONSCOMPNS = {

    getDepedentFields: function() {
        if(licGlobalObj.currentRecId != null) {
            var fieldsQuery = 'SELECT Id';
            $.each(questionsList, function(i, val) {
                if((val.parentFieldObject == currObjName) && (val.parentField != null)) {
                    fieldsQuery = fieldsQuery + ', ' + val.parentField;
                }
                $.each(val.childQueList, function(j, val2) {
                    if((val2.parentFieldObject == currObjName) && (val2.parentField != null)) {
                        fieldsQuery = fieldsQuery + ', ' + val2.parentField;
                    }
                });
            });
            fieldsQuery = fieldsQuery + " FROM " + currObjName + " WHERE Id = '" + licGlobalObj.currentRecId + "'";
            var resultDependentFields = sforce.connection.query(fieldsQuery);
            recordsDependentFields = resultDependentFields.getArray("records");

            $.each(questionsList, function(i, val) {
                if(val.parentFieldObject == currObjName) {
                    if(val.parentField != null) {
                        if(val.qualifyingResponseForField == eval('recordsDependentFields[0].' + val.parentField)) {
                            val.show = true;
                        }
                        else {
                            val.show = false;
                        }
                    }
                    else {
                        val.show = true;
                    }
                }
                else if(val.parentFieldObject != null) {
                    val.show = false;
                }
                else {
                    val.show = true;
                }
                $.each(val.childQueList, function(j, val2) {
                    if(val2.parentFieldObject == currObjName) {
                        if(val2.parentField != null) {
                            if(val2.qualifyingResponseForField == eval('recordsDependentFields[0].' + val2.parentField)) {
                                val2.show = true;
                            }
                            else {
                                val2.show = false;
                            }
                        }
                        else {
                            val2.show = true;
                        }
                    }
                    else if(val2.parentFieldObject != null) {
                        val2.show = false;
                    }
                    else {
                        val2.show = true;
                    }
                });
            });
        }
    },
    

    /* Get data, build marup and inject */
    loadRecords: function() {
        // Initialize variables
        var innerHtml = '';
        var innerHtml2 = '';
        var domainMarkup = '';

        // Empty list
        $("#injectQuestionMarkup").empty();

        try {

            // Domain management
            var currentDomain = '';
            var domainNum = 0;
            var formGroupAnswerArray = [];

            // Loop through parent questions
            $.each(questionsList, function(i, val) {
            var isQuestionAnswerd = 'NO' ;
            if(val.answerId != null )
            {
	            isQuestionAnswerd = 'YES' ;
            }

                if(val.show) {

                    // Remove null values
                    if (val.answerText == null) {
                        val.answerText = '';
                    }
                    if (val.answerComment == null) {
                        val.answerComment = '';
                    }

                    // If domain has changed
                    if(currentDomain != val.domain) {
                        currentDomain = val.domain != null ? val.domain : '' ;
                        domainNum += 1;
                        domainArray[domainNum] = currentDomain;

                        innerHtml += '<section id="question-domain-' + domainNum + '" class="question-domain less-spacing">'
                                + '<div class="row">'
                                + '<div class="col-sm-4">'
                                + '<h2>' + currentDomain + '</h2>'
                                + '</div>'
                                + '<div class="col-sm-8">'
                                + '<div class="injectQuestions">';

                         if(domainNum == 1) {
                         	if(currentDomain != ''	)
                         	{
                             domainMarkup += '<a href="#question-domain-' + domainNum + '" class="active">' + currentDomain + '</a>';
                            }
                         }
                         else {
                             if(currentDomain != ''	)
                         	{
                             domainMarkup += '<a href="#question-domain-' + domainNum + '">' + currentDomain + '</a>';
                            }
                         }
                    }


                    // If multiple options type of question
                    if(val.questionType == 'Multiple Options') {
                        // Build parent question markup
						// TFS_9666 - checked subsection component, if PGFQuestionsComp, add asterisk
						innerHtml += '<div class="form-group parent_oclqs_multiselect_question_container" id="multiselect_group_'+val.id+'"><div class=""><label class="multiselect_question_body">' + '* ' + val.questionBody + '</label></div>';
                        
                        // Build response options
                        var responseNum = 0;
                        var hasOther = false;
                        $.each(val.possibleResponses, function(k, val3) {
                            responseNum += 1;
                            innerHtml += '<div class="styled-checkbox"><label class="helper-label"><input class="helper-label" type="checkbox" id="ckbox' + responseNum + val.id + '"/>&nbsp;' + val3 + '</label></div>';

                            if(val3.indexOf('If \'Other\', explain') >= 0) { 
                                //console.log(val3);
                                hasOther = true;
                            }
                        });

                        // Enclose markup
                        if(hasOther) {
                            innerHtml += '<div class="form-child-panel parentQueOther' + val.id + '" style="display:none;"><label>Other</label><textarea class="form-control form-textarea-fixed" rows="4" placeholder="Please enter comments here..." id="parentQueComment' + val.id + '">' + val.answerComment + '</textarea></div>';
                        }
                        innerHtml += '<div class="form-child-panel parentQue' + val.id + '" style="display:none;"></div>';
                    }
                    else if(val.questionType == 'Single Option') {

                        // Build parent question markup
                        innerHtml += '<div class="form-group"><div class=""><label>' + val.questionBody + '</label></div>';

                        // Build response options
                        var responseNum = 0;
                        $.each(val.possibleResponses, function(k, val3) {
                            responseNum += 1;
                            innerHtml += '<div class="radio-wrap"><input type="radio" class="questionRadio" id="radio' + responseNum + val.id + '" name="radio' + val.id + '"/><label for="radio' + responseNum + val.id + '">' + val3 + '</label></div>';
                        });

                        // Enclose markup
                        innerHtml += '<div class="form-child-panel parentQueComment' + val.id + '" style="display:none"><label></label><textarea class="form-control form-textarea-fixed" rows="4" placeholder="Please enter comments here..." id="parentQueComment' + val.id + '">' + val.answerComment + '</textarea></div><div class="form-child-panel parentQue' + val.id + '" style="display:none;"></div>';
                    }
                    // If picklist

                    else if (val.questionType == 'Picklist') {
                        // Build parent question markup
                        //TFS#15121 Starts
                        PicklistDefault="--Select--";
                        innerHtml += '<div class="form-group-inanimated form-group label-normal parent_oclqs_question_container"> <input type="hidden" class="ParentquestionUserResponseCollected" value="'+ isQuestionAnswerd +'" id="' + val.id + '" /><input type="hidden" class="questionBodyContent" value=" ' + val.questionBody +'"/> <label class="parentQuestionLabel">' + '* ' + val.questionBody + '</label><select class="selectpicker questionPkList form-control wide-fix" id="parentPkListAns' + val.id + '"><option value="" selected>'+PicklistDefault+'</option>'
                       //TFS#15121 Starts
                        // Add picklist values
                        $.each(val.possibleResponses, function(k, val3) {
                            innerHtml += '<option value="' + val3.trim() + '">' + val3.trim() + '</option>';
                        });

                        innerHtml += '</select></div><div class="form-child-panel parentQueComment' + val.id + '" style="display:none"><label></label><textarea class="form-control form-textarea-fixed" rows="4" placeholder="Please enter comments here..." id="parentQueComment' + val.id + '">' + val.answerComment + '</textarea></div><div class="form-child-panel parentQue' + val.id + '" style="display:none"></div>';
                    }
                    // If text       
                    else if (val.questionType == 'Text') {
                        // Build parent question markup
                        innerHtml += '<div class="form-group"><div class="row parent_oclqs_textarea_question" id="textarea_group_'+val.id+'"><label class="textarea_question_body">' + '* ' + val.questionBody + '</label></div><div class="parent_oclqs_textarea_question_container"><input type="text" class="form-control questionText" id="parentTextAns' + val.id + '" value="' + val.answerText.trim() + '"/></div>'; 
                    }
					// If number
                    //9480
                    else if (val.questionType == 'Number') {
                        // Build parent question markup
                        innerHtml += '<div class="form-group"><div class="row parent_oclqs_textarea_question" id="textarea_group_'+val.id+'"><label class="textarea_question_body">' + '* ' + val.questionBody + '</label></div><div class="parent_oclqs_textarea_question_container"><input type="number" class="form-control questionNumber" onkeydown="javascript: return event.keyCode == 69 || event.keyCode == 187 || event.keyCode == 189 || event.keyCode == 190 ? false : true" min="0" id="parentTextAns' + val.id + '" value="' + val.answerText.trim() + '"/></div>'; 
                    }
                    if(questionsList[i+1] != null)
                        if(currentDomain != questionsList[i+1].domain) {
                            innerHtml += '</div></div></div></section>';
                        }
                }

                // Re-initialize markup variable
                //innerHtml = '';

            });

            // Inject parent markup
            $("#injectQuestionMarkup").append(innerHtml);

            // Inject domains
            $("#section-nav").append(domainMarkup);

            $.each(questionsList, function(i, val) {
                // Loop through child questions
                $.each(val.childQueList, function(j, val2) {

                    // Remove null values
                    if (val2.answerText == null) {
                        val2.answerText = '';
                    }
                    if (val2.answerComment == null) {
                        val2.answerComment = '';
                    }

                    // If multiple options type of question
                    if(val2.questionType == 'Multiple Options') {
						// TFS_9666 - checked subsection component, if PGFQuestionsComp, add asterisk
                        // Build parent question markup
                        innerHtml2 += '<div class="form-group"><div class=""><label>' + '* ' + val2.questionBody + '</label></div>';

                        // Build response options
                        var responseNum = 0;
                        var hasOther = false;
                        $.each(val2.possibleResponses, function(k, val3) {
                            responseNum += 1;
                            innerHtml2 += '<div class="styled-checkbox"><label class="helper-label"><input class="checkboxQ" type="checkbox" id="ckbox' + responseNum + val2.id + '"/>&nbsp;' + val3 + '</label></div>';

                            if(val3.indexOf('If \'Other\', explain') >= 0) {
                                hasOther = true;
                            }
                        });

                        // Enclose markup
                        if(hasOther) {
                            innerHtml2 += '<div class="form-child-panel parentQueOther' + val2.id + '" style="display:none;"><label>Other</label><textarea class="form-control form-textarea-fixed" rows="4" placeholder="Please enter comments here..." id="parentQueComment' + val2.id + '">' + val2.answerComment + '</textarea></div>';
                        }
                        innerHtml2 += '<div class="form-child-panel parentQue' + val2.id + '" style="display:none;"></div>';
                    }
                    else if(val2.questionType == 'Single Option') {

                        // Build parent question markup
                        innerHtml2 += '<div class="childQue' + val2.id + '" style="display:none"><div class="form-group"><div class=""><label>' + val2.questionBody + '</label></div>';

                        // Build response options
                        var responseNum = 0;
                        $.each(val2.possibleResponses, function(k, val3) {
                            responseNum += 1;
                            innerHtml2 += '<div class="radio-wrap"><input type="radio" class="questionRadio" id="radio' + responseNum + val2.id + '" name="radio' + val2.id + '"/><label for="radio' + responseNum + val2.id + '">' + val3 + '</label></div>';
                        });

                        // Enclose markup
                        innerHtml2 += '<div class="form-child-panel parentQueComment' + val2.id + '" style="display:none"><label></label><textarea class="form-control form-textarea-fixed" rows="4" placeholder="Please enter comments here..." id="parentQueComment' + val2.id + '">' + val2.answerComment + '</textarea></div><div class="form-child-panel parentQue' + val2.id + '" style="display:none;"></div></div>';
                    }
                    // If Picklist type of question
                    else if (val2.questionType == 'Picklist') {
                    	// TFS_9666 - checked subsection component, if PGFQuestionsComp, add asterisk
                        // Build parent question markup
                        innerHtml2 += '<div class="childQue' + val2.id + '" style="display:none"><div class="form-group-inanimated label-normal"><label>' + '* ' + val2.questionBody + '</label><select class="selectpicker questionPkList form-control wide-fix" id="parentPkListAns' + val2.id + '"><option value="">--None--1</option></select></div></div>';
                    }
                    // If text type of question
                    else if (val2.questionType == 'Text') { //14913 -  Added astrisk symbol for text fields too. 
                        // Build parent question markup
                        innerHtml2 += '<div class="childQue' + val2.id + '" style="display:none"><div class="form-group"><div class=""><label for="textAns' + val2.id + '">' + '* ' +  val2.questionBody + '</label></div><div class=""><input type="text" class="form-control questionText" id="textAns' + val2.id + '" value="' + val2.answerText.trim() + '"/></div><div class="parentQue' + val2.id + '" style="display:none"></div></div>';
                    }else if(val2.questionType == 'Instruction'){ //14858
                        
                        innerHtml2 += '<div class="childQue' + val2.id + '" style="display:none"><div class="form-group"><div class=""><label for="textAns' + val2.id + '">' + val2.questionBody + '</label></div><div class="parentQue' + val2.id + '" style="display:none"></div></div>';
                    
                    }                    
                    // Inject parent markup
                    $(".parentQue" + val.id).append(innerHtml2);

                    // Add picklist values
                    var picklistHtml2 = '';
                    $.each(val2.possibleResponses, function(k, val3) {
                        picklistHtml2 += '<option value="' + val3.trim() + '">' + val3.trim() + '</option>';
                    });
                    $("#parentPkListAns" + val2.id).append(picklistHtml2);

                    // Re-initialize markup variable
                    innerHtml2 = '';
                });
            });

            // Update UI with previous answers, except for multiple options
            $.each(questionsList, function(i, val) {

                // If answers are saved
                if (val.answerText != null && val.answerText != '') {
                    // Set answers
                    if (val.questionType == 'Yes_No') {

                        if (val.answerText == 'Yes') {
                            $("#radioY" + val.id).prop("checked", true);
                            $("#radioN" + val.id).prop("checked", false);
                        } else if (val.answerText == 'No') {
                            $("#radioY" + val.id).prop("checked", false);
                            $("#radioN" + val.id).prop("checked", true);
                        }
                    }
                    else if (val.questionType == 'Picklist') {
                        $("#parentPkListAns" + val.id).val(val.answerText.trim());
                    }
                    else if (val.questionType == 'Multiple Options') {
                        formGroupAnswerArray.push({
                            formGroup: val.id,
                            answer: val.answerText
                        });
                    }

                    if (val.answerText == val.triggeringResponseForComment) {
                        $(".parentQueComment" + val.id).show();
                    }


                }

                $.each(val.childQueList, function(j, val2) {

                    // Only process child answers with existing parent answer
                    if (val.answerText == null || val.answerText == '') {
                        return;
                    }
                    if (val.answerText == val2.triggeringParentAnswer || val2.triggeringParentAnswer.indexOf(val.answerText) > -1) {
                        $(".childQue" + val2.id).show();
                        $(".parentQue" + val.id).show();
                    }

                    if (val2.answerText != null && val2.answerText !='') {
                        // Set answers
                        if (val2.questionType == 'Yes_No') {

                            if (val2.answerText == 'Yes') {
                                $("#radioY" + val2.id).prop("checked", true);
                                $("#radioN" + val2.id).prop("checked", false);
                            } else if (val2.answerText == 'No') {
                                $("#radioY" + val2.id).prop("checked", false);
                                $("#radioN" + val2.id).prop("checked", true);
                            }
                        }
                        else if (val2.questionType == 'Picklist') {
                            $("#parentPkListAns" + val2.id).val(val2.answerText.trim());
                        }
                        else if (val2.questionType == 'Multiple Options') {
                            formGroupAnswerArray.push({
                                formGroup: val2.id,
                                answer: val2.answerText
                            });
                        }

                        if (val2.answerText == val2.triggeringResponseForComment) {
                            $(".parentQueComment" + val2.id).show();
                        }
                    }
                });
            });

            for (var i = 0; i < formGroupAnswerArray.length; i++) {
                QUESTIONSCOMPNS.renderAnswers(formGroupAnswerArray[i].formGroup, formGroupAnswerArray[i].answer);
            }
            QUESTIONSCOMPNS.loadDynEvents();
        }
        catch(e) { 
            console.log(e); 
        }
    },

    /* Load all dynamic events */
    loadDynEvents: function() {

		$(".checkboxQ").on("change", function() {
            var currentId = $(this).attr("id");
            if(currentId.length == 24){
                currentId = currentId.substring(6, currentId.length);
            }
            else if(currentId.length == 25) {
                currentId = currentId.substring(7, currentId.length);
            }

            if(this.checked) {
                if($(this).parent().text().trim().indexOf('If \'Other\', explain') >= 0) {
                    $(".parentQueOther" + currentId).show();
                }
            }
            else {
                if($(this).parent().text().trim().indexOf('If \'Other\', explain') >= 0) {
                    $(".parentQueOther" + currentId).hide();
                }
            }
        });

        //START Added by Gaurav For bug # 8557-
        $(".helper-label").on("click", function() {
		    var currentObjId = $(this).attr("id");
		    if (currentObjId != undefined) {
		        var currentAnswer = $("#" + currentObjId)[0].parentElement.innerText;
		        var state = $("#" + currentObjId)[0].checked;
		        currentAnswer = currentAnswer.trim();
		        currentObjId = currentObjId.substring(6, currentObjId.length);
		        $.each(questionsList, function(i, val) {
		            if (val.id == currentObjId) {
		                $.each(val.childQueList, function(j, val2) {
		                	    if (val2.triggeringParentAnswer != null && val2.triggeringParentAnswer == currentAnswer) {
			                    if(state == true){
			                        $(".parentQue" + val.id).show();
			                    } else {
			                        $(".parentQue" + val.id).hide();
			                    }
		                    }
		                });
		            }
		        });
		    }
		});
        //END Added by Gaurav For bug # 8557

        // Event to capture parent question's answer
        $(".questionRadio").on("click", function() {
            var currentObjId = '';
            var currentAns = '';
            currentObjId = $(this).attr("id");

            currentAns = $(this).parent().find('label').text();

            // If yes
            // if (currentObjId.indexOf('radioY') >= 0) { currentAns = 'Yes'; }
            // // If no
            // else if (currentObjId.indexOf('radioN') >= 0) { currentAns = 'No'; }

            // Process
            currentObjId = currentObjId.substring(6, currentObjId.length);

            $.each(questionsList, function(i, val) {
                if (val.id == currentObjId) {

                    if (val.triggeringResponseForComment == currentAns) {
                        $(".parentQueComment" + val.id).show();
                    } else {
                        $(".parentQueComment" + val.id).hide();
                    }

                    QUESTIONSCOMPNS.showHideChildQuestions(val, currentAns, currentObjId);
                }

                $.each(val.childQueList, function(j, val2) {
                    if (val2.id == currentObjId) {
                        if (val2.triggeringResponseForComment == currentAns) {
                            $(".parentQueComment" + val2.id).show();
                        } else {
                            $(".parentQueComment" + val2.id).hide();
                        }
                    }
                });
            });
        });

        $(".questionPkList").on("change", function() {
            var currentAns = $(this).val();
            var currentObjId = '';
            currentObjId = $(this).attr("id");
            currentObjId = currentObjId.substring(15, currentObjId.length);
            $.each(questionsList, function(i, val) {
                if (val.id == currentObjId) {
                    if (val.triggeringResponseForComment == currentAns) {
                        $(".parentQueComment" + val.id).show();
                    } else {
                        $(".parentQueComment" + val.id).hide();
                        $(".parentQue" + val.id).find(".checkboxQ").each(function() {
                            $(this).prop("checked", false);
                        });
                    }

                    QUESTIONSCOMPNS.showHideChildQuestions(val, currentAns, currentObjId);
                }

                $.each(val.childQueList, function(j, val2) {
                    if (val2.id == currentObjId) {
                        if (val2.triggeringResponseForComment == currentAns) {
                            $(".parentQueComment" + val2.id).show();
                        } else {
                            $(".parentQueComment" + val2.id).hide();
                            $(".parentQue" + val2.id).find(".checkboxQ").each(function() {
                                $(this).prop("checked", false);
                            });
                        }
                    }
                });
            });
        });
    },

    /* Load all events */
    loadEvents: function() {
        // Event to capture parent question's answer
        $("#saveQuestionsSection").on("click", function() {
            QUESTIONSCOMPNS.saveRecords();
            QUESTIONSCOMPNS.handleReloadPage();
        });
    },

    /* Show or hide child questions */
    showHideChildQuestions: function(parentQueObj, currentAns, currentObjId) {

        var hasChildQuestions = false;

        $.each(parentQueObj.childQueList, function(j, val2) {

            $.each(val2.triggeringResponses, function(k, val3) {

                if (val3.trim() == currentAns.trim()) {
                    hasChildQuestions = true;
                }

                if (parentQueObj.id == currentObjId) {
                    if (val3 == currentAns) {
                        $(".childQue" + val2.id).show();
                    } else {
                        $(".childQue" + val2.id).hide();
                    }
                } else if (val2.id == currentObjId) {
                    if (val2.triggeringResponseForComment == currentAns) {
                        $(".parentQueComment" + val2.id).show();
                    } else {
                        $(".parentQueComment" + val2.id).hide();
                    }
                }
            });
        });

        if (hasChildQuestions) {
            $(".parentQue" + parentQueObj.id).show();
        }
        else {
            $(".parentQue" + parentQueObj.id).hide();

            $.each(parentQueObj.childQueList, function(j, val2) {
                try {
                    $("#radioY" + val2.id).prop("checked", false);
                    $("#radioN" + val2.id).prop("checked", false);
                    $("#parentPkListAns" + val2.id).val('');
                    $("#textAns" + val2.id).val('');
                    $("#parentQueComment" + val2.id).val('');
                    $(".parentQueComment" + val2.id).hide();
                }
                catch(e) { 
                    console.log(e); 
                }
            });
        }
    },

    /* Save answers to Answer object */
    saveRecords: function() {
        // Initialize list
        var answersList = [];

        // Loop through parent questions
        $.each(questionsList, function(i, val) {

            if(val.show) {

                // Initialize object of Answer object
                var ansObj = new sforce.SObject("Answer__c");
                ansObj.AssociatedQuestion__c = val.id;
                ansObj.Program_Transaction__c = transactionId.trim();
                ansObj.Answer_Text__c = '';
                ansObj.Comment__c = '';

                // Added this block to reset validation factor
                if(ansObj.AssociatedQuestion__c != null )
                {
                	 $("#"+ ansObj.AssociatedQuestion__c ).val("NO") ;
                }

                // If Yes-No type of question
                if (val.questionType == 'Single Option') {
                    var responseNum = 0;
                    var numResponses = val.possibleResponses.length;
                    while(responseNum < numResponses) {
                        responseNum += 1;
                        if ($("#radio" + responseNum + val.id).is(':checked')) {
                            ansObj.Answer_Text__c = $("#radio" + responseNum + val.id).parent().find('label').text().trim();
                            val.answerText = ansObj.Answer_Text__c;
                        }
                    }
                    // Add comment
                    val.answerComment = $("#parentQueComment" + val.id).val();
                    ansObj.Comment__c = $("#parentQueComment" + val.id).val();
                }
                else if (val.questionType == 'Multiple Options') {
                    var responseNum = 0;
                    var numResponses = val.possibleResponses.length;
                    while(responseNum < numResponses) {
                        responseNum += 1;
                        if ($("#ckbox" + responseNum + val.id).is(':checked')) {
                            ansObj.Answer_Text__c += $("#ckbox" + responseNum + val.id).parent().text().trim() + ';';
                        }
                    }
                    if (ansObj.Answer_Text__c.slice(-1) == ";") {
                        ansObj.Answer_Text__c = ansObj.Answer_Text__c.slice(0, -1);
                    }
                    val.answerText = ansObj.Answer_Text__c;
                    // Add comment
                    val.answerComment = $("#parentQueComment" + val.id).val();
                    ansObj.Comment__c = $("#parentQueComment" + val.id).val();
                }
                // If picklist type of question
                else if ((val.questionType == 'Picklist') && ($("#parentPkListAns" + val.id).val() != null)) {
                    ansObj.Answer_Text__c = $("#parentPkListAns" + val.id).val();
                    val.answerText = $("#parentPkListAns" + val.id).val();
                }
                // If text type of question                
                else if ((val.questionType == 'Text') && ($("#parentTextAns" + val.id).val() != null)) {
                //alert('T1 - ' + $("#parentTextAns" + val.id).val());
                    ansObj.Answer_Text__c = $("#parentTextAns" + val.id).val();
                    val.answerText = $("#parentTextAns" + val.id).val();
                 //alert('T2 - ' + ansObj.Answer_Text__c); 
                }
				//9480 Added Number type
                else if ((val.questionType == 'Number') && ($("#parentTextAns" + val.id).val() != null)) {
                //alert('N1 - ' + $("#parentTextAns" + val.id).val());
                    ansObj.Answer_Text__c = $("#parentTextAns" + val.id).val().toString();
                    val.answerText = $("#parentTextAns" + val.id).val().toString();
                 //alert('N2 - ' + ansObj.Answer_Text__c); 
                }
                // Set Answer for updates
                if (val.answerId != null && val.answerId != '') {
               // alert('Answer ID - ' + val.answerId);
                    ansObj.Id = val.answerId;
                }

                // Push object into array list
                if ((ansObj.Answer_Text__c != '') && (ansObj.Answer_Text__c != null))
                {
                    // Added this block
                    if(ansObj.AssociatedQuestion__c != null )
                    {
                    	 $("#"+ ansObj.AssociatedQuestion__c ).val("YES") ;
                    }

                    answersList.push(ansObj);
                    alert('answersList ' + answersList);
                }

                // Loop through child questions
                $.each(val.childQueList, function(j, val2) {

                    if(val2.show) {

                        // Initialize object of Answer object
                        var ansObj = new sforce.SObject("Answer__c");
                        ansObj.AssociatedQuestion__c = val2.id;
                        ansObj.Program_Transaction__c = transactionId;
                        ansObj.Answer_Text__c = '';
                        ansObj.Comment__c = '';

                        // If Yes-No type of question
                        if (val2.questionType == 'Single Option') {
                            var responseNum = 0;
                            var numResponses = val2.possibleResponses.length;
                            while(responseNum < numResponses) {
                                responseNum += 1;
                                if ($("#radio" + responseNum + val2.id).is(':checked')) {
                                    ansObj.Answer_Text__c = $("#radio" + responseNum + val2.id).parent().find('label').text();
                                    val2.answerText = ansObj.Answer_Text__c;
                                }
                            }
                            // Add comment
                            val2.answerComment = $("#parentQueComment" + val2.id).val();
                            ansObj.Comment__c = $("#parentQueComment" + val2.id).val();
                        }
                        else if (val2.questionType == 'Multiple Options') {
                            var responseNum = 0;
                            var numResponses = val2.possibleResponses.length;
                            while(responseNum < numResponses) {
                                responseNum += 1;
                                if ($("#ckbox" + responseNum + val2.id).is(':checked')) {
                                    ansObj.Answer_Text__c += $("#ckbox" + responseNum + val2.id).parent().text().trim() + ';';
                                    val2.answerText = ansObj.Answer_Text__c;
                                }
                            }
                            if (ansObj.Answer_Text__c.slice(-1) == ";") {
                                ansObj.Answer_Text__c = ansObj.Answer_Text__c.slice(0, -1);
                            }
                            val2.answerText = ansObj.Answer_Text__c;
                            // Add comment
                            val2.answerComment = $("#parentQueComment" + val2.id).val();
                            ansObj.Comment__c = $("#parentQueComment" + val2.id).val();
                        }
                        // If picklist
                        else if (val2.questionType == 'Picklist') {
                            ansObj.Answer_Text__c = $("#parentPkListAns" + val2.id).val();
                            val2.answerText = $("#parentPkListAns" + val2.id).val();
                        }
                        // If text
                        else if ((val2.questionType == 'Text') && ($("#textAns" + val2.id).val() != '')) {
                            ansObj.Answer_Text__c = $("#textAns" + val2.id).val();
                            val2.answerText = $("#textAns" + val2.id).val();
                        }

                        // Set Answer for updates
                        if (val2.answerId != null && val2.answerId != '') {
                            ansObj.Id = val2.answerId;
                        }

                        // Push object into array list
                        if ((ansObj.Answer_Text__c != '') && (ansObj.Answer_Text__c != null)) {
                            answersList.push(ansObj);
                        }
                    }
                });
            }
        });

        // Insert list
        if (answersList.length > 0) {
            QUESTIONSCOMPNS.executeSaveRecords(answersList);
        } else {
            OH_MODAL_UTILITY.errorMessageModal('Please answer the questions.');
        }
        
    },

    // Update UI with checkboxes for multiple options
    renderAnswers: function(formGroup, answerGroup) {
        var formGroupArray = [];
        var multipleOptionAnswers = [];

        formGroupArray.push(formGroup);

        $.each(formGroupArray, function(i, ansId) {
            $("[id$="+ansId+"]").each(function(i, ansElement) {
                var parentHtml = $(this).parent(".helper-label").text();
                if (answerGroup.indexOf(";") !== -1) {
                    var tempArray = answerGroup.split(";");
                    $.each(tempArray, function(i, ans) {
                        multipleOptionAnswers.push(ans);
                    });
                } else {
                    multipleOptionAnswers.push(answerGroup);
                }
                $.each(multipleOptionAnswers, function(i, optAns) {
                    // whitespace removal
                    var answer = optAns.replace(/\s+/g, '');
                    var html = parentHtml.replace(/\s+/g, '');
                    if (html.slice(-1) == ".") {
                        html = html.slice(0, -1);
                    }
                    if (answer.slice(-1) == ".") {
                        answer = answer.slice(0, -1);
                    }
                    if (answer == html) {
                        $(ansElement).prop("checked", true);
                    }
                });
            });
        });

        // for nested Other "comments"
        $(".checkboxQ:checkbox:checked").each(function() {
            var currentId = $(this).attr("id");
            if(currentId.length == 24){
                currentId = currentId.substring(6, currentId.length);
            }
            else if(currentId.length == 25) {
                currentId = currentId.substring(7, currentId.length);
            }
            if (this.checked) {
                if ($(this).parent().text().trim().indexOf('If \'Other\', explain') >= 0) {
                    $(".parentQueOther" + currentId).show();
                }
            }
        });
    },

    executeSaveRecords: function(upsertList) {
        // Important var, uncomment this for debugging
        //console.log('--->Answers:');
        //console.log(upsertList);
        upsJSON = null;
        var jsonFilter = ['Answer_Text__c','AssociatedQuestion__c','Comment__c','Program_Transaction__c'];

        if (upsertList.length > 0) {
            upsJSON = JSON.stringify(upsertList, jsonFilter);
        }

        processAnswersAction(upsJSON);
    }
}