z = require 'zorium'

PrimaryButton = require '../primary_button'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class WeeklyRaffle
  constructor: ({@model, @router, group}) ->
    me = @model.user.getMe()

    @$shareButton = new PrimaryButton()

    @state = z.state {
      group: group
      player: me.switchMap ({id}) =>
        @model.player.getByUserIdAndGameKey id, 'fortnite'
        .map (player) ->
          return player or {}
      language: @model.l.getLanguage()
    }

  share: =>
    {player, group, language} = @state.getValue()

    apiUrl = config.PUBLIC_API_URL
    shareImageSrc =
      "#{apiUrl}/di/fortnite-stats/#{player?.id}/#{language}.png"
    # make request to backend to create image so it gets
    # cached by cloudflare (facebook reqs images to load fast)
    img = new Image()
    img.src = shareImageSrc
    path = "/g/#{group?.key}?referrer=#{encodeURIComponent(player.id)}" +
    "&lang=#{language}"

    @model.portal.call 'share.any', {
      text: ''
      image: shareImageSrc
      path: path # legacy (< 1.5.06)
      url: "https://#{config.HOST}#{path}"
    }

  render: =>

    z '.z-weekly-raffle',
      z '.g-grid',
        z '.subhead',
          @model.l.get 'weeklyRaffle.title'
        z 'p',
          @model.l.get 'weeklyRaffle.text1'
        z 'p',
          @model.l.get 'weeklyRaffle.text2'
        z '.share',
          z @$shareButton,
            text: @model.l.get 'general.share'
            isFullWidth: true
            onclick: @share
