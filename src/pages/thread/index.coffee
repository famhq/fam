z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Thread = require '../../components/thread'
Avatar = require '../../components/avatar'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

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

  renderHead: => @$head

  render: =>
    {isRefreshing} = @state.getValue()

    z '.p-thread', {
      style:
        height: "#{window?.innerHeight}px"
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
