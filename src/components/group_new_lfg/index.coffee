z = require 'zorium'
_map = require 'lodash/map'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switch'

ActionBar = require '../action_bar'
Icon = require '../icon'
PrimaryTextarea = require '../primary_textarea'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditChannel
  constructor: ({@model, @router, group}) ->
    me = @model.user.getMe()

    @$actionBar = new ActionBar {@model}

    @textValue = new RxBehaviorSubject ''
    @textError = new RxBehaviorSubject null

    @$textTextarea = new PrimaryTextarea
      value: @textValue
      error: @textError

    @state = z.state
      me: me
      isSaving: false
      group: group
      text: @textValue

  save: =>
    {me, isSaving, group, text} = @state.getValue()

    if isSaving
      return Promise.resolve null

    @state.set isSaving: true

    @model.lfg.upsert {
      text
      groupId: group.id
    }
    .then =>
      @state.set isSaving: false
      @router.go 'groupPeople', {groupId: group.key or group.id}

  render: =>
    {me, isSaving, group, text} = @state.getValue()

    if group?.gameKey is 'fortnite'
      tags = ['ps4', 'xb1', 'pc', 'mobile']
    else
      tags = ['2c2', 'clan', 'amigo']

    z '.z-group-new-lfg',
      z @$actionBar, {
        isSaving: isSaving
        cancel:
          text: 'Discard'
          onclick: =>
            @router.back()
        save:
          text: 'Done'
          onclick: @save
      }
      z '.g-grid',
        z '.hashtags',
          z '.description',
            @model.l.get 'groupNewLfg.hashtagsDescription'
          z '.tags',
            _map tags, (tag) =>
              z '.tag', {
                onclick: =>
                  @$textTextarea.setModifier {
                    pattern: "\##{tag} "
                  }
              },
                "\##{tag}"
        z '.input',
          z @$textTextarea,
            hintText: @model.l.get 'compose.postHintText'
