// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require bootstrap
//= require bootstrap-hover-dropdown
//= require fancybox
//= require_directory .


// This function will be executed when the user scrolls the page.
$(window).scroll(function(e) {
    // Get the position of the location where the scroller starts.
    if ($(".scroller_anchor").length){
        var scroller_anchor = $(".scroller_anchor").offset().top;
         
        // Check if the user has scrolled and the current position is after the scroller start location and if its not already fixed at the top 
        if ($(this).scrollTop() >= scroller_anchor && $('.scroller').css('position') != 'fixed') 
        {    // Change the CSS of the scroller to hilight it and fix it at the top of the screen.
            $('.scroller').css({
                // 'background': '#CCC',
                // 'border': '1px solid #000',
                'position': 'fixed',
                'top': '0px'
            });
            // Changing the height of the scroller anchor to that of scroller so that there is no change in the overall height of the page.
            $('.scroller_anchor').css('height', '50px');
        } 
        else if ($(this).scrollTop() < scroller_anchor && $('.scroller').css('position') != 'relative') 
        {    // If the user has scrolled back to the location above the scroller anchor place it back into the content.
             
            // Change the height of the scroller anchor to 0 and now we will be adding the scroller back to the content.
            $('.scroller_anchor').css('height', '0px');
             
            // Change the CSS and put it back to its original position.
            $('.scroller').css({
                // 'background': '#FFF',
                // 'border': '1px solid #CCC',
                'position': 'relative'
            });
        }
    }
});

$(document).ready(function() {
    $(window).scroll(function () {
        if ($(this).scrollTop() > 0 && $(window).width()>1184) {
            $('#scroller').fadeIn();
        } else {
            $('#scroller').fadeOut();
        }
    });
    $('#scroller').click(function () {
        $('body,html').animate({
            scrollTop: 0
        }, 400);
        return false;
    });
});
