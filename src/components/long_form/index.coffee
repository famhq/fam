z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
require 'moment-timezone'
_map = require 'lodash/map'
_reduce = require 'lodash/reduce'
_every = require 'lodash/every'
_find = require 'lodash/find'

PrimaryInput = require '../primary_input'
PrimaryTextarea = require '../primary_textarea'
Dropdown = require '../dropdown'
Toggle = require '../toggle'
Icon = require '../icon'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

fieldsWithElements = (fields, data) ->
  _map fields, (field) ->
    valueStreams = new Rx.ReplaySubject 1
    valueStreams.onNext data?.map((data) ->
      if field.isDataField
        val = data.data[field.field.replace 'data.', ''] or
                field.defaultValue or ''
      else
        val = data[field.field] or field.defaultValue or ''

      if field.type is 'date'
        val = moment(val).format('YYYY-MM-DD')
      else if field.type is 'time'
        val = moment(val).format('HH:mm')
      else if field.id is 'duration'
        val = (new Date(data.endTime) - new Date(data.startTime)) / 1000

      val
    ) or Rx.Observable.just field.defaultValue or ''

    isSelectedStreams = new Rx.ReplaySubject 1
    isSelectedStreams.onNext data?.map((data) ->
      if field.id
        tiedToField = _find fields, {tiedToToggleId: field.id}
        if tiedToField
          return Boolean data[tiedToField.field] or
                  data.data[tiedToField.field.replace 'data.', '']
    ) or Rx.Observable.just field.defaultValue or false

    error = new Rx.BehaviorSubject null

    {
      field
      valueStreams: valueStreams
      isSelectedStreams: isSelectedStreams
      error: error
      $el: if field.type in ['text', 'password', 'number', 'date', 'time'] \
           then new PrimaryInput {valueStreams, error}
           else if field.type is 'textarea'
           then new PrimaryTextarea {valueStreams, error}
           else if field.type is 'select'
           then new Dropdown {valueStreams, error}
           else if field.type is 'toggle'
           then new Toggle {isSelectedStreams}
           else field.$el
      $icon: if field.icon then new Icon() else null
    }

module.exports = class Form
  constructor: ({@model, @router, fields, data}) ->
    @state = z.state
      data: data
      fields: fieldsWithElements fields, data

  updateDiffFromField: (diff, {field, $el}, fields) ->
    if field.ignoreInSave
      return diff

    if field.field is 'startTime' and field.type is 'date'
      startTimeField = _find fields, {field: {id: 'startTime'}}
      durationField = _find fields, {field: {id: 'duration'}}
      dateValue = $el.state.getValue().value
      startTimeValue = startTimeField.$el.state.getValue().value
      durationValue = durationField.$el.state.getValue().value

      diff['startTime'] = new Date("#{dateValue} #{startTimeValue}")
      diff['endTime'] = moment(diff[field.field])
                        .add(durationValue, 's').toDate()

    else if field.type in [
      'text', 'textarea', 'password', 'number', 'select'
    ]
      if field.field.tiedToToggleId
        toggle = _find fields, {field: {id: field.field.tiedToToggleId}}
        unless toggle.$el.state.getValue().isSelected
          return diff

      if field.isDataField
        diff.data[field.field.replace 'data.', ''] = $el.state.getValue().value
      else
        diff[field.field] = $el.state.getValue().value

    else if field.type is 'toggle' and field.field and not field.id
      if field.isDataField
        diff.data[field.field.replace 'data.', ''] =
          $el.state.getValue().isSelected
      else
        diff[field.field] = $el.state.getValue().isSelected
    else if $el.getValue
      diff[field.field] = $el.getValue()
    else
      console.log 'skip', field, $el

    return diff

  getSaveDiff: =>
    {fields, data} = @state.getValue()

    _reduce fields, (diff, field) =>
      @updateDiffFromField diff, field, fields
    , {data: {}}

  isCompleted: =>
    {fields} = @state.getValue()

    _every fields, (field) ->
      if field.field.isOptional
        return true
      if field.field.type in [
        'text', 'password', 'number', 'date', 'time', 'select'
      ]
        if field.field.tiedToToggleId
          toggle = _find fields, {field: {id: field.field.tiedToToggleId}}
          unless toggle.$el.state.getValue().isSelected
            return true
        field?.$el?.state.getValue().value
      else
        true

  render: =>
    {data, fields} = @state.getValue()

    z '.z-long-form',
      z '.g-grid',
        z '.content',
          _map fields, ({field, value, error, $el, $icon}) ->
            if field.tiedToToggleId
              toggle = _find fields, {field: {id: field.tiedToToggleId}}
              unless toggle.$el.state.getValue().isSelected
                return false

            z '.row', {
              className: z.classKebab {
                isInput: field.type in [
                  'text', 'password', 'number', 'date', 'time', 'textarea'
                ]
              }
            },
              z '.icon',
                if $icon
                  z $icon,
                    icon: field.icon
                    isTouchTarget: false
                    color: colors.$tertiary500

              if field.type in ['text', 'password', 'number', 'date', 'time']
                z '.input',
                  z $el,
                    hintText: field.hintText
                    type: field.type
              else if field.type is 'textarea'
                z '.input',
                  z $el,
                    hintText: field.hintText
              else if field.type is 'select'
                z '.input',
                  z $el,
                    hintText: field.hintText
                    options: _map field.options, (text, value) ->
                      {text, value}
              else if field.type is 'toggle'
                z '.input.flex',
                  z '.label', field.label
                  z '.right',
                    z $el
              else
                z '.input', $el
