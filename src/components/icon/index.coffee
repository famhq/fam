z = require 'zorium'

icons = require './icons'

if window?
  require './index.styl'

module.exports = class Icon
  render: (options) ->
    {icon, size, isAlignedTop, isAlignedLeft, isAlignedRight,
              isAlignedBottom, isTouchTarget, color, onclick,
              flipX, viewBox, heightRatio} = options
    size ?= '24px'
    viewBox ?= 24
    heightRatio ?= 1
    isTouchTarget ?= true
    isClickable = Boolean onclick

    z 'div.z-icon', {
      className: z.classKebab {isAlignedTop, isAlignedLeft, isAlignedRight,
                                isTouchTarget, isClickable}
      onclick: onclick
      style:
        width: size
        height: if size?.indexOf?('%') isnt -1 \
                then "#{parseInt(size) * heightRatio}%"
                else "#{parseInt(size) * heightRatio}px"
    },
      z 'svg', {
        namespace: 'http://www.w3.org/2000/svg'
        attributes:
          'viewBox': "0 0 #{viewBox} #{viewBox * heightRatio}"
        style:
          width: size
          height: if size?.indexOf?('%') isnt -1 \
                  then "#{parseInt(size) * heightRatio}%"
                  else "#{parseInt(size) * heightRatio}px"
      },
        z 'path', {
          namespace: 'http://www.w3.org/2000/svg'
          attributes:
            d: icons[icon]
            fill: color
            'fill-rule': 'evenodd'
            transform: if flipX \
                       then 'translate(12, 12) scale(-1, 1) translate(-12, -12)'
                       else 'scale(1, 1)'
        }
