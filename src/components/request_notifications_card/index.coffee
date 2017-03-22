_map = require 'lodash/map'
z = require 'zorium'

UiCard = require '../ui_card'
PushService = require '../../services/push'

if window?
  require './index.styl'

module.exports = class RequestNotificationsCard
  constructor: ({@model, @isVisible}) ->
    @$uiCard = new UiCard()
    @state = z.state {
      state: 'ask'
    }

  render: =>
    {state} = @state.getValue()

    z '.z-request-notifications-card',
      z @$uiCard,
        isHighlighted: state is 'ask'
        text:
          if state is 'turnedOn'
            'Notifications have been enabled! You can always adjust
            them from the settings'
          else if state is 'noThanks'
            'If you change your mind, notifications can be toggled on
            from the settings'
          else
            'Would you like to turn on notifications?
            You\'ll receive a daily recap of your progress'
        cancel:
          if state is 'ask'
            {
              text: 'no thanks'
              onclick: =>
                @state.set state: 'noThanks'
                localStorage?['hideNotificationCard'] = '1'
            }
        submit:
          text: if state is 'ask' then 'yes, turn on' else 'got it'
          onclick: =>
            if state is 'ask'
              PushService.register {@model}
              localStorage?['hideNotificationCard'] = '1'
              @state.set state: 'turnedOn'
            else
              @isVisible.onNext false
