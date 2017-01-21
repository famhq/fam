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

# TODO: clean this up and move out into some form component

fields1 = [
  {
    hintText: 'Event name'
    icon: 'info'
    type: 'text'
    field: 'name'
  }
  {
    hintText: 'ID tag #'
    type: 'text'
    isDataField: true
    field: 'data.tournamentId'
  }
  {
    label: 'Password protected'
    type: 'toggle'
    icon: 'lock-outline'
    id: 'password'
  }
  {
    hintText: 'Password'
    # type: 'password'
    type: 'text'
    field: 'password'
    tiedToToggleId: 'password'
  }
  {
    hintText: 'Date'
    type: 'date'
    defaultValue: moment().format('YYYY-MM-DD')
    field: 'startTime'
    icon: 'date'
  }
  {
    hintText: 'Start time (' + moment.tz(moment.tz.guess()).zoneAbbr() + ')'
    type: 'time'
    defaultValue: moment().format('HH:mm')
    field: 'startTime'
    icon: 'time'
    ignoreInSave: true
    id: 'startTime'
  }
  {
    hintText: 'Duration'
    type: 'select'
    field: 'startTime'
    options:
      config.EVENT_DURATIONS
    ignoreInSave: true
    id: 'duration'
  }
]
fields2 = [
  {
    hintText: 'Description / rules'
    icon: 'info'
    type: 'textarea'
    field: 'description'
  }
  {
    hintText: 'Min trophies'
    icon: 'trophy'
    type: 'number'
    defaultValue: 0
    isDataField: true
    field: 'data.minTrophies'
  }
  {
    label: 'Max limit'
    id: 'maxLimit'
    type: 'toggle'
  }
  {
    hintText: 'Max trophies'
    type: 'number'
    defaultValue: 4000
    isDataField: true
    field: 'data.maxTrophies'
    tiedToToggleId: 'maxLimit'
  }
  {
    hintText: 'Event size'
    icon: 'friends'
    type: 'select'
    field: 'maxUserCount'
    options:
      50: '50'
      100: '100'
      200: '200'
      1000: '1,000'
  }
  # TODO
  # {
  #   hintText: 'Visibility'
  #   type: 'select'
  #   field: 'visibility'
  #   options:
  #     group: 'Group members only'
  #     public: 'Public'
  #     link: 'Anyone with link'
  # }
]

fieldsWithElements = (fields, event) ->
  _map fields, (field) ->
    valueStreams = new Rx.ReplaySubject 1
    valueStreams.onNext event?.map((event) ->
      if field.isDataField
        val = event.data[field.field.replace 'data.', ''] or
                field.defaultValue or ''
      else
        val = event[field.field] or field.defaultValue or ''

      if field.type is 'date'
        val = moment(val).format('YYYY-MM-DD')
      else if field.type is 'time'
        val = moment(val).format('HH:mm')
      else if field.id is 'duration'
        val = (new Date(event.endTime) - new Date(event.startTime)) / 1000

      val
    ) or Rx.Observable.just field.defaultValue or ''

    isSelectedStreams = new Rx.ReplaySubject 1
    isSelectedStreams.onNext event?.map((event) ->
      if field.id
        tiedToField = _find fields, {tiedToToggleId: field.id}
        if tiedToField
          return Boolean event[tiedToField.field] or
                  event.data[tiedToField.field.replace 'data.', '']
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
      $icon: if field.icon then new Icon() else null
    }

module.exports = class EditEvent
  constructor: ({@model, @router, group, event}) ->
    step1Fields = fieldsWithElements fields1, event
    step2Fields = fieldsWithElements fields2, event

    @state = z.state
      group: group
      event: event
      step: 1
      isLoading: false
      step1Fields: step1Fields
      step2Fields: step2Fields

  setValuesFromField: (diff, {field, $el}, fields) ->
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

    return diff

  save: (isNewEvent) =>
    {step1Fields, step2Fields, event} = @state.getValue()
    fields = step1Fields.concat(step2Fields)
    diff = _reduce fields, (diff, field) =>
      @setValuesFromField diff, field, fields
    , {data: {}}

    (if isNewEvent
      @model.event.create diff
    else
      @model.event.updateById event.id, diff
    ).then (newEvent) =>
      id = newEvent?.id or event?.id
      @router.go "/event/#{id}"

  isCompleted: (fields) ->
    _every fields, (field) ->
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

  render: ({isNewEvent} = {}) =>
    {group, step, isLoading,
      step1Fields, step2Fields} = @state.getValue()

    stepFields = if step is 1 then step1Fields else step2Fields
    isStepCompleted = @isCompleted stepFields

    fieldsTo$ = ({field, value, error, $el, $icon}) ->
      if field.tiedToToggleId
        toggle = _find stepFields, {field: {id: field.tiedToToggleId}}
        unless toggle.$el.state.getValue().isSelected
          return false

      z '.row',
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

    z '.z-edit-event',
      z '.content',
        _map stepFields, fieldsTo$


      z '.step-bar',
        z '.g-grid',
          z '.previous', {
            onclick: =>
              if step > 1
                @state.set step: step - 1
          },
            if step isnt 1
              'Back'

          z '.step-counter',
            z '.step-dot',
              className: z.classKebab {isActive: step is 1}
            z '.step-dot',
              className: z.classKebab {isActive: step is 2}

          z '.next', {
            className: z.classKebab {canContinue: isStepCompleted}
            onclick: =>
              unless isStepCompleted
                return
              if step is 2#  and not isLoading # FIXME FIXME
                @state.set isLoading: true
                @save isNewEvent
              else
                @state.set step: step + 1
          },
            if isLoading
            then 'Loading...'
            else if step is 2 and isNewEvent
            then 'Create'
            else if step is 2
            then 'Save'
            else 'Next'
