z = require 'zorium'
Rx = require 'rx-lite'
_find = require 'lodash/find'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Conversation = require '../../components/conversation'
Avatar = require '../../components/avatar'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class ConversationPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    conversation = requests.flatMapLatest ({route}) =>
      @model.conversation.getById route.params.conversationId

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
    @$buttonBack = new ButtonBack {@model, @router}
    @$conversation = new Conversation {
      @model, @router, isRefreshing, conversation
    }
    @$refreshingSpinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      conversation: conversation
      isRefreshing: isRefreshing

  renderHead: => @$head

  render: =>
    {conversation, me, isRefreshing} = @state.getValue()

    console.log conversation

    toUser = _find conversation?.users, (user) ->
      me?.id isnt user.id

    console.log conversation

    z '.p-conversation', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: @model.user.getDisplayName toUser
        $topLeftButton: z @$buttonBack, {color: colors.$tertiary900}
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$conversation
