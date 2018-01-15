z = require 'zorium'
_find = require 'lodash/find'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ProfileChest = require '../../components/clash_royale_profile_chests'
Spinner = require '../../components/spinner'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ProfileChestsPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    playerId = requests.map ({route}) ->
      if route.params.playerId then route.params.playerId else false

    player = playerId.switchMap (playerId) =>
      @model.player.getByPlayerIdAndGameId playerId, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    @$spinner = new Spinner()

    @$head = new Head({
      @model
      requests
      serverData
      meta: player.map (player) =>
        playerName = player?.data?.name
        smcCount = _find(player?.data?.upcomingChests?.items, {
          name: 'Super Magical Chest'
        })?.index
        {
          title: "#{playerName}'s #{@model.l.get 'profileChestsPage.title'}"
          description:
            if smcCount?
              "+#{smcCount} until " +
              'Super Magical Chest'
            else
              'Track my chest cycle'
          twitter:
            image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{player?.id}.png"
          openGraph:
            image: "#{config.PUBLIC_API_URL}/di/crChestCycle/#{player?.id}.png"
        }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profileChest = new ProfileChest {@model, @router, player}

    @state = z.state
      windowSize: @model.window.getSize()
      player: player

  renderHead: => @$head

  render: =>
    {windowSize, player, gameKey} = @state.getValue()

    z '.p-profile-chests', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'profileChestsPage.title'
        style: 'primary'
        $topLeftButton: z @$buttonBack, {
          color: colors.$primary500
          fallbackPath: @router.get 'clashRoyalePlayer', {playerId: player?.id}
        }
      }
      if player
        @$profileChest
      else
        @$spinner
