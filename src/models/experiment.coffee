module.exports = class Experiment
  constructor: ({@cookie}) ->
    expLfgNewButton = @cookie.get 'exp:lfgNewButton'
    unless expLfgNewButton
      rand = Math.random()
      expLfgNewButton = if rand > 0.5 \
                         then 'big'
                         else 'control'
      @cookie.set 'exp:lfgNewButton', expLfgNewButton
    ga? 'send', 'event', 'exp', 'lfgNewButton', expLfgNewButton


    expLfgNewThread = @cookie.get 'exp:lfgNewThread'
    unless expLfgNewThread
      rand = Math.random()
      expLfgNewThread = if rand > 0.5 \
                         then 'new'
                         else 'control'
      @cookie.set 'exp:lfgNewThread', expLfgNewThread
    ga? 'send', 'event', 'exp', 'lfgNewThread', expLfgNewThread

    @experiments =
      lfgNewButton: expLfgNewButton
      lfgNewThread: expLfgNewThread

  get: (key) =>
    @experiments[key]
