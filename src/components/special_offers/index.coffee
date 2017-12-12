z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
Environment = require 'clay-environment'
Fingerprint = require 'fingerprintjs'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/fromPromise'

Icon = require '../icon'
UiCard = require '../ui_card'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
DateService = require '../../services/date'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpecialOffers
  constructor: ({@model, @router, @overlay$}) ->
    if @model.portal
      getUsageStats = =>
        console.log 'gettt'
        RxObservable.fromPromise(
          @model.portal.call 'usageStats.getStats'
          .then (stats) ->
            console.log 'got, parse'
            try
              JSON.parse stats
            catch err
              []

          .catch ->
            RxObservable.of null
        )

      offers = RxObservable.combineLatest(
        RxObservable.fromPromise @model.portal.call 'app.getDeviceId'
        @model.l.getLanguage()
        (vals...) -> vals
      )
      .switchMap ([deviceId, language, time]) =>
        matches = /(Android|iPhone OS) ([0-9\._]+)/g.exec(navigator.userAgent)
        osVersion = matches?[2].replace /_/g, '.'
        @model.specialOffer.getAll {
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
          isApp: Environment.isGameApp config.GAME_KEY
          appVersion: Environment.getAppVersion config.GAME_KEY
        }
        .switchMap (offers) =>
          getUsageStats()
          .map (usageStats) =>
            offers = _map offers, (offer) =>
              usageStats = _find usageStats, {PackageName: offer.androidPackage}
              isInstalled = true or Boolean usageStats
              if isInstalled and not offer.transaction
                # give fire for installing
                console.log 'give reward'
                @model.specialOffer.giveReward {offer, usageStats}

              _defaults {
                androidPackageStats: usageStats
              }, offer
            offers or false
    else
      offers = RxObservable.of null

    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      offers: offers.map (offers) ->
        _map offers, (offer) ->
          {
            offer
            $fireIcon1: new Icon()
            $fireIcon2: new Icon()
          }

  offerAction: (offer) =>
    console.log offer
    @model.portal.call 'browser.openWindow', {
      url:
        "https://play.google.com/store/apps/details?id=#{offer.androidPackage}"
      target: '_system'
    }
    @model.portal.call 'launcher.launch', {packageName: offer.androidPackage}

  render: =>
    {me, offers} = @state.getValue()

    z '.z-special-offers',
      z '.g-grid',
        z '.g-cols',
          _map offers, ({$fireIcon1, $fireIcon2, offer}) =>
            console.log new Date offer.androidPackageStats?.FirstTimeStamp
            console.log new Date offer.androidPackageStats?.LastTimeStamp
            console.log new Date offer.androidPackageStats?.LastTimeUsed
            console.log offer.androidPackageStats?.TotalTimeInForeground / 1000, 's'

            {days, dailyPayout, installPayout} = offer.defaultData
            totalPayout = installPayout + days * dailyPayout
            z '.g-col.g-xs-12.g-md-6',
              z '.offer', {
                onclick: =>
                  @offerAction offer
              },
                z '.header',
                  style:
                    backgroundImage: "url(#{offer.backgroundImage})"
                z '.info',
                  style:
                    backgroundColor: offer.backgroundColor
                    color: offer.textColor
                  # z '.icon'
                  z '.left',
                    z '.name', {
                      style:
                        color: offer.textColor
                    },
                      offer.name
                    z '.amount', {
                      style:
                        color: offer.textColor
                    },
                      "Earn #{totalPayout}"
                      z '.icon',
                        z $fireIcon1,
                          icon: 'fire'
                          isTouchTarget: false
                          color: colors.$quaternary500
                          size: '16px'
                      "in #{days} days"
                  z '.action', {
                    style:
                      color: offer.textColor
                  },
                    z '.title',
                      if offer?.androidPackageStats
                        "Play & earn #{dailyPayout}"
                      else
                        "Install & earn #{installPayout}"
                    z '.icon',
                      z $fireIcon2,
                        icon: 'fire'
                        isTouchTarget: false
                        color: colors.$quaternary500
                        size: '16px'
                    # z '.title', 'Play 10 min today'
                    # z '.description', '3 / 5 days'
