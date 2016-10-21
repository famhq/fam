_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
PrimaryButton = require '../primary_button'
PrimaryInput = require '../primary_input'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Pay
  constructor: ({@model, @router}) ->
    me = @model.user.getMe()

    @$payButton = new PrimaryButton()
    @$cancelButton = new PrimaryButton()
    @numberValue = new Rx.BehaviorSubject ''
    @cvcValue = new Rx.BehaviorSubject ''
    @expireMonthValue = new Rx.BehaviorSubject ''
    @expireYearValue = new Rx.BehaviorSubject ''
    @$numberInput = new PrimaryInput
      value: @numberValue
    @$cvcInput = new PrimaryInput
      value: @cvcValue
    @$expireMonthInput = new PrimaryInput
      value: @expireMonthValue
    @$expireYearInput = new PrimaryInput
      value: @expireYearValue

    @state = z.state
      me: me
      isLoading: false
      error: null
      numberValue: @numberValue
      cvcValue: @cvcValue
      expireMonthValue: @expireMonthValue
      expireYearValue: @expireYearValue

  onNewStripe: ({product}) =>
    {isLoading, numberValue, cvcValue,
      expireMonthValue, expireYearValue} = @state.getValue()

    if isLoading
      return

    @state.set isLoading: true
    Stripe.card.createToken {
      number: numberValue
      cvc: cvcValue
      exp_month: expireMonthValue
      exp_year: expireYearValue
    }, (status, response) =>
      if response.error
        @state.set error: response.error.message, isLoading: false
        return

      stripeToken = response.id

      @model.payment.purchase {productId: product.productId, stripeToken}
      .then =>
        @state.set isLoading: false
        @selectedProduct.onNext null
        gaPurchase product
      .catch =>
        @state.set isLoading: false

  onPurchase: ({product}) =>
    @state.set isLoading: true
    @model.payment.purchase {productId: product.productId}
    .then =>
      @state.set isLoading: false
      @selectedProduct.onNext null
      gaPurchase product
    .catch =>
      @state.set isLoading: false

  render: =>
    {me, error, isLoading} = @state.getValue()

    hasStripeId = me?.flags.hasStripeId
    product = {productId: 'com.clay.redtritium.lifetime'}

    z '.z-pay',
      z '.title', 'Finish'
      z '.product',
        z '.left', 'Lifetime membership'
        z '.right', '$100'
      z '.due',
        z '.left', 'Due today'
        z '.right', '$0'
      z 'form.form', {
        onsubmit: (e) =>
          e.preventDefault()
          @onNewStripe {product}
      },
        if error
          z 'span.payment-errors', error
        z '.form-row',
          z @$numberInput,
            hintText: 'Card Number'
            type: 'number'
            isFloating: true


        z '.form-row',
          z @$cvcInput,
            hintText: 'CVC'
            type: 'number'
            isFloating: true

        z '.form-row.flex',
          z @$expireMonthInput,
            hintText: 'Exp Month'
            type: 'number'
            isFloating: true
          z '.slash', ' / '
          z @$expireYearInput,
            hintText: 'Exp Year'
            type: 'number'
            isFloating: true
        z 'input', # for onsubmit to work
          type: 'submit'
          style:
            display: 'none'

        # z @$cancelButton,
        #   text: 'cancel'

        z '.button',
          z @$payButton,
            text: if isLoading then 'loading...' else 'purchase'
            onclick: (e) =>
              e.preventDefault()

              console.log 'go'
              if isLoading
                return false

              if hasStripeId
                @onPurchase {product}
              else
                @onNewStripe {product}
