z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
EditGuide = require '../../components/edit_guide'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EditGuidePage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    guide = requests.flatMapLatest ({route}) =>
      if route.params.id
        @model.thread.getById route.params.id
      else
        Rx.Observable.just null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Edit Guide'
        description: 'Edit Guide'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$deleteIcon = new Icon()
    @$editGuide = new EditGuide {
      @model
      @router
      guide
    }

    @state = z.state
      windowSize: @model.window.getSize()
      guide: guide

  renderHead: => @$head

  delete: =>
    {guide} = @state.getValue()
    # @model.thread.deleteById guide.id
    # .then =>
    #   @router.go '/guides'

  render: =>
    {windowSize} = @state.getValue()

    z '.p-edit-guide', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Edit Guide'
        isFlat: true
        $topLeftButton: z @$buttonBack
        $topRightButton:
          z @$deleteIcon,
            icon: 'delete'
            onclick: @delete
            color: colors.$tertiary900
      }
      z @$editGuide
