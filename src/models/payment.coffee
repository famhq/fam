config = require '../config'

module.exports = class Payment
  namespace: 'payments'

  constructor: ({@auth}) -> null

  verify: (options) =>
    {platform, groupId, receipt, productId, packageName, price,
        priceMicros, currency, isFromPending} = options

    @auth.call "#{@namespace}.verify", {
      platform: platform
      groupId: groupId
      receipt: receipt
      productId: productId
      packageName: packageName
      price: price
      isFromPending: isFromPending
      priceMicros: priceMicros
      currency: currency
    }, {invalidateAll: true}

  purchase: ({iapKey, platform, groupId, stripeToken, transactionId}) =>
    @auth.call "#{@namespace}.purchase", {
      iapKey: iapKey
      platform: platform
      groupId: groupId
      stripeToken: stripeToken
      transactionId: transactionId
    }, {invalidateAll: true}
