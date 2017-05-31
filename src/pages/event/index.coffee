z = require 'zorium'

Head = require '../../components/head'
Event = require '../../components/event'
AppBar = require '../../components/app_bar'
Icon = require '../../components/icon'
ButtonBack = require '../../components/button_back'
Dialog = require '../../components/dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EventPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    event = requests.flatMapLatest ({route}) =>
      @model.event.getById route.params.id

    @$head = new Head({
      @model
      requests
      serverData
      meta: event.map (event) ->
        {
          title: event.name
          description: event.description
        }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$leaveIcon = new Icon()
    @$shareIcon = new Icon()
    @$editIcon = new Icon()
    @$leaveDialog = new Dialog()
    @$event = new Event {
      @model, @router, serverData, event
    }

    @state = z.state
      event: event
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      isLeaveDialogVisible: false

  renderHead: => @$head

  edit: =>
    {event} = @state.getValue()
    @router.go "/event/#{event.id}/edit"

  leave: =>
    {event} = @state.getValue()
    @model.event.leaveById event.id
    @state.set isLeaveDialogVisible: false

  share: =>
    {event} = @state.getValue()
    @model.portal.call 'share.any', {
      text: @model.l.get 'eventPage.shareText'
      path: "/event/#{event.id}"
    }

  render: =>
    {windowSize, event, me, isLeaveDialogVisible} = @state.getValue()

    hasMemberPermission = @model.event.hasPermission event, me, {
      level: 'member'
    }
    hasAdminPermission = @model.event.hasPermission event, me, {
      level: 'admin'
    }

    z '.p-event', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'eventPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
        $topRightButton:
          z '.p-event_top-right',
            if hasMemberPermission
              z @$leaveIcon,
                icon: 'leave'
                color: colors.$primary500
                onclick: =>
                  @state.set isLeaveDialogVisible: true

            z @$shareIcon,
              icon: 'share'
              color: colors.$primary500
              onclick: @share

            if hasAdminPermission
              z @$editIcon,
                icon: 'edit'
                color: colors.$primary500
                onclick: @edit
      }
      @$event
      if isLeaveDialogVisible
        z @$leaveDialog,
          isVanilla: true
          onLeave: =>
            @state.set isLeaveDialogVisible: true
          cancelButton:
            text: @model.l.get 'general.cancel'
            onclick: =>
              @state.set isLeaveDialogVisible: false
          submitButton:
            text: @model.l.get 'general.yes'
            onclick: @leave
          $content: @model.l.get 'eventPage.leave'
