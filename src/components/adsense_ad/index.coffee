z = require 'zorium'

colors = require '../../colors'

CLIENT = 'ca-pub-9043203456638369'
slots =
  desktop728x90:
    slot: '3445650539'
    width: 728
    height: 90
  mobile320x50:
    slot: '3284200136'
    width: 320
    height: 50
  desktop336x280:
    slot: '2577692937'
    width: 336
    height: 280
  mobile300x250:
    slot: '4972756133'
    width: 300
    height: 250
  mobile320x100:
    slot: '1003987655'
    width: 320
    height: 100

module.exports = class AdsenseAd
  constructor: ({@model}) ->
    @unique = Math.random()

  afterMount: ->
    if window?
      setTimeout ->
        (window.adsbygoogle = window.adsbygoogle or []).push({})
      , 500

  render: ({slot} = {}) =>
    slotInfo = slots[slot]

    if not slotInfo or not @model.ad.isVisible()
      return

    z '.z-adsense-ad', {
      key: "adsense-#{@unique}"
      style:
        width: "#{slotInfo.width}px"
        height: "#{slotInfo.height}px"
        margin: '0 auto'
        backgroundColor: colors.$tertiary700
        position: 'relative'
    },
      z 'ins',
        className: 'adsbygoogle'
        style:
          position: 'absolute'
          top: 0
          left: 0
          display: 'inline-block'
          width: "#{slotInfo.width}px"
          height: "#{slotInfo.height}px"
        attributes:
          'data-ad-client': CLIENT
          'data-ad-slot': slotInfo.slot
          # 'data-ad-format': format
