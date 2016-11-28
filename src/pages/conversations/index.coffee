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
Conversations = require '../../components/conversations'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class ConversationsPage
  constructor: ({@model, requests, @router, serverData}) ->
    toUser = requests.map ({route}) =>
      @model.user.getById route.params.id

    isRefreshing = new Rx.BehaviorSubject false

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Private Messages'
        description: 'Private Messages'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$conversations = new Conversations {
      @model, @router, isRefreshing, toUser
    }
    @$refreshingSpinner = new Spinner()

    @state = z.state
      toUser: toUser
      isRefreshing: isRefreshing

  renderHead: => @$head

  render: =>
    {toUser, isRefreshing} = @state.getValue()

    z '.p-conversations', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Private Messages'
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$conversations
