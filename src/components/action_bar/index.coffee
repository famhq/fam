z = require 'zorium'
_defaults = require 'lodash/defaults'

AppBar = require '../app_bar'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ActionBar
  constructor: ({@model}) ->
    @$appBar = new AppBar {@model}
    @$cancelIcon = new Icon()
    @$saveIcon = new Icon()

  render: ({title, cancel, save, isSaving}) =>
    cancel = _defaults cancel, {
      icon: 'close'
      text: @model.l.get 'general.cancel'
      onclick: -> null
    }
    save = _defaults save, {
      icon: 'check'
      text: @model.l.get 'general.save'
      onclick: -> null
    }


    z '.z-action-bar',
      z @$appBar, {
        title: title
        style: 'secondary'
        $topLeftButton:
          z @$cancelIcon,
            icon: cancel.icon
            color: colors.$primary500
            onclick: cancel.onclick
        $topRightButton:
          if isSaving
            '...'
          else
            z @$saveIcon,
              icon: save.icon
              color: colors.$primary500
              onclick: save.onclick
        isFlat: true
      }
