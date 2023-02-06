/**
 * progress bar widget definition
 */
$.widget('dd.progressbar', {      
    options: {
        activeSection: 0,
        reviewSection: 0,
        nextSection: 0,
        errorList: []
    },
    
    getActiveSection: function() {
        return this.options.activeSection;
    },

    getNextSection: function() {
        return this.options.nextSection;
    },

    setActiveSection: function(val) {
      this.options.activeSection = val;
      var currentDiv = $("div[orderNumber='" + val + "']");                
      currentDiv.addClass( 'active' );       
    },

    setNextSection: function(val) {
      this.options.nextSection = val;      
    },

    getReviewSection: function() {
      return this.options.reviewSection;
    },

    addError: function(iSectionNum, iSubSectionNum, sFieldName, sErrorMessage, bIsLicenseObjError) {
      var ValidationError = {sectionNum: iSectionNum, subSectionNum: iSubSectionNum, fieldName: sFieldName, errorMessage: sErrorMessage, isLicenseObjError: bIsLicenseObjError};
      this.options.errorList.push(ValidationError);
    },

    removeError: function(iSectionNum, iSubSectionNum, sFieldName) {
      for( var i = 0; i < this.options.errorList.length; i++) {
        var currentError = this.options.errorList[i];
        if ( currentError.sectionNum === iSectionNum && currentError.subSectionNum === iSubSectionNum && currentError.fieldName === sFieldName ) {
          this.option.errorList.splice(i, 1);
          break;
        }
      }
    },

    // remove all errors that apply to the license object only - leaves all other errors in the list
    removeAllLicenseErrors: function() {
      for( var i = 0; i < this.options.errorList.length; i++) {
        var currentError = this.options.errorList[i];
        if ( currentError.isLicenseObjError ) {
          this.option.errorList.splice(i, 1);
        }
      }        
    },

    getAllErrors: function() {
      return this.options.errorList;
    },
    
    /**
     * method that updates the visual state of the progress bar when the "model" for 
     * the prgress bar has changed
     */
    update: function() {

        // read the progress bar data again bc it was updated
        try {
          // Get progressbar data
          var pBarData = validationObj; 
          var that = this;
          
          $.each(pBarData, function(i, section) {
        	  
              var currentDiv = $("div[orderNumber='" + section.orderNumber + "']");                
              currentDiv.removeClass( 'active' );
              currentDiv.addClass( section.progressBarStatus );

              if(currentDiv.hasClass('error') && currentDiv.hasClass('in-progress'))
                currentDiv.removeClass( 'in-progress' );

              if(currentDiv.hasClass('error') && currentDiv.hasClass('complete'))
                currentDiv.removeClass( 'error' );
              

              // logic to build a list of errors - starts here
              if (section.hasOwnProperty('subSectionObjMap') ) {
                $.each( section.subSectionObjMap, function(i, subSection) {
                  if(subSection.progressBarStatus == 'error') {
                    $.each( subSection.fieldObjMap, function(i, field ) {
                      // all the errors from the Server are for the license2 object (for now)
                      that.addError(section.orderNumber, subSection.orderNumber, field.name, field.errorMessage, true);
                    });
                  }
                });
              } 


              // logic to build a list of errors - ends here
                          
              if ( section.progressBarStatus && section.progressBarStatus.includes('active') ) {                 
                  that.options.activeSection = section.orderNumber;
                  if(that.options.activeSection != that.options.reviewSection) {
                    that.options.nextSection = validationObj[i+1].orderNumber;
                  }
                  else {
                    that.options.nextSection = validationObj[0].orderNumber;
                  }
              }
              
          });     
        
        }
        catch(err) { 
          // TODO: need logic to handle errors!!!
         
        }  

        // Build validation object
        APPLYFORSOBJECT.buildValidationObject();                    
    },
    
    _create: function() {     

        // Get progressbar data     
        var pBarData = validationObj;         
        var container = $('<div>').attr( {class: 'progress-bar' } );  
        
        if(pBarData.length <= 1) {
          return;
        }
        
        var that = this;
        try {
          $.each(pBarData, function(i, val) {

              var progressSection = $('<div>').attr( {class: 'progress-section ' + val.progressBarStatus, orderNumber: val.orderNumber  } );
              if ( val.progressBarStatus && val.progressBarStatus.includes('active') ) {
                  that.options.activeSection = val.orderNumber;
                  

                  if(that.options.activeSection != that.options.reviewSection) {
                    if(validationObj[i+1] != null)
                      that.options.nextSection = validationObj[i+1].orderNumber;

                  }
                  else {
                    that.options.nextSection = validationObj[0].orderNumber;
                  }
              }  
              // Set review section
              that.options.reviewSection = val.orderNumber;   
                  
              $('<span>').appendTo( $('<div>').appendTo(progressSection) );
              $('<h6>').html( val.name ).appendTo(progressSection);
              progressSection.appendTo(container);                        
          });
        }
        catch(e) {
          OH_MODAL_UTILITY.errorMessageModal('Invalid data in configuration. Please check. ' + e);
        }
        
        container.appendTo(this.element);
        
        var that = this;
        // handle on click event -- 
        $( '.progress-section' ).on('click', function() {  
      
            if(PBAR.isItOkToNavigate($(this).attr('orderNumber'))) 
        	{
            	that._trigger( "navigate", null, { nextSection: Number($(this).attr('orderNumber')), currentSection: that.options.activeSection } );
        	}
        });
    },                
    
    _destroy: function() {},
    
    _setOption: function(key, value) {}
});

