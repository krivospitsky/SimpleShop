$(document).ready(function() {
  $("a.fancybox").fancybox();

  if (  $('.tab-content').height()>300){
    $('.tab-content').height(300)
    $('.show-more').show().on('click', (function(){
      $('.tab-content').height('auto');
      $('.show-more').hide()
    }));
  }
  // $(".attributes tr:gt(4)").hide();
  // $(".attributes tr:last()").show();

  // $(".show-all").click(function(){
  //       $(this).hide()
  //       //$(".show_recent_only").show()
  //       $(".attributes tr:gt(4)").slideDown()
  //       return false;
  //   });
  
   $("#lightSlider").lightSlider({autoWidth: false, item: 1}); 

   $("#sort_order").change(function(){   	
   	order=$("#sort_order").val()
   	if (order !=  'default'){
   		window.location.href=location.protocol + '//' + location.host + location.pathname + '?sort_order=' + $("#sort_order").val()   		
   	}else{
   		window.location.href=location.protocol + '//' + location.host + location.pathname
   	}
  });

  $(".name").matchHeight({byRow: true});
  $(".product_item").matchHeight({byRow: true});

});