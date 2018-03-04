z = require 'zorium'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'
Environment = require '../../services/environment'
Fingerprint = require 'fingerprintjs'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/fromPromise'

Icon = require '../icon'
Dialog = require '../dialog'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
DateService = require '../../services/date'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EarnFire
  constructor: ({@model, @router, @overlay$, group}) ->
    if @model.portal
      @update = new RxBehaviorSubject null

      rewards = RxObservable.combineLatest(
        RxObservable.fromPromise @model.portal.call 'app.getDeviceId'
        @model.l.getLanguage()
        group
        @update
        (vals...) -> vals
      )
      .switchMap ([deviceId, language, group, time]) =>
        matches = /(Android|iPhone OS) ([0-9\._]+)/g.exec(navigator.userAgent)
        osVersion = matches?[2].replace /_/g, '.'
        @model.reward.getAll {
          deviceId: deviceId
          language: language
          screenDensity: window.devicePixelRatio
          screenResolution: "#{window.innerWidth}x#{window.innerHeight}"
          locale: navigator.languages?[0] or navigator.language or language
          osName: if Environment.isiOS() \
                  then 'iOS'
                  else if Environment.isAndroid()
                  then 'Android'
                  else 'Windows' # TODO
          osVersion: osVersion
          isApp: Environment.isNativeApp config.GAME_KEY
          appVersion: Environment.getAppVersion config.GAME_KEY
          groupId: group.id
        }, {ignoreCache: true}
        .map (rewards) ->
          rewards or false
    else
      rewards = RxObservable.of null

    @$previewDialog = new Dialog()
    @$tipsDialog = new Dialog()
    @$completeOfferButton = new PrimaryButton()
    @$refreshButton = new PrimaryButton()
    @$tipsButton = new PrimaryButton()
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      loadingOfferIndex: null
      rewards: rewards.map (rewards) ->
        _map rewards, (reward) ->
          {
            reward
            $fireIcon: new Icon()
          }

  updateRewards: =>
    @update.next Date.now()

  showTips: =>
    @overlay$.next z @$tipsDialog, {
      isVanilla: true
      isWide: true
      $title: @model.l.get 'earnFire.tips'
      $content:
        z '.z-earn-fire_tips-dialog',
          z 'ul',
            z 'li', @model.l.get 'earnFire.tips1'
            z 'ul',
              z 'li', @model.l.get 'earnFire.tips1a'
              z 'li', @model.l.get 'earnFire.tips1b'
              z 'li', @model.l.get 'earnFire.tips1c'
              z 'li', @model.l.get 'earnFire.tips1d'
              z 'ul',
                z 'li', @model.l.get 'earnFire.tips1d1'
              z 'li', @model.l.get 'earnFire.tips1e'
            z 'li', @model.l.get 'earnFire.tips2'
            z 'ul',
              z 'li', @model.l.get 'earnFire.tips2a'
              z 'li', @model.l.get 'earnFire.tips2b'
            z 'li', @model.l.get 'earnFire.tips3'
            z 'ul',
              z 'li', @model.l.get 'earnFire.tips3a'
      onLeave: =>
        @overlay$.next null
      cancelButton:
        text: @model.l.get 'installOverlay.closeButtonText'
        onclick: =>
          @overlay$.next null
    }

  render: =>
    {me, rewards, loadingOfferIndex} = @state.getValue()

    z '.z-earn-fire',
      z '.g-grid',
        if not rewards?
          @$spinner
        else if _isEmpty rewards
          z '.no-rewards', @model.l.get 'earnFire.noRewards'
        else
          [
            _map rewards, ({reward, $fireIcon}, i) =>
              z '.reward', {
                onclick: (e) =>
                  if loadingOfferIndex is i
                    return
                  if reward.onclick
                    return reward.onclick()

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
                            DateService.fromNow(
                              Date.now() +
                                (reward.averageSecondsUntilPayout * 1000)
                            )
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
                            # if we wait for this, popup gets blocked
                            @model.reward.incrementAttemptsByNetworkAndOfferId {
                              network: reward.network, offerId: reward.offerId
                            }
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
                z '.info',
                  z '.title',
                    if loadingOfferIndex is i
                      @model.l.get 'general.loading'
                    else
                      reward.title

                  z '.description',
                    reward.instructions

                  z '.amount',
                    @model.l.get 'general.earn'
                    ' '
                    FormatService.number reward.amount
                    z '.icon',
                      z $fireIcon,
                        icon: 'fire'
                        color: colors.$quaternary500
                        isTouchTarget: false
                        size: '16px'

            z '.buttons',
              z '.refresh',
                z @$refreshButton,
                  text: @model.l.get 'earnFire.refresh'
                  isFullWidth: true
                  onclick: @updateRewards

              z '.tips',
                z @$tipsButton,
                  text: @model.l.get 'earnFire.tips'
                  isFullWidth: true
                  onclick: @showTips
          ]
