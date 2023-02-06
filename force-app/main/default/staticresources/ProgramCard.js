;oclqs_programCards = {
	loadAllData : function(){
		//$("#licenseDataTable").empty();
		var allProgramData = null;
		var pData = JSON.parse($("#jsData").val()) ;
		console.log(pData);
		$(Object.keys(pData)).each(function(index,val){
			allProgramData = pData[val];
			oclqs_programCards.programCardData(allProgramData);
		});
	},
	dateConversion : function (inputFormat) {
		if(inputFormat != undefined){
			  function pad(s) { return (s < 10) ? '0' + s : s; }
			  var d = new Date(inputFormat);
			  if(d.getDate() == 30 && (d.getMonth() == 3 || d.getMonth() == 5 || d.getMonth() == 8 || d.getMonth() == 10)) {
			  	return [pad(d.getMonth()+2), pad(1), d.getFullYear()].join('/');
			  }
			  else if(d.getDate() == 31 && (d.getMonth() != 3 && d.getMonth() != 5 && d.getMonth() != 8 && d.getMonth() != 10 && d.getMonth() != 1 && d.getMonth() != 11)){
			  	 return [pad(d.getMonth()+2), pad(1), d.getFullYear()].join('/');
			  }
			  else if((d.getDate() == 28 || d.getDate() == 29) && (d.getMonth() == 1)){
			  	 return [pad(d.getMonth()+2), pad(1), d.getFullYear()].join('/');
			  }
			  else if((d.getDate() == 31) && (d.getMonth() == 11)){
			  	return [pad(1), pad(1), d.getFullYear() + 1].join('/');
			  }
			  else {
			  	return [pad(d.getMonth()+1), pad(d.getDate() + 1), d.getFullYear()].join('/');
			  }  
			 
		}else
			return '';
	},
	programCardData : function(allProgramData){
       

		if(Object.keys(allProgramData).length > 0 ){
			var tableBody =$("#ulId") ;
			$(Object.keys(allProgramData.mapOfProgramCards)).each(function(index,val3){
				var record = allProgramData.mapOfProgramCards[val3] ;
				var programRecord = record.programRecord;
				var cardAction = record.mapOfCardActions;
				var actionRequired = "";
				var cardActionTitle = "";
				var ratingExpDate = "";
				// TFS #15776 - Added the below lines for the Day camps to refer the current registration end date
				if(programRecord.CLQ_Program_Record_Type__c == 'Day Camp'){
					var provisionalDate = programRecord.CLQ_End_Date__c == ''?'':oclqs_programCards.dateConversion(programRecord.CLQ_End_Date__c);
				}else{
					var provisionalDate = programRecord.CLQ_License_Type__c == 'Continuous'?'N/A':oclqs_programCards.dateConversion(programRecord.CLQ_License_Expiration_Date__c);
				}
				var hiddenDate = oclqs_programCards.dateConversion(programRecord.CLQ_License_Expiration_Date__c);
				if(provisionalDate == 'N/A') {
				var d = new Date();
				d.setFullYear(4000);
					hiddenDate = oclqs_programCards.dateConversion(d);
				}
				if(provisionalDate == '') {
				var d = new Date();
				d.setFullYear(3999);
					hiddenDate = oclqs_programCards.dateConversion(d);
				}
				if(!$.isEmptyObject(cardAction)){
					cardActionTitle = "ACTION(S) REQUIRED";
					actionRequired = "license-message-danger";
				}
				tableBody.append(
					$("<li>").append(
						$("<a>").attr({ href:"/gclicensing/oclqs_LicenseDetail?ProgramId="+programRecord.Id, onclick:"oclqs_notifications.startSpinner();" })
						.append(
							$("<header>").append(
								$("<span>").addClass("license-title").append(programRecord.Name),
								$("<span>").addClass("program-number").append(programRecord.CLQ_Program_Number__c),
								$("<span>").addClass("license-message "+actionRequired).append(
									$("<span>").addClass("license-message-content priority").append(
										cardActionTitle
									)
								)
							),
							$("<main>").addClass("row").append(
								$("<div>").addClass("rating-wrap").append(
									$("<span>").addClass("rating rating-sm-"+programRecord.CLQ_Current_Rating__c)
								),
								$("<div>").addClass("license-row").append(
									$("<span>").addClass("license-label").append("Type:"),
									$("<span>").addClass("license-value").append(programRecord.CLQ_Program_Type__c)
								),
								$("<div>").addClass("license-row").append(
									$("<span>").addClass("license-label").append("Program Status:"),
									$("<span>").addClass("license-value program-status").append(programRecord.CLQ_Program_Status__c)
								),
								$("<div>").addClass("license-row").append(
									$("<span>").addClass("license-label").append("Expires:"),
									$("<span>").addClass("license-value").append(provisionalDate),
									$("<span>").addClass("license-expires").css("display","none").append(hiddenDate)
								),
								$("<div>").addClass("license-row").append(
									$("<span>").addClass("license-label").append("SUTQ Status:"),
									$("<span>").addClass("license-value").append(programRecord.OCLQS_Stepup_Status__c)
								),
								$("<div>").addClass("license-row").append(
									$("<span>").addClass("license-label").append("Expires:"),
									$("<span>").addClass("license-value rating-expires").append(
											oclqs_programCards.dateConversion(programRecord.CLQ_Current_Rating_Expiration_Date__c)
									)
								)
							)
						)
					)
				);
			});

			//dataTable.append(tableBody);
			$("#ulId").append(tableBody);
		}
	},
	cardActionData : function(cardAction){
		$(Object.keys(cardAction)).each(function(index,val){
			var action = cardAction[val];
			console.debug(action);
		});
	}

}

$(document).ready(function(){
	oclqs_programCards.loadAllData();
	var searchList = new List("license-dashboard", {
		valueNames: [ "program-number", "license-title"]
	});

	var sortList = new List("license-dashboard", {
	    valueNames: [ "program-number", "license-title", "license-expires", "program-status", "priority", "rating-expires" ]
	});

	var floatingBoxEl;
	sortInitial(reChain);

	function sortInitial(cb) {
		floatingBoxEl = sortList.items.shift(0);
		sortList.sort("priority", {order: "desc"});
		cb(sortList.items);
	}

	function reChain(list) {
		list.unshift(floatingBoxEl);
		sortList.update();
	}

	$("#sort-programs").on("change", function() {
    var $val = $("option:selected", this).attr("value");
    		floatingBoxEl = sortList.items.shift(0);
		
		if ($val === "priority") {
			sortBox("desc", reChain);
		} else {
			sortBox("asc", reChain);
		}

		function sortBox(order, cb) {
			sortList.sort($val, {order: order});
			cb(sortList.items);
		}
	});
});
