z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
require 'moment-timezone'

Icon = require '../icon'
PrimaryInput = require '../primary_input'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class EventInfo
  constructor: ({@model, event}) ->
    @$nameIcon = new Icon()
    @$descriptionIcon = new Icon()

    tournamentIdValueStreams = new Rx.ReplaySubject 1
    tournamentIdValueStreams.onNext event.map (event) ->
      event.data.tournamentId
    @$tournamentIdInput = new PrimaryInput {
      valueStreams: tournamentIdValueStreams
    }
    @$tournamentIdCopyIcon = new Icon()

    passwordStreams = new Rx.ReplaySubject 1
    passwordStreams.onNext event.map (event) ->
      event.password
    @$passwordInput = new PrimaryInput {
      valueStreams: passwordStreams
    }
    @$passwordCopyIcon = new Icon()

    @$dateIcon = new Icon()
    @$trophiesIcon = new Icon()
    @$membersIcon = new Icon()

    @state = z.state
      event: event

  afterMount: (@$$el) => null

  render: =>
    {event} = @state.getValue()

    event ?= {}
    minTrophies = event.data?.minTrophies
    maxTrophies = event.data?.maxTrophies

    startDateStr = moment(event.startTime).format('ddd, MMM D, YYYY')
    endDateStr = moment(event.endTime).format('ddd, MMM D, YYYY')
    isMultiDay = startDateStr isnt endDateStr
    timeZone = moment.tz(moment.tz.guess()).zoneAbbr()

    z '.z-event-info',
      z '.g-grid',
        # GROUP
        if event.group
          z '.row',
            z '.icon',
              z @$groupIcon
            z '.info',
              event.group.name

        # NAME
        z '.row',
          z '.icon',
            z @$nameIcon,
              icon: 'info'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.info', event.name

        # TOURNAMENT ID
        z '.row.no-vertical-padding#tournament-id',
          z '.icon'
          z '.info'
            z @$tournamentIdInput, {
              hintText: 'ID tag'
              isDisabled: true
            }
          z '.copy',
            z @$tournamentIdCopyIcon,
              icon: 'copy'
              color: colors.$primary500
              onclick: =>
                $$input = @$$el.querySelector('#tournament-id input')
                $$input.disabled = false
                $$input.select()
                try
                  successful = document.execCommand('copy')
                catch err
                  null
                $$input.disabled = true

        # PASSWORD
        if event.password
          z '.row.no-vertical-padding#password',
            z '.icon'
            z '.info'
              z @$passwordInput, {
                hintText: 'Password'
                isDisabled: true
              }
            z '.copy',
              z @$passwordCopyIcon,
                icon: 'copy'
                color: colors.$primary500
                onclick: =>
                  $$input = @$$el.querySelector('#password input')
                  $$input.disabled = false
                  $$input.select()
                  try
                    successful = document.execCommand('copy')
                  catch err
                    null
                  $$input.disabled = true

        # TIME
        z '.row',
          z '.icon',
            z @$dateIcon,
              icon: 'date'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.info',
            z '.title',
              startDateStr
            z '.sub-title',
              if isMultiDay
                'Begins: ' + moment(event.startTime).format('h:mma') +
                  " (#{timeZone})"
              else
                [
                  moment(event.startTime).format('h:mma')
                  ' - '
                  moment(event.endTime).format('h:mma') +
                    " (#{timeZone})"
                ]

        if isMultiDay
          z '.row',
            z '.icon'
            z '.info',
              z '.title',
                startDateStr
              z '.sub-title',
                'Ends: ' + moment(event.endTime).format('h:mma') +
                  " (#{timeZone})"

        # TROPHIES
        if minTrophies or maxTrophies
          z '.row',
            z '.icon',
              z @$trophiesIcon,
                icon: 'trophy'
                isTouchTarget: false
                color: colors.$tertiary500
            z '.info',
              if minTrophies and not maxTrophies
                "#{minTrophies}+"
              else if maxTrophies and not minTrophies
                "0-#{maxTrophies}"
              else
                "#{minTrophies}-#{maxTrophies}"

        # MEMBER COUNT
        z '.row',
          z '.icon',
            z @$membersIcon,
              icon: 'friends'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.info',
            "#{event.userIds?.length or 0} / #{event.maxUserCount}"

        # DESCRIPTION
        z '.row',
          z '.icon',
            z @$descriptionIcon,
              icon: 'info'
              isTouchTarget: false
              color: colors.$tertiary500
          z '.info', event.description
