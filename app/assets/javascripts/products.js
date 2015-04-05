$(document).ready(function() {
  $("a.fancybox").fancybox();

  $(".attributes tr:gt(4)").hide();
  $(".attributes tr:last()").show();

  // var maxHeight = 0;
  // var w = $('div.product_item').width()
  // $('div.product_item')
  //   .each(function() { maxHeight = Math.max(maxHeight, $(this).height()); })
  //   .height(maxHeight);

  $(".show-all").click(function(){
        $(this).hide()
        //$(".show_recent_only").show()
        $(".attributes tr:gt(4)").slideDown()
        return false;
    });
  
   $("#lightSlider").lightSlider({autoWidth: false, item: 1}); 

});