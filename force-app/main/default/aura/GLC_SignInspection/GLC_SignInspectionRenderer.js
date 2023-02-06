({
	afterRender:  function(component, helper) {
        
        this.superAfterRender();
        setTimeout(function(){
        
        var t = document.getElementById("signature");
        console.log('value of t ' +t);
        if(t != null)
        {
            t.height = '200';
            t.width = '564';
            var signaturePad = new SignaturePad(t, {
                backgroundColor: 'rgb(255, 255, 255)'
            });
            signaturePad.clear();
        }
       },3000);   
	},
})