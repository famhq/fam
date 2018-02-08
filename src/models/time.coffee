config = require '../config'

module.exports = class Time
  constructor: ({@auth}) ->
    @serverTime = Date.now()
    @timeInterval = setInterval =>
      @serverTime += 1000
    , 1000
    @updateServerTime()

  updateServerTime: =>
    @auth.call 'time.get'
    .then (timeObj) =>
      @serverTime = Date.parse timeObj.now

  getServerTime: =>
    @serverTime

  dispose: =>
    clearInterval @timeInterval
