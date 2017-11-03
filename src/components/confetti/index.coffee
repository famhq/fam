z = require 'zorium'
_map = require 'lodash/map'
_range = require 'lodash/range'
_each = require 'lodash/each'

config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

###
Copyright (c) 2015 by Linmiao Xu (http://codepen.io/linrock/pen/Amdhr)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
###

NUM_CONFETTI = 100
COLORS = [
  [33, 150, 243] # blue
  [76, 175, 80] # green
  [244, 67, 54] # red
  [255, 193, 7] # yellow
  [238, 238, 238] # grey
]
PI_2 = 2 * Math.PI

range = (a, b) -> (b - a) * Math.random() + a

drawCircle = (context, x, y, r, style) ->
  context.beginPath()
  context.arc(x,y,r,0,PI_2,false)
  context.fillStyle = style
  context.fill()

class ConfettiItem
  constructor: (@$$canvas, @context) ->
    @style = COLORS[~~range(0,5)]
    @rgb = "rgba(#{@style[0]}, #{@style[1]}, #{@style[2]}"
    @r = ~~range(2, 6)
    @r2 = 2 * @r
    @replace()

  replace: ->
    w = @$$canvas.width
    h = @$$canvas.height
    xPos = 0.5 # can change on mousemove
    @opacity = 0
    @dop = 0.03 * range(1, 4)
    @x = range(-@r2, w - @r2)
    @y = range(-20, h - @r2)
    @xmax = w - @r
    @ymax = h - @r
    @vx = range(0, 2) + 8 * xPos - 5
    @vy = 0.7 * @r + range(-1, 1)

  draw: =>
    @x += @vx
    @y += @vy
    @opacity += @dop
    if @opacity > 1
      @opacity = 1
      @dop *= -1
    @replace() if @opacity < 0 or @y > @ymax
    if not (0 < @x < @xmax)
      @x = (@x + @xmax) % @xmax
    drawCircle(@context, ~~@x, ~~@y, @r, "#{@rgb}, #{@opacity})")

module.exports = class Confetti
  constructor: ->
    @paused = false

  afterMount: (@$$canvas) =>
    @paused = false
    @context = @$$canvas.getContext '2d'
    @$$canvas.width = window.innerWidth
    @$$canvas.height = window.innerHeight

    @confettis = _map _range(NUM_CONFETTI), =>
      new ConfettiItem(@$$canvas, @context)
    @step()

  beforeUnmount: =>
    @paused = true
    @confettis = []

  step: =>
    unless @paused
      requestAnimationFrame(@step)
    @context.clearRect(0, 0, @$$canvas.width, @$$canvas.height)
    _each @confettis, (confetti) ->
      confetti.draw()

  render: ->
    z 'canvas.z-confetti'
