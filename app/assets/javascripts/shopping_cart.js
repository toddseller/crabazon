$(document).ready(function() {
	$('.add-product-button').on('click', add_product)
});

var add_product = function(event){
	event.preventDefault()
	event.stopPropagation();
	console.log('hello')
	var button_id = $(this).attr('id')
	var id = button_id.slice(4)

    $.ajax({url: "/carts/" + id , 
    	   type: 'POST',
    	   dataType: 'json'
    	   })

      // $('.cart-count').html(data)
      // $this.find('span').html(new_target)
      // $this.data('target', new_target)




 
}