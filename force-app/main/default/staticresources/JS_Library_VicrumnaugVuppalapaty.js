/******* DML Operations Library *******/

/* Class - Manage REST upserts */
var UpsertClass = function(objectName) {
    this.objectName = objectName;
    this.sObject = new sforce.SObject(objectName);
    this.objectList = [];
};

/* Method - Build object */
UpsertClass.prototype.buildObject = function(fieldName, fieldValue) {

    this.sObject[fieldName] = fieldValue;
};

/* Method - Push object to list */
UpsertClass.prototype.pushObjectToList = function() {

    this.objectList.push(this.sObject);

    this.sObject = new sforce.SObject(this.objectName);
};

/* Method - Upsert object */
UpsertClass.prototype.upsertObject = function() {

    // Upsert object
    var result = sforce.connection.upsert("Id", [this.sObject]);
};

/* Method - Upsert objects list */
UpsertClass.prototype.upsertList = function() {

    // Upsert object
    var result = sforce.connection.upsert("Id", this.objectList);
};

/******* DML Operations Library *******/










/******* Attachment Operations Library *******/

;ATTACHMENTNS = {

	/* Method - Save attachment */
	uploadFile: function(filesObject, parentId, attachmentDescription, callbackFunctionOnSuccess, callbackFunctionOnFailure) {
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
		                callbackFunctionOnSuccess(result, source);
		            },
		            onFailure : function(error, source) {
		                callbackFunctionOnFailure(error, source);
		            }
		        });                        
		    };

		    // Read array
		    reader.readAsArrayBuffer(f); 
		}
	},

	/* Method - Delete attachment */
	deleteFile: function(attachmentId) {
		// Delete attachment
		var result = sforce.connection.deleteIds([attachmentId]);
	}
}

/******* Attachment Operations Library *******/