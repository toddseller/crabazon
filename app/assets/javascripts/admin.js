$(document).ready(function() {
  $('.clickable-row').on('click', function() {
    window.document.location = $(this).data('url');
  });

  $(document).bind('click', function(event) {
    var $clicked = $(event.target);
  });

  $('.add-product-button').on('click', function() {
    if ('session[:id]') {
      console.log('logged in')
      addProduct
    } else {
      console.log('not logged in')
      event.preventDefault();
      event.stopPropagation();
      $.get('new_user_session_path');
    }
  })

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

var addProduct = function(event){
  event.preventDefault();
  event.stopPropagation();
  var button_id = $(this).attr('id');
  var id = button_id.slice(4);

    $.ajax({url: "/carts/" + id , 
         type: 'POST',
         dataType: 'json',
         success: updateCart
         });
}

var updateCart = function(response) {
  $('#cart tbody').empty();
  $.each(response, insertProduct)
  $('.badge').empty().append(response.length);
  $('#cart').modal('show');
}

var insertProduct = function(index, product) {
  $row = buildRow(product);
  $('#cart tbody').append($row);
}

var buildRow = function(product) {
  var $row = $('<tr></tr>');
  
  var $img = $('<img src="' + product.product_image + '"/>');
  $row.append(buildTd($img, 'admin-image'));
  
  $row.append(buildTd(product.name));
  
  var price = parseFloat(product.price).toFixed(2);
  $row.append(buildTd(price, 'text-center').prepend('$'));

  $row.append(buildTd(product.quantity, 'text-center'));

  var total = (product.quantity * price).toFixed(2);
  $row.append(buildTd(total, 'text-center').prepend('$'));

  return $row;
}

var buildTd = function(value, tdClass) {
  return $('<td class="' + tdClass + '"></td>').append(value);
}