z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'

if window?
  require './index.styl'

FlatButton = require '../flat_button'
colors = require '../../colors'

module.exports = class Dialog
  constructor: ->
    @$cancelButton = new FlatButton()
    @$submitButton = new FlatButton()

  render: ({$content, cancelButton, submitButton, isVanilla, onLeave}) =>
    $content ?= ''
    onLeave ?= (-> null)

    z '.z-dialog', {className: z.classKebab {isVanilla}},
      z '.backdrop', onclick: ->
        onLeave()

      z '.dialog',
        z '.content',
          $content
        if cancelButton or submitButton
          z '.actions',
            if cancelButton
              z '.action', {
                className: z.classKebab {isFullWidth: cancelButton.isFullWidth}
              },
                z @$cancelButton, _defaults cancelButton, {
                  colors: {cText: colors.$primary500}
                }
            if submitButton
              z '.action',
                z @$submitButton, _defaults submitButton, {
                  colors: {cText: colors.$primary500}
                }
