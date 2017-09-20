module.exports = class Experiment
  constructor: ->
    expThreadsGroup = localStorage?['exp:threads']
    unless expThreadsGroup
      expThreadsGroup = if Math.random() > 0.5 \
                               then 'lite'
                               else 'control'
      localStorage?['exp:threads'] = expThreadsGroup
    ga? 'send', 'event', 'exp', 'threads', expThreadsGroup


    expThreadThumbsGroup = localStorage?['exp:thread:thumbs']
    unless expThreadThumbsGroup
      expThreadThumbsGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:thread:thumbs'] = expThreadThumbsGroup
    ga? 'send', 'event', 'exp', 'thread_thumbs', expThreadThumbsGroup


    expForumGroup = localStorage?['exp:forum']
    unless expForumGroup
      expForumGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:forum'] = expForumGroup
    ga? 'send', 'event', 'exp', 'forum', expForumGroup

    @experiments =
      threads: expThreadsGroup
      threadThumbs: expThreadThumbsGroup
      forum: expForumGroup

  get: (key) =>
    @experiments[key]
