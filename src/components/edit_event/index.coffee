z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
require 'moment-timezone'
_merge = require 'lodash/merge'

LongForm = require '../long_form'
StepBar = require '../step_bar'
config = require '../../config'

if window?
  require './index.styl'


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
    isOptional: true
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


module.exports = class EditEvent
  constructor: ({@model, @router, group, event}) ->
    @$step1Form = new LongForm {@model, fields: fields1, data: event}
    @$step2Form = new LongForm {@model, fields: fields2, data: event}

    step = new Rx.BehaviorSubject 1
    @$stepBar = new StepBar {step}

    @state = z.state
      group: group
      event: event
      step: step
      isLoading: false

  save: (isNewEvent) =>
    {event} = @state.getValue()
    diff = _merge @$step1Form.getSaveDiff(), @$step2Form.getSaveDiff()

    @state.set isLoading: true
    (if isNewEvent or not event
      @model.event.create diff
    else
      @model.event.updateById event.id, diff
    ).then (newEvent) =>
      @state.set isLoading: false
      id = newEvent?.id or event?.id
      @router.go "/event/#{id}"

  render: ({isNewEvent} = {}) =>
    {group, step, isLoading,
      step1Fields, step2Fields} = @state.getValue()

    stepFields = if step is 1 then step1Fields else step2Fields

    z '.z-edit-event',
      z '.g-grid',
        z '.content',
          if step is 1
            @$step1Form
          else
            @$step2Form
      z @$stepBar, {
        isLoading: isLoading
        isStepCompleted: if step is 1 \
                          then @$step1Form.isCompleted()
                          else @$step2Form.isCompleted()
        save:
          text: if isNewEvent then 'Create' else 'Save'
          onclick: =>
            @save isNewEvent
        steps: 2
      }
