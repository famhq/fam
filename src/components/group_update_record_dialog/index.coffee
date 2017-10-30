z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'

module.exports = class GroupUpdateRecordDialog
  constructor: ({@overlay$}) ->
    @value = new RxBehaviorSubject 0
    @error = new RxBehaviorSubject null
    @$valueInput = new PrimaryInput {@value, @error}
    @$dialog = new Dialog()

  setValue: (value) =>
    @value.next value

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
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
        submitButton:
          text: 'save'
          onclick: =>
            onSave? @value.getValue()
            @overlay$.next null
