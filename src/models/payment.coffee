Rx = require 'rx-lite'

config = require '../config'

module.exports = class Payment
  constructor: ({@auth}) -> null

  verify: (options) =>
    {platform, receipt, productId, packageName, price,
        priceMicros, currency, isFromPending} = options

    @auth.call 'payments.verify',
      platform: platform
      receipt: receipt
      productId: productId
      packageName: packageName
      price: price
      isFromPending: isFromPending
      priceMicros: priceMicros
      currency: currency

  purchase: ({productId, stripeToken, transactionId}) =>
    @auth.call 'payments.purchase',
      productId: productId
      stripeToken: stripeToken
      transactionId: transactionId
