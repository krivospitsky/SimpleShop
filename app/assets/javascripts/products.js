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
  
   // $("#lightSlider").lightSlider({autoWidth: false, item: 1}); 
   $('.expertfisher_productimages_slider_container').owlCarousel({items: 1, loop: true, center: true, autoplay: true, autoplayTimeout: 2000}); 


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

  $('.add-to-cart').on('click', function(){
    if (goal=$( this ).attr('data-yandex-goal')){
      eval(goal);
    }
  })

  var page = 1;
  var is_loading = 0;
  $(window).scroll(function() {
    height = window.innerHeight ? window.innerHeight : $(window).height();
    if ($(window).scrollTop() >= $(document).height() - height - 100) {
      if (!is_loading && page < $('#ajax-loader').attr('data-pages')){
        $('#ajax-loader').show();
        page = page + 1;
        is_loading=1;

        $.ajax(addParameterToURL('page=' + page)).done(function(data){
          $(".products_list").append($(".products_list", data).html());
          $('#ajax-loader').hide();
          is_loading=0;
          $(".name").matchHeight({byRow: true});
          $(".product_item").matchHeight({byRow: true});          
        });
      }
    }
  });
});

function addParameterToURL(param){
    _url = location.href;
    _url += (_url.split('?')[1] ? '&':'?') + param;
    return _url;
}