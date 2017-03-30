z = require 'zorium'
_ = require 'lodash'
Rx = require 'rx-lite'
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
    # @state = z.state {
    #   $waves: []
    #   waveKeyCounter: 0
    # }

  ripple: ({$$el, color, isCenter, mouseX, mouseY, onComplete}) ->
    # {$waves, waveKeyCounter} = @state.getValue()

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

    # $wave =  z '.wave',
    #   key: waveKeyCounter
    #   style:
    #     top: y + 'px'
    #     left: x + 'px'
    #     backgroundColor: color
    # @state.set
    #   $waves: $waves.concat $wave

    # $$wave.addEventListener 'animationend', ->
    # we want to do this a little before the animation actually completes
    setTimeout ->
      $$el.removeChild $$wave
      onComplete?()
      # {$waves} = @state.getValue()
      # @state.set
      #   $waves: _.without $waves, $wave
    , ANIMATION_TIME_MS

  render: ({color, isCircle, isCenter, onComplete}) ->
    # {$waves} = @state.getValue()

    onTouch = (e) =>
      $$el = e.target
      e?.preventDefault()
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
      # $waves
