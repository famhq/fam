z = require 'zorium'
Rx = require 'rx-lite'
Environment = require 'clay-environment'

FormatService = require '../../services/format'
Icon = require '../icon'
Spinner = require '../spinner'
Dialog = require '../dialog'
StripeDialogInner = require '../stripe_dialog_inner'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

LOAD_TIME_MS = 2000
AMOUNTS = [1, 5, 10, 25, 50]
DEFAULT_AMOUNT = 10

module.exports = class DonateDialog
  constructor: ({@model, @router, @isVisible, username}) ->
    @$dialog = new Dialog()

    @amountValue = new Rx.BehaviorSubject DEFAULT_AMOUNT

    product = Rx.Observable.combineLatest(
      username
      @amountValue
      (username, amount) ->
        console.log 'combine', username, amount
        {username, amount}
    )

    @$stripeDialogInner = new StripeDialogInner {
      @model, @router, product, @isVisible
    }

    @state = z.state
      me: @model.user.getMe()
      isLoading: false
      error: null
      amount: @amountValue
      step: 'setAmount'

  render: =>
    {me, error, isLoading, amount, step} = @state.getValue()
    console.log 'amount', amount

    hasStripeId = me?.flags.hasStripeId

    z '.z-donate-dialog',
      z @$dialog,
        $title: if step is 'setAmount' \
                then @model.l.get 'general.donate'
                else if hasStripeId
                then @model.l.get 'stripeDialog.confirmTitle'
                else @model.l.get 'stripeDialog.title'
        isVanilla: true
        onLeave: =>
          @isVisible.onNext false
        $content:
          z '.z-donate-dialog_dialog',
            if step is 'pay'
              @$stripeDialogInner
            else
              z '.donate',
                z 'p', @model.l.get 'donateDialog.text1'
                z 'p', @model.l.get 'donateDialog.text2'
                z 'input.range',
                  type: 'range'
                  defaultValue: Math.floor AMOUNTS.length / 2
                  oninput: z.ev (e, $$el) =>
                    @amountValue.onNext AMOUNTS[$$el.value]
                  min: 0
                  max: AMOUNTS.length - 1
                  step: 1
                z '.amount',
                  amount
        cancelButton:
          text: 'cancel'
          onclick: =>
            @isVisible.onNext false
        submitButton:
          text: if isLoading \
                then 'loading...'
                else @model.l.get 'general.donate'
          onclick: (e) =>
            e.preventDefault()
            if isLoading
              return

            if step is 'pay'
              @state.set isLoading: true
              @$stripeDialogInner.purchase {product}
              .then =>
                @state.set isLoading: false
                @isVisible.onNext false
              .catch =>
                @state.set isLoading: false

            @state.set step: 'pay'
