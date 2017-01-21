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

    @state = z.state {
      group
      conversation
      isChannelDrawerOpen: @isChannelDrawerOpen
    }

  render: =>
    {group, conversation, isChannelDrawerOpen} = @state.getValue()

    z '.z-group-chat',
      z '.current-channel', {
        onclick: =>
          @isChannelDrawerOpen.onNext true
      },
        z '.g-grid',
          z '.flex',
            z '.status'
            z '.hashtag', '#'
            z '.name', conversation?.name
            z '.arrow'
      z @$conversation
      # always having the channel drawer in the dom slows down scrolling
      # for some reason. probably fixable since the normal drawer does
      # fine with scrolling. guessing it has to do with the normal drawer
      # being a sibling / pos fixed, while this drawer is position
      # absolute as child of group-chat
      if isChannelDrawerOpen
        z @$channelDrawer
