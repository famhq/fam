b = require 'b-assert'
query = require 'vtree-query'

HelloWorld = require './index'

describe 'z-hello-world', ->
  it 'goes to red page', (done) ->
    HelloWorld::goToRed
      go: (path) ->
        b path, '/red'
        done()

  it 'says Hello World', ->
    $ = query HelloWorld::render.call
      state: getValue: ->
        username: 'test_name'
        count: 20

    b $('.hello').contents, 'Hello World'
