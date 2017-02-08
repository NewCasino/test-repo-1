(function (window, document) {
     'use strict';

     var _utils = window._utils || (window._utils = {});

     // BEGIN API

    function parseParams(str) {
        return str.split('&').reduce(function (params, param) {
            var paramSplit = param.split('=').map(function (value) {
                return decodeURIComponent(value.replace('+', ' '));
            });
            params[paramSplit[0]] = paramSplit[1];
            return params;
        }, {});
    }   

    
    function confirm(msg) {
        var defer = jQuery.Deferred();
        var a = msg.split("\n");
        ymz.jq_confirm({
            title:"", 
            text: a.join('<br />'), 
            no_btn:"NO", 
            yes_btn:"YES", 
            yes_fn:function() {
                defer.resolve(true);
            },
            no_fn:function() {
                defer.resolve(false);
            }
        }); 
        return defer;
    }

    function alert(msg) {
        var defer = jQuery.Deferred();
        var a = msg.split("\n");
        ymz.jq_alert({
            title:"", 
            text: a.join('<br />'), 
            ok_btn:"OK", 
            close_fn:function() {
                defer.resolve(false);
            }
        }); 
        return defer;
    }   

    // END API

    // publish external API by extending _utils
     function publishExternalAPI(_utils) {
         angular.extend(_utils, {
             'parseParams': parseParams,
             'alert': alert,
             'confirm': confirm
         });
    }

    publishExternalAPI(_utils);

 })(window, document);