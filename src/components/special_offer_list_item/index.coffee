z = require 'zorium'
_defaults = require 'lodash/defaults'
Environment = require '../../services/environment'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/fromPromise'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
SemverService = require '../../services/semver'
ThemeService = require '../../services/theme'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpecialOfferListItem
  constructor: ({@model, @router, offer, deviceId}) ->
    @$infoIcon = new Icon()
    @$installFireIcon = new Icon()
    @$dailyFireIcon = new Icon()
    @$installButton = new PrimaryButton()
    @$dailyButton = new PrimaryButton()

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

    timeInForeground = offer.androidPackageStats?.TotalTimeInForeground or 0
    minutesPlayed = Math.round(
      100 * (timeInForeground / (60 * 1000))
    ) / 100

    countryData = offer.meCountryData or {}
    data = _defaults countryData, offer.defaultData
    isInstalled = offer.androidPackageStats

    {days, dailyPayout, installPayout,
      minutesPerDay} = data
    totalPayout = installPayout + days * dailyPayout
    unless totalPayout
      return z ''

    minutesPlayedPercent = Math.min(
      100 * minutesPlayed / minutesPerDay
      100
    )

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
        z '.top',
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
            if offer.transaction and offer.transaction.status isnt 'clicked'
              "#{minutesPlayed} / #{minutesPerDay} minutes"
            else
              [
                @model.l.get 'specialOffers.earnAmount', {
                  replacements:
                    amount: totalPayout
                }
                z '.icon',
                  z @$infoIcon,
                    icon: 'fire'
                    isTouchTarget: false
                    color: colors.$quaternary500
                    size: '16px'
                @model.l.get 'specialOffers.inDays', {
                  replacements:
                    days: days
                }
              ]
        z '.actions',
          z '.action', {
            className: z.classKebab {isInstalled}
          },
            z '.description', {
              style:
                color: offer.textColor
            },
              if isLoading
                @model.l.get 'general.loading'
              else
                @model.l.get 'specialOffers.install'
            if isInstalled
              z '.icon',
                z @$installFireIcon,
                  icon: 'check'
                  isTouchTarget: false
                  color: offer.textColor
                  size: '16px'

            else
              z '.button',
                z @$installButton,
                  isShort: true
                  text:
                    z '.z-special-offer-list-item_install-button',
                      "+#{installPayout}"
                      z '.icon',
                        z @$installFireIcon,
                          icon: 'fire'
                          isTouchTarget: false
                          color: colors.$quaternary500
                          size: '16px'

          z '.action',
            z '.description', {
              style:
                color: offer.textColor
            },
              if isLoading
                @model.l.get 'general.loading'
              else
                @model.l.get 'specialOffers.play', {
                  replacements:
                    minutes: minutesPerDay
                }
              if minutesPlayed
                z '.progress',
                  z '.fill',
                    style:
                      width: "#{minutesPlayedPercent}%"
                      backgroundColor: offer.textColor
                      borderColor: offer.textColor
            z '.button',
              z @$dailyButton,
                isShort: true
                isDisabled: not isInstalled
                text:
                  z '.z-special-offer-list-item_install-button',
                    "+#{dailyPayout}"
                    z '.icon',
                      z @$dailyFireIcon,
                        icon: 'fire'
                        isTouchTarget: false
                        color: colors.$quaternary500
                        size: '16px'
