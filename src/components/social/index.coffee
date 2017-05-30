z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
GroupConversations = require '../../components/group_conversations'
Conversations = require '../../components/conversations'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Fab = require '../../components/fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Social
  constructor: ({@model, @router, thread}) ->
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$fab = new Fab()
    @$addIcon = new Icon()

    @$groupConversations = new GroupConversations {@model, @router}
    @$conversations = new Conversations {@model, @router}

    selectedIndex = new Rx.BehaviorSubject 0
    @$tabs = new Tabs {@model, selectedIndex}

    @$groupsIcon = new Icon()
    @$pmsIcon = new Icon()

    @state = z.state
      selectedIndex: selectedIndex
      me: @model.user.getMe()

  render: =>
    {selectedIndex, me, $sideEl} = @state.getValue()

    z '.z-social',
      z @$appBar, {
        title: @model.l.get 'social.title'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }

      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuIcon: @$groupsIcon
            menuIconName: 'friends'
            $menuText: @model.l.get 'social.groupChats'
            $el: @$groupConversations
          }
          {
            $menuIcon: @$pmsIcon
            menuIconName: 'chat'
            $menuText: @model.l.get 'social.pms'
            $el: @$conversations
          }
        ]

      # z '.fab',
      #   z @$fab,
      #     colors:
      #       c500: colors.$primary500
      #     $icon: z @$addIcon, {
      #       icon: 'add'
      #       isTouchTarget: false
      #       color: colors.$white
      #     }
      #     onclick: =>
      #       @model.signInDialog.openIfGuest me
      #       .then =>
      #         @router.go '/'
