z = require 'zorium'
Rx = require 'rx-lite'
_find = require 'lodash/find'

Head = require '../../components/head'
GroupChat = require '../../components/group_chat'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
ButtonMenu = require '../../components/button_menu'
ChannelDrawer = require '../../components/channel_drawer'
ProfileDialog = require '../../components/profile_dialog'
Icon = require '../../components/icon'
BottomBar = require '../../components/bottom_bar'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupChatPage
  # hideDrawer: true # FIXME

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.flatMapLatest ({route}) =>
      @model.group.getById route.params.id

    conversationId = requests.map ({route}) ->
      route.params.conversationId

    overlay$ = new Rx.BehaviorSubject null
    @isChannelDrawerOpen = new Rx.BehaviorSubject false
    selectedProfileDialogUser = new Rx.BehaviorSubject null
    me = @model.user.getMe()

    groupAndConversationIdAndMe = Rx.Observable.combineLatest(
      group
      conversationId
      me
      (vals...) -> vals
    )

    conversation = groupAndConversationIdAndMe
    .flatMapLatest ([group, conversationId, me]) =>
      hasMemberPermission = @model.group.hasPermission group, me
      conversationId ?= localStorage?['groupConversationId3:' + group.id]
      unless conversationId
        if me.country in ['RU', 'LV']
          conversationId = _find(group.conversations, {name: 'русский'})?.id
        if me.country in [
          'AR', 'BO', 'CR', 'CU', 'DM', 'EC', 'SV', 'GQ', 'GT', 'HN', 'MX'
          'NI', 'PA', 'PE', 'ES', 'UY', 'VE'
        ] or window?.navigator?.language?.split?('-')[0] is 'es'
          conversationId = _find(group.conversations, {name: 'español'})?.id
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
          conversationId = _find(group.conversations, {name: 'general'})?.id

        conversationId ?= group.conversations?[0].id
      if hasMemberPermission and conversationId
        @model.conversation.getById conversationId
      else
        Rx.Observable.just null

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
    @$buttonBack = new ButtonBack {@model, @router}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$settingsIcon = new Icon()
    @$bottomBar = new BottomBar {@model, @router, requests}

    @$groupChat = new GroupChat {
      @model
      @router
      group
      selectedProfileDialogUser
      overlay$
      conversation: conversation
    }
    @$profileDialog = new ProfileDialog {
      @model
      @router
      group
      selectedProfileDialogUser: selectedProfileDialogUser
    }

    @$channelDrawer = new ChannelDrawer {
      @model
      @router
      group
      conversation
      isOpen: @isChannelDrawerOpen
    }

    @state = z.state
      windowSize: @model.window.getSize()
      group: group
      me: me
      overlay$: overlay$
      selectedProfileDialogUser: selectedProfileDialogUser
      isChannelDrawerOpen: @isChannelDrawerOpen
      conversation: conversation

  renderHead: => @$head

  render: =>
    {windowSize, overlay$, group, me, conversation, isChannelDrawerOpen
      selectedProfileDialogUser} = @state.getValue()

    hasMemberPermission = @model.group.hasPermission group, me
    hasAdminPermission = @model.group.hasPermission group, me, {level: 'admin'}

    z '.p-group-chat', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: z '.p-group-chat_title', {
          onclick: =>
            @isChannelDrawerOpen.onNext not isChannelDrawerOpen
        },
          z '.group', group?.name
          z '.channel',
            z 'span.hashtag', '#'
            conversation?.name
            z '.arrow'
        $topLeftButton:
          if @model.experiment.get('social') is 'visible'
            z @$buttonBack, {color: colors.$primary500}
          else
            z @$buttonMenu, {color: colors.$primary500}
        $topRightButton:
          z '.p-group_top-right',
            z '.icon',
              z @$settingsIcon,
                icon: 'settings'
                color: colors.$primary500
                onclick: =>
                  @router.go "/group/#{group?.id}/settings"
      }
      z '.content',
        @$groupChat

      if @model.experiment.get('social') isnt 'visible'
        @$bottomBar

      if overlay$
        z '.overlay',
          overlay$

      if selectedProfileDialogUser
        z @$profileDialog

      if isChannelDrawerOpen
        z @$channelDrawer
