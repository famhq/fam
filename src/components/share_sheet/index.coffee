z = require 'zorium'
_map = require 'lodash/map'
Rx = require 'rx-lite'
Environment = require 'clay-environment'
colors = require '../../colors'

config = require '../../config'
Icon = require '../icon'
Sheet = require '../sheet'

if window?
  require './index.styl'

SEND_LOADING_DELAY_MS = 2000 # 2s
FACEBOOK_BLUE = '#3b5998'
TWITTER_BLUE = '#4099FF'

module.exports = class ShareSheet
  constructor: ({@model, @router, @isVisible}) ->
    @$sheet = new Sheet {@model, @router, @isVisible}
    @$twitterIcon = new Icon()
    @$facebookIcon = new Icon()
    @$shareAnyIcon = new Icon()

    @state = z.state
      isVisible: @isVisible
      currentLoading: null

  render: ({path, text}) =>
    {isVisible, currentLoading} = @state.getValue()

    url = "https://#{config.HOST}#{path}"

    options =
      facebook:
        isVisible: true
        onclick: =>
          @model.portal.call 'facebook.share', {url}
        text: 'Facebook'
        $icon: z @$facebookIcon,
          icon: 'facebook'
          color: FACEBOOK_BLUE
          isTouchTarget: false

      twitter:
        isVisible: true
        onclick: =>
          @model.portal.call 'twitter.share', {
            text: "#{text} #{url}"
          }
        text: 'Twitter'
        $icon: z @$twitterIcon,
          icon: 'twitter'
          color: TWITTER_BLUE
          isTouchTarget: false

      any:
        isVisible: Environment.isGameApp config.GAME_KEY
        onclick: =>
          @model.portal.call 'share.any', {text, path}
        text: 'Other...'
        $icon: z @$shareAnyIcon,
          icon: 'share'
          color: colors.$primary500
          isTouchTarget: false

    z '.z-share-sheet', {
      onclick: =>
        @isVisible.onNext null
    },
      z @$sheet,
        $content:
          z '.z-share-sheet_sheet',
            z '.title', 'Share'
            _map options, (option, type) ->
              unless option.isVisible
                return

              z '.item', {
                onclick: option.onclick
              },
                z '.icon',
                  option.$icon
                z '.text', if currentLoading is type \
                           then 'Loading...'
                           else option.text
