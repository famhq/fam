module.exports = class Experiment
  constructor: ->
    expSocialGroup = localStorage?['exp:social']
    unless expSocialGroup
      expSocialGroup = if Math.random() > 0.5 \
                               then 'visible'
                               else 'control'
      localStorage?['exp:social'] = expSocialGroup
    ga? 'send', 'event', 'exp', 'social', expSocialGroup

    @experiments =
      social: expSocialGroup

  get: (key) =>
    @experiments[key]
