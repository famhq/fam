b = require 'b-assert'
query = require 'vtree-query'

HomePage = require './index'

describe 'home page', ->
  it 'renders', ->
    $ = query HomePage.prototype.render()
    b $('.').className, 'p-home'
