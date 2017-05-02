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


module.exports = class EditEvent
  constructor: ({@model, @router, group, event}) ->
    fields1 = [
      {
        hintText: @model.l.get 'editEvent.nameHintText'
        icon: 'info'
        type: 'text'
        field: 'name'
      }
      {
        hintText: @model.l.get 'editEvent.tournamentIdHintText'
        type: 'text'
        isDataField: true
        field: 'data.tournamentId'
        isOptional: true
      }
      {
        label: @model.l.get 'editEvent.passwordLabel'
        type: 'toggle'
        icon: 'lock-outline'
        id: 'password'
      }
      {
        hintText: @model.l.get 'general.password'
        # type: 'password'
        type: 'text'
        field: 'password'
        tiedToToggleId: 'password'
      }
      {
        hintText: @model.l.get 'editEvent.dateHintText'
        type: 'date'
        defaultValue: moment().format('YYYY-MM-DD')
        field: 'startTime'
        icon: 'date'
      }
      {
        hintText: @model.l.get('editEvent.startTimeHintText') +
                    ' (' + moment.tz(moment.tz.guess()).zoneAbbr() + ')'
        type: 'time'
        defaultValue: moment().format('HH:mm')
        field: 'startTime'
        icon: 'time'
        ignoreInSave: true
        id: 'startTime'
      }
      {
        hintText: @model.l.get 'editEvent.durationHintText'
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
        hintText: @model.l.get 'general.description'
        icon: 'info'
        type: 'textarea'
        field: 'description'
      }
      {
        hintText: @model.l.get 'editEvent.minTrophiesHintText'
        icon: 'trophy'
        type: 'number'
        defaultValue: 0
        isDataField: true
        field: 'data.minTrophies'
      }
      {
        label: @model.l.get 'editEvent.maxTrophiesHintText'
        id: 'maxLimit'
        type: 'toggle'
      }
      {
        hintText: @model.l.get 'editEvent.maxTrophiesHintText'
        type: 'number'
        defaultValue: 4000
        isDataField: true
        field: 'data.maxTrophies'
        tiedToToggleId: 'maxLimit'
      }
      {
        hintText: @model.l.get 'editEvent.maxUserCountHintText'
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

    @$step1Form = new LongForm {@model, fields: fields1, data: event}
    @$step2Form = new LongForm {@model, fields: fields2, data: event}

    step = new Rx.BehaviorSubject 1
    @$stepBar = new StepBar {@model, step}

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
          text: if isNewEvent \
                then @model.l.get 'general.create'
                else @model.l.get 'general.save'
          onclick: =>
            @save isNewEvent
        steps: 2
      }
