window.onload = function() {
  var scriptTag = document.querySelector('script[data-error-message]');
  var errorMessage = scriptTag.getAttribute('data-error-message');

  if (errorMessage && errorMessage !== "None") {
    alert(errorMessage);
  }
};