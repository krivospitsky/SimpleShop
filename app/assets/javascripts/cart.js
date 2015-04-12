$(document).ready(function() {
    $(".new_cart_item").bind("ajax:success", function(e, data, status, xhr){
        var cart = $('.shopping-cart');
        var imgtodrag = $(this).closest('.fly-to-cart')
         // $(this).parent('.item').find("img").eq(0);
        if (imgtodrag) {
            var imgclone = imgtodrag.clone()
                .offset({
                top: imgtodrag.offset().top,
                left: imgtodrag.offset().left
            })
                .css({
                'opacity': '0.9',
                    'position': 'absolute',
                    'width': '250px',
                    'z-index': '100'
            })
                .appendTo($('body'))
                .animate({
                'top': cart.offset().top + 10,
                    'left': cart.offset().left + 10,
                    'width': 75,
                    'height': 75
            }, 1000, 'easeInOutExpo');

            // $('html, body').animate({
            //     scrollTop: 0              
            // }, 300);
            
            // setTimeout(function () {
            //     cart.effect("shake", {
            //         times: 2
            //     }, 200);
            // }, 1500);

            imgclone.animate({
                'width': 0,
                    'height': 0
            }, function () {
                $(this).detach()
                if (cart_text){
                    $(".cart-text").text(cart_text)
                }
            });

        }
    })

})