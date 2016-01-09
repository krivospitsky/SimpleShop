$(window).load(function(){
  $( "#pages_list.sortable" ).sortable({
    update : function (event, ui) { 
    	id=ui.item.attr('id')
    	if (id) {
	    	$.ajax({
			  type: 'PATCH',
			  url: '/admin/pages/'+id,
			  dataType: 'json',
			  data: { page: { sort_order_position: ui.item.index() } },  // or whatever your new position is
			});
		}
    }
  });
  $( "#sortable" ).disableSelection();

  $('#page_image').on('change', function(){
		preview=$('.preview');
		var oFReader = new FileReader();
		oFReader.readAsDataURL(this.files[0]);
		console.log(this.files[0]);
		oFReader.onload = function (oFREvent) {
			preview.attr('src', oFREvent.target.result).show();
		};

		$('.remove_image').val(0);
		$('#image').find('img').first().hide();

		$('.add-page-image').hide();
		$('.remove-page-image').show();
		$('.replace-page-image').show();
  });

  $('.add-page-image,.replace-page-image').on('click', function() {
      $('#page_image').focus().click();;
    }); 

  $('.remove-page-image').on('click', function() {
	  $('.remove_image').val(1);
	  $('.add-page-image').show();
	  $('.remove-page-image').hide();      
	  $('.replace-page-image').hide();
	  $('#image').find('img').first().hide();
	  $('.preview').hide();
    }); 
});
