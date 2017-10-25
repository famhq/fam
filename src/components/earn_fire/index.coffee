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
      @update = new Rx.BehaviorSubject null
      rewards = Rx.Observable.combineLatest(
        Rx.Observable.fromPromise @model.portal.call 'app.getDeviceId'
        @model.l.getLanguage()
        @update
        (vals...) -> vals
      )
      .switchMap ([deviceId, language, time]) =>
        matches = /(Android|iPhone OS) ([0-9\._]+)/g.exec(navigator.userAgent)
        osVersion = matches?[2].replace /_/g, '.'
        @model.reward.getAll {
          deviceId: deviceId
          language: language
          screenDensity: window.devicePixelRatio
          screenResolution: "#{window.innerWidth}x#{window.innerHeight}"
          locale: navigator.languages?[0] or navigator.language
          osName: if Environment.isiOS() \
                  then 'iOS'
                  else if Environment.isAndroid
                  then 'Android'
                  else 'Windows' # TODO
          osVersion: osVersion
          isApp: Environment.isGameApp config.GAME_KEY
          appVersion: Environment.getAppVersion config.GAME_KEY
        }, {ignoreCache: true}
        .map (rewards) =>
          if rewards?[0]?.id is 'rewardedVideo'
            rewards[0] = {
              title: "Video (#{rewards[0].rewardedVideosLeft} left)"
              amount: 1
              imageUrl: "#{config.CDN_URL}/movie.png?"
              onclick: =>
                @state.set loadingOfferIndex: 0
                @model.portal.call 'admob.prepareRewardedVideo', {
                  adId: if Environment.isiOS() \
                        then 'ca-app-pub-9043203456638369/5979905134'
                        else 'ca-app-pub-9043203456638369/8896044215'
                }
                .then =>
                  timestamp = Date.now()
                  @model.portal.call 'admob.showRewardedVideo', {timestamp}
                  .then (successKey) =>
                    @state.set loadingOfferIndex: null
                    @model.reward.videoReward {timestamp, successKey}
                    .then =>
                      # rewards not in cache, so they don't auto-update
                      @update.next Date.now()
                .catch =>
                  @state.set loadingOfferIndex: null
            }
          rewards or false
    else
      rewards = Rx.Observable.of null

    @$previewDialog = new Dialog()
    @$tipsDialog = new Dialog()
    @$completeOfferButton = new PrimaryButton()
    @$refreshButton = new PrimaryButton()
    @$tipsButton = new PrimaryButton()
    @$infoCard = new UiCard()
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      isInfoCardVisible: window? and not localStorage?['hideEarnFireInfo']
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
    ###
    - Surveys
      - Surveys are pages littered with ads everywhere
      - The hardest part is finding the right buttons to click ("start" and "next")
      - Sometimes you have to wait for the "next" button to show
      - Typically you don't need to get 100% correct (even if it says you do)
        - Some of them only give credits for 80%+
    - Apps
      - Usually you have to download an app and either spend a couple minutes in it, or complete some action
      - Sometimes they just don't work and give you credits :/ We're trying our best to filter those ones out
    ###

  render: =>
    {me, rewards, isInfoCardVisible, loadingOfferIndex} = @state.getValue()

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

      z '.buttons',
        z '.refresh',
          z @$refreshButton,
            text: @model.l.get 'earnFire.refresh'
            isFullWidth: true
            onclick: @updateRewards

        # z '.tips',
        #   z @$tipsButton,
        #     text: @model.l.get 'earnFire.tips'
        #     isFullWidth: true
        #     onclick: @showTips

      if rewards is false
        z '.no-rewards', @model.l.get 'earnFire.noRewards'
      else if _isEmpty rewards
        @$spinner
      _map rewards, ({reward, $fireIcon}, i) =>
        ga? 'send', 'event', 'reward', 'view', JSON.stringify(reward)

        z '.reward', {
          onclick: (e) =>
            if loadingOfferIndex is i
              return
            if reward.onclick
              return reward.onclick()
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
          z '.text',
            if loadingOfferIndex is i
              @model.l.get 'general.loading'
            else
              reward.title
          z '.amount',
            FormatService.number reward.amount
            z '.icon',
              z $fireIcon,
                icon: 'fire'
                color: colors.$quaternary500
                isTouchTarget: false
