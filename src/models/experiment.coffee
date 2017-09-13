module.exports = class Experiment
  constructor: ->
    expThreadsGroup = localStorage?['exp:threads']
    unless expThreadsGroup
      expThreadsGroup = if Math.random() > 0.5 \
                               then 'lite'
                               else 'control'
      localStorage?['exp:threads'] = expThreadsGroup
    ga? 'send', 'event', 'exp', 'threads', expThreadsGroup

    @experiments =
      threads: expThreadsGroup

  get: (key) =>
    @experiments[key]
