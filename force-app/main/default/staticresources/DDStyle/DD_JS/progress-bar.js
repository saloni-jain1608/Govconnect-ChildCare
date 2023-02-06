$(document).ready(function(){
  /*Events*/
  var showBool = true;
  $('.mobile-dropdown').click(function(){
    showBool = toggleDropdown( $('.progress-section.active'), showBool );
  });

  $('.progress-section').click(function(){
    showBool = toggleActive( $('.progress-section.active'), this, showBool );
  });

  //on resize from mobile to 992px, undo mobile only style for dropdown
  $( window ).resize(function() {
    if ( $( window ).width() < 992 ){
      $('.progress-section').show()
      showBool = true;
    }
  });
});
function toggleDropdown( activeItem, showBool ){
  if (showBool) {
    $('.progress-section').show()
    $('.progress-bar').css('height','400px');
  } else {
    $('.progress-section').hide();
    $('.progress-bar').css('height','120px');
  }

  $(activeItem).show();
  
  return !showBool;
}
function toggleActive( activeItem, newActiveItem, showBool ){
  $(activeItem).removeClass('active');
  $(newActiveItem).addClass('active');

  if ( $( window ).width() < 992 ){
    return toggleDropdown( $(newActiveItem), showBool );
  }
}