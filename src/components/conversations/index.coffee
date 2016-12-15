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
            'No conversations found'
        else if conversations
          _map conversations, ({conversation, $avatar}) =>
            otherUser = _find conversation.users, (user) ->
              user.id isnt me?.id

            isUnread = not conversation.userData[me?.id]?.isRead

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
                z '.last-message', conversation.lastMessage?.body

        else
          @$spinner
