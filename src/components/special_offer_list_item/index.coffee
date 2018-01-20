z = require 'zorium'
_defaults = require 'lodash/defaults'
Environment = require 'clay-environment'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/fromPromise'

Icon = require '../icon'
FormatService = require '../../services/format'
SemverService = require '../../services/semver'
ThemeService = require '../../services/theme'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpecialOfferListItem
  constructor: ({@model, @router, offer, deviceId}) ->
    @$fireIcon1 = new Icon()
    @$fireIcon2 = new Icon()

    @state = z.state
      me: @model.user.getMe()
      deviceId: deviceId
      isLoading: false
      offer: offer

  offerAction: (offer) =>
    {deviceId} = @state.getValue()

    @state.set isLoading: true
    @model.specialOffer.logClickById offer.id, {deviceId}
    .then =>
      appVersion = Environment.getAppVersion config.GAME_KEY
      openCustomMappstreet = appVersion and
                              SemverService.gte(appVersion, '1.4.15') and
                              offer.defaultData.sourceType is 'mappstreet'

      trackUrl = offer.defaultData.trackUrl
      if trackUrl
        trackUrl = trackUrl.replace '{deviceId}', deviceId

      if offer.transaction and offer.transaction.status isnt 'clicked'
        @model.portal.call 'launcher.launch', {
          options:
            packageName: offer.androidPackage
        }
        .then =>
          @state.set isLoading: false
      else if openCustomMappstreet
        @model.portal.call 'browser.openWindow', {
          url: trackUrl
          # target: '_system'
          target: '_blank'
          executeJs: 'try { var response = document.body.getAttribute(\'onclick\') } catch (err) { var response = \'\' }; response || window.location.href'
          options:
            hidden: true
            statusbar: {
              color: ThemeService.getVariableValue colors.$primary700
            }
            toolbar: {
              height: 56
              color: ThemeService.getVariableValue colors.$tertiary700
            }
            title: {
              color: ThemeService.getVariableValue colors.$tertiary700Text
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
              url: trackUrl
              target: '_system'
            }
        .then =>
          @state.set isLoading: false

      else
        @model.portal.call 'browser.openWindow', {
          url: trackUrl or "https://play.google.com/store/apps/details?id=#{offer.androidPackage}"
          target: '_system'
        }
        .then =>
          @state.set isLoading: false
    .catch (err) =>
      console.log 'caught', err
      @state.set isLoading: false

  render: =>
    {me, offer, isLoading} = @state.getValue()

    minutesPlayed = Math.floor(
      (offer.androidPackageStats?.TotalTimeInForeground or 0) / (60 * 1000)
    )

    countryData = offer.meCountryData or {}
    data = _defaults countryData, offer.defaultData

    {days, dailyPayout, installPayout,
      minutesPerDay} = data
    totalPayout = installPayout + days * dailyPayout
    unless totalPayout
      return z ''
    z '.z-special-offer-list-item', {
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
            if offer.transaction and offer.transaction?.status isnt 'clicked'
              "#{minutesPlayed} / #{minutesPerDay} minutes"
            else
              [
                @model.l.get 'specialOffers.earnAmount', {
                  replacements:
                    amount: totalPayout
                }
                z '.icon',
                  z @$fireIcon1,
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
            z @$fireIcon2,
              icon: 'fire'
              isTouchTarget: false
              color: colors.$quaternary500
              size: '16px'
          # z '.title', 'Play 10 min today'
          # z '.description', '3 / 5 days'
