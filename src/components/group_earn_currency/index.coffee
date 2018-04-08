z = require 'zorium'
Environment = require '../../services/environment'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_find = require 'lodash/find'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/observable/combineLatest'
require 'rxjs/operator/map'
require 'rxjs/operator/switchMap'

Base = require '../base'
Icon = require '../icon'
Spinner = require '../spinner'
CurrencyIcon = require '../currency_icon'
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

# TODO: make it clear that they earn currency for sticker packs

module.exports = class GroupEarnCurrency
  constructor: ({@model, @router, group}) ->
    @$spinner = new Spinner()

    currencyActions = group.switchMap (group) =>
      @model.earnAction.getAllByGroupId group.id
      .map (actions) =>
        _map actions, (action) =>
          {
            action: action.name
            actionKey: action.key
            route:
              key: 'groupChat'
              replacements: {groupId: group.key or group.id}
            currency: action.currencyAmount
            $claimButton: new PrimaryButton()
            $claimButtonText: @model.l.get 'earnXp.dailyChatMessageButton'
            $currencyIcon: new CurrencyIcon {itemKey: action.currencyItemKey}
            isClaimed: Boolean action.transaction
          }
        # videoTransaction = _find transactions, {actionKey: 'rewardedVideos'}
        # videosLeft = 3 - (videoTransaction?.count or 0)
        # _filter [
        #   if Environment.isNativeApp(config.GAME_KEY)
        #     {
        #       action: @model.l.get 'earnXp.watchAd'
        #       actionKey: 'rewardedVideos'
        #       currency: 1
        #       $claimButton: new PrimaryButton()
        #       $currencyIcon: new CurrencyIcon {itemKey: action?.currencyItemKey}
        #       $claimButtonText: @model.l.get 'earnXp.watchAdButton', {
        #           replacements: {videosLeft}
        #       }
        #       isClaimed: not videosLeft
        #       onclick: =>
        #         {loadingActionKey} = @state.getValue()
        #         unless loadingActionKey is 'rewardedVideos'
        #           @state.set loadingActionKey: 'rewardedVideos'
        #           @model.portal.call 'admob.prepareRewardedVideo', {
        #             adId: if Environment.isiOS() \
        #                   then 'ca-app-pub-9043203456638369/5979905134'
        #                   else 'ca-app-pub-9043203456638369/8896044215'
        #           }
        #           .then =>
        #             timestamp = Date.now()
        #             @model.portal.call 'admob.showRewardedVideo', {timestamp}
        #             .then (successKey) =>
        #               @state.set loadingActionKey: null
        #               @model.earnAction.incrementByGroupIdAndKey(
        #                 group.id, 'rewardedVideos', {timestamp, successKey}
        #               )
        #           .catch =>
        #             @state.set loadingActionKey: null
        #     }
        #   {
        #     action: @model.l.get 'earnXp.dailyVisit'
        #     actionKey: 'dailyVisit'
        #     currency: 5
        #     $claimButton: new PrimaryButton()
        #     $claimButtonText: @model.l.get 'earnXp.claim'
        #     isClaimed: _find transactions, {actionKey: 'dailyVisit'}
        #     onclick: (e) =>
        #       @state.set loadingActionKey: 'dailyVisit'
        #       @model.rewardTransaction.incrementByGroupIdAndActionKey(
        #         group.id, 'dailyVisit'
        #       )
        #       .catch -> null
        #       .then =>
        #         $$button = e?.target
        #         if $$button
        #           boundingRect = $$button.getBoundingClientRect?()
        #           x = boundingRect?.left + boundingRect?.width / 2
        #           y = boundingRect?.top
        #         else
        #           x = e?.clientX
        #           y = e?.clientY
        #         @model.currencyGain.show {currency: 5, x, y}
        #         @state.set loadingActionKey: null
        #   }
          # {
          #   action: @model.l.get 'earnXp.dailyChatMessage'
          #   actionKey: 'dailyChatMessage'
          #   route:
          #     key: 'groupChat'
          #     replacements: {groupId: group.key or group.id}
          #   currency: 5
          #   $claimButton: new PrimaryButton()
          #   $claimButtonText: @model.l.get 'earnXp.dailyChatMessageButton'
          #   isClaimed: _find transactions, {actionKey: 'dailyChatMessage'}
          # }
          # {
          #   action: @model.l.get 'earnXp.dailyForumComment'
          #   actionKey: 'dailyForumComment'
          #   route:
          #     key: 'groupForum'
          #     replacements: {groupId: group.key or group.id}
          #   currency: 5
          #   $claimButton: new PrimaryButton()
          #   $claimButtonText: @model.l.get 'earnXp.dailyForumCommentButton'
          #   isClaimed: _find transactions, {actionKey: 'dailyForumComment'}
          # }
          # {
          #   action: @model.l.get 'earnXp.openStickerPacks'
          #   actionKey: 'openStickerPacks'
          #   route:
          #     key: 'groupCollectionWithTab'
          #     replacements: {groupId: group.key or group.id, tab: 'shop'}
          #   currency: '∞'
          #   $claimButton: new PrimaryButton()
          #   $claimButtonText: @model.l.get 'earnXp.openStickerPacksButton'
          #   isClaimed: false
          # }
          # if group.id is 'ad25e866-c187-44fc-bdb5-df9fcc4c6a42'
          #   {
          #     action: @model.l.get 'earnXp.dailyVideoView'
          #     actionKey: 'dailyVideoView'
          #     route:
          #       key: 'groupVideos'
          #       replacements: {groupId: group.key or group.id}
          #     currency: 5
          #     $claimButton: new PrimaryButton()
          #     $claimButtonText: @model.l.get 'earnXp.dailyVideoViewButton'
          #     isClaimed: _find transactions, {actionKey: 'dailyVideoView'}
          #   }
        # ]

    me = @model.user.getMe()

    groupAndMe = RxObservable.combineLatest(
      group
      me
      (vals...) -> vals
    )

    @state = z.state
      me: me
      meGroupUser: groupAndMe.switchMap ([group, me]) =>
        @model.groupUser.getByGroupIdAndUserId group.id, me.id
      currencyActions: currencyActions
      loadingActionKey: null

  render: =>
    {me, currencyActions, loadingActionKey, meGroupUser} = @state.getValue()

    z '.z-group-earn-currency',
      z '.g-grid',
        z '.g-cols',
        _map currencyActions, (item) =>
          {action, route, currency, onclick, isClaimed, actionKey,
            $claimButton, $claimButtonText, $currencyIcon} = item
          isLoading = loadingActionKey is actionKey
          z '.g-col.g-xs-12.g-md-6',
            z '.action',
              z '.title', action
              z '.amount',
                z 'span',
                  innerHTML: '&nbsp;&middot;&nbsp;'
                currency
                z $currencyIcon, {size: '16px'}
              z '.button',
                if isClaimed
                  'Claimed'
                else
                  z $claimButton,
                    text: if isLoading \
                          then @model.l.get 'general.loading'
                          else $claimButtonText
                    onclick: (e) =>
                      onclick? e
                      if route
                        @router.go route.key, route.replacements
