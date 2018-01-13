module.exports = class Experiment
  constructor: ({@cookie}) ->
    expNewHome = @cookie.get 'exp:newHome'
    unless expNewHome
      expNewHome = if Math.random() > 0.5 \
                               then 'new'
                               else 'control'
      @cookie.set 'exp:newHome', expNewHome
    ga? 'send', 'event', 'exp', 'newHome', expNewHome

    @experiments =
      newHome: expNewHome

  get: (key) =>
    @experiments[key]
