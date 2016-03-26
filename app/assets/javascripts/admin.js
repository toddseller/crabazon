$(document).ready(function() {
  bindListeners();
});

var bindListeners = function() {
  $('.clickable-row').on('click', redirectProductUrl);
  $('.add-product-button').on('click', addProduct);
  $('.multiSelect input[type="checkbox"]').on('click', multiSelectCheckboxes);
  $('#checkout-now').on('click', redirectCheckoutUrl);
}

var multiSelectCheckboxes = function() {
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
}

var redirectCheckoutUrl = function() {
  window.document.location = $(this).data('url');
}

var redirectProductUrl = function() {
  window.document.location = $(this).data('url');
}

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
  $.each(response.cart, insertProduct)
  insertTotal(response.cart_total)
  $('.badge').empty().append(response.cart.length);
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
  $row.append(buildTd(total, 'text-right').prepend('$'));

  return $row;
}

var buildTd = function(value, tdClass) {
  return $('<td class="' + tdClass + '"></td>').append(value);
}

var insertTotal = function(total) {
  var formattedTotal = parseFloat(total).toFixed(2)
  $row = buildTotalRow(formattedTotal);
  $('#cart tbody').append($row);
}

var buildTotalRow = function(total) {
    var total = total;
    var $row = $('<tr></tr>');
    $row.append(buildTd());
    $row.append(buildTd());
    $row.append(buildTd());
    $row.append(buildTd());
    $row.append(buildTd(total, 'text-right').prepend('$'));
    return $row;
}