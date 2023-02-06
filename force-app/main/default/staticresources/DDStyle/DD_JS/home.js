$(document).ready(function(){
  /*Events*/
  /*Unauth*/
  $(".toggle-anchor#individual, .toggle-anchor#business").on( 'click' , function(e){
    toggleClasses(e, this);
  });
  /*Auth*/
  $(".license-place-holder").on( 'click' , function(e){
    alert('Adding License...');
  });

  /*Init*/
  $(".business-show").hide();
  
  /*
  Script to update background
  Will need to be handled dynamically by salesforce
  */
  updateCEDProgressBar( $('#license-1'), 5 );
  updateCEDProgressBar( $('#license-2'), 90 );
  updateCEDProgressBar( $('#license-3'), 50 );

  function toggleClasses(e, el){
    $(".toggle-anchor").removeClass('active');
    $(el).addClass('active');

    $(".individual-show, .business-show").hide();
    $('.' + el.id + '-show').show();
  }
  /**
  * Purpose: Adjusts the CED progress bar for a license
  * Params:
  **   el - jQuery element object - $("#license-2")
  **   completionPercent - Number - percentage CED is complete 0-100
  * Returns - null
  */
  function updateCEDProgressBar(el, completionPercent){
    var color;

    //switch for completion percent colors
    if ( completionPercent >= 66 ) {
      color = 'b5dc10';
    } else if ( completionPercent >= 33) {
      color = 'f6c053';
    } else if ( completionPercent < 33 ) {
      color = 'ff8768';
    } else {
      color = 'BBBBBB';
    }

    //update CE progress bar color
    $( el.selector + ' .ce-progress-bar' ).css( 'background', 'linear-gradient(90deg, #' + color + ' ' + ( completionPercent - 1 ) + '%, #bbbbbb ' + ( completionPercent + 1 ) + '%)' )
  }
});