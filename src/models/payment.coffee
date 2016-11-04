Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

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

  purchase: (options) =>
    {productId, stripeToken, facebookSignedRequest,
        transactionId} = options

    @auth.call 'payments.purchase',
      productId: productId
      stripeToken: stripeToken
      facebookSignedRequest: facebookSignedRequest
      transactionId: transactionId
