z = require 'zorium'
isUuid = require 'isuuid'

AppBar = require '../../components/app_bar'
Collection = require '../../components/collection'
ButtonMenu = require '../../components/button_menu'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupCollectionPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, overlay$, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$collection = new Collection {
      @model
      @router
      group
      overlay$
    }

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'collectionPage.title'
      description: @model.l.get 'collectionPage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-videos', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'collectionPage.title'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
      }
      @$collection
