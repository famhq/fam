io = require 'socket.io-client/dist/socket.io.slim.js'

###
I initially thought websockets blocked UI thread, but they don't cause any
lag / slowdown. i ran a test with 100 req / second in background and 0 lag.

the only benefit of doing this would be having a shared websocket connection
across multiple tabs
###

# https://github.com/IguMail/socketio-shared-webworker
module.exports = class IOService
  constructor: (socketUri, options) ->
    console.log 'io ', socketUri, options
    @socket = null
    @worker = null

    @start socketUri, options

  emit: (event, data, cb) =>
    console.log '>> emit:', event, data, cb, worker
    if @worker
      # todo: ack cb
      @worker.port.postMessage
        eventType: 'emit'
        event: event
        data: data
    else
      @socket.emit.apply this, arguments

  on: (event, cb) =>
    console.log 'on0', event
    if @worker
      console.log 'post'
      @worker.port.postMessage
        eventType: 'on'
        event: event
      events.on event, cb
    else
      @socket.on.apply this, arguments

  off: (event, cb) =>
    console.log 'off', event
    if @worker
      @worker.port.postMessage
        eventType: 'off'
        event: event
      events.off event, cb
    else
      @socket.off.apply this, arguments

  start: (socketUri, options) =>
    console.log 'start'
    try
      @_startWorker socketUri, options
    catch e
      console.log 'Could not start shared webwoker', e
      @_startSocketIo socketUri, options

  _startWorker: (socketUri, options) =>
    console.log 'worker'
    workerUri = '/shared_worker.js'
    console.log 'Connecting to SharedWorker', workerUri, socketUri, options
    # FIXME: use WebWorker in safari/ios
    @worker = new SharedWorker(workerUri)
    @worker.port.addEventListener 'message', ((event) ->
      console.log '<< message:', event.data.type, event.data.message
      events.emit event.data.type, event.data.message
      return
    ), false

    @worker.onerror = (event) ->
      console.log 'worker error', event
      events.emit 'error', event
      return

    @worker.port.start()

    @worker.port.postMessage
      eventType: 'connect'
      socketUri: socketUri
      options: options

  _startSocketIo: (uri, options) =>
    @socket = io(uri, options)
