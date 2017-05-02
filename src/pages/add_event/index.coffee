z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
EditEvent = require '../../components/edit_event'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'

if window?
  require './index.styl'

module.exports = class AddEventPage
  hideDrawer: true
  isPrivate: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) =>
      if route.params.groupId
        @model.group.getById route.params.groupId
      else
        Rx.Observable.just null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'addEventPage.title'
        description: @model.l.get 'addEventPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$editEvent = new EditEvent {
      @model
      @router
      group
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-add-event', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'addEventPage.title'
        isFlat: true
        $topLeftButton: z @$buttonBack
      }
      z @$editEvent, {isNewEvent: true}
