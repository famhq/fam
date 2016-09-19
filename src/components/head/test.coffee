_ = require 'lodash'
query = require 'vtree-query'
b = require 'b-assert'
config = require '../../config'

Head = require './index'

describe 'z-head', ->
  it 'renders title', ->
    $ = query Head::render.call {
      state: getValue: ->
        meta:
          title: 'test_title'
    }, {}

    b $('title').contents, 'test_title'

  it 'has viewport meta', ->
    $ = query Head::render.call {
      state: getValue: -> {}
    }, {}

    b $('meta[name=viewport]')?

  it 'inlines styles in production mode', ->
    oldEnv = config.ENV
    config.ENV = config.ENVS.PROD
    try
      $ = query Head::render.call {
        state: getValue: ->
          serverData:
            styles: 'xxx'
      }
    finally
      config.ENV = oldEnv

    b $('.styles').innerHTML, 'xxx'


  it 'uses bundle path in production mode', ->
    oldEnv = config.ENV
    config.ENV = config.ENVS.PROD
    try
      $ = query Head::render.call {
        state: getValue: ->
          serverData:
            bundlePath: 'xxx'
      }
    finally
      config.ENV = oldEnv

    b $('.bundle').src, 'xxx'
