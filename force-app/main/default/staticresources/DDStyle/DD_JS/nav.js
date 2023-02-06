$(document).ready(function(){
  $( '#hamburger-menu' ).on( 'click', function(e){
    alert('expand menu');
  });
  // #username-dropdown-content
  $( '#username-dropdown' ).hover(
    function(){
      $('#username-dropdown-content').addClass('show');
    }, function(){
      $('#username-dropdown-content').removeClass('show');
    }
  );
});