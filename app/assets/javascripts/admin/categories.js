$(window).load(function(){

  $('#category_image').on('change', function(){
		preview=$('.preview');
		var oFReader = new FileReader();
		oFReader.readAsDataURL(this.files[0]);
		console.log(this.files[0]);
		oFReader.onload = function (oFREvent) {
			preview.attr('src', oFREvent.target.result).show();
		};

		$('.remove_image').val(0);
		$('#image').find('img').first().hide();

		$('.add-category-image').hide();
		$('.remove-category-image').show();
		$('.replace-category-image').show();
  });

  $('.add-category-image,.replace-category-image').on('click', function() {
      $('#category_image').focus().click();;
    }); 

  $('.remove-category-image').on('click', function() {
	  $('.remove_image').val(1);
	  $('.add-category-image').show();
	  $('.remove-category-image').hide();      
	  $('.replace-category-image').hide();
	  $('#image').find('img').first().hide();
	  $('.preview').hide();
    }); 


  $( ".sortable-cat" ).sortable({
    update : function (event, ui) { 
    	id=ui.item.attr('id')
    	if (id) {
	    	$.ajax({
			  type: 'PATCH',
			  url: '/admin/categories/'+id,
			  dataType: 'json',
			  data: { category: { sort_order_position: ui.item.index() } },  // or whatever your new position is
			});
		}
    }
  });
  $( ".sortable-cat" ).disableSelection();
});
