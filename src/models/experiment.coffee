module.exports = class Experiment
  constructor: ->
    expThreadsGroup = localStorage?['exp:threads']
    unless expThreadsGroup
      expThreadsGroup = if Math.random() > 0.5 \
                               then 'lite'
                               else 'control'
      localStorage?['exp:threads'] = expThreadsGroup
    ga? 'send', 'event', 'exp', 'threads', expThreadsGroup

    expThreadInlineCommentGroup = localStorage?['exp:thread:inline_comment']
    unless expThreadInlineCommentGroup
      expThreadInlineCommentGroup = if window? and Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:thread:inline_comment'] = expThreadInlineCommentGroup
    ga? 'send', 'event', 'exp', 'thread_inline_comment', expThreadInlineCommentGroup

    @experiments =
      threads: expThreadsGroup
      threadInlineComment: expThreadInlineCommentGroup

  get: (key) =>
    @experiments[key]
