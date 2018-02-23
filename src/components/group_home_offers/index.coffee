z = require 'zorium'
_map = require 'lodash/map'
_sumBy = require 'lodash/sumBy'
_defaults = require 'lodash/defaults'
_take = require 'lodash/take'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
Environment = require '../../services/environment'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/fromPromise'

Base = require '../base'
Spinner = require '../spinner'
Icon = require '../icon'
SpecialOfferListItem = require '../special_offer_list_item'
PrimaryButton = require '../primary_button'
UiCard = require '../ui_card'
FormatService = require '../../services/format'
SpecialOfferService = require '../../services/special_offer'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupHomeOffers
  constructor: ({@model, @router, @group, player, @overlay$}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$fireIcon = new Icon()
    @$uiCard = new UiCard()
    @$openPermissionsButton = new PrimaryButton()
    @$installAndroidAppButton = new PrimaryButton()

    @usageStatsStreams = new RxReplaySubject 1
    if @model.portal
      $offers = RxObservable.combineLatest(
        RxObservable.fromPromise @model.portal.call 'app.getDeviceId'
        @group
        @model.l.getLanguage()
        (vals...) -> vals
      )
      .switchMap ([deviceId, group, language]) =>
        @model.specialOffer.getAll {deviceId, language, limit: 3}
        .switchMap (offers) =>
          if offers
            packageNames = _map offers, 'androidPackage'
            usageStats = RxObservable.fromPromise(
              SpecialOfferService.getUsageStats {
                @model, packageNames
              }
              .catch (err) ->
                false
            )
            @usageStatsStreams.next usageStats
            usageStats
            .map (usageStats) =>
              offers = SpecialOfferService.embedStatsAndFilter {
                offers, usageStats, @model, deviceId, groupId: group.id
              }
          else
            RxObservable.of false
        .map (offers) =>
          offers = _take(offers, 1)
          _map offers, (offer) =>
            new SpecialOfferListItem {@model, @router, offer, deviceId}
      .publishReplay(1).refCount()
    else
      $offers = null

    @state = z.state {
      me
      @group
      usageStats: @usageStatsStreams.switch()
      $offers: $offers
    }

  afterMount: =>
    unless Environment.isGameApp config.GAME_KEY
      @group.take(1).subscribe (group) =>
        @model.appInstallAction.upsert {
          path: @router.get 'groupHome', {
            groupId: group.key or group.id
          }
        }
    @mountDisposable = @model.window.onResume(
      SpecialOfferService.clearUsageStatsCache
    )

  beforeUnmount: =>
    @mountDisposable?.unsubscribe()

  render: =>
    {me, group, usageStats, $offers} = @state.getValue()

    noPermissions = usageStats is false
    isAndroidApp = Environment.isGameApp(config.GAME_KEY) and
                    Environment.isAndroid()
    isiOSApp = Environment.isGameApp(config.GAME_KEY) and
                    Environment.isiOS()

    z '.z-group-home-offers',
      z @$uiCard,
        $title: @model.l.get 'groupHome.shop'
        $content:
          z '.z-group-home-offers_ui-card',
            z '.fire-amount',
              z '.amount', FormatService.number me?.fire
              z '.icon',
                z @$fireIcon,
                  icon: 'fire'
                  color: colors.$quaternary500
                  isTouchTarget: false
            z '.description', @model.l.get 'groupHome.offersDescription'
            z '.offers', {
              className: z.classKebab {noPermissions}
            },
              if isiOSApp
                z '.info-box',
                  z '.text',
                    @model.l.get 'specialOffers.notAvailableiOS'
              else if not isAndroidApp# and not isDev
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
              z $offers
        submit:
          text: @model.l.get 'groupHome.goToShop'
          onclick: =>
            @router.go 'groupFire', {groupId: group.key or group.id}
