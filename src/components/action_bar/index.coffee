z = require 'zorium'
_defaults = require 'lodash/defaults'

Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ActionBar
  constructor: ->
    @$cancelIcon = new Icon()
    @$saveIcon = new Icon()

  render: ({cancel, save, isSaving}) =>
    cancel = _defaults cancel, {
      icon: 'close'
      text: 'Cancel'
      onclick: -> null
    }
    save = _defaults save, {
      icon: 'check'
      text: 'Save'
      onclick: -> null
    }

    z 'header.z-action-bar',
      z '.action', {
        onclick: cancel.onclick
      },
        z '.icon',
          z @$cancelIcon,
            icon: cancel.icon
            color: colors.$primary500
            isTouchTarget: false
        z '.text', cancel.text

      z '.action', {
        onclick: save.onclick
      },
        z '.icon',
          z @$saveIcon,
            icon: save.icon
            color: colors.$primary500
            isTouchTarget: false
        z '.text',
          if isSaving then 'Loading...' else save.text
