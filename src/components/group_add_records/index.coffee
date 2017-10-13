z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'
_find = require 'lodash/find'
_filter = require 'lodash/filter'
_flatten = require 'lodash/flatten'

Avatar = require '../avatar'
ActionBar = require '../action_bar'
SecondaryInput = require '../secondary_input'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupAddRecords
  constructor: ({@model, @router, group}) ->
    groupRecordTypes = group.switchMap (group) =>
      @model.groupRecordType.getAllByGroupId group.id, {
        embed: ['userValues']
      }

    groupAndRecordTypes = Rx.Observable.combineLatest(
      group
      groupRecordTypes
      (vals...) -> vals
    )

    @$actionBar = new ActionBar {@model}

    @state = z.state
      group: group
      groupUsers: groupAndRecordTypes.map ([group, recordTypes]) ->
        _map group.users, (user) ->
          {
            $avatar: new Avatar()
            recordTypes: _map recordTypes, (recordType) ->
              userValue = _find(recordType.userValues, {userId: user.id})?.value
              userValue ?= 0

              value = new Rx.BehaviorSubject userValue
              {
                $input: new SecondaryInput({value})
                value: value
                initialValue: userValue
                recordType: recordType
              }
            user: user
          }

  save: =>
    {groupUsers} = @state.getValue()

    @state.set isSaving: true

    changes = _flatten _map groupUsers, ({user, recordTypes}) ->
      _filter _map recordTypes, ({recordType, value, initialValue}) ->
        newValue = value.getValue()
        if newValue is initialValue
          return
        {
          userId: user.id
          groupRecordTypeId: recordType.id
          value: newValue
        }

    @model.groupRecord.bulkSave changes
    .then =>
      @state.set isSaving: false
      @router.back()

  render: =>
    {groupUsers, isSaving} = @state.getValue()

    z '.z-group-add-records',
      z @$actionBar, {
        isSaving
        cancel:
          onclick: => @router.back()
        save:
          onclick: @save
      }
      z '.g-grid',
        z '.content',
          _map groupUsers, ({$avatar, user, recordTypes}) =>
            z '.user',
              z '.avatar',
                z $avatar, {user}
              z '.right',
                z '.name', @model.user.getDisplayName user
                _map recordTypes, ({$input, recordType}) ->
                  z '.record-type',
                    z '.name', "#{recordType.name} / #{recordType.timeScale}"
                    z '.input', z $input, {type: 'number'}
