z = require 'zorium'
Rx = require 'rxjs'
_find = require 'lodash/find'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Conversation = require '../../components/conversation'
ProfileDialog = require '../../components/profile_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ConversationPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    conversation = requests.switchMap ({route}) =>
      @model.conversation.getById route.params.id
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    selectedProfileDialogUser = new Rx.BehaviorSubject null
    overlay$ = new Rx.BehaviorSubject null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'general.chat'
        description: @model.l.get 'general.chat'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$profileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser, gameKey
    }
    @$conversation = new Conversation {
      @model, @router, conversation, selectedProfileDialogUser, overlay$
    }

    @state = z.state
      me: @model.user.getMe()
      conversation: conversation
      selectedProfileDialogUser: selectedProfileDialogUser
      overlay$: overlay$
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {conversation, me, selectedProfileDialogUser,
      windowSize, overlay$} = @state.getValue()

    toUser = _find conversation?.users, (user) ->
      me?.id isnt user.id

    z '.p-conversation', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.user.getDisplayName toUser
        style: 'primary'
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$conversation

      if overlay$
        z '.overlay', overlay$

      if selectedProfileDialogUser
        z @$profileDialog, {user: selectedProfileDialogUser}
