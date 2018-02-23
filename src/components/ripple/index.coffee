z = require 'zorium'
Environment = require '../../services/environment'

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

  ripple: ({$$el, color, isCenter, mouseX, mouseY, onComplete, fadeIn} = {}) =>
    $$el ?= @$$el

    {width, height, top, left} = $$el.getBoundingClientRect()

    if isCenter
      x = width / 2
      y = height / 2
    else
      x = mouseX - left
      y = mouseY - top

    $$wave = document.createElement 'div'
    $$wave.className = if fadeIn then 'wave fade-in' else 'wave'
    $$wave.style.top = y + 'px'
    $$wave.style.left = x + 'px'
    $$wave.style.backgroundColor = color
    $$el.appendChild $$wave

    new Promise (resolve, reject) ->
      setTimeout ->
        onComplete?()
        resolve()
        setTimeout ->
          $$el.removeChild $$wave
        , 100 # give some time for onComplete to render
      , ANIMATION_TIME_MS

  render: ({color, isCircle, isCenter, onComplete, fadeIn}) ->
    onTouch = (e) =>
      $$el = e.target
      @ripple {
        $$el
        color
        isCenter
        onComplete
        fadeIn
        mouseX: e.clientX or e.touches?[0]?.clientX
        mouseY: e.clientY or e.touches?[0]?.clientY
      }

    z '.z-ripple',
      className: z.classKebab {isCircle}
      ontouchstart: if Environment.isAndroid() then null else onTouch
      onmousedown: onTouch
