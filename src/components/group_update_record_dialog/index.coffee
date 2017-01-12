z = require 'zorium'
Rx = require 'rx-lite'

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'

module.exports = class GroupUpdateRecordDialog
  constructor: ({@overlay$}) ->
    @value = new Rx.BehaviorSubject 0
    @error = new Rx.BehaviorSubject null
    @$valueInput = new PrimaryInput {@value, @error}
    @$dialog = new Dialog()

  setValue: (value) =>
    @value.onNext value

  render: ({recordType, onSave} = {}) =>
    z '.z-group-update-record-dialog',
      z @$dialog,
        isVanilla: true
        $content: z 'div',
          z @$valueInput, {
            type: 'number'
            hintText: "#{recordType.name} / #{recordType.timeScale}"
          }
        cancelButton:
          text: 'cancel'
          onclick: =>
            @overlay$.onNext null
        submitButton:
          text: 'save'
          onclick: =>
            onSave? @value.getValue()
            @overlay$.onNext null
