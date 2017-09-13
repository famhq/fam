z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Thread = require '../../components/thread'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ThreadPage
  hideDrawer: true
  hasBottomBanner: true

  constructor: ({@model, requests, @router, serverData}) ->
    # allow reset beforeUnmount so stale thread doesn't show when loading new
    @thread = new Rx.BehaviorSubject null
    loadedThread = requests.flatMapLatest ({route}) =>
      @model.thread.getById route.params.id
    thread = Rx.Observable.merge @thread, loadedThread

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Community thread'
        description: 'Community'
      }
    })
    @$thread = new Thread {@model, @router, thread}

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  beforeUnmount: =>
    @thread.onNext {}

  render: =>
    {windowSize, $el} = @state.getValue()

    z '.p-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$thread
