z = require 'zorium'
isUuid = require 'isuuid'
_find = require 'lodash/find'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'

Head = require '../../components/head'
GroupChat = require '../../components/group_chat'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
ChannelDrawer = require '../../components/channel_drawer'
ProfileDialog = require '../../components/profile_dialog'
Icon = require '../../components/icon'
BottomBar = require '../../components/bottom_bar'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupChatPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.id
      else
        @model.group.getByKey route.params.id

    conversationId = requests.map ({route}) ->
      route.params.conversationId

    gameKey = requests.map ({route}) ->
      route.params.gameKey

    overlay$ = new RxBehaviorSubject null
    @isChannelDrawerOpen = new RxBehaviorSubject false
    selectedProfileDialogUser = new RxBehaviorSubject null
    isLoading = new RxBehaviorSubject false
    me = @model.user.getMe()

    groupAndConversationIdAndMe = RxObservable.combineLatest(
      group
      conversationId
      me
      (vals...) -> vals
    )

    currentConversationId = null
    conversation = groupAndConversationIdAndMe
    .switchMap ([group, conversationId, me]) =>
      # side effect
      if conversationId isnt currentConversationId
        # is set to false when messages load in conversation component
        isLoading.next true

      currentConversationId = conversationId
      hasMemberPermission = @model.group.hasPermission group, me
      conversationId ?= localStorage?['groupConversationId3:' + group.id]
      unless conversationId
        if me.country in ['RU', 'LV']
          conversationId = _find(group.conversations, {name: 'русский'})?.id
        else if me.country is 'FR'
          conversationId = _find(group.conversations, {name: 'francais'})?.id
        else if me.country is 'IT'
          conversationId = _find(group.conversations, {name: 'italiano'})?.id
        else if me.country in [
          'AE', 'EG', 'IQ', 'IL', 'SA', 'JO', 'SY',
          'YE', 'KW', 'OM', 'LY', 'MA', 'DZ', 'SD'
        ] or window?.navigator?.language?.split?('-')[0] is 'ar'
          conversationId = _find(group.conversations, {name: 'عربى'})?.id
        else
          conversationId = _find(group.conversations, ({name, isDefault}) ->
            isDefault or name is 'general'
          )?.id

        conversationId ?= group.conversations?[0].id
      if hasMemberPermission and conversationId
        @model.conversation.getById conversationId
      else
        RxObservable.of null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupChatPage.title'
        description: @model.l.get 'groupChatPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$settingsIcon = new Icon()
    @$linkIcon = new Icon()
    @$bottomBar = new BottomBar {@model, @router, requests}

    @$groupChat = new GroupChat {
      @model
      @router
      group
      selectedProfileDialogUser
      overlay$
      gameKey
      isLoading: isLoading
      conversation: conversation
    }
    @$profileDialog = new ProfileDialog {
      @model
      @router
      group
      selectedProfileDialogUser
      gameKey
    }

    @$channelDrawer = new ChannelDrawer {
      @model
      @router
      group
      conversation
      gameKey
      isOpen: @isChannelDrawerOpen
    }

    @state = z.state
      windowSize: @model.window.getSize()
      group: group
      gameKey: gameKey
      me: me
      overlay$: overlay$
      selectedProfileDialogUser: selectedProfileDialogUser
      isChannelDrawerOpen: @isChannelDrawerOpen
      conversation: conversation

  renderHead: => @$head

  render: =>
    {windowSize, overlay$, group, me, conversation, isChannelDrawerOpen
      selectedProfileDialogUser, gameKey} = @state.getValue()

    hasMemberPermission = @model.group.hasPermission group, me
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.p-group-chat', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        isFullWidth: true
        title: z '.p-group-chat_title', {
          onclick: =>
            @isChannelDrawerOpen.next not isChannelDrawerOpen
        },
          z '.group', group?.name
          z '.channel',
            z 'span.hashtag', '#'
            conversation?.name
            z '.arrow'
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
        $topRightButton:
          z '.p-group-chat_top-right',
            z '.icon',
              z @$settingsIcon,
                icon: 'settings'
                color: colors.$primary500
                onclick: =>
                  @router.go 'groupSettings', {gameKey, id: group?.id}
            if group?.type is 'public'
              z '.icon',
                z @$linkIcon,
                  icon: 'shop'
                  color: colors.$primary500
                  onclick: =>
                    @router.go 'groupShop', {
                      id: group.key or group.id
                      gameKey: gameKey
                    }

      }
      z '.content',
        @$groupChat

      if overlay$
        z '.overlay',
          overlay$

      if selectedProfileDialogUser
        z @$profileDialog

      if isChannelDrawerOpen
        z @$channelDrawer
