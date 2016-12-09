z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
RequestInviteForm = require '../request_invite_form'
InfoBlock = require '../info_block'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class RequestInvite
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @$infoBlock = new InfoBlock()
    @$requestInviteForm = new RequestInviteForm {@model, @router}

    @state = z.state
      me: me

  render: =>
    {me} = @state.getValue()

    z '.z-request-invite',
      z @$infoBlock,
        $title: 'Request an invite'
        $content: [
          z 'p', 'We\'re starting with elite players (4,000+ trophies)'
          z 'p', 'Your request is subject to review and approval'
        ]
        $form: @$requestInviteForm
