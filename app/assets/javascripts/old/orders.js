//= require jquery.inputmask.js
//= require jquery.bind-first-0.1.min.js
//= require jquery.inputmask-multi.js

$(document).ready(function($) {
       var listRU = $.masksSort($.masksLoad("/phones-ru.js"), ['#'], /[0-9]|#/, "mask");
       var optsRU = {
           inputmask: {
               definitions: {
                   '#': {
                       validator: "[0-9]",
                       cardinality: 1
                   }
               },
               //clearIncomplete: true,
               showMaskOnHover: false,
               autoUnmask: true
           },
           match: /[0-9]/,
           replace: '#',
           list: listRU,
           listKey: "mask",
               onMaskChange: function(maskObj, determined) {
                       if (determined) {
                               if (maskObj.type != "mobile") {
                                       $("#city").val(maskObj.city.toString() + " (" + maskObj.region.toString() + ")");
                               } else {
                                       $("#city").val("");
                               }
                       } else {
                               $("#city").val("");
                       }
                       $(this).attr("placeholder", $(this).inputmask("getemptymask"));
                       }
               };

       $('#phone').inputmasks(optsRU);
})