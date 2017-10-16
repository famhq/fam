z = require 'zorium'
Rx = require 'rxjs'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ShopOffers = require '../../components/shop_offers'
Spinner = require '../../components/spinner'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ShopOffersPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    username = requests.map ({route}) ->
      if route.params.username then route.params.username else false

    id = requests.map ({route}) ->
      if route.params.id then route.params.id else false

    usernameAndId = Rx.Observable.combineLatest(
      username
      id
      (vals...) -> vals
    )

    me = @model.user.getMe()
    user = usernameAndId.switchMap ([username, id]) =>
      if username
        @model.user.getByUsername username
      else if id
        @model.user.getById id
      else
        @model.user.getMe()

    player = user.switchMap ({id}) =>
      @model.player.getByUserIdAndGameId id, config.CLASH_ROYALE_ID
      .map (player) ->
        return player or {}

    meAndPlayer = Rx.Observable.combineLatest(me, player, (vals...) -> vals)

    @$spinner = new Spinner()

    @$head = new Head({
      @model
      requests
      serverData
      meta: meAndPlayer.map ([me, player]) =>
        playerName = player?.data?.name
        {
          title: "#{playerName}'s #{@model.l.get 'profileChests.title'}"
        }
    })
    @$shopOffers = new ShopOffers {@model, @router, player}

    @state = z.state
      windowSize: @model.window.getSize()
      player: player

  renderHead: => @$head

  render: =>
    {windowSize, player} = @state.getValue()

    z '.p-profile-chests', {
      style:
        height: "#{windowSize.height}px"
    },
      if player
        @$shopOffers
      else
        @$spinner
