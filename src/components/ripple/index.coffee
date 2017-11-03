z = require 'zorium'
Environment = require 'clay-environment'

colors = require '../../colors'

if window?
  require './index.styl'

# adding to DOM directly is actually a little faster in this case
# than doing a full re-render. ideally zorium would just diff the relevant
# components

# note that ripples are slow if network requests are happening simultaneously

ANIMATION_TIME_MS = 350

module.exports = class Ripple
  type: 'Widget'

  constructor: -> null

  afterMount: (@$$el) => null

  ripple: ({$$el, color, isCenter, mouseX, mouseY, onComplete}) =>
    $$el ?= @$$el

    {width, height, top, left} = $$el.getBoundingClientRect()

    if isCenter
      x = width / 2
      y = height / 2
    else
      x = mouseX - left
      y = mouseY - top

    $$wave = document.createElement 'div'
    $$wave.className = 'wave'
    $$wave.style.top = y + 'px'
    $$wave.style.left = x + 'px'
    $$wave.style.backgroundColor = color
    $$el.appendChild $$wave

    new Promise (resolve, reject) ->
      setTimeout ->
        $$el.removeChild $$wave
        onComplete?()
        resolve()
      , ANIMATION_TIME_MS

  render: ({color, isCircle, isCenter, onComplete}) ->
    onTouch = (e) =>
      $$el = e.target
      @ripple {
        $$el
        color
        isCenter
        onComplete
        mouseX: e.clientX or e.touches?[0]?.clientX
        mouseY: e.clientY or e.touches?[0]?.clientY
      }

    z '.z-ripple',
      className: z.classKebab {isCircle}
      ontouchstart: if Environment.isAndroid() then null else onTouch
      onmousedown: onTouch
