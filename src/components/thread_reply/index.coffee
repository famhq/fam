_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ThreadReply
  constructor: ({@model, @router}) ->

    @state = z.state
      me: @model.user.getMe()

  render: =>
    {me} = @state.getValue()

    z '.z-thread-reply', 'test'
