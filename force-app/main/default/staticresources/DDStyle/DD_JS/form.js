$(document).ready(function(){
  init();
});

/*
 * Params: null
 * Purpose: initializes the animated-form JS
 * Returns: null
 * Scope: Public
 */
function init() {
  var c = $('.animated-form .form-group'),
      i = 0;

  c.each(function( index ) {
    bindFormEvents( c[index] );
  });
}

/*
 * Params: event, element
 * Purpose: Adds the animation class to the label to remove it from sight, adds animation class to span for moving focus
 * Returns: null
 * Scope: Private
 */
function addLabelClass(e, el) {
  el.children[0].className += el.children[0].className ? ' animated' : 'animated';
  el.children[2].className += el.children[2].className ? ' active' : 'active';
}

/*
 * Params: event, element
 * Purpose: Removes the animation class to the label if no text is in input, removes animation class to span for moving focus
 * Returns: null
 * Scope: Private
 */
function removeLabelClass(e, el) {
  var input = document.getElementById( el.children[1].id );
  if (input.value === '') {
    el.children[0].className = '';
  }
  el.children[2].className = '';

  checkErrorState(e, el, input.value);
}

/*
 * Params: elements
 * Purpose: binds the blur and focus events to each form element
 * Returns: null
 * Scope: Private
 */
function bindFormEvents(el) {
  if ( el.nodeName === 'DIV' && $( el ).hasClass( 'form-group' ) && el.children[1].nodeName !== "SELECT") {
    el.children[1].addEventListener( 'focus', function( e ) {
      addLabelClass( e, el );
    }, true);
    el.children[1].addEventListener( 'blur', function( e ) {
      removeLabelClass( e, el );
    }, true);
  } else if (el.children[1].nodeName === "SELECT") {
    el.children[0].className += el.children[0].className ? ' animated' : 'animated';
  }
}

/*
 * Params: event, element, value of input
 * Purpose: adds or removes error class
 * Returns: null
 * Scope: Private
 */
function checkErrorState(e, el, iVal) {
  var element = $(el);
  if ( element.hasClass( 'required' ) && iVal === '' ) {
    element.addClass( 'error' );
  } else if ( element.hasClass( 'required') && iVal !== '' ) {
    element.removeClass( 'error' );
  }
}

/*Tc Form Validation*/

/* Adding Bootstrap Form Class on Change "conditional selects" */
$("[id$='board']").on('change', function(){
  $("[id$='licenseType']").addClass('selectpicker');
    console.log('worked');
});
console.log($("[id$='board']").length + 'jason test');
