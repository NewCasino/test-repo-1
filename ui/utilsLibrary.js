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
        ca.jq_confirm({
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
        ca.jq_alert({
            title:"", 
            text: a.join('<br />'), 
            ok_btn:"OK", 
            close_fn:function() {
                defer.resolve(false);
            }
        }); 
        return defer;
    }   

    // asset loader
    var loader = {};
    var config = {headers: {'Accept' : 'text/html'}};
        
    // load array of css urls
    loader.loadCSS = function (urls) {
        for (var i in urls) {
            loader.load('css', urls[i]);
        }
    };

    // load array of js urls
    loader.loadJS = function (urls) {
        for (var i in urls) {
            loader.load('js', urls[i]);
        }
    };

    // load of html urls (usually view templates)
    loader.loadHTML = function (urls) {
        for (var i in urls) {
            loader.load('html', urls[i]);
        }
    };

    loader.load = function (mode, url) {
        if (mode == 'css') {
            var style = document.createElement('link');
            style.rel = 'stylesheet';
            // style.type = 'text/css';
            style.url = url;
            document.body.appendChild(style);
            return;
        }
        if (mode == 'js') {
            var script = document.createElement('script');
            script.src = url;
            document.body.appendChild(script);
            return;
        }
        if (mode == 'html') {
            jQuery.ajax({
                url: url,
                success: function (data) { jQuery('body').append(data); },
                dataType: 'html'
            });
        }
    };

    // END API

    // publish external API by extending _utils
     function publishExternalAPI(_utils) {
         angular.extend(_utils, {
             'parseParams': parseParams,
             'alert': alert,
             'confirm': confirm,
             'loader': loader
         });
    }

    publishExternalAPI(_utils);

 })(window, document);