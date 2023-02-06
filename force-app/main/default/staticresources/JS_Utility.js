/* Class - Manage documents */
var DocumentManager = function() {};

DocumentManager.prototype.uploadDoc = function(e, parentId) {
	var conMIMEType = this.checkMIMEType(e);
	var transDocResult = this.createStandardDocumentForProgram(e.originalEvent.target.files[0], conMIMEType);
	if(transDocResult) {
		this.upload();
	}
};
DocumentManager.prototype.deleteDoc = function() {};

/* Method - Upload document */
DocumentManager.prototype.upload = function() {};

/* Method - Create Program Transaction record */
DocumentManager.prototype.createStandardDocumentForProgram = function(file, conMIMEType, docType, programId) {
	var transD = new sforce.SObject("CLQ_Transaction_Document__c"); 
    transD.OwnerId = sforce.connection.getUserInfo().userId;
    transD.CLQ_Integration_File_Name__c = file.name.trim();
    transD.CLQ_Integration_Document_Size__c = file.size;
    transD.CLQ_Integration_Doc_MIMEType__c = conMIMEType;
    transD.CLQ_Integration_Document_Type__c = docType;
    transD.Name = file.name.trim();
    transD.CLQ_Document_Affiliation__c = 'Program';
    transD.CLQ_Program__c = programId;
    result = sforce.connection.create([transD])[0]; 
    return result.success;
};

/* Method - Check for MIME type */
DocumentManager.prototype.checkMIMEType = function(e) {
	var extension = e.originalEvent.target.files[0].name.substring(e.originalEvent.target.files[0].name.lastIndexOf('.') + 1).toLowerCase().trim();
	var customMIMEType = sforce.connection.query("Select Id, File_Extension__c, MIME_Type__c from Integration_OnBase_Mime_Types__mdt where File_Extension__c like '" + extension + "' LIMIT 1");
    records = customMIMEType.getArray("records"); 
    if(records.length > 0){ return records[0].MIME_Type__c.trim(); }
    else { return null; }
};

/* Class - Manage attachments */
var AttachmentClass = function() {};

/* Method - Save attachment */
AttachmentClass.prototype.uploadFile = function(filesObject, parentId, attachmentDescription) {
	// Get all files
	var filesToUpload = filesObject.files;       

	// Loop through all uploaded files                                          
    for(var i = 0, f; f = filesToUpload[i]; i++) {

    	// Initialize reader
        var reader = new FileReader();

        // Load a file
        reader.file = f;
    	
    	// Event fires when loading is complete
	    reader.onload = function(evt) {   

	        // Create attachment object with required fields
	        var att = new sforce.SObject("Attachment");
	        att.Name = this.file.name;
	        att.ContentType = this.file.type;
	        att.ParentId = parentId;
	        att.Description = attachmentDescription;

	        // Populate attachment body
	        var binary = "";
	        var bytes = new Uint8Array(evt.target.result);
	        var length = bytes.byteLength;
	        for (var j = 0; j < length; j++) {
	            binary += String.fromCharCode(bytes[j]);
	        }
	        att.body = (new sforce.Base64Binary(binary)).toString();

	        // Insert attachment
	        sforce.connection.create([att], {
	            onSuccess : function(result, source) {
	                afterUploadSuccess(result, source);
	            },
	            onFailure : function(error, source) {
	                afterUploadFailure(error, source);
	            }
	        });                        
	    };

	    // Read array
	    reader.readAsArrayBuffer(f); 
	}
};

/* Method - Delete attachment */
AttachmentClass.prototype.deleteFile = function(attachmentId) {
	// Delete attachment
	var result = sforce.connection.deleteIds([attachmentId]);
};

/* Method - After success execution */
AttachmentClass.prototype.afterUploadSuccess = function(result, source) {};

/* Method - After failure execution */
AttachmentClass.prototype.afterUploadFailure = function(error, source) {};



