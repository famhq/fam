# not in use
#
# z = require 'zorium'
# _clone = require 'lodash/clone'
# _map = require 'lodash/map'
# _first = require 'lodash/first'
#
# colors = require '../../colors'
# config = require '../../config'
#
# RENDER_IN_TIME_SET_DELAY_MS = 300
# PREVIEW_IMAGE_WIDTH = 512
# PREVIEW_IMAGE_HEIGHT = 512
# PREVIEW_IMAGE_BLUR_RADIUS = 50
# MIN_FRAME_DELAY_FOR_SLOW_FRAME_MS = 40
# MIN_SLOW_FRAMES_FOR_SLOW_DEVICE = 3
# RE_RENDER_FREQ_MS = 250
#
# if window?
#   require './index.styl'
#
# # Render a set of x, y coordinates to ctx
# # point = [x, y, dt]
# renderPoints = (ctx, options, info = {}) ->
#   {points, thickness, res} = options
#   {renderLastPoint, canvasWidth, canvasHeight, isSlowDevice} = info
#
#   # renders last point as a circle
#   renderLastPoint ?= true
#
#   if res
#     scale = Math.min canvasWidth / res[0], canvasHeight / res[1]
#   if not scale or isNaN scale
#     scale = 1
#
#   ctx.strokeStyle = colors.$white
#   ctx.fillStyle = colors.$white
#   ctx.lineWidth = (thickness or 1) * scale
#   ctx.globalCompositeOperation = 'destination-out'
#
#   if points.length
#     # start with rounded point
#     firstPoint = points[0]
#     ctx.beginPath()
#     x = firstPoint[0] * scale
#     y = firstPoint[1] * scale
#     ctx.arc x, y, thickness * scale / 2, 0, Math.PI * 2, true
#     ctx.fill()
#     ctx.closePath()
#
#     if points.length >= 2
#       ctx.beginPath()
#       ctx.moveTo points[0][0] * scale, points[0][1] * scale
#       i = 0
#       while i < points.length - 1
#         currentPoint = points[i]
#         nextPoint = points[i + 1]
#         if isSlowDevice
#           ctx.lineTo nextPoint[0] * scale, nextPoint[1] * scale
#         else
#           controlPointX = (currentPoint[0] + nextPoint[0]) / 2 * scale
#           controlPointY = (currentPoint[1] + nextPoint[1]) / 2 * scale
#           x = currentPoint[0] * scale
#           y = currentPoint[1] * scale
#           # quadratic curve gives smoothest looking lines
#           ctx.quadraticCurveTo x, y, controlPointX, controlPointY
#         i += 1
#       lastPoint = points[i]
#       ctx.lineTo lastPoint[0] * scale, lastPoint[1] * scale
#       ctx.stroke()
#       ctx.closePath()
#
#       # for the last point (close off with rounded point)
#       if renderLastPoint
#         ctx.beginPath()
#         x = lastPoint[0] * scale
#         y = lastPoint[1] * scale
#         ctx.arc x, y, thickness * scale / 2, 0, Math.PI * 2, true
#         ctx.fill()
#         ctx.closePath()
#
# module.exports = class Canvas
#   constructor: ({@onDrawStart, @topImageSrc}) ->
#     @renderingPaused = true
#     @$$canvas = null
#     @lastRenderTime = null
#     @dataPoints = []
#     @mouse =
#       x: 0
#       y: 0
#     @lastMouse =
#       x: 0
#       y: 0
#     # not in state because i don't want re-render when setting
#     @slowFrameCount = 0
#
#     @state = z.state
#       canvasWidth: 0
#       canvasHeight: 0
#
#   setDataPoints: (@dataPoints) => null
#
#   addDataPoint: (dataPoint) =>
#     @dataPoints[0].points.push dataPoint
#
#   getDataPoints: =>
#     return @dataPoints
#
#   trashAll: =>
#     @setDataPoints []
#     @clear()
#
#
#   afterMount: ($$el) =>
#     # TODO: wait for width
#     setTimeout =>
#       @start $$el
#     , 500
#
#   start: ($$el) =>
#     @timeSinceLastReRender = 0
#     # http://codetheory.in/html5-canvas-drawing-lines-with-smooth-edges/
#     @$$canvas = $$el.querySelector '.canvas'
#     @ctx = @$$canvas.getContext('2d')
#     canvasBoundingRect = @$$canvas.getBoundingClientRect()
#     console.log canvasBoundingRect
#     topOffset = canvasBoundingRect.top
#     leftOffset = canvasBoundingRect.left
#
#     canvasWidth = canvasBoundingRect.width
#     canvasHeight = canvasBoundingRect.height
#
#     @state.set
#       canvasWidth: canvasWidth
#       canvasHeight: canvasHeight
#
#     @$$canvas.width = canvasWidth
#     @$$canvas.height = canvasHeight
#
#     @ctx.lineJoin = 'round'
#     @ctx.lineCap = 'round'
#
#     @topImageSrc.take(1).subscribe (topImageSrc) =>
#       console.log 'img', topImageSrc
#       topImage = new Image()
#       topImage.src = topImageSrc
#       topImage.addEventListener 'load', =>
#         @topImage = topImage
#         @fillCanvas()
#         @renderTmpCanvas()
#
#     #
#     # Touchstart
#     #
#     isFirstTouch = true
#     touchStart = (e) ->
#       e.stopPropagation()
#       e.preventDefault()
#
#       if isFirstTouch
#         isFirstTouch = false
#         # @onDrawStart?()
#         # @clear() # black screen canvas bug
#
#     @$$canvas.addEventListener 'touchstart', touchStart
#     @$$canvas.addEventListener 'mousedown', touchStart
#
#     unless @isDisabled
#       #
#       # Touchmove
#       #
#       touchMove = (e) =>
#         e.stopPropagation()
#         e.preventDefault()
#
#         if e.touches
#           @mouse.x = e.touches[0].clientX - leftOffset
#           @mouse.y = e.touches[0].clientY - topOffset
#         else
#           @mouse.x = e.clientX - leftOffset
#           @mouse.y = e.clientY - topOffset
#       @$$canvas.addEventListener 'touchmove', touchMove
#       @$$canvas.addEventListener 'mousemove', touchMove
#
#       #
#       # Touchstart
#       #
#       touchStart = (e) =>
#         e.stopPropagation()
#         e.preventDefault()
#
#         # all points for current drawing go in this array (touchdown to touchup)
#         dataPoints = @getDataPoints()
#
#         dataPoints.unshift
#           points: []
#           res: [canvasWidth, canvasHeight]
#           thickness: 35
#         @setDataPoints dataPoints
#
#         if e.touches
#           @mouse.x = e.touches[0].clientX - leftOffset
#           @mouse.y = e.touches[0].clientY - topOffset
#         else
#           @mouse.x = e.clientX - leftOffset
#           @mouse.y = e.clientY - topOffset
#
#         @renderingPaused = false
#         @renderTmpCanvas()
#
#       @$$canvas.addEventListener 'touchstart', touchStart
#       @$$canvas.addEventListener 'mousedown', touchStart
#
#       #
#       # Touch End
#       #
#       touchEnd = (e) =>
#         e.stopPropagation()
#         e.preventDefault()
#
#         @slowFrameCount = 0
#
#         @renderTmpCanvas true
#         @renderingPaused = true
#         # redraw for smoother lines
#         @rerenderCanvas()
#         # @clearTmp()
#       @$$canvas.addEventListener 'touchend', touchEnd
#       @$$canvas.addEventListener 'mouseup', touchEnd
#
#   fillCanvas: =>
#     {canvasWidth, canvasHeight} = @state.getValue()
#     @ctx.globalCompositeOperation = 'source-over'
#     @ctx.drawImage(
#       @topImage,
#       0, 0, @topImage.width, @topImage.height,
#       0, 0, canvasWidth, canvasHeight
#     )
#
#   rerenderCanvas: =>
#     {canvasWidth, canvasHeight} = @state.getValue()
#     # redraw entire canvas for smoother lines
#     @fillCanvas()
#     dataPoints = @getDataPoints()
#     _map dataPoints, (points) =>
#       renderPoints @ctx, points, {canvasWidth, canvasHeight}
#
#   renderTmpCanvas: (isLastRender) =>
#     if not @getDataPoints()[0] or @renderingPaused
#       return
#
#     {canvasWidth, canvasHeight} = @state.getValue()
#
#     now = Date.now()
#     dt = now - @lastRenderTime
#     @timeSinceLastReRender += dt
#
#     if dt > MIN_FRAME_DELAY_FOR_SLOW_FRAME_MS and @lastRenderTime
#       @slowFrameCount += 1
#
#     @lastRenderTime = now
#
#     # Saving all the points in an array
#     if @mouse.x isnt @lastMouse.x or @mouse.y isnt @lastMouse.y or
#         isLastRender is true
#
#       @addDataPoint [@mouse.x, @mouse.y, dt]
#
#       isSlowDevice = @slowFrameCount > MIN_SLOW_FRAMES_FOR_SLOW_DEVICE
#
#       dataPoints = @getDataPoints()[0]
#
#       # render last point as single point (circle) to smooth it off
#       # we don't do this while it's drawing because it looks bad
#       renderLastPoint = isLastRender is true
#
#       if @timeSinceLastReRender > RE_RENDER_FREQ_MS
#         @rerenderCanvas()
#       else
#         renderPoints @ctx, dataPoints, {
#           renderLastPoint: renderLastPoint
#           canvasWidth: canvasWidth
#           canvasHeight: canvasHeight
#           isSlowDevice: isSlowDevice
#         }
#
#     @lastMouse = x: @mouse.x, y: @mouse.y
#
#     window.requestAnimationFrame @renderTmpCanvas
#
#
#   render: =>
#     {canvasWidth, canvasHeight} = @state.getValue()
#
#     z '.z-scratch-sticker-canvas',
#       z 'canvas.canvas',
#         key: 'scratch-canvas'
