_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Avatar = require '../avatar'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class AcceptInvite
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()
    @$avatar = new Avatar()
    @$editButton = new PrimaryButton()

    @state = z.state
      me: me
  render: =>
    {me} = @state.getValue()

    z '.z-accept-invite',
      z '.title', 'Congratulations'
      z '.description',
        z 'p',
          'You\'ve been selected to join the most exclusive club for the most
          elite players in the world'

        z 'p', 'Now, let’s get started…'

      z '.g-grid',
        z '.section',
          z '.top',
            z '.left',
              z '.title', ''
