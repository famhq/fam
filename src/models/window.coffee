Rx = require 'rx-lite'

DRAWER_RIGHT_PADDING = 56
DRAWER_MAX_WIDTH = 336

getSize = ->
  {
    width: window?.innerWidth# or 412
    height: window?.innerHeight# or 732
  }

getBreakpoint = ->
  if window?.innerWidth >= 1280
    'desktop'
  else
    'mobile'

getDrawerWidth = ->
  Math.min(
    window?.innerWidth - DRAWER_RIGHT_PADDING
    DRAWER_MAX_WIDTH
  )

getAppBarHeight = ->
  if window?.innerWidth > 768 then 64 else 56

module.exports = class Window
  constructor: ->
    @isPaused = false

    @size = new Rx.BehaviorSubject getSize()
    @breakpoint = new Rx.BehaviorSubject getBreakpoint()
    @drawerWidth = new Rx.BehaviorSubject getDrawerWidth()
    @appBarHeight = new Rx.BehaviorSubject getAppBarHeight()
    window?.addEventListener 'resize', @updateSize

  updateSize: =>
    unless @isPaused
      @size.onNext getSize()
      @breakpoint.onNext getBreakpoint()

  getSize: =>
    @size

  getDrawerWidth: =>
    @drawerWidth

  getBreakpoint: =>
    @breakpoint

  getAppBarHeight: =>
    @appBarHeight

  pauseResizing: =>
    @isPaused = true

  resumeResizing: =>
    @isPaused = false
    @updateSize()
