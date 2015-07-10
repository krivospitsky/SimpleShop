$(window).load(function(){
/* image preview */
  $('#images').on('change', '.file_upload', function(){
      preview=$(this).parent().find('.preview');
      var oFReader = new FileReader();
      oFReader.readAsDataURL(this.files[0]);
      console.log(this.files[0]);
      oFReader.onload = function (oFREvent) {
          preview.attr('src', oFREvent.target.result);
      };
  });

  $('#images')
    .on('cocoon:after-insert', function(e, added_image) {
      $(added_image).find('input').focus().click();;
    }); 


  $( "#image_list.sortable" ).sortable({
    update : function () { 
        $('input.position').each(function() {           
            var parentID = $(this).parent().parent().attr('ID');
            $(this).val( parentID );
        });
    }
  });
  $( "#sortable" ).disableSelection();


  $( "#products_list.sortable" ).sortable({
    update : function (event, ui) { 
      id=ui.item.attr('id')
      if (id) {
        $.ajax({
        type: 'PATCH',
        url: '/admin/products/'+id,
        dataType: 'json',
        data: { product: { sort_order_position: $(ui.item[0].nextElementSibling).attr('data-sort-order') } },  // or whatever your new position is
      });
    }
    }
  });
  $( "#sortable" ).disableSelection();
});

