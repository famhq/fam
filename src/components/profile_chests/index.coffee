z = require 'zorium'
_map = require 'lodash/map'
_startCase = require 'lodash/startCase'
Rx = require 'rx-lite'
Environment = require 'clay-environment'

config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ProfileChests
  constructor: ({@model, @router, player}) ->
    @state = z.state {
      me: @model.user.getMe()
      player: player
    }

  afterMount: =>
    {player, me} = @state.getValue()

    unless player?.isVerified
      @model.portal.call 'heyzap.showBanner', {
        position: 'bottom'
        # size: 'large'
      }
      @model.portal.call 'facebook.showBanner', {
        placementId: '305278286509542_418535418517161'
        position: 'bottom'
      }

  #   setTimeout =>
  #     @addFbAd()
  #   , 100
  #
  beforeUnmount: =>
    @model.portal.call 'facebook.destroyBanner'
    @model.portal.call 'heyzap.destroyBanner'
    # @destroyFbAd()

  # ugly, but works
  # https://github.com/fbsamples/audience-network/blob/master/samples/mobile_web/mweb_dynamic.html
  # FIXME FIXME: move into portal-gun, have the iframe be in app.coffee
  # addFbAd: ->
  #   placementId = '305278286509542_418535418517161'
  #   txt1 = '<script id="facebook-jssdk" src="https://connect.facebook.net/en_US/sdk/xfbml.ad.js#xfbml=1&version=v2.5&appId=' + config.FB_ID + '">' + '</scr' + 'ipt>'
  #   txt3 = '<script>' + 'window.fbAsyncInit = function() {' + 'FB.Event.subscribe(' + '\'ad.loaded\',' + 'function(placementID) {' + 'console.log(\'ad loaded\');' + '});' + 'FB.Event.subscribe(' + '\'ad.error\',' + 'function(errorCode, errorMessage, placementID) {' + 'console.log(\'ad error \' + errorCode + \': \' + errorMessage);' + '});' + '};' + '</scr' + 'ipt>'
  #   txt2 = '<div id="fb-root">' + '</div>' + '<fb:' + 'ad placementid="' + placementId + '" format="320x50" testmode="false">' + '</fb:' + 'ad>'
  #   $fbAd = document.getElementById 'fb-ad'
  #   if $fbAd
  #     docMWeb = $fbAd.contentWindow.document
  #     docMWeb.open()
  #     docMWeb.write '<html><head>' + txt1 + '</head><body>' + txt3 + txt2 + '</body></html>'
  #     docMWeb.close()
  #
  # destroyFbAd: ->
  #   $fbAd = document.getElementById('fb-ad')
  #   if $fbAd
  #     $fbAd.contentWindow.location.reload()

  render: =>
    {player, me} = @state.getValue()

    isNative = Environment.isGameApp config.GAME_KEY
    isVerified = player?.isVerified

    z '.z-profile-chests',
      z '.g-grid',
        z '.title', @model.l.get 'profileChests.chestsTitle'
        z '.chests', {
          ontouchstart: (e) ->
            e?.stopPropagation()
        },
          _map player?.data.chestCycle.chests, (chest, i) ->
            if i is player?.data.chestCycle.countUntil.superMagical
              chest = 'super_magical'
            else if i is player?.data.chestCycle.countUntil.legendary
              chest = 'legendary'
            else if i is player?.data.chestCycle.countUntil.epic
              chest = 'epic'
            z '.chest',
              z 'img',
                src: "#{config.CDN_URL}/chests/#{chest}_chest.png"
                width: 90
                height: 90
              z '.count',
                if i is 0 then 'Next' else "+#{i + 1}"
        z '.title', @model.l.get 'profileChests.chestsUntilTitle'
        z '.chests-until',
          z '.chest',
            z '.image',
              style:
                backgroundImage:
                  "url(#{config.CDN_URL}/chests/super_magical_chest.png)"
            z '.info',
              z '.name', 'Super Magical'
              z '.count',
                "+#{player?.data.chestCycle.countUntil.superMagical + 1}"

          if player?.data.chestCycle.countUntil.legendary
            z '.chest',
              z '.image',
                style:
                  backgroundImage:
                    "url(#{config.CDN_URL}/chests/legendary_chest.png)"
              z '.info',
                z '.name', 'Legendary'
                z '.count',
                  "+#{player?.data.chestCycle.countUntil.legendary + 1}"

          if player?.data.chestCycle.countUntil.epic
            z '.chest',
              z '.image',
                style:
                  backgroundImage:
                    "url(#{config.CDN_URL}/chests/epic_chest.png)"
              z '.info',
                z '.name', 'Epic'
                z '.count',
                  "+#{player?.data.chestCycle.countUntil.epic + 1}"


        # leadbolt cpms suck
        # if window? and Environment.isMobile() and not isNative
        #   # z 'iframe#fb-ad.banner'
        #   referer = window.location.href.substr(0, 255)
        #   z 'iframe.banner',
        #     src: 'https://ad.leadbolt.net/show_app_ad?' +
        #         'section_id=442400826' +
        #         "&lang=#{navigator.language}" +
        #         "&scr_w=#{window.screen.width}" +
        #         "&scr_h=#{window.screen.height}" +
        #         "&referer=#{encodeURIComponent(referer)}"
        #     scrolling: 'no'
