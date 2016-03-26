$(document).ready(function() {
  $('.clickable-row').on('click', function() {
    window.document.location = $(this).data('url');
  });

  $(document).bind('click', function(event) {
    var $clicked = $(event.target);
  });

  $('.add-product-button').on('click', addProduct)

  $('.multiSelect input[type="checkbox"]').on('click', function() {
    var title = $(this).closest('.multiSelect,li').text()+',';

    if ($(this).is(':checked')) {
      var html = '<span title="' + title + '">' + title + '</span>';
      $('.multiSel').append(html);
      $('.multiSel').css('text-align', 'left');
      $('.hida').hide();
    } else {
      $('span[title="' + title + '"]').remove();
      var ret = $('.hida');
      $('.dropdown button span').append(ret);
    }
  });
});