_ = require 'lodash'
z = require 'zorium'
log = require 'loga'

if window?
  require './index.styl'

module.exports = class HelloWorld
  constructor: ({model, router}) ->
    @state = z.state
      username: model.user.getMe().map ({username}) -> username

  render: =>
    {username} = @state.getValue()

    z '.z-hello-world',
      z '.content',
        z '.hello',
          'Hello World'
        z '.username',
          "username: #{username}"
