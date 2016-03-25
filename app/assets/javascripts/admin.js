$(document).ready(function() {
  $('.clickable-row').on('click', function() {
    console.log('FUCK!')
    window.document.location = $(this).data('url');
  });
});