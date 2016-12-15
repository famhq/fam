z = require 'zorium'
Rx = require 'rx-lite'
_find = require 'lodash/find'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Conversation = require '../../components/conversation'
Spinner = require '../../components/spinner'
ProfileDialog = require '../../components/profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ConversationPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    conversation = requests.flatMapLatest ({route}) =>
      @model.conversation.getById route.params.conversationId

    selectedProfileDialogUser = new Rx.BehaviorSubject null

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
    @$profileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser
    }
    @$conversation = new Conversation {
      @model, @router, isRefreshing, conversation, selectedProfileDialogUser
    }
    @$refreshingSpinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      conversation: conversation
      isRefreshing: isRefreshing
      selectedProfileDialogUser: selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {conversation, me, isRefreshing,
      selectedProfileDialogUser} = @state.getValue()

    toUser = _find conversation?.users, (user) ->
      me?.id isnt user.id

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

      if selectedProfileDialogUser
        z @$profileDialog, {user: selectedProfileDialogUser}
