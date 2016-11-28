Rx = require 'rx-lite'

config = require '../config'

# io = require('socket.io-client')(config.API_URL)
#
# class WSService
#   getObservable: (eventName) ->
#     return Rx.Observable.create (observer) ->
#       io.on eventName, (data) ->
#         observer.onNext(data)
#       return {dispose: io.close}

module.exports = new WSService()
