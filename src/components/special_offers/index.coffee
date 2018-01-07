z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_filter = require 'lodash/filter'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'
_uniq = require 'lodash/uniq'
Environment = require 'clay-environment'
Fingerprint = require 'fingerprintjs'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
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
SemverService = require '../../services/semver'
DateService = require '../../services/date'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpecialOffers
  constructor: ({@model, @router, @overlay$}) ->
    @usageStatsStreams = new RxReplaySubject 1
    if @model.portal
      specialOffersAndUsageStats = RxObservable.combineLatest(
        @getSpecialOffers()
        @usageStatsStreams.switch()
        (vals...) -> vals
      )
      @deviceId = RxObservable.fromPromise @model.portal.call 'app.getDeviceId'
      @offers = specialOffersAndUsageStats.map ([offers, usageStats]) ->
        offers = _filter _map offers, (offer) ->
          stats = _find usageStats, {PackageName: offer.androidPackage}

          isInstalled = Boolean stats
          wasPreviouslyInstalled = isInstalled and not offer.transaction
          isCompleted = offer.transaction?.status is 'completed'
          if (wasPreviouslyInstalled or isCompleted) and config.ENV isnt config.ENVS.DEV
            return

          _defaults {
            androidPackageStats: stats
          }, offer
        offers or false
    else
      @deviceId = RxObservable.of null
      @offers = RxObservable.of null

    @$spinner = new Spinner()
    @$openPermissionsButton = new PrimaryButton()
    @$installAndroidAppButton = new PrimaryButton()

    me = @model.user.getMe()

    @state = z.state
      me: me
      deviceId: @deviceId
      country: me.map (me) -> me?.country or 'br' # TODO
      usageStats: @usageStatsStreams.switch()
      loadingOfferId: null
      offers: @offers.map (offers) ->
        _map offers, (offer) ->
          {
            offer
            $fireIcon1: new Icon()
            $fireIcon2: new Icon()
          }

  afterMount: =>
    @mountDisposable = @model.window.onResume @fetchUsageStats
    @fetchUsageStats()

  beforeUnmount: =>
    @mountDisposable?.unsubscribe()

  fetchUsageStats: =>
    {country, deviceId} = @state.getValue()

    usageStatsPromise = @model.portal.call 'usageStats.getStats'
    # .catch -> null
    .then (stats) ->
      usageStats = try
        JSON.parse stats
      catch err
        []
    @usageStatsStreams.next RxObservable.fromPromise usageStatsPromise

    Promise.all [
      usageStatsPromise
      @offers.take(1).toPromise()
    ]
    .then ([usageStats, offers]) =>
      offers = _filter _map offers, (offer) =>
        stats = _find usageStats, {PackageName: offer.androidPackage}
        isInstalled = Boolean stats
        wasPreviouslyInstalled = isInstalled and not offer.transaction
        isCompleted = offer.transaction?.status is 'completed'
        if wasPreviouslyInstalled or isCompleted
          return # there should be a 'clicked' transaction
        else if isInstalled and offer.transaction.status is 'clicked'
          # give fire for installing
          @model.specialOffer.giveInstallReward {
            offer, deviceId, usageStats: stats
          }
        else if isInstalled and offer.transaction.status is 'installed'
          minutesPlayed = Math.floor(
            offer.androidPackageStats?.TotalTimeInForeground / (60 * 1000)
          )
          data = _defaults offer.countryData[country], offer.defaultData
          hasCompletedDailyMinutes = minutesPlayed > data.minutesPerDay
          if hasCompletedDailyMinutes
            @model.specialOffer.giveDailyReward {
              offer, deviceId, usageStats: stats
            }
        else
          console.log 'none', isInstalled, offer.transaction

        _defaults {
          androidPackageStats: stats
        }, offer

  getSpecialOffers: =>
    RxObservable.combineLatest(
      @deviceId or RxObservable.of null
      @model.l.getLanguage()
      (vals...) -> vals
    )
    .switchMap ([deviceId, language]) =>
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

  offerAction: (offer) =>
    {usageStats, deviceId, country} = @state.getValue()

    @state.set loadingOfferId: offer.id
    @model.specialOffer.logClickById offer.id, {deviceId, country}
    .then =>
      appVersion = Environment.getAppVersion config.GAME_KEY
      openCustomMappstreet = SemverService.gte(appVersion, '1.4.15') and
                              offer.defaultData.sourceType is 'mappstreet'

      if _find usageStats, {PackageName: offer.androidPackage} and config.ENV isnt config.ENVS.DEV
        @model.portal.call 'launcher.launch', {
          options:
            packageName: offer.androidPackage
        }
        .then =>
          @state.set loadingOfferId: null
      else if openCustomMappstreet
        @model.portal.call 'browser.openWindow', {
          url: offer.trackUrl
          # target: '_system'
          target: '_blank'
          executeJs: 'try { var response = document.body.getAttribute(\'onclick\') } catch (err) { var response = \'\' }; response || window.location.href'
          options:
            hidden: true
            statusbar: {
              color: colors.$primary700
            }
            toolbar: {
              height: 56
              color: colors.$tertiary700
            }
            title: {
              color: colors.$tertiary700Text
              staticText: ''
            }
            closeButton: {
              image: 'close'
              align: 'left'
              event: 'closePressed'
            }
        }
        .then (response) =>
          text = response?[0] or ''

          if googlePlayLink = text.match /(https:\/\/play\.google[^"]+)/i
            url = googlePlayLink[0]
            @model.portal.call 'browser.openWindow', {
              url, target: '_system'
            }
          else if code = text.match /10482__0__0.05__([^&]*)/
            @model.portal.call 'browser.openWindow', {
              url: "https://play.google.com/store/apps/details?id=#{offer.androidPackage}&referrer=utm_source%3D#{code}"
              target: '_system'
            }
          else
            @model.portal.call 'browser.openWindow', {
              url: offer.trackUrl
              target: '_system'
            }
        .then =>
          @state.set loadingOfferId: null

      else
        @model.portal.call 'browser.openWindow', {
          url: offer.trackUrl or "https://play.google.com/store/apps/details?id=#{offer.androidPackage}"
          target: '_system'
        }
        .then =>
          @state.set loadingOfferId: null
    .catch =>
      @state.set loadingOfferId: null

  render: =>
    {me, country, offers, usageStats, loadingOfferId} = @state.getValue()

    noPermissions = _isEmpty usageStats

    isAndroidApp = Environment.isGameApp(config.GAME_KEY) and
                    Environment.isAndroid()
    isiOSApp = Environment.isGameApp(config.GAME_KEY) and
                    Environment.isiOS()

    z '.z-special-offers', {
      className: z.classKebab {noPermissions}
    },
      if isiOSApp
        z '.info-box',
          z '.text',
            @model.l.get 'specialOffers.notAvailableiOS'
      else if not isAndroidApp
        z '.info-box',
          z '.text',
            @model.l.get 'specialOffers.requiresAndroidApp'
          z @$installAndroidAppButton,
            text: @model.l.get 'specialOffers.installAndroidApp'
            onclick: =>
              @model.portal.call 'browser.openWindow', {
                url: 'https://play.google.com/store/apps/details?id=com.clay.redtritium'
                target: '_system'
              }
      else if noPermissions
        z '.info-box',
          z '.text',
            @model.l.get 'specialOffers.permissionInfo'
          z @$openPermissionsButton,
            text: @model.l.get 'specialOffers.openPermissions'
            onclick: =>
              @model.portal.call 'usageStats.openPermissions'
      z '.g-grid',
        if _isEmpty offers
          @model.l.get 'specialOffers.noOffersFound'
        else
          z '.g-cols',
            _map offers, ({$fireIcon1, $fireIcon2, offer}) =>
              # console.log new Date offer.androidPackageStats?.FirstTimeStamp
              # console.log new Date offer.androidPackageStats?.LastTimeStamp
              # console.log new Date offer.androidPackageStats?.LastTimeUsed
              minutesPlayed = Math.floor(
                offer.androidPackageStats?.TotalTimeInForeground / (60 * 1000)
              )

              isLoading = loadingOfferId is offer.id

              data = _defaults offer.countryData[country], offer.defaultData

              {days, dailyPayout, installPayout,
                minutesPerDay} = data
              totalPayout = installPayout + days * dailyPayout
              z '.g-col.g-xs-12.g-md-6',
                z '.offer', {
                  onclick: =>
                    unless isLoading
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
                        if offer.transaction?.status is 'installed'
                          "#{minutesPlayed} / #{minutesPerDay} minutes"
                        else
                          [
                            @model.l.get 'specialOffers.earnAmount', {
                              replacements:
                                amount: totalPayout
                            }
                            z '.icon',
                              z $fireIcon1,
                                icon: 'fire'
                                isTouchTarget: false
                                color: colors.$quaternary500
                                size: '16px'
                            @model.l.get 'specialOffers.inDays', {
                              replacements:
                                days: days
                            }
                          ]
                    z '.action', {
                      style:
                        color: offer.textColor
                    },
                      z '.title',
                        if isLoading
                          @model.l.get 'general.loading'
                        else if offer?.androidPackageStats
                          @model.l.get 'specialOffers.playAndEarn', {
                            replacements:
                              amount: dailyPayout
                          }
                        else
                          @model.l.get 'specialOffers.installAndEarn', {
                            replacements:
                              amount: installPayout
                          }
                      z '.icon',
                        z $fireIcon2,
                          icon: 'fire'
                          isTouchTarget: false
                          color: colors.$quaternary500
                          size: '16px'
                      # z '.title', 'Play 10 min today'
                      # z '.description', '3 / 5 days'
