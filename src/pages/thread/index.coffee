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
Conversation = require '../../components/conversation'
Avatar = require '../../components/avatar'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class ThreadPage
  constructor: ({@model, requests, @router, serverData}) ->
    toUser = requests.map ({route}) =>
      @model.user.getById route.params.id

    isRefreshing = new Rx.BehaviorSubject false

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Chat'
        description: 'Chat'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$conversation = new Conversation {@model, @router, isRefreshing, toUser}
    @$refreshingSpinner = new Spinner()

    @state = z.state
      toUser: toUser
      isRefreshing: isRefreshing

  renderHead: => @$head

  render: =>
    {toUser, isRefreshing} = @state.getValue()

    z '.p-conversation', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'NAME'
        $topLeftButton: z @$buttonMenu, {color: colors.$primary900}
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$conversation
