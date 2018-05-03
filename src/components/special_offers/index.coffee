z = require 'zorium'
_map = require 'lodash/map'
_find = require 'lodash/find'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'
_uniq = require 'lodash/uniq'
Environment = require '../../services/environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/fromPromise'

Icon = require '../icon'
Spinner = require '../spinner'
PrimaryButton = require '../primary_button'
SpecialOfferListItem = require '../special_offer_list_item'
DateService = require '../../services/date'
SpecialOfferService = require '../../services/special_offer'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SpecialOffers
  constructor: ({@model, @router, @overlay$, @group}) ->
    @usageStatsStreams = new RxReplaySubject 1
    if @model.portal
      $offers = RxObservable.combineLatest(
        RxObservable.fromPromise @model.portal.call 'app.getDeviceId'
        @group
        @model.l.getLanguage()
        (vals...) -> vals
      )
      .switchMap ([deviceId, group, language]) =>
        @model.specialOffer.getAll {deviceId, language}
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
              offers
          else
            RxObservable.of false
        .map (offers) =>
          _map offers, (offer) =>
            new SpecialOfferListItem {@model, @router, offer, deviceId}
      .publishReplay(1).refCount()
    else
      $offers = null

    @$spinner = new Spinner()
    @$openPermissionsButton = new PrimaryButton()
    @$installAndroidAppButton = new PrimaryButton()

    me = @model.user.getMe()

    @state = z.state
      me: me
      usageStats: @usageStatsStreams.switch()
      $offers: $offers
      group: @group

  afterMount: =>
    unless Environment.isNativeApp config.GAME_KEY
      @group.take(1).subscribe (group) =>
        @model.appInstallAction.upsert {
          path: @model.group.getPath group, 'groupEarnWithType', {
            @router
            replacements:
              type: 'fire'
          }
        }
    @mountDisposable = @model.window.onResume(
      SpecialOfferService.clearUsageStatsCache
    )

  beforeUnmount: =>
    @model.appInstallAction.upsert {
      path: @router.get 'home'
    }
    @mountDisposable?.unsubscribe()

  render: =>
    {me, $offers, usageStats, group} = @state.getValue()

    isDev = config.ENV is config.ENVS.DEV
    noPermissions = usageStats is false and not isDev

    isAndroidApp = Environment.isNativeApp(config.GAME_KEY) and
                    Environment.isAndroid()
    isiOSApp = Environment.isNativeApp(config.GAME_KEY) and
                    Environment.isiOS()

    z '.z-special-offers', {
      className: z.classKebab {noPermissions}
    },
      if isiOSApp
        z '.info-box',
          z '.text',
            @model.l.get 'specialOffers.notAvailableiOS'
      else if not isAndroidApp and not isDev
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
        if _isEmpty $offers
          @model.l.get 'specialOffers.noOffersFound'
        else
          z '.g-cols',
            _map $offers, ($offer) ->
              z '.g-col.g-xs-12.g-md-6', $offer
