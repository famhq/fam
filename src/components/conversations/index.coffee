z = require 'zorium'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'
_find = require 'lodash/find'
moment = require 'moment'

Icon = require '../icon'
Avatar = require '../avatar'
Spinner = require '../spinner'

if window?
  require './index.styl'

IMAGE_REGEX_STR = '\!\\[(.*?)\\]\\((.*?)\\)'
IMAGE_REGEX = new RegExp IMAGE_REGEX_STR, 'gi'

module.exports = class Conversations
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @state = z.state
      me: @model.user.getMe()
      conversations: @model.conversation.getAll().map (conversations) ->
        _map conversations, (conversation) ->
          {conversation, $avatar: new Avatar()}

  render: =>
    {me, conversations} = @state.getValue()

    z '.z-conversations',
      z '.g-grid',
        if conversations and _isEmpty conversations
          z '.no-conversations',
            @model.l.get 'conversations.noneFound'
        else if conversations
          _map conversations, ({conversation, $avatar}) =>
            otherUser = _find conversation.users, (user) ->
              user.id isnt me?.id

            isUnread = not conversation.userData[me?.id]?.isRead
            isLastMessageFromMe = conversation.lastMessage?.userId is me?.id

            @router.link z 'a.conversation', {
              href: "/conversation/#{conversation.id}"
              className: z.classKebab {isUnread}
            },
              z '.status'
              z '.avatar', z $avatar, {user: otherUser}
              z '.right',
                z '.info',
                  z '.name', @model.user.getDisplayName otherUser
                  z '.time',
                    moment(conversation.lastUpdateTime).fromNowModified()
                z '.last-message',
                  if isLastMessageFromMe
                    @model.l.get 'conversations.me'
                  else if conversation.lastMessage
                    "#{@model.user.getDisplayName otherUser}: "

                  conversation.lastMessage?.body?.replace IMAGE_REGEX, 'image'

        else
          @$spinner
