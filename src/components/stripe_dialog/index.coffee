z = require 'zorium'
Environment = require '../../services/environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

FormatService = require '../../services/format'
Icon = require '../icon'
Spinner = require '../spinner'
Dialog = require '../dialog'
Input = require '../input'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

LOAD_TIME_MS = 2000


module.exports = class StripeDialog
  constructor: ({@model, group, @overlay$, iap}) ->
    @$spinner = new Spinner()
    @$dialog = new Dialog()
    @numberValue = new RxBehaviorSubject ''
    @cvcValue = new RxBehaviorSubject ''
    @expireMonthValue = new RxBehaviorSubject ''
    @expireYearValue = new RxBehaviorSubject ''
    @$numberInput = new Input
      value: @numberValue
    @$cvcInput = new Input
      value: @cvcValue
    @$expireMonthInput = new Input
      value: @expireMonthValue
    @$expireYearInput = new Input
      value: @expireYearValue

    @state = z.state
      me: @model.user.getMe()
      isLoading: false
      error: null
      numberValue: @numberValue
      cvcValue: @cvcValue
      expireMonthValue: @expireMonthValue
      expireYearValue: @expireYearValue
      iap: iap
      group: group

  purchase: =>
    {me, iap} = @state.getValue()
    hasStripeId = me?.flags.hasStripeId

    if hasStripeId
      @onPurchase {iap}
    else
      @onNewStripe {iap}


  onNewStripe: ({iap}) =>
    {isLoading, group, numberValue, cvcValue,
      expireMonthValue, expireYearValue} = @state.getValue()

    console.log 'iap', iap

    new Promise (resolve, reject) =>
      Stripe.card.createToken {
        number: numberValue
        cvc: cvcValue
        exp_month: expireMonthValue
        exp_year: expireYearValue
      }, (status, response) =>
        if response.error
          @state.set error: response.error.message, isLoading: false
          return reject()

        stripeToken = response.id

        resolve @model.payment.purchase {
          iapKey: iap.key, groupId: group.id, stripeToken, platform: 'web'
        }

  onPurchase: ({iap}) =>
    {group} = @state.getValue()
    @model.payment.purchase {
      iapKey: iap.key, groupId: group.id, platform: 'web'
    }

  render: =>
    {me, iap, error} = @state.getValue()

    isiOSApp = Environment.isNativeApp(config.GAME_KEY) and Environment.isiOS()
    if isiOSApp
      return # against TOS

    hasStripeId = me?.flags.hasStripeId

    z '.z-stripe-dialog',
      z @$dialog,
        onLeave: =>
          @overlay$.next null
        isVanilla: true
        $title: @model.l.get 'stripeDialog.title'
        $content:
          z '.z-stripe-dialog_dialog',
            if hasStripeId
              "Are you sure you want to buy #{iap?.name}?"
            else
              z 'form.form', {
                onsubmit: (e) =>
                  e.preventDefault()
                  @onNewStripe {iap}
              },
                if error
                  z 'span.payment-errors', error
                z '.form-row',
                  z @$numberInput,
                    hintText: 'Card Number'
                    isFloating: true
                    type: 'number'

                z '.form-row',
                  z @$cvcInput,
                    hintText: 'CVC'
                    isFloating: true
                    type: 'number'

                z '.form-row.flex',
                  z @$expireMonthInput,
                    hintText: 'Exp Month'
                    isFloating: true
                    type: 'number'
                  z '.slash', ' / '
                  z @$expireYearInput,
                    hintText: 'Exp Year'
                    isFloating: true
                    type: 'number'
                z 'input', # for onsubmit to work
                  type: 'submit'
                  style:
                    display: 'none'
        submitButton:
          text: @model.l.get 'stripeDialog.title'
          onclick: @purchase
        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @overlay$.next null
