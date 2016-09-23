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
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
Spinner = require '../../components/spinner'

if window?
  require './index.styl'

module.exports = class ThreadsPage
  constructor: ({@model, requests, @router, serverData}) ->
    isRefreshing = new Rx.BehaviorSubject false

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Community'
        description: 'Community'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$threads = new Threads {@model, @router, isRefreshing}
    @$refreshingSpinner = new Spinner()

    @state = z.state
      isRefreshing: isRefreshing

  renderHead: => @$head

  render: =>
    {isRefreshing} = @state.getValue()

    z '.p-threads', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Community'
        $topLeftButton: z @$buttonMenu, {color: colors.$primary900}
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$threads
