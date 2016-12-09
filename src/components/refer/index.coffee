z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Refer
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()
    @$gemIcon = new Icon()
    @$shareButton = new PrimaryButton()

    @state = z.state
      me: me

  render: =>
    {me} = @state.getValue()

    z '.z-refer',
      z '.icon',
        z @$gemIcon,
          icon: 'gem'
          isTouchTarget: false
          color: colors.$primary500
          size: '56px'
      z '.description',
        z 'p',
          'For a limited time, refer new members and get
          $50 for each one that signs up and is accepted'

        z 'p', 'Coming soon!'
      # z 'input.link', {
      #   onfocus: (e) ->
      #     e.target.select()
      #   value: "https://#{config.HOST}/r/#{me?.id}"
      # }
      #
      # z @$shareButton,
      #   text: 'Share link'
      #   onclick: =>
      #     @model.portal.call 'share.any', {
      #       text: 'Red Tritium'
      #       path: "/r/#{me?.id}"
      #     }
