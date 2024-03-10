$(document).ready(function(){
    $("body").on('click',".form-horizontal",function(){
      $(".form").toggleClass("form-horizontal");
    });

    var errorMessage = $('#error-message').val();
    if (errorMessage) {
        alert(errorMessage);
    }
  });