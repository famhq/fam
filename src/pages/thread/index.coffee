z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Thread = require '../../components/thread'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ThreadPage
  hideDrawer: true

  constructor: ({@model, requests, @router, @overlay$, serverData, group}) ->
    # allow reset beforeUnmount so stale thread doesn't show when loading new
    @thread = new RxBehaviorSubject null
    loadedThread = requests.switchMap ({route}) =>
      @model.thread.getById route.params.id
    thread = RxObservable.merge @thread, loadedThread

    @$thread = new Thread {@model, @router, @overlay$, thread, group}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: ->
    {
      title: 'Community thread'
      description: 'Community'
    }

  beforeUnmount: =>
    @thread.next {}

  render: =>
    {windowSize, $el} = @state.getValue()

    z '.p-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$thread
