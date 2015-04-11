$(document).ready(function() {
    $("#new_cart_item").on("ajax:success", function(e, data, status, xhr){
        $(".cart-text").text(xhr.responseText)
    })

   // ).on "ajax:error", (e, xhr, status, error) ->
   //  $("#new_article").append "<p>ERROR</p>"


    // $('.add-to-cart').click( function (e) {
    //         e.preventDefault();
    //         var cart = $('.shopping-cart');
    //         var imgtodrag = $(this).closest('.fly-to-cart')
    //          // $(this).parent('.item').find("img").eq(0);
    //         if (imgtodrag) {
    //             var imgclone = imgtodrag.clone()
    //                 .offset({
    //                 top: imgtodrag.offset().top,
    //                 left: imgtodrag.offset().left
    //             })
    //                 .css({
    //                 'opacity': '0.5',
    //                     'position': 'absolute',
    //                     'height': '150px',
    //                     'width': '150px',
    //                     'z-index': '100'
    //             })
    //                 .appendTo($('body'))
    //                 .animate({
    //                 'top': cart.offset().top + 10,
    //                     'left': cart.offset().left + 10,
    //                     'width': 75,
    //                     'height': 75
    //             }, 1000, 'easeInOutExpo');

    //             $('html, body').animate({
    //                 scrollTop: $(".shopping-cart").offset().top                
    //             }, 300);
                
    //             // setTimeout(function () {
    //             //     cart.effect("shake", {
    //             //         times: 2
    //             //     }, 200);
    //             // }, 1500);

    //             imgclone.animate({
    //                 'width': 0,
    //                     'height': 0
    //             }, function () {
    //                 $(this).detach()
    //             });
    //         }
    //     })

})