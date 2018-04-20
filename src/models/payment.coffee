config = require '../config'

module.exports = class Payment
  constructor: ({@auth}) -> null

  verify: (options) =>
    {platform, groupId, receipt, productId, packageName, price,
        priceMicros, currency, isFromPending} = options

    @auth.call 'payments.verify',
      platform: platform
      groupId: groupId
      receipt: receipt
      productId: productId
      packageName: packageName
      price: price
      isFromPending: isFromPending
      priceMicros: priceMicros
      currency: currency

  purchase: ({iapKey, platform, groupId, stripeToken, transactionId}) =>
    @auth.call 'payments.purchase',
      iapKey: iapKey
      platform: platform
      groupId: groupId
      stripeToken: stripeToken
      transactionId: transactionId
