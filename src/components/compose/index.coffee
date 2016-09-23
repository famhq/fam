_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Compose
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @$discardIcon = new Icon()
    @$doneIcon = new Icon()

    @state = z.state
      me: me
  render: =>
    {me} = @state.getValue()

    z '.z-compose',
      z '.actions',
        z '.action',
          z '.icon',
            z @$discardIcon,
              icon: 'close'
              color: colors.$primary500
              isTouchTarget: false
        z '.text', 'Discard'
          z '.action',
            z '.icon',
              z @$doneIcon,
                icon: 'check'
                color: colors.$primary500
                isTouchTarget: false
            z '.text', 'Done'
      z '.g-grid', 'test'
