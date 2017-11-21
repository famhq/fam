console.log 'Loading shared worker123'
io = require('socket.io-client/dist/socket.io.slim.js')
socket = null
ports = []
socketConnected = false
# handle new clients
addEventListener 'connect', (event) ->
  port = event.ports[0]
  ports.push port
  port.start()
  console.log 'client connected to worker', event
  port.addEventListener 'message', (event) ->
    model = event.data
    console.log 'received message', model.eventType, model.event, model.data
    switch model.eventType
      when 'connect'
        if !socket
          console.log 'conn', model
        socket = io(model.socketUri, model.options)
        # handle webworker clients already with ports
        socket.on 'connect', (msg) ->
          socketConnected = true
          ports.forEach (port) ->
            port.postMessage
              type: 'connect'
              message: msg
            return
          return
        socket.on 'disconnect', (msg) ->
          socketConnected = false
          ports.forEach (port) ->
            port.postMessage
              type: 'disconnect'
              message: msg
            return
          return
      when 'on'
        console.log 'on1', model
        eventName = model.event
        console.log 'on2'
        if eventName == 'connect'
          console.log 'conn'
          if socketConnected
            console.log 'post conn'
            port.postMessage type: eventName
          break
        if eventName == 'disconnect'
          console.log 'disconn'
          break
        console.log 'on', eventName
        socket.on eventName, (msg) ->
          console.log 'rec', eventName, msg
          port.postMessage
            type: eventName
            message: msg
          return
      when 'off'
        console.log 'TODO! off'
      when 'emit'
        socket.emit model.event, model.data
        # todo: ack cb
    return
  return
