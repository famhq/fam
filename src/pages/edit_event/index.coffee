z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
EditEvent = require '../../components/edit_event'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EditEventPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    event = requests.flatMapLatest ({route}) =>
      if route.params.id
        @model.event.getById route.params.id
      else
        Rx.Observable.just null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Edit Event'
        description: 'Edit Event'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$deleteIcon = new Icon()
    @$editEvent = new EditEvent {
      @model
      @router
      event
    }

    @state = z.state
      windowSize: @model.window.getSize()
      event: event

  renderHead: => @$head

  delete: =>
    {event} = @state.getValue()
    @model.event.deleteById event.id
    .then =>
      @router.go '/events'

  render: =>
    {windowSize} = @state.getValue()

    z '.p-edit-event', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Edit Event'
        isFlat: true
        $topLeftButton: z @$buttonBack
        $topRightButton:
          z @$deleteIcon,
            icon: 'delete'
            onclick: @delete
            color: colors.$tertiary900
      }
      z @$editEvent
