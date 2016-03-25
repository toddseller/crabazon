$(document).ready(function() {
  $('.clickable-row').on('click', function() {
    window.document.location = $(this).data('url');
  });
});