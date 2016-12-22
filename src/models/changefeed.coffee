Rx = require 'rx-lite'
uuid = require 'uuid'
_merge = require 'lodash/merge'
_clone = require 'lodash/clone'
_forEach = require 'lodash/forEach'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_findIndex = require 'lodash/findIndex'

module.exports = class Changefeed
  constructor: ({@auth}) ->
    # buffer 0 so future streams don't try to add the client changes
    # (causes smooth scroll to bottom in conversations)
    @clientChangesStream = new Rx.ReplaySubject 0

  create: (diff, localDiff) =>
    clientId = uuid.v4()

    @clientChangesStream.onNext _merge diff, {clientId}, localDiff

    @auth.call "#{@namespace}.create", _merge diff, {clientId}

  stream: (changesStream, {initialSortFn} = {}) =>
    items = []

    if @clientChangesStream
      changesStream = Rx.Observable.merge(
        changesStream
        @clientChangesStream.map (change) ->
          {initial: null, changes: [{newVal: change}]}
      )

    changesStream.map ({initial, changes}) ->
      if initial
        items = _clone initial
        if initialSortFn
          items = initialSortFn items
      else
        _forEach changes, (change) ->
          existingIndex = change.oldId and
                          _findIndex(items, {id: change.oldId}) or
                          _findIndex(items, {clientId: change.newVal?.clientId})
          if existingIndex and existingIndex isnt -1 and change.newVal
            items.splice existingIndex, 1, change.newVal
            # items = _map items, (item, index) ->
            #   if index is existingIndex then change.newVal else item
          else if existingIndex and existingIndex isnt -1
            items.splice existingIndex, 1
            # items = _filter items, (item, index) -> index isnt existingIndex
          else
            items = items.concat [change.newVal]
      return items
