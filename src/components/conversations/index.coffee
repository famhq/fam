z = require 'zorium'
Rx = require 'rx-lite'
colors = require '../../colors'
_isEmpty = require 'lodash/lang/isEmpty'
log = require 'loga'
Dialog = require 'zorium-paper/dialog'
FloatingActionButton = require 'zorium-paper/floating_action_button'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
PrimaryButton = require '../primary_button'
Spinner = require '../spinner'

if window?
  require './index.styl'

module.exports = class Conversations
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()
    @$addIcon = new Icon()

    @$fab = new FloatingActionButton()

    @state = z.state
      me: @model.user.getMe()
      conversations: @model.conversation.getAll().map (conversations) ->
        _.map conversations, (group) ->
          {group, $icon: new Icon()}

  render: =>
    {me, conversations} = @state.getValue()

    z '.z-conversations',
      z '.g-grid', [
        if conversations and _.isEmpty conversations
          'No conversations found'
        else if conversations
          _.map conversations, ({group, $icon}) =>

            z '.group', {
              className: z.classKebab {isPlayer}
              onclick: =>
                @state.set selectedGroup: group
            },
              z '.left',
                z '.name', group.name
                z '.games', _.map(group.gameKeys, _.startCase).join ' · '
                z '.info', 'test'
                  z '.members',
                    "#{group.playerIds.length} / #{group.maxPlayers} members"
              z '.right',
                z $icon,
                  icon: group.platform
                  isTouchTarget: false
                  color: colors["$#{group.platform}"]

        else
          @$spinner

        z '.fab',
          z @$fab,
            colors:
              c500: colors.$primary500
            $icon: z @$addIcon, {
              icon: 'add'
              isTouchTarget: false
              color: colors.$white
            }
            onclick: =>
              @router.go '/newMessage'
      ]
