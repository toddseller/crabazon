$(document).ready(function() {
  bindListeners();
});

var bindListeners = function() {
  $('.clickable-row').on('click', redirectProductUrl);
  $('.add-product-button').on('click', addProduct);
  $('.multiSelect input[type="checkbox"]').on('click', multiSelectCheckboxes);
  $('#checkout-now').on('click', redirectCheckoutUrl);
  $('.glyphicon-trash').on('click', deleteProduct);
  $('#order-update').on('click', updateProductQuantity);
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
      console.log(response.quantity_available)
      if (response.quantity_available <= 0){
        console.log(response.quantity_available)
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
  console.log(button_id)

  var id = button_id.slice(6);
  console.log(id)

    $.ajax({url: "/carts/" + id , 
         type: 'DELETE',
         dataType: 'json',
         success: changeTotalPrice });
    $(this).parent().parent().parent().hide()
}

var changeTotalPrice = function(response){
  $('#totalCartPrice').empty()
  var text = response.cart_total
  $('#totalCartPrice').append(text)

}


var updateProductQuantity = function(event){
  event.preventDefault();
  event.stopPropagation();
  console.log("what up bitch")
    $.ajax({url: "/carts" , 
         type: 'POST',
         data: {all_product_quantities: $('form').serializeArray()},
         dataType: 'json'
         });
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

var checkout = function(){
   event.preventDefault();
   event.stopPropagation();

  $.ajax({url: "/orders" , 
         type: 'POST'
         }).done(function(response){
         })
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