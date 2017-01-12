z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

TabsBar = require '../../components/tabs_bar'

if window?
  IScroll = require 'iscroll'
  require './index.styl'

SELECTOR_POSITION_INTERVAL_MS = 50

# iScroll does a translate transform, but it only does it for one transform
# property (eg transform or webkitTransform). We need to know which one iscroll
# is using, so this is the same code they have to pick one
transformProperty = 'transform'
getTransformProperty = ->
  _elementStyle = document.createElement('div').style
  _vendor = do ->
    vendors = [
      't'
      'webkitT'
      'MozT'
      'msT'
      'OT'
    ]
    transform = undefined
    i = 0
    l = vendors.length
    while i < l
      transform = vendors[i] + 'ransform'
      if transform of _elementStyle
        return vendors[i].substr(0, vendors[i].length - 1)
      i += 1
    false

  _prefixStyle = (style) ->
    if _vendor is false
      return false
    if _vendor is ''
      return style
    _vendor + style.charAt(0).toUpperCase() + style.substr(1)

  _prefixStyle 'transform'

module.exports = class Tabs
  constructor: ({@model, @selectedIndex, @isPageScrolling, hideTabBar}) ->
    @selectedIndex ?= new Rx.BehaviorSubject 0
    @isPageScrolling ?= new Rx.BehaviorSubject false
    @mountDisposable = null
    @scrollInterval = null
    @iScrollContainer = null

    @$tabsBar = new TabsBar {@model, @selectedIndex}

    @state = z.state
      selectedIndex: @selectedIndex
      x: 0
      hideTabBar: hideTabBar
      vDomKey: Math.random()
      windowSize: @model.window.getSize()

  afterMount: (@$$el) =>
    checkIsReady = =>
      $$container = @$$el?.querySelector('.z-tabs > .content > .tabs-scroller')
      if $$container and $$container.clientWidth
        @initIScroll $$container
      else
        setTimeout checkIsReady, 1000

    checkIsReady()

  beforeUnmount: (keepEl = false) =>
    @mountDisposable?.dispose()
    clearInterval @scrollInterval
    @iScrollContainer?.destroy()
    @$$el?.removeEventListener 'touchstart', @onTouchStart
    @$$el?.removeEventListener 'touchend', @onTouchEnd
    unless keepEl
      @$$el = null

  onTouchStart: =>
    @isPageScrolling.onNext true

  onTouchEnd: =>
    @isPageScrolling.onNext false

  initIScroll: ($$container) =>
    {hideTabBar} = @state.getValue()

    transformProperty = getTransformProperty()

    @iScrollContainer = new IScroll $$container, {
      scrollX: true
      scrollY: false
      eventPassthrough: true
      snap: '.tab'
      deceleration: 0.002
    }

    @$$el.addEventListener 'touchstart', @onTouchStart
    @$$el.addEventListener 'touchend', @onTouchEnd

    unless hideTabBar
      @$$selector = @$$el?.querySelector '.z-tabs-bar .selector'
      updateSelectorPosition = =>
        # updating state and re-rendering every time is way too slow
        xOffset = -100 * @iScrollContainer.pages.length * (
          @iScrollContainer.x / @iScrollContainer.scrollerWidth
        )
        xOffset = "#{xOffset}%"
        @$$selector?.style.transform = "translate(#{xOffset}, 0)"
        @$$selector?.style.webkitTransform = "translate(#{xOffset}, 0)"

    # the scroll listener in IScroll (iscroll-probe.js) is really slow
    # interval looks 100x better
    @iScrollContainer.on 'scrollStart', =>
      @isPageScrolling.onNext true
      unless hideTabBar
        @$$selector = document.querySelector '.z-tabs-bar .selector'
        @scrollInterval = setInterval(
          updateSelectorPosition, SELECTOR_POSITION_INTERVAL_MS
        )
        updateSelectorPosition()

    @iScrollContainer.on 'scrollEnd', =>
      {selectedIndex} = @state.getValue()
      @isPageScrolling.onNext false

      clearInterval @scrollInterval
      newIndex = @iScrollContainer.currentPage.pageX
      @state.set x: @iScrollContainer?.x
      # landing on new tab
      if selectedIndex isnt newIndex
        @selectedIndex.onNext newIndex

    @mountDisposable = @selectedIndex.subscribeOnNext (index) =>
      if @iScrollContainer.pages?[index]
        @iScrollContainer.goToPage index, 0, 500
      unless hideTabBar
        @$$selector = document.querySelector '.z-tabs-bar .selector'
        updateSelectorPosition()

  render: (options) =>
    {tabs, barColor, barBgColor, barInactiveColor, isBarFixed, barTabWidth,
      hasAppBar, vDomKey, windowSize} = options

    if @lastTabsLength and tabs?.length and @lastTabsLength isnt tabs?.length
      @beforeUnmount true
      setTimeout =>
        @afterMount @$$el
      , 100
    @lastTabsLength = tabs?.length

    {selectedIndex, x, hideTabBar, vDomKey, windowSize} = @state.getValue()

    isBarFixed ?= true

    z '.z-tabs', {
      className: z.classKebab {isBarFixed}
      vDomKey: vDomKey
      style:
        maxWidth: "#{windowSize.width}px"
    },
      z '.content',
        unless hideTabBar
          z '.tabs-bar',
            z @$tabsBar, {
              isFixed: isBarFixed
              tabWidth: barTabWidth
              color: barColor
              inactiveColor: barInactiveColor
              bgColor: barBgColor
              items: tabs
            }
        z '.tabs-scroller', {
          key: vDomKey
        },
          z '.tabs', {
            style:
              minWidth: "#{(100 * tabs.length)}%"
              # v-dom sometimes changes up the DOM node we're using when the
              # page changes, then back to this page. when that happens,
              # translate x is 0 initially even though iscroll might realize
              # it's actually something other than 0. since iscroll uses
              # css transitions, it causes the page to swipe in, which looks bad
              # This fixes that
              "#{transformProperty}": "translate(#{x}px, 0px) translateZ(0px)"
              # webkitTransform: "translate(#{x}px, 0px) translateZ(0px)"
          },
            _map tabs, ({$el}, i) ->
              z '.tab', {
                style:
                  width: "#{(100 / tabs.length)}%"
              },
                $el
