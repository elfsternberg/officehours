require.config
    paths:
        'underscore': './lib/lodash'
        'jquery': './lib/jquery.min'
        'backbone': './lib/backbone-min'
        'json2': './lib/json2'
        'domReady': './lib/domReady'
    shim:
        json2:
          exports: 'JSON'
        'backbone': ['json2']

require ['backbone', 'json2'], () ->
    require ['officehours', 'domReady'], (start, ready) ->
      ready(start)
