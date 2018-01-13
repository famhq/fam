z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

ClashRoyaleChestCycle = require '../clash_royale_chest_cycle'
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

# TODO TODO: have the profile page for users in this ab group show all chests

# TODO: grid component that orders correctly and groups in flexboxes

# TODO: refresh profile in chest cycle card?

module.exports = class GroupHome
  constructor: ({@model, @router, group, gameKey}) ->
    me = @model.user.getMe()

    # FIXME: rm
    group ?= Rx.Observable.of {id: config.CLASH_ROYALE_ID}

    player = me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$clashRoyaleChestCycle = new ClashRoyaleChestCycle {
      @model, @router, player
    }
    @$chestCycleUiCard = new UiCard()
    @$threadsUiCard = new UiCard()
    @$chatUiCard = new UiCard()
    @$addonsUiCard = new UiCard()
    @$currentDeckUiCard = new UiCard()
    @$masonryGrid = new MasonryGrid {@model}

    @state = z.state {
      group
      gameKey
      $threads: group.switchMap (group) =>
        console.log 'tm', group
        @model.thread.getAll {
          groupId: group?.id
          gameKey: config.DEFAULT_GAME_KEY
          category: 'all'
          sort: 'popular'
          limit: 3
        }
      .map (threads) =>
        _map threads, (thread) =>
          new ThreadListItem {
            @model, @router, gameKey, thread
          }
      $addons: @model.addon.getAll({}).map (addons) =>
        addons = _filter addons, (addon) ->
          addon.key in ['chestSimulator', 'clanManager', 'deckBandit']
        _map addons, (addon) =>
          new AddonListItem {@model, @router, gameKey, addon}
      deck: player.switchMap (player) =>
        @model.clashRoyalePlayerDeck.getAllByPlayerId player.id, {
          type: 'all', sort: 'recent', limit: 1
        }
      .map (playerDecks) =>
        playerDeck = playerDecks?[0]
        if playerDeck?.deck
          {
            playerDeck: playerDeck
            $deck: new DeckCards {deck: playerDeck?.deck, cardsPerRow: 8}
            $stats: new PlayerDeckStats {@model, playerDeck}
          }
      groupUsersOnline: group.switchMap (group) =>
        @model.groupUser.getOnlineCountByGroupId group.id
      me: me
    }

  render: =>
    {me, group, $threads, $addons, deck,
      groupUsersOnline, gameKey} = @state.getValue()

    gameKey ?= config.DEFAULT_GAME_KEY # TODO: rm

    z '.z-group-home',
      z '.g-grid',
        z '.card',
          z @$chestCycleUiCard,
            $title: @model.l.get 'profileChestsPage.title'
            $content:
              z '.z-group-home_ui-card',
                z @$clashRoyaleChestCycle
            submit:
              text: @model.l.get 'groupHome.viewAllStats'
              onclick: =>
                @router.go 'profile', {gameKey}

        z @$masonryGrid,
          columnCounts:
            mobile: 1
            desktop: 2
          $elements: [
            z @$threadsUiCard, {
              $title: @model.l.get 'groupHome.topForumThreads'
              $content:
                z '.z-group-home_ui-card',
                  _map $threads, ($thread) ->
                    z '.list-item', $thread
              submit:
                text: @model.l.get 'general.viewAll'
                onclick: =>
                  @router.go 'forum', {gameKey}
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
                  @router.go 'groupChat', {gameKey, id: group?.id}

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
                  @router.go 'mods', {gameKey}

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
                  @router.go 'profile', {gameKey}
          ]

          # z '.title', @model.l.get 'groupHome.notifications'
          # z '.notifications',
