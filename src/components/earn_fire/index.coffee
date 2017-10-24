z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'
moment = require 'moment'
Environment = require 'clay-environment'

Icon = require '../icon'
Dialog = require '../dialog'
UiCard = require '../ui_card'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EarnFire
  constructor: ({@model, @router, @overlay$}) ->
    if @model.portal
      rewards = Rx.Observable.combineLatest(
        Rx.Observable.fromPromise @model.portal.call 'app.getDeviceId'
        @model.l.getLanguage()
        (vals...) -> vals
      )
      .switchMap ([deviceId, language]) =>
        matches = /(Android|iPhone OS) ([0-9\._]+)/g.exec(navigator.userAgent)
        osVersion = matches?[2].replace /_/g, '.'
        @model.reward.getAll {
          deviceId: deviceId
          language: language
          screenDensity: window.devicePixelRatio
          screenResolution: "#{window.innerWidth}x#{window.innerHeight}"
          locale: navigator.languages?[0] or navigator.language
          osName: if Environment.isiOS() then 'iOS' else 'Android'
          osVersion: osVersion
        }
        .map (rewards) ->
          rewards or false
    else
      rewards = Rx.Observable.of null

    @$previewDialog = new Dialog()
    @$completeOfferButton = new PrimaryButton()
    @$infoCard = new UiCard()
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      isInfoCardVisible: window? and not localStorage?['hideEarnFireInfo']
      rewards: rewards.map (rewards) ->
        _map rewards, (reward) ->
          {
            reward
            $fireIcon: new Icon()
          }

  render: =>
    {me, rewards, isInfoCardVisible} = @state.getValue()

    z '.z-earn-fire',
      if isInfoCardVisible
        z @$infoCard,
          text:
            z 'div',
              z 'p', @model.l.get 'earnFire.description1'
              z 'p', @model.l.get 'earnFire.description2'
          submit:
            text: @model.l.get 'installOverlay.closeButtonText'
            onclick: =>
              @state.set isInfoCardVisible: false
              localStorage?['hideEarnFireInfo'] = '1'

      z 'p.', @model.l.get 'earnFire.youHave', {
      replacements:
        fire: FormatService.number me?.fire
      }
      z '.subhead', @model.l.get 'earnFire.description3'
      if rewards is false
        z '.no-rewards', @model.l.get 'earnFire.noRewards'
      else if _isEmpty rewards
        @$spinner
      _map rewards, ({reward, $fireIcon}) =>
        ga? 'send', 'event', 'reward', 'view', JSON.stringify(reward)

        z '.reward', {
          # href: reward.url
          onclick: (e) =>
            ga? 'send', 'event', 'reward', 'modal_open', JSON.stringify(reward)

            @overlay$.next z @$previewDialog, {
              isVanilla: true
              $title: reward.title
              $content:
                z '.z-earn-fire_preview-dialog',
                  z 'p', reward.instructions
                  if reward.averageSecondsUntilPayout
                    z 'p',
                      @model.l.get 'earnFire.averageTimeToComplete'
                      ' '
                      moment().add(reward.averageSecondsUntilPayout, 's')
                      .fromNowModified()
                  z @$completeOfferButton,
                    text: @model.l.get 'earnFire.completeOffer'
                    onclick: =>
                      ga?(
                        'send'
                        'event'
                        'reward'
                        'complete_button_click'
                        JSON.stringify(reward)
                      )
                      @model.portal.call 'browser.openWindow', {
                        url: reward.url
                        target: '_system'
                      }

              onLeave: =>
                @overlay$.next null
            }
        },
          z '.image',
            style:
              backgroundImage: "url(#{reward.imageUrl})"
          z '.text',
            reward.title
          z '.amount',
            reward.amount
            z '.icon',
              z $fireIcon,
                icon: 'fire'
                color: colors.$quaternary500
                isTouchTarget: false
