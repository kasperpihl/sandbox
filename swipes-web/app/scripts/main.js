require.config({
    baseUrl: "scripts",
    paths: {
        apps: '../apps',
        jquery: '../bower_components/jquery/dist/jquery',
        backbone: '../bower_components/backbone/backbone',
        requirejs: '../bower_components/requirejs/require',
        'sass-bootstrap': '../bower_components/sass-bootstrap/dist/js/bootstrap',
        underscore: '../bower_components/underscore/underscore',
        localStorage: '../bower_components/Backbone.localStorage/backbone.localStorage',
        collectionSubset: 'plugins/backbone.collectionsubset',
        'TweenLite': 'plugins/greensock-js/src/minified/TweenLite.min',
        gsap: 'plugins/greensock-js/src/uncompressed/TweenMax',
        timelinelite: 'plugins/greensock-js/src/uncompressed/TimelineLite',

        'gsap-scroll': 'plugins/greensock-js/src/uncompressed/plugins/ScrollToPlugin',
        'gsap-text': 'plugins/greensock-js/src/uncompressed/plugins/TextPlugin',
        'gsap-easing': 'plugins/greensock-js/src/uncompressed/easing/EasePack',
        'gsap-css': 'plugins/greensock-js/src/uncompressed/plugins/CSSPlugin',
        'gsap-throwprops': 'plugins/greensock-js/src/uncompressed/plugins/ThrowPropsPlugin',
        'gsap-draggable': 'plugins/greensock-js/src/uncompressed/utils/Draggable',
        text: '../bower_components/requirejs-text/text',
        momentjs: '../bower_components/momentjs/moment',
        'requirejs-text': '../bower_components/requirejs-text/text',
        'parse': '../bower_components/parse/parse'
    },
    shim: {
        backbone: {
            deps: [
                'jquery',
                'underscore'
            ],
            exports: 'Backbone'
        },
        localStorage:{
            deps:[
                'backbone'
            ],
            exports: 'localStorage'
        },
        collectionSubset:{
            deps:[
                'backbone'
            ],
            exports: 'collectionSubset'
        },
        underscore: {
            exports: '_'
        },
        gsap: {
            deps: [
                'gsap-easing',
                'gsap-css'
            ],
            exports: 'TweenMax'
        },
        timelinelite: {
            deps: [
                'gsap'
            ],
            exports: 'TimelineLite'
        },
        'gsap-draggable': {
            deps: [
                'gsap-throwprops'
            ],
            exports: 'Draggable'
        },
        clndr: {
            deps: [
                'momentjs'
            ]
        },
        'jquery-hammerjs': {
            deps: [
                'hammerjs'
            ]
        },
        mousetrapGlobal: {
            deps: ['mousetrap']
        }
    }
});
var QueryString = function () {
  // This function is anonymous, is executed immediately and
  // the return value is assigned to QueryString!
  var query_string = {};
  var query = window.location.search.substring(1);
  var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
        // If first entry with this name
    if (typeof query_string[pair[0]] === "undefined") {
      query_string[pair[0]] = pair[1];
        // If second entry with this name
    } else if (typeof query_string[pair[0]] === "string") {
      var arr = [ query_string[pair[0]], pair[1] ];
      query_string[pair[0]] = arr;
        // If third or later entry with this name
    } else {
      query_string[pair[0]].push(pair[1]);
    }
  }
    return query_string;
} ();
if (typeof String.prototype.startsWith != 'function') {
  // see below for better implementation!
  String.prototype.startsWith = function (str){
    return this.indexOf(str) === 0;
  };
}
window.urlbase = 'http://' + document.location.hostname + ':5000'
require(["jquery", "underscore", "backbone"], function($) {
    var appCache = window.applicationCache;
    if(appCache){
        window.applicationCache.addEventListener('updateready', function(e) {
            if (window.applicationCache.status == window.applicationCache.UPDATEREADY) {
                // Browser downloaded a new app cache.
                if (confirm('A new version of this site is available. Load it?')) {
                    appCache.swapCache();
                    window.location.reload();
                }
            } else {
                // Manifest didn't changed. Nothing new to server.
            }
        }, false);
    }

    /*require(["bootstrapTooltip"],function(){
        $('[data-toggle="tooltip"]').tooltip({delay:{show:1000,hide:0}});
    })*/

    if (localStorage.getItem("swipy-token")) {
      queryString = QueryString;
      require(["js/app", "js/DebugHelper", "plugins/log"], function (App, DebugHelper) {
          'use strict';

          window.swipy = new App();
          window.swipy.handleQueryString(queryString);
          window.swipy.manualInit();
          window.debugHelper = new DebugHelper();
          swipy.start();
      });
    } else {
      localStorage.clear();
      location.href = location.origin + "/login/";
    }
});
