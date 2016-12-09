z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
_ = require 'lodash'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'
moment = require 'moment'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
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
        _.map conversations, (conversation) ->
          {conversation, $avatar: new Avatar()}

  render: =>
    {me, conversations} = @state.getValue()

    z '.z-conversations',
      z '.g-grid',
        if conversations and _.isEmpty conversations
          z '.no-conversations',
            'No conversations found'
        else if conversations
          _.map conversations, ({conversation, $avatar}) =>
            op = conversation.users?[0]

            @router.link z 'a.conversation', {
              href: "/conversation/#{conversation.id}"
            },
              z '.avatar', z $avatar, {user: op}
              z '.right',
                z '.info',
                  z '.name', @model.user.getDisplayName op
                  z '.time', moment(conversation.lastUpdateTime).fromNowModified()
                z '.last-message', conversation.lastMessage?.body

        else
          @$spinner
