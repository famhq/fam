z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'

GroupHomeVideos = require '../group_home_videos'
GroupHomeThreads = require '../group_home_threads'
GroupHomeAddons = require '../group_home_addons'
GroupHomeAdminStats = require '../group_home_admin_stats'
GroupHomeChat = require '../group_home_chat'
GroupHomeOffers = require '../group_home_offers'
GroupHomeClashRoyaleChestCycle = require '../group_home_clash_royale_chest_cycle'
GroupHomeClashRoyaleDecks = require '../group_home_clash_royale_decks'
MasonryGrid = require '../masonry_grid'
UiCard = require '../ui_card'
FormatService = require '../../services/format'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHome
  constructor: ({@model, @router, group, @overlay$}) ->
    me = @model.user.getMe()

    player = me.switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$groupHomeThreads = new GroupHomeThreads {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeAddons = new GroupHomeAddons {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeAdminStats = new GroupHomeAdminStats {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeClashRoyaleChestCycle = new GroupHomeClashRoyaleChestCycle {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeClashRoyaleDecks = new GroupHomeClashRoyaleDecks {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeOffers = new GroupHomeOffers {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeChat = new GroupHomeChat {
      @model, @router, group, player, @overlay$
    }
    @$groupHomeVideos = new GroupHomeVideos {
      @model, @router, group, player, @overlay$
    }
    @$masonryGrid = new MasonryGrid {@model}

    @state = z.state {
      group
      player
      language: @model.l.getLanguage()
      me: me
    }

  render: =>
    {me, group, player, deck, language} = @state.getValue()

    z '.z-group-home',
      z '.g-grid',
        z '.card',
          z @$groupHomeClashRoyaleChestCycle

        if group?.id
          z @$masonryGrid,
            columnCounts:
              mobile: 1
              desktop: 2
            $elements: _filter [
              if group.key in ['clashroyalees', 'clashroyalept']
                z @$groupHomeThreads

              z @$groupHomeChat

              if me?.username is 'austin'
                z @$groupHomeAdminStats

              if group.key in ['playhard', 'eclihpse']
                z @$groupHomeOffers

              if group.key in ['playhard', 'eclihpse']
                z @$groupHomeVideos

              if player?.id
                z @$groupHomeClashRoyaleDecks

              z @$groupHomeAddons
            ]
