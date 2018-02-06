config = require '../config'

module.exports = class Time
  constructor: ({@auth}) ->
    @serverTime = Date.now()
    setInterval =>
      @serverTime += 1000
    , 1000
    @updateServerTime()

  updateServerTime: =>
    @auth.call 'time.get'
    .then (timeObj) =>
      @serverTime = Date.parse timeObj.now

  getServerTime: =>
    @serverTime
