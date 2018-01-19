module.exports = class Experiment
  constructor: ({@cookie}) ->
    expCustomColors = @cookie.get 'exp:customColors'
    unless expCustomColors
      rand = Math.random()
      expCustomColors = if rand > 0.666 \
                         then 'light'
                         else if rand > 0.333 \
                         then 'dark'
                         else 'control'
      @cookie.set 'exp:customColors', expCustomColors
    ga? 'send', 'event', 'exp', 'customColors', expCustomColors

    @experiments =
      customColors: expCustomColors

  get: (key) =>
    @experiments[key]
