$(document).ready(function(){
    $("body").on('click',".form-horizontal",function(){
      $(".form").toggleClass("form-horizontal");
    });

   
  });

  window.onload = function() {
    var scriptTag = document.querySelector('script[data-error-message]');
    var errorMessage = scriptTag.getAttribute('data-error-message');
  
    if (errorMessage && errorMessage !== "None") {
      alert(errorMessage);
    }
  };