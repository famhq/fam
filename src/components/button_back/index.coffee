z = require 'zorium'
colors = require '../../colors'

Icon = require '../icon'

module.exports = class ButtonBack
  constructor: ({@router}) ->
    @$backIcon = new Icon()

  render: ({color, onclick, fallbackPath} = {}) =>
    z '.z-button-back',
      z @$backIcon,
        isAlignedLeft: true
        icon: 'back'
        color: color or colors.$header500Icon
        onclick: (e) =>
          e.preventDefault()
          if onclick
            onclick()
          else
            @router.back {fallbackPath}