/*var promise = new Promise(function(resolve, reject) {
 
  var x = 0;

  if (x == 0) {
    resolve("Stuff worked!");
  }
  else {
    reject(Error("It broke"));
  }
});

console.log('--->Promise:');
console.log(promise);*/









// class AttachmentObject {

// 	constructor(filesObject, parentId, attachmentDescription) {
// 		this._filesObject = filesObject;
// 		this._parentId = parentId;
// 		this._attachmentDescription = attachmentDescription;
// 	}

//   	uploadFiles() {

//   		var filesObject = this._filesObject;
//   		console.log(filesObject);

//   		return new Promise(function(resolve, reject) {

// 			// Get all files
// 			var filesToUpload = filesObject.files;   
// 			console.log(filesToUpload);    

// 			// Loop through all uploaded files                                          
// 		    for(var i = 0, f; f = filesToUpload[i]; i++) {

// 		    	// Initialize reader
// 		        var reader = new FileReader();

// 		        // Load a file
// 		        reader.file = f;
		    	
// 		    	// Event fires when loading is complete
// 			    reader.onload = function(evt) {   

// 			        // Create attachment object with required fields
// 			        var att = new sforce.SObject("Attachment");
// 			        att.Name = this.file.name;
// 			        att.ContentType = this.file.type;
// 			        att.ParentId = this._parentId;
// 			        att.Description = attachmentDescription;

// 			        // Populate attachment body
// 			        var binary = "";
// 			        var bytes = new Uint8Array(evt.target.result);
// 			        var length = bytes.byteLength;
// 			        for (var j = 0; j < length; j++) {
// 			            binary += String.fromCharCode(bytes[j]);
// 			        }
// 			        att.body = (new sforce.Base64Binary(binary)).toString();

// 			        // Insert attachment
// 			        sforce.connection.create([att], {
// 			            onSuccess : function(result, source) {
// 			                resolve("Stuff worked!");
// 			            },
// 			            onFailure : function(error, source) {
// 			                reject(Error("It broke"));
// 			            }
// 			        });                        
// 			    };

// 			    // Read array
// 			    reader.readAsArrayBuffer(f); 
// 			}
// 		});
//   	}

// 	deleteFile(attachmentId) {
// 	    // Delete attachment
// 		var result = sforce.connection.deleteIds([attachmentId]);
// 	}
// }


// class AttachmentManager {

// 	constructor() {}

// 	upload()
// }

// var a1 = {files : 'a'};
// var a2 = 'x';
// var a3 = 'x';

// // /* Usage */
// var objX = new AttachmentObject(a1, a2, a3).uploadFiles().then(
// function(response) {
// 	console.log("Success!", response);
// }, 
// function(error) {
// 	console.error("Failed!", error);
// });



// var obj = new AttachmentObject(a1, a2, a3);

// obj.uploadFiles();


/* Class - Manage REST upserts */
var UpsertClass = function() {
	this.objectName = null;
	this.fieldValueMap = [];
};

/* Method - Build object and upsert */
UpsertClass.prototype.buildObject = function(fieldName, fieldValue) {

	this.fieldValueMap.push({fieldName : fieldName, fieldValue : fieldValue});
};

/* Method - Build object and upsert */
UpsertClass.prototype.upsertObject = function(objectName) {

	// Create object
	var currentObj = new sforce.SObject(objectName);

	// Add values to fields
	$.each(this.fieldValueMap, function(i, val) {
		eval('currentObj.' + val.fieldName + ' = ' + val.fieldValue);
	});

	// Upsert object
	var result = sforce.connection.upsert("Id", [currentObj]);
};









var DateUtility = function(date){
	this.utc = null;
	this.display = null;
	this.toUTC = function(date){
		return new Date(date).toISOString().slice(0,-14)
	}

	this.toDisplay = function(date){
		date = date.concat(" 00:00:00");
		var date = new Date(date.toString().replace('-', '/').replace('-', '/'));
		return (date.getMonth() + 1) + '/' + date.getDate() + '/' +  date.getFullYear()
	}
}