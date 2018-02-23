z = require 'zorium'
Environment = require '../../services/environment'

colors = require '../../colors'

if window?
  require './index.styl'

# adding to DOM directly is faster than doing a full re-render

ANIMATION_TIME_MS = 1050

module.exports = class XpGain
  type: 'Widget'

  constructor: ({@model}) ->
    @hasMounted = false

  afterMount: (@$$el) =>
    unless @hasMounted
      @hasMounted = true
      $$xp = document.createElement 'div'
      $$xp.className = 'xp'
      @mountDisposable = @model.xpGain.getXp().subscribe ({xp, x, y} = {}) =>
        $$xp.innerText = "+#{xp}xp"
        $$xp.style.left = x + 'px'
        $$xp.style.top = y + 'px'
        @$$el.appendChild $$xp
        setTimeout =>
          @$$el.removeChild $$xp
        , ANIMATION_TIME_MS

  # always in dom in app
  # beforeUnmount: =>
  #   @mountDisposable?.unsubscribe()

  render: ->
    z '.z-xp-gain', {key: 'xp-gain'}
