$(document).ready(function() {
  bindListeners();
});

var bindListeners = function() {

  $('.clickable-row').on('click', redirectProductUrl);
  $('.add-product-button').on('click', addProduct);
  $('.multiSelect input[type="checkbox"]').on('click', multiSelectCheckboxes);
  $('#checkout-now').on('click', redirectCheckoutUrl);
  $('.glyphicon-trash').on('click', deleteProduct);
  $('.glyphicon-refresh').on('click', updateProductQuantity);
  $('#order-checkout').on('click', checkout);


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
         type: 'POST'
    }).done(function(response){
  
      if (response.quantity_available <= 0){
        $("#" + button_id).prop('disabled', true)
      };
      $('#cart tbody').empty();
      $.each(response.cart, insertProduct)
      insertTotal(response.cart_total)
      $('.badge').empty().append(response.cart.length);
      $('#cart').modal('show');

    })
         //change the button if product is disabled
}

var updateCart = function(response) {
  $('#cart tbody').empty();
  $.each(response.cart, insertProduct)
  insertTotal(response.cart_total)
  $('.badge').empty().append(response.cart.length);
  $('#cart').modal('show');
}


var deleteProduct = function(event){
  event.preventDefault();
  event.stopPropagation();
  var button_id = $(this).attr('id');

  var id = button_id.slice(6);
  console.log(button_id)
    $.ajax({url: "/carts/" + id , 
         type: 'DELETE',
         dataType: 'json',
         success: changeTotalPrice
    });
    $(this).parent().parent().parent().hide()
}

var changeTotalPrice = function(response){
  $('#totalCartPrice').empty()
  var text = parseFloat(response.cart_total).toFixed(2)
  $('#totalCartPrice').append(text)

}

var updateProductQuantity = function(event){
  console.log('FUCK!!!!!!!!')
  event.preventDefault();
  event.stopPropagation();
  var id = $(this).attr('id').slice(7)
  var value = $('input[name="quantity_' + id + '"]').val()
  console.log(value)
  $.ajax({
      url: "/carts" , 
      type: 'POST',
      data: {id: id, product_quantities: value},
      dataType: 'json',
      success: function(response) {
        var total = (response.cart[0].price * value).toFixed(2)
        var grandTotal = parseFloat(response.cart_total).toFixed(2)
        if (response.quantity_available <= 0){
          $("#" + button_id).prop('disabled', true)
        };
        $('#total_' + id).html('$' + total)
        $('#totalCartPrice').html('$' + grandTotal)
}
  })
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

  var $qty = $('<input class="pull-right form-control order-qty" type="number" name="quantity_' + product.id + '" value="' + product.cart_quantity + '" min="0" max="' + product.quantity + '"/>')
  $row.append(buildTd($qty));

  var $update = $('<a class="order-update"><i class="glyphicon glyphicon-refresh" id="update_' + product.id + '"></i></a>')
  $row.append(buildTd($update, 'text-left'))

  var total = (product.cart_quantity * price).toFixed(2);
  $row.append(buildTd(total, "text-right", "total_" + product.id).prepend('$'));

  return $row;
}

var checkout = function(event){
  event.preventDefault();
  // event.stopPropagation();
  console.log('Here I am')
  $.ajax({url: "/orders", 
         type: 'POST',
         success: displayOrder
       })
  console.log('Here I go')
}

var displayOrder = function(response) {
  window.document.location = '/orders/' + response.id
}

var buildTd = function(value, tdClass, tdId) {
  return $('<td class="' + tdClass + '" id="' + tdId + '"></td>').append(value);
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
    $row.append(buildTd());
    $row.append(buildTd(total, 'text-right', 'totalCartPrice').prepend('$'));
    return $row;
}