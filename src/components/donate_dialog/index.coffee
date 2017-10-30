z = require 'zorium'
Environment = require 'clay-environment'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

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

    @amountValue = new RxBehaviorSubject DEFAULT_AMOUNT

    product = RxObservable.combineLatest(
      username
      @amountValue
      (username, amount) ->
        {username, amount, currency: 'eur'}
    )

    @$stripeDialogInner = new StripeDialogInner {
      @model, @router, product, @isVisible
    }

    @state = z.state
      me: @model.user.getMe()
      username: username
      isLoading: false
      error: null
      amount: @amountValue
      product: product
      step: 'setAmount'

  render: =>
    {me, error, isLoading, amount, step, username, product} = @state.getValue()
    hasStripeId = me?.flags.hasStripeId

    # start with just spain
    currency = '€'

    z '.z-donate-dialog',
      z @$dialog,
        $title: if step is 'setAmount' \
                then @model.l.get 'general.donate'
                else if hasStripeId
                then @model.l.get 'stripeDialog.confirmTitle'
                else @model.l.get 'stripeDialog.title'
        isVanilla: true
        onLeave: =>
          @isVisible.next false
        $content:
          z '.z-donate-dialog_dialog',
            if step is 'pay'
              @$stripeDialogInner
            else
              z '.donate',
                z 'p', @model.l.get 'donateDialog.text1', {
                  replacements:
                    name: username
                }
                # z 'p', @model.l.get 'donateDialog.text2', {name: username}
                z 'input.range',
                  type: 'range'
                  defaultValue: Math.floor AMOUNTS.length / 2
                  oninput: z.ev (e, $$el) =>
                    @amountValue.next AMOUNTS[$$el.value]
                  min: 0
                  max: AMOUNTS.length - 1
                  step: 1
                z '.amount',
                  "#{currency}#{amount}"
        cancelButton:
          text: 'cancel'
          onclick: =>
            @isVisible.next false
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
                @isVisible.next false
              .catch =>
                @state.set isLoading: false

            @state.set step: 'pay'