;PBAR = {       
		isItOkToNavigate : function(targetSectionNumber)
		{
			var continueNavigaion = true ; 
			var recordsCreated = false ;
			if($("#ProgramIdString").html() != null 
				&& $("#ProgramIdString").html().trim().length  == 18 
				&& $("#TransactionIdString").html()  != null 
				&& $("#ProgramIdString").html().trim().length == 18 )
			{
				recordsCreated = true ;
			}
			
			//If user is trying to navigate Review section and Records are nor created  
			if(progressBarWidget.progressbar("getReviewSection")  == targetSectionNumber &&  recordsCreated == false )
			{
				continueNavigaion = false ;
				OH_MODAL_UTILITY.errorMessageModal('Please complete all sections before clicking  Review & Submit ');
			}else if( progressBarWidget.progressbar("getActiveSection") == targetSectionNumber )  // User is clicking on same section which is active
			{
				continueNavigaion = true ;
			}else
			{
				continueNavigaion = true ;
			}

			return continueNavigaion ;
		},
		
		//12496 logic to reload page when OK is clicked on modal
		handleReloadPage: function() {
		
            ATTACHMENTCOMPNS.loadRecords();
		},
		
		
		handleSaveAndContinue: function() {
    	  //Keep continue only if overall operation succeed 
    	  var overAllStatus = REVIEWCOMPNS.checkFinalTransactionStatus();
    	  if(overAllStatus == false )
    	  return false ;
    	  var nextSectionNumber = progressBarWidget.progressbar("getActiveSection") ;
    	  nextSectionNumber = nextSectionNumber + 1 ;
    	  if(progressBarWidget.progressbar("getReviewSection") == nextSectionNumber )
    	  {
    		  REVIEWCOMPNS.pBarStatusCollectionObj = [] ;
    	  }
    	  progressBarWidget.progressbar("update");
          currentSec = progressBarWidget.progressbar("getActiveSection");
          $(".pageSection").hide();
          $("#section" + currentSec).show();  
          // If first insert or clicked into the Documentation section
          if(isFirstInsert) {
            ATTACHMENTCOMPNS.loadRecords();
            isFirstInsert = false;
          }
 
          if( currentSec == progressBarWidget.progressbar("getReviewSection") ) {
            $("#multiPageButtons").hide();
            REVIEWCOMPNS.getErrors();
          } 
          else {
            $("#multiPageButtons").show();
          }  
          
          PBAR.adjustProgressBar() ;
          
          OH_NOTIFICATIONS.spinnerStop();
      },

      handleJustContinue: function() {
          currentSec = progressBarWidget.progressbar("getActiveSection");
          $(".pageSection").hide();
          $("#section" + currentSec).show();    
          
          if( currentSec == progressBarWidget.progressbar("getReviewSection") ) {
          	$("#multiPageButtons").hide();
          	REVIEWCOMPNS.getErrors();
          } 
          else {
            $("#multiPageButtons").show();
          }      
          
          OH_NOTIFICATIONS.spinnerStop();
      },

      getStatusFromSecondarySource : function(currentSectionId )
      {
          var pStatus = '' ;
                var arrSecStat = [];
                arrSecStat = REVIEWCOMPNS.pBarStatusCollectionObj;
               
                for (var i=0; i<REVIEWCOMPNS.pBarStatusCollectionObj.length; i++){

                if (currentSectionId == REVIEWCOMPNS.pBarStatusCollectionObj[i].sectionId ) {
                 
                  pStatus = REVIEWCOMPNS.pBarStatusCollectionObj[i].secondaryStatus;

                }
              }
              
          return pStatus ;

      }, 
      
      adjustProgressBar : function()
      {
    	  var pBarData = validationObj;
    	  $.each(pBarData, function(i, section) 
          {
        	  var currentDiv = $("div[orderNumber='" + section.orderNumber + "']");
        	  var secStatus = PBAR.getStatusFromSecondarySource(section.id);
              
        	  if(secStatus == 'error')
              {
            	 if(currentDiv.hasClass("complete"))
            	{
            		currentDiv.removeClass("complete").addClass("error") ;
            	}else
            	{
            		currentDiv.addClass("error") ;
            	}
              } 		  
          });
    	  
    	  //Also move to progresss bar 
    	  var targetElement = $("#internal-header") ;
    	  $('html, body').animate({
              scrollTop: targetElement.offset().top
          }, 1000);
      }
  }