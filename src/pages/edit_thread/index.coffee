z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/switchMap'

Head = require '../../components/head'
NewThread = require '../../components/new_thread'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EditThreadPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    thread = requests.switchMap ({route}) =>
      if route.params.id
        @model.thread.getById route.params.id
      else
        RxObservable.of null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'editThreadPage.title'
        description: @model.l.get 'editThreadPage.title'
      }
    })
    @$editThread = new NewThread {
      @model
      @router
      thread
      group
    }

    @state = z.state
      windowSize: @model.window.getSize()
      thread: thread

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-edit-thread', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$editThread
