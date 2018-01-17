z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

Base = require '../base'
ClashRoyaleChestCycle = require '../clash_royale_chest_cycle'
ProfileRefreshBar = require '../profile_refresh_bar'
GetPlayerTagForm = require '../get_player_tag_form'
Spinner = require '../spinner'
AddonListItem = require '../addon_list_item'
ThreadListItem = require '../thread_list_item'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
MasonryGrid = require '../masonry_grid'
UiCard = require '../ui_card'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHome extends Base
  constructor: ({@model, @router, group, @overlay$}) ->
    me = @model.user.getMe()

    player = me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$clashRoyaleChestCycle = new ClashRoyaleChestCycle {
      @model, @router, player
    }
    @$profileRefreshBar = new ProfileRefreshBar {
      @model, @router, player, @overlay$, group
    }
    @$clashRoyaleChestCycleSpinner = new Spinner()
    @$getPlayerTagForm = new GetPlayerTagForm {@model, @router}
    @$chestCycleUiCard = new UiCard()
    @$threadsUiCard = new UiCard()
    @$chatUiCard = new UiCard()
    @$addonsUiCard = new UiCard()
    @$currentDeckUiCard = new UiCard()
    @$masonryGrid = new MasonryGrid {@model}

    @state = z.state {
      group
      player
      language: @model.l.getLanguage()
      $threads: group.switchMap (group) =>
        @model.thread.getAll {
          groupId: group?.id
          category: 'all'
          sort: 'popular'
          limit: 3
        }
      .map (threads) =>
        _map threads, (thread) =>
          @getCached$ "thread-#{thread.id}", ThreadListItem, {
            @model, @router, thread, group
          }
      $addons: @model.addon.getAll({}).map (addons) =>
        addons = _filter addons, (addon) ->
          addon.key in ['chestSimulator', 'clanManager', 'deckBandit']
        _map addons, (addon) =>
          new AddonListItem {@model, @router, addon}
      deck: player.switchMap (player) =>
        @model.clashRoyalePlayerDeck.getAllByPlayerId player.id, {
          type: 'all', sort: 'recent', limit: 1
        }
      .map (playerDecks) =>
        playerDeck = playerDecks?[0]
        if playerDeck?.deck
          $deck = @getCached$ (playerDeck?.deckId), DeckCards, {
            deck: playerDeck?.deck, cardsPerRow: 8
          }
          {
            playerDeck: playerDeck
            $deck: $deck
            $stats: new PlayerDeckStats {@model, playerDeck}
          }
      groupUsersOnline: group.switchMap (group) =>
        @model.groupUser.getOnlineCountByGroupId group.id
      me: me
    }

  beforeUnmount: ->
    super()

  render: =>
    {me, group, player, $threads, $addons, deck, language,
      groupUsersOnline} = @state.getValue()

    z '.z-group-home',
      z '.g-grid',
        z '.card',
          z @$chestCycleUiCard,
            $title: @model.l.get 'profileChestsPage.title'
            minHeightPx: 200
            $content:
              z '.z-group-home_ui-card',
                if player?.id
                  [
                    z @$clashRoyaleChestCycle
                    z @$profileRefreshBar
                  ]
                else if player
                  z @$getPlayerTagForm
                else
                  @$clashRoyaleChestCycleSpinner
            submit:
              if player?.id
                {
                  text: @model.l.get 'groupHome.viewAllStats'
                  onclick: =>
                    @router.go 'groupProfile', {groupId: group.key or group.id}
                }

        z @$masonryGrid,
          columnCounts:
            mobile: 1
            desktop: 2
          $elements: _filter [
            # TODO: give each of these their own comonent with defined height
            if language in ['es', 'pt'] and group?.type is 'public' and group?.key isnt 'playhard'
              z @$threadsUiCard, {
                $title: @model.l.get 'groupHome.topForumThreads'
                minHeightPx: 354
                $content:
                  z '.z-group-home_ui-card',
                    _map $threads, ($thread) ->
                      z '.list-item',
                        z $thread, {hasPadding: false}
                submit:
                  text: @model.l.get 'general.viewAll'
                  onclick: =>
                    @router.go 'groupForum', {groupId: group.key or group.id}
              }
            z @$chatUiCard,
              $title: @model.l.get 'general.chat'
              $content:
                z '.z-group-home_ui-card',
                  @model.l.get 'groupHome.peopleInChat', {
                    replacements:
                      count: FormatService.number(groupUsersOnline or 0)
                  }
              submit:
                text: @model.l.get 'earnXp.dailyChatMessageButton'
                onclick: =>
                  @router.go 'groupChat', {groupId: group.key or group.id}

            if player?.id
              z @$currentDeckUiCard,
                $title: @model.l.get 'profileHistory.currentTitle'
                $content:
                  z '.z-group-home_ui-card',
                    z '.deck',
                      z deck?.$deck, {cardMarginPx: 0}
                      z deck?.$stats
                submit:
                  text: @model.l.get 'general.viewAll'
                  onclick: =>
                    @router.go 'groupProfile', {groupId: group.key or group.id}

            z @$addonsUiCard,
              $title: @model.l.get 'groupHome.popularAddons'
              $content:
                z '.z-group-home_ui-card',
                  _map $addons, ($addon) ->
                    z '.list-item',
                      z $addon, {hasPadding: false}
              submit:
                text: @model.l.get 'general.viewAll'
                onclick: =>
                  @router.go 'groupTools', {groupId: group.key or group.id}
          ]

          # z '.title', @model.l.get 'groupHome.notifications'
          # z '.notifications',
