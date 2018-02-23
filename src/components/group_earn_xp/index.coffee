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
PrimaryButton = require '../primary_button'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

# TODO: make it clear that they earn xp for sticker packs

module.exports = class GroupEarnXp
  constructor: ({@model, @router, group}) ->
    @$spinner = new Spinner()

    xpActions = group.switchMap (group) =>
      @model.groupUserXpTransaction.getAllByGroupId group.id
      .map (xpTransactions) =>
        videoTransaction = _find xpTransactions, {actionKey: 'rewardedVideos'}
        videosLeft = 3 - (videoTransaction?.count or 0)
        _filter [
          if Environment.isGameApp(config.GAME_KEY)
            {
              action: @model.l.get 'earnXp.watchAd'
              actionKey: 'rewardedVideos'
              xp: 1
              $claimButton: new PrimaryButton()
              $claimButtonText: @model.l.get 'earnXp.watchAdButton', {
                  replacements: {videosLeft}
              }
              isClaimed: not videosLeft
              onclick: =>
                {loadingActionKey} = @state.getValue()
                unless loadingActionKey is 'rewardedVideos'
                  @state.set loadingActionKey: 'rewardedVideos'
                  @model.portal.call 'admob.prepareRewardedVideo', {
                    adId: if Environment.isiOS() \
                          then 'ca-app-pub-9043203456638369/5979905134'
                          else 'ca-app-pub-9043203456638369/8896044215'
                  }
                  .then =>
                    timestamp = Date.now()
                    @model.portal.call 'admob.showRewardedVideo', {timestamp}
                    .then (successKey) =>
                      @state.set loadingActionKey: null
                      @model.groupUserXpTransaction.incrementByGroupIdAndActionKey(
                        group.id, 'rewardedVideos', {timestamp, successKey}
                      )
                  .catch =>
                    @state.set loadingActionKey: null
            }
          {
            action: @model.l.get 'earnXp.dailyVisit'
            actionKey: 'dailyVisit'
            xp: 5
            $claimButton: new PrimaryButton()
            $claimButtonText: @model.l.get 'earnXp.claim'
            isClaimed: _find xpTransactions, {actionKey: 'dailyVisit'}
            onclick: (e) =>
              @state.set loadingActionKey: 'dailyVisit'
              @model.groupUserXpTransaction.incrementByGroupIdAndActionKey(
                group.id, 'dailyVisit'
              )
              .catch -> null
              .then =>
                $$button = e?.target
                if $$button
                  boundingRect = $$button.getBoundingClientRect?()
                  x = boundingRect?.left + boundingRect?.width / 2
                  y = boundingRect?.top
                else
                  x = e?.clientX
                  y = e?.clientY
                @model.xpGain.show {xp: 5, x, y}
                @state.set loadingActionKey: null
          }
          {
            action: @model.l.get 'earnXp.dailyChatMessage'
            actionKey: 'dailyChatMessage'
            route:
              key: 'groupChat'
              replacements: {groupId: group.key or group.id}
            xp: 5
            $claimButton: new PrimaryButton()
            $claimButtonText: @model.l.get 'earnXp.dailyChatMessageButton'
            isClaimed: _find xpTransactions, {actionKey: 'dailyChatMessage'}
          }
          {
            action: @model.l.get 'earnXp.dailyForumComment'
            actionKey: 'dailyForumComment'
            route:
              key: 'groupForum'
              replacements: {groupId: group.key or group.id}
            xp: 5
            $claimButton: new PrimaryButton()
            $claimButtonText: @model.l.get 'earnXp.dailyForumCommentButton'
            isClaimed: _find xpTransactions, {actionKey: 'dailyForumComment'}
          }
          {
            action: @model.l.get 'earnXp.openStickerPacks'
            actionKey: 'openStickerPacks'
            route:
              key: 'groupCollectionWithTab'
              replacements: {groupId: group.key or group.id, tab: 'shop'}
            xp: '∞'
            $claimButton: new PrimaryButton()
            $claimButtonText: @model.l.get 'earnXp.openStickerPacksButton'
            isClaimed: false
          }
          if group.id is 'ad25e866-c187-44fc-bdb5-df9fcc4c6a42'
            {
              action: @model.l.get 'earnXp.dailyVideoView'
              actionKey: 'dailyVideoView'
              route:
                key: 'groupVideos'
                replacements: {groupId: group.key or group.id}
              xp: 5
              $claimButton: new PrimaryButton()
              $claimButtonText: @model.l.get 'earnXp.dailyVideoViewButton'
              isClaimed: _find xpTransactions, {actionKey: 'dailyVideoView'}
            }
        ]

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
      xpActions: xpActions
      loadingActionKey: null

  render: =>
    {me, xpActions, loadingActionKey, meGroupUser} = @state.getValue()

    currentXp = meGroupUser?.xp or 0
    level = _find(config.XP_LEVEL_REQUIREMENTS, ({xpRequired}) ->
      currentXp >= xpRequired
    )?.level
    nextLevel = _find config.XP_LEVEL_REQUIREMENTS, {level: level + 1}
    nextLevelXp = nextLevel?.xpRequired
    xpPercent = 100 * currentXp / nextLevelXp

    z '.z-group-earn-xp',
      z '.g-grid',
        z '.bar',
          z '.fill',
            style:
              width: "#{xpPercent}%"
          z '.progress',
            @model.l.get 'general.level'
            ": #{level}"
            ' ('
            FormatService.number currentXp
            ' / '
            "#{nextLevelXp}xp"
            ')'
        z '.g-cols',
        _map xpActions, (item) =>
          {action, route, xp, onclick, isClaimed, actionKey,
            $claimButton, $claimButtonText} = item
          isLoading = loadingActionKey is actionKey
          z '.g-col.g-xs-12.g-md-6',
            z '.action',
              # z '.icon',
              #   style:
              #     backgroundImage: "url(#{config.CDN_URL}/movie.png)"

              z '.title', action
              z '.amount',
                z 'span',
                  innerHTML: '&nbsp;&middot;&nbsp;'
                "#{xp}xp"
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
