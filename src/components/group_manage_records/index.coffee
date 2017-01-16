z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'

PrimaryInput = require '../primary_input'
Dropdown = require '../dropdown'
Dialog = require '../dialog'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

timeScaleOptions = [
  {
    value: 'day'
    text: 'Daily'
  }
  {
    value: 'week'
    text: 'Weekly'
  }
  {
    value: 'biweek'
    text: 'Biweekly'
  }
]

module.exports = class GroupManageRecords
  constructor: ({@model, group}) ->
    recordTypes = group.flatMapLatest (group) =>
      @model.groupRecordType.getAllByGroupId group.id

    @nameValue = new Rx.BehaviorSubject ''
    @nameError = new Rx.BehaviorSubject null
    isNameFocused = new Rx.BehaviorSubject false
    @$newNameInput = new PrimaryInput {
      value: @nameValue
      error: @nameError
      isFocused: isNameFocused
    }

    @timeScaleValue = new Rx.BehaviorSubject ''
    @timeScaleError = new Rx.BehaviorSubject null
    @$newTimeScaleDropdown = new Dropdown {
      value: @timeScaleValue
      error: @timeScaleError
    }

    disposableSub = Rx.Observable.combineLatest(
      isNameFocused
      @nameValue
      @timeScaleValue
      group
      (vals...) -> vals
    )
    .map ([isNameFocused, name, timeScale, group]) =>
      if name and timeScale and not isNameFocused
        @nameValue.onNext ''
        setTimeout =>
          @timeScaleValue.onNext ''
        , 100
        @state.set isLoading: true
        @model.groupRecordType.create {
          name, timeScale, groupId: group.id
        }
        .then =>
          @state.set isLoading: false
    .share()

    @$confirmDeleteDialog = new Dialog()

    @state = z.state
      group: group
      recordTypes: recordTypes.map (recordTypes) ->
        _map recordTypes, (recordType) ->
          {
            recordType: recordType
            $nameInput: new PrimaryInput {
              value: new Rx.BehaviorSubject recordType.name
            }
            $timeScaleInput: new Dropdown {
              value: new Rx.BehaviorSubject recordType.timeScale
            }
            $deleteIcon: new Icon()
          }
      disposableSub: disposableSub
      isConfirmDeleteDialogVisible: false
      deletingRecordType: null
      isLoading: false

  render: =>
    {group, recordTypes, isLoading, deletingRecordType,
      isConfirmDeleteDialogVisible} = @state.getValue()

    console.log 'rerender', recordTypes?.length

    z '.z-group-manage-records', [
      _map recordTypes, (options) =>
        {recordType, $nameInput, $timeScaleInput, $deleteIcon} = options
        z '.row',
          z '.name',
            # TODO: add editing support
            # will need to save onblur for text / onchange for dropdown
            z $nameInput,
              hintText: 'Record name'
              isDisabled: true
          z '.time-scale',
            z $timeScaleInput,
              hintText: 'Time scale'
              isDisabled: true
              options: timeScaleOptions
          z '.delete',
            z $deleteIcon,
              icon: 'delete'
              color: colors.$primary500
              onclick: =>
                @state.set
                  isConfirmDeleteDialogVisible: true
                  deletingRecordType: recordType

      z '.row',
        z '.name',
          z @$newNameInput,
            hintText: 'Record name'
            isDisabled: isLoading

        z '.time-scale',
          z @$newTimeScaleDropdown,
            hintText: 'Time scale'
            isDisabled: isLoading
            options: timeScaleOptions

      if isConfirmDeleteDialogVisible
        z @$confirmDeleteDialog,
          isVanilla: true
          $content:
            z 'div',
              z 'div', 'Are you sure you want to delete this record type?'
              z 'div', {style: marginTop: '16px'},
                'All associated member records will be deleted as well.'
          cancelButton:
            text: 'cancel'
            onclick: =>
              @state.set isConfirmDeleteDialogVisible: false
          submitButton:
            text: 'Delete'
            onclick: =>
              @model.groupRecordType.deleteById deletingRecordType.id
              @state.set isConfirmDeleteDialogVisible: false
    ]
