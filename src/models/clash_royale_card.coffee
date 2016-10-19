Rx = require 'rx-lite'

config = require '../config'

PATH = config.BACKEND_API_URL

module.exports = class ClashRoyaleCard
  constructor: ({@auth}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream 'clashRoyaleCard.getAll', {sort, filter}

  getById: (id) =>
    @auth.stream 'clashRoyaleCard.getById', {id}
