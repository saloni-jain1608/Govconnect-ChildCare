window._globalErrCds = (function() {
    var glErrorCodes = new Array();
	
	glErrorCodes.push(new Array("1","^ & ^ shoud not be null"));
    glErrorCodes.push(new Array("2","^ must be less than or equal to ^."));
	glErrorCodes.push(new Array("3","^ must be greater than or equal to ^."));
	return {
        getErrorMsg: function(errCode, rplcStr) {
            var i;
            var errMsg="";
            for (i = 0; i < glErrorCodes.length; i++) {
                var aError = glErrorCodes[i];
                if(aError[0] == errCode) {
                    errMsg = aError[1];
                    var args = rplcStr.split(",");
                    if(aError[1].includes("^")){
                        //var aErrMsg = errMsg.split("^");
                        //console.log("Error Message "+aErrMsg);
                        var concatStr="";
                        var k = 0;
                        for(var j=0;j<errMsg.length;j++) {
                            if(errMsg.charAt(j)==="^"){
                                concatStr = concatStr + args[k] + " ";
                                k = k+1;
                            }else{
                                concatStr = concatStr + errMsg.charAt(j);
                            }
                        }
                        errMsg = concatStr;
                    } else {
                        errMsg = aError[1];
                    }
                }
            }
            return errMsg;
        }
    };
}());