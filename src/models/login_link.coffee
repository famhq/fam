config = require '../config'

module.exports = class LoginLink
  constructor: ({@auth}) -> null

  getByIdAndToken: ({id, token}) =>
    @auth.stream 'loginLinks.getByIdAndToken', {id, token}

  invalidateById: (id) =>
    @auth.call 'loginLinks.invalidateById', {id}
