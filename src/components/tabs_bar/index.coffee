z = require 'zorium'
_map = require 'lodash/collection/map'

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TabsBar
  type: 'Widget'

  constructor: ({@selectedIndex}) ->
    @state = z.state
      selectedIndex: @selectedIndex

  # update: ($$prev, $$el) ->
  #   prevLeft = $$prev.style.left
  #   $$prev.style.left = 'auto'
  #   $$el = prevLeft

  onTouchMove: (e) ->
    e.preventDefault()

  afterMount: (@$$el) =>
    @$$el.addEventListener 'touchmove', @onTouchMove

  beforeUnmount: =>
    @$$el?.removeEventListener 'touchmove', @onTouchMove

  render: ({items, bgColor, color, inactiveColor, isFixed, tabWidth}) =>
    {selectedIndex} = @state.getValue()

    bgColor ?= colors.$primary500
    color ?= colors.$tabSelected
    underlineColor = colors.$white
    inactiveColor ?= colors.$tabUnselected
    isFullWidth = not tabWidth

    z '.z-tabs-bar', {
      className: z.classKebab {isFixed, isFullWidth}
      style:
        background: bgColor
    },
      z '.g-grid',
        z '.bar', {
          style:
            background: bgColor
            width: if isFullWidth \
                   then '100%'
                   else "#{tabWidth * items.length}px"
        },
            z '.selector',
              key: 'selector'
              style:
                background: underlineColor
                width: "#{100 / items.length}%"
            _map items, (item, i) =>
              hasIcon = Boolean item.$menuIcon
              hasText = Boolean item.$menuText
              isSelected = i is selectedIndex

              z '.tab',
                key: i
                id: item.id
                className: z.classKebab {hasIcon, hasText, isSelected}
                style: if tabWidth then {width: "#{tabWidth}px"} else null

                onclick: (e) =>
                  e.preventDefault()
                  e.stopPropagation()
                  @selectedIndex.onNext(i)
                if hasIcon
                  z '.icon',
                    item.$menuIcon
                if hasText
                  z '.text', {
                    style:
                      color: if isSelected then color else inactiveColor
                  },
                   item.$menuText
