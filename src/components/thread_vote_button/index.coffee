z = require 'zorium'
colors = require '../../colors'

Icon = require '../icon'

module.exports = class ThreadVoteButton
  constructor: ({@model}) ->
    @$icon = new Icon()

    @state = z.state
      me: @model.user.getMe()

  render: ({threadId, vote, hasVoted, isTouchTarget, color, size}) =>
    {me} = @state.getValue()

    color ?= colors.$white
    size ?= '18px'

    z '.z-thread-vote-button',
      z @$icon,
        icon: if @model.experiment.get('threadThumbs') is 'visible' \
              then "thumb-#{vote}"
              else "#{vote}vote"
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
              @model.thread.voteById threadId, {vote: vote}
