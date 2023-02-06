$(function() { 
  
  // Toggle menu open/closed in site header
  $('body').on('click', '#hamburger-menu', function(e){
    $('body').toggleClass('menu-open');
  });

  // Toggle card flips
  $('.card .flip').click(function(e) {
    e.preventDefault();
    var el = $(this).attr('href');
    $(el).toggleClass('hover');
  });

  // Toggle styled-tables
  $('.styled-table .menu-toggle').click(function(e) {
    e.preventDefault();
    var el = $(this).attr('href');
    $(el).toggleClass('open');
  });

  // Homepage
  var formfields = [];
  formfields.push({
      id:"username",
      validator: "Email",
      required: true,
      name: "Portal Id",
      watch: true
  });
  formfields.push({
      id:"password",
      required: true,
      name: "Password",
      watch: true
  });
  var validationEngine = new ValidationEngine(
  {
      onValidationSuccess : function()
      { 
        performLogin( $("#username").val() , $("#password").val()) ; 
      },
      fields: formfields 
  } ) ;
  
  $("#loginButton, #ODJFSloginButton").on("click",function(e){
    e.preventDefault();
    console.debug(validationEngine) ;
    
    //validationEngine.runValidations();
  });

  // Table sorting
  $('.styled-table table').DataTable({
    "pagingType": "simple_numbers",
    "bFilter": false,
  });

  // Rating input
  $('.rating-input .glyphicon').click(function() {
    $('.rating-input').toggleClass('open');
  });

  $('.option .rating').click(function() {
    var rating_class = $(this).attr('class'),
        rating = $(this).attr('[data-rating]');

    // Update selected star rating
    $('.selected-rating .rating').attr('class', rating_class);
    $('.rating-input').toggleClass('open');

    // Update input
    $('.desired-rating-input').val(rating);
  });

});