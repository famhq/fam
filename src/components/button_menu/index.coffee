z = require 'zorium'
colors = require '../../colors'

Icon = require '../icon'

module.exports = class ButtonBack
  constructor: ({@model}) ->
    @$backIcon = new Icon()

  render: ({color, onclick} = {}) =>
    z '.z-button-back',
      z @$backIcon,
        isAlignedLeft: true
        icon: 'menu'
        color: color or colors.$tertiary900
        onclick: (e) =>
          e.preventDefault()
          @model.drawer.open()
