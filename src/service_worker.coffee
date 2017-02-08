# https://serviceworke.rs/push-rich.html
# https://www.npmjs.com/package/web-push
console.log 'service'

self.addEventListener 'push', (event) ->
  console.log 'push', event
  payload = if event.data then event.data.text() else 'no payload'
  console.log payload
  event.waitUntil self.registration.showNotification 'Starfire',
    icon: payload.icon
    body: payload.title + ': ' + payload.text
