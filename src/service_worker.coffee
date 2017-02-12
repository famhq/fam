PortalGun = require 'portal-gun'

config = require './config'

onPush = null
topOnData = (callback) ->
  onPush = callback

portal = new PortalGun()
portal.listen()
portal.on 'top.onData', topOnData

self.addEventListener 'install', (e) ->
  self.skipWaiting()

self.addEventListener 'push', (e) ->
  message = if e.data then e.data.json() else {}

  e.waitUntil self.registration.showNotification 'Starfire',
    icon: if message.icon \
          then message.icon
          else "#{config.CDN_URL}/android-chrome-192x192.png"
    body: message.title + ': ' + message.text
    vibrate: [200, 100, 200, 100, 200, 100, 400]
    data:
      url: "#{config.HOST}#{message.data.path}"
      path: message.data.path

self.addEventListener 'notificationclick', (e) ->
  # close the notification
  e.notification.close()
  #To open the app after click notification
  e.waitUntil clients.matchAll(type: 'window').then((clientList) ->
    i = 0
    while i < clientList.length
      client = clientList[i]
      if 'focus' of client
        client.focus()
        onPush? e.notification.data
      i += 1
    if clientList.length is 0
      if clients.openWindow
        clients.openWindow e.notification.data.url
  )
