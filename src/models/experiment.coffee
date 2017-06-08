module.exports = class Experiment
  constructor: ->
    expAdGroup = localStorage?['exp:ad']
    unless expAdGroup
      expAdGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:ad'] = expAdGroup
    ga? 'send', 'event', 'exp', 'ad', expAdGroup

    @experiments =
      ad: expAdGroup

  get: (key) =>
    @experiments[key]
