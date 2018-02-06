config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class Trade
  constructor: ({@auth}) -> null

  create: ({sendItemKeys, receiveItemKeys, toIds}) =>
    @auth.call 'trade.create', {
      sendItemKeys: sendItemKeys
      receiveItemKeys: receiveItemKeys
      toIds: toIds
    }, {invalidateAll: true}

  getById: (id) =>
    @auth.stream 'trade.getById', {id}

  getAll: ({ignoreCache} = {}) =>
    @auth.stream 'trade.getAll', {}, {ignoreCache}

  declineById: (id) =>
    @auth.call 'trade.declineById', {id}, {invalidateAll: true}

  deleteById: (id) =>
    @auth.call 'trade.deleteById', {id}, {invalidateAll: true}

  updateById: (id, {status}) =>
    @auth.call 'trade.updateById', {id, status}, {invalidateAll: true}
