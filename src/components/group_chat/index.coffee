z = require 'zorium'
Rx = require 'rx-lite'

Conversation = require '../conversation'
ChannelDrawer = require '../channel_drawer'

if window?
  require './index.styl'

module.exports = class GroupChat
  constructor: (options) ->
    {@model, @router, conversation, overlay$, toggleIScroll, group
      selectedProfileDialogUser, isActive} = options

    @isChannelDrawerOpen = new Rx.BehaviorSubject false

    @$conversation = new Conversation {
      @model
      @router
      selectedProfileDialogUser
      isActive
      toggleIScroll
      conversation
      overlay$
      scrollYOnly: true
      isGroup: true
    }

    @$channelDrawer = new ChannelDrawer {
      @model
      @router
      group
      conversation
      isOpen: @isChannelDrawerOpen
    }

    @state = z.state {group, conversation}

  render: =>
    {group, conversation} = @state.getValue()

    z '.z-group-chat',
      z '.current-channel', {
        onclick: =>
          @isChannelDrawerOpen.onNext true
      },
        z '.status'
        z '.hashtag', '#'
        z '.name', conversation?.name
        z '.arrow'
      z @$conversation
      z @$channelDrawer
