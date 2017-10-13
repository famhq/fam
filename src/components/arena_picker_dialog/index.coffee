z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'

Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class ArenaPickerDialog
  constructor: ({@model, @overlay$}) ->
    @$dialog = new Dialog()

    @onPickFn = null

    @state = z.state {}

  onPick: (@onPickFn) => null

  render: =>
    {} = @state.getValue()

    z '.z-arena-picker-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @overlay$.next null
        $content:
          z '.z-arena-picker-dialog_dialog',
            z '.title', @model.l.get 'arenaPickerDialog.title'
            z '.arenas',
              _map config.ARENAS, (arenaName, arenaNumber) =>
                z '.arena', {
                  onclick: =>
                    @onPickFn? arena
                    @overlay$.next null
                },
                  arenaName
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
