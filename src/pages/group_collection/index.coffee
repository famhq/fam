z = require 'zorium'
isUuid = require 'isuuid'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
Collection = require '../../components/collection'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupCollectionPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, overlay$}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'collectionPage.title'
        description: @model.l.get 'collectionPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$collection = new Collection {
      @model
      @router
      gameKey
      group
      overlay$
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-videos', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'collectionPage.title'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$primary500
        }
      }
      @$collection
