config = require '../config'

module.exports = class User
  constructor: ({@auth}) -> null

  getMe: =>
    @auth.stream 'users.getMe'
