_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
RequestInviteForm = require '../request_invite_form'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Referred
  constructor: ({@model, @router, referrer}) ->
    me = @model.user.getMe()

    @$scrollIcon = new Icon()
    @$requestInviteForm = new RequestInviteForm {@model, @router}

    @state = z.state
      me: me
      referrer: referrer

  render: =>
    {me, referrer} = @state.getValue()

    referrerName = @model.user.getDisplayName referrer

    z '.z-referred',
      z '.top', {
        style:
          height: "#{window?.innerHeight}px"
      },
        z '.logo'
        z '.title', 'Congratulations'
        z '.description',
          z 'p',
            "#{referrerName} has invited you to join Red Tritium"

          z 'p', 'Red Tritium is an exclusive club for only the most elite
                  players. Your registration is subject to approval'

        z '.scroll-down',
          'Scroll to learn more'
          z '.icon',
            z @$scrollIcon,
              icon: 'expand-more'
              isTouchTarget: false
              color: colors.$primary500
              size: '36px'
      z '.bottom', {
        style:
          minHeight: "#{window?.innerHeight}px"
      },
        z '.logo'
        z '.title', 'Request an acccount'
        z '.description',
          '4,000 trophy minimum requirement'
        z @$requestInviteForm, {referrer}
