z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Thread = require '../../components/thread'
Spinner = require '../../components/spinner'

if window?
  require './index.styl'

module.exports = class ThreadPage
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
    @$refreshingSpinner = new Spinner()

    @state = z.state
      isRefreshing: isRefreshing
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {isRefreshing, windowSize} = @state.getValue()

    z '.p-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: ''
        $topLeftButton: z @$buttonBack
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$thread
