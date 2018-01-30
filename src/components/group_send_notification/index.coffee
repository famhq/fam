z = require 'zorium'
_map = require 'lodash/map'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/switch'

Toggle = require '../toggle'
PrimaryInput = require '../primary_input'
PrimaryButton = require '../primary_button'
Dropdown = require '../dropdown'
Icon = require '../icon'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupSendNotification
  constructor: ({@model, @router, group}) ->
    me = @model.user.getMe()
    @titleValue = new RxBehaviorSubject ''
    @titleError = new RxBehaviorSubject null

    @descriptionValue = new RxBehaviorSubject ''
    @descriptionError = new RxBehaviorSubject null

    @pathKeyValue = new RxBehaviorSubject 'groupChat'

    @$titleInput = new PrimaryInput
      value: @titleValue
      error: @titleError

    @$descriptionInput = new PrimaryInput
      value: @descriptionValue
      error: @descriptionError

    @$pathKeyDropdown = new Dropdown {value: @pathKeyValue}

    @$sendButton = new PrimaryButton()

    @state = z.state
      me: me
      group: group
      isSending: false
      isLeaveGroupLoading: false

  beforeUnmount: =>
    @state.set hasSent: false

  send: =>
    {group, isSending} = @state.getValue()

    if isSending
      return

    title = @titleValue.getValue()
    description = @descriptionValue.getValue()
    pathKey = @pathKeyValue.getValue()

    @state.set isSending: true

    @model.group.sendNotificationById group.id, {title, description, pathKey}
    .then =>
      @state.set isSending: false, hasSent: true

  render: =>
    {me, group, isSending, hasSent} = @state.getValue()

    z '.z-group-send-notification',
      z '.g-grid',
        if hasSent
          @model.l.get 'groupSendNotification.sent'
        else
          [
            z '.input',
              z @$titleInput,
                hintText: @model.l.get 'groupSendNotification.titleHint'

            z '.input',
              z @$descriptionInput,
                hintText: @model.l.get 'groupSendNotification.descriptionHint'

            z '.input',
                z @$pathKeyDropdown,
                  hintText: @model.l.get 'groupSendNotification.path'
                  isFloating: true
                  options: [
                    {value: 'groupChat', text: @model.l.get 'general.chat'}
                    {value: 'groupShop', text: @model.l.get 'general.shop'}
                    {value: 'groupHome', text: @model.l.get 'general.home'}
                  ]

            z @$sendButton,
              text: if isSending \
                    then @model.l.get 'general.loading'
                    else @model.l.get 'groupSendNotification.send'
              onclick: @send
          ]
