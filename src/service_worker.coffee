PortalGun = require 'portal-gun'

config = require './config'

###
# Clear cloudflare cache...
###

onPush = null
topOnData = (callback) ->
  onPush = callback

portal = new PortalGun()
portal.listen()
portal.on 'top.onData', topOnData
# TODO: setcontext, don't show push if context

self.addEventListener 'install', (e) ->
  self.skipWaiting()

self.addEventListener 'activate', (e) ->
  e.waitUntil self.clients.claim()

self.addEventListener 'push', (e) ->
  message = if e.data then e.data.json() else {}

  console.log 'rec message', e

  e.waitUntil(
    self.registration.showNotification 'Starfire',
      icon: if message.icon \
            then message.icon
            else "#{config.CDN_URL}/android-chrome-192x192.png"
      title: message.title
      body: message.text
      tag: message.data.path
      vibrate: [200, 100, 200]
      data:
        url: "https://#{config.HOST}#{message.data.path}"
        path: message.data.path
  )

self.addEventListener 'notificationclick', (e) ->
  e.notification.close()

  e.waitUntil(
    clients.matchAll {
      includeUncontrolled: true
      type: 'window'
    }
    .then (activeClients) ->
      if activeClients.length > 0
        activeClients[0].focus()
        onPush? e.notification.data
      else
        clients.openWindow e.notification.data.url
  )
  return
