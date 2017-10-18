z = require 'zorium'
colors = require '../../colors'

Icon = require '../icon'

module.exports = class ThreadVoteButton
  constructor: ({@model}) ->
    @$icon = new Icon()

    @state = z.state
      me: @model.user.getMe()

  render: (options) =>
    {parent, parentType, vote, hasVoted,
      isTouchTarget, color, size} = options

    {me} = @state.getValue()

    color ?= colors.$white
    size ?= '18px'

    z '.z-thread-vote-button',
      z @$icon,
        icon: "thumb-#{vote}"
        size: size
        isTouchTarget: isTouchTarget
        color: if hasVoted \
               then colors.$primary500
               else color
        onclick: (e) =>
          e?.stopPropagation()
          e?.preventDefault()
          unless hasVoted
            @model.signInDialog.openIfGuest me
            .then =>
              @model.threadVote.upsertByParent(
                parent
                {vote}
              )
