require.config
    paths:
        'underscore': './lib/lodash'
        'jquery': './lib/jquery.min'
        'backbone': './lib/backbone-min'
        'json2': './lib/json2'
    shim:
        'backbone': ['json2']

require ['backbone', 'json2'], () ->
    require ['officehours'], (start) ->
      $(start)
