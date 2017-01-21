z = require 'zorium'
moment = require 'moment'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'
_groupBy = require 'lodash/groupBy'

Base = require '../base'
Avatar = require '../avatar'
Spinner = require '../spinner'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Events extends Base
  constructor: ({@model, @router, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    events = @model.event.getAll({filter})

    @state = z.state
      me: me
      filter: filter
      eventsByDate: events.map (events) ->
        events = _map events, (event) ->
          {
            event
            $avatar: new Avatar()
          }
        eventsByDate = _groupBy events, (event) ->
          moment(event.event.startTime).format('YYYY-MM-DD')


  render: =>
    {me, eventsByDate, filter} = @state.getValue()

    z '.z-events',
      z '.g-grid',
        if eventsByDate and _isEmpty eventsByDate
          z '.no-events',
            if filter is 'mine'
              'You haven\'t joined any events.'
            else
              'No events found. '
        else if eventsByDate
          _map eventsByDate, (events, dateStr) =>
            date = moment(dateStr)

            z '.event-group',
              z '.date',
                z '.month', date.format('MMM')
                z '.day', date.format('D')
              z '.events',
                _map events, ({event, $avatar}) =>
                  duration = new Date(event.endTime) - new Date(event.startTime)
                  duration /= 1000
                  duration = config.EVENT_DURATIONS[duration]
                  [
                    @router.link z 'a.event', {
                      href: "/event/#{event.id}"
                    },
                      z '.creator',
                        z $avatar, {user: event.creator, size: '20px'}
                        z '.name', @model.user.getDisplayName event.creator
                      z '.name', event.name
                      z '.details',
                        moment(event.startTime).format('h:mma')
                        z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
                        duration
                        z 'span', innerHTML: '&nbsp;&middot;&nbsp;'
                        event.userIds.length
                        ' / '
                        event.maxUserCount
                        ' participants'

                    z '.divider'
                  ]
        else
          @$spinner
