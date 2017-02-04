z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Thread = require '../../components/thread'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ThreadPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    thread = requests.flatMapLatest ({route}) =>
      @model.thread.getById route.params.id

    page = requests.map ({route}) ->
      route.params.page

    isRefreshing = new Rx.BehaviorSubject false

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Community thread'
        description: 'Community'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router}
    @$thread = new Thread {@model, @router, thread, isRefreshing}
    @$editIcon = new Icon()

    @state = z.state
      isRefreshing: isRefreshing
      windowSize: @model.window.getSize()
      thread: thread
      me: @model.user.getMe()

  renderHead: => @$head

  render: =>
    {isRefreshing, windowSize, thread, me} = @state.getValue()

    hasAdminPermission = @model.thread.hasPermission thread, me, {
      level: 'admin'
    }
    console.log 'hp', hasAdminPermission

    z '.p-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: ''
        bgColor: colors.$tertiary700
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
        $topRightButton: if hasAdminPermission
          z @$editIcon,
            icon: 'edit'
            color: colors.$primary500
            onclick: =>
              @router.go "/editGuide/#{thread.id}"
        else
          null
      }
      @$thread
