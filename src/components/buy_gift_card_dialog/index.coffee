z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Dialog = require '../dialog'
PrimaryInput = require '../primary_input'
FlatButton = require '../flat_button'
Icon = require '../icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class BuyGiftCardDialog
  constructor: ({@model, @router, @overlay$}) ->
    @emailValue = new RxBehaviorSubject ''
    @emailError = new RxBehaviorSubject null
    @$emailInput = new PrimaryInput
      value: @emailValue
      error: @emailError

    @$dialog = new Dialog()

    @state = z.state
      isLoading: false
      error: null

  render: ({onSubmit, onLeave}) =>
    {isLoading, error} = @state.getValue()

    z '.z-buy-gift-card-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.next null
          onLeave()
        isVanilla: true
        $title: @model.l.get 'buyGiftCardDialog.title'
        $content:
          z '.z-buy-gift-card-dialog_dialog',
            z 'form.content', {
              onsubmit: onSubmit
            },
              z '.error', error
              z '.input',
                z @$emailInput, {
                  type: 'text'
                  hintText: @model.l.get 'general.email'
                }
              z '.text', @model.l.get 'buyGiftCardDialog.description'
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
            onLeave()
        submitButton:
          text: if isLoading then @model.l.get 'general.loading' \
                else @model.l.get 'general.submit'
          onclick: =>
            @overlay$.next null
            onSubmit {email: @emailValue.getValue()}
