z = require 'zorium'
request = require 'clay-request'
qs = require 'qs'

colors = require '../../colors'

module.exports = class AerservAd
  constructor: ({@model, group}) ->
    @unique = Math.random()

    q =
      plc: '1038744' # sets width and height, in aerserv dash
      key: 3 # json
      appname: 'Fam'
      # appversion: ''
      bundleid: 'com.openfam.fortnite'
      cb: @unique
      # network: ''
      dnt: 1 # 1 don't track, 0 ok to track
      adid: '6D92078A-8246-4BA4-AE5B-76104861E7DC' # idfa
      # lat: ''
      # long: ''
      ip: '70.122.23.236'
      # make: ''
      # model: ''
      # os: ''
      # osv: ''
      # type: ''
      ua: 'Mozilla/5.0 (Linux; Android 7.0; Nexus 5X Build/NRD90R) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.2704.106 Crosswalk/21.51.546.6 Mobile Safari/537.36'
      # carrier: ''
      # locationsource: ''
      # carrier: ''
      # dw: ''
      # dh: ''
      # pchain: ''
      pl: 0 # 0 display right away, 1 just preload
      site_appstore_id: '1363619767'
      site_url: 'https://fam.gg'
      url: 'https://fam.gg' # FIXME
    console.log qs.stringify q
    request 'https://ads.aerserv.com/as/',
      qs:
        plc: '1038744' # sets width and height, in aerserv dash
        key: 3 # json
        appname: 'Fam'
        # appversion: ''
        bundleid: 'com.openfam.fortnite'
        cb: @unique
        # network: ''
        dnt: 1 # 1 don't track, 0 ok to track
        adid: '6D92078A-8246-4BA4-AE5B-76104861E7DC' # idfa
        # lat: ''
        # long: ''
        ip: '70.122.23.236'
        # make: ''
        # model: ''
        # os: ''
        # osv: ''
        # type: ''
        ua: 'Mozilla/5.0 (Linux; Android 7.0; Nexus 5X Build/NRD90R) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.2704.106 Crosswalk/21.51.546.6 Mobile Safari/537.36'
        # carrier: ''
        # locationsource: ''
        # carrier: ''
        # dw: ''
        # dh: ''
        # pchain: ''
        pl: 0 # 0 display right away, 1 just preload
        site_appstore_id: '1363619767'
        site_url: 'https://fam.gg'
        url: 'https://fam.gg' # FIXME
    .then (response) ->
      console.log 'rrr', response

    @state = z.state {group}

  render: ({slot} = {}) =>
    {group} = @state.getValue()

    slotInfo = slots[group?.key or group?.id]?[slot] or slots.default[slot]

    if not slotInfo or not @model.ad.isVisible({isWebOnly: true})
      return

    z '.z-aerserv-ad', {
      key: "aerserv-#{@unique}"
      style:
        width: "#{slotInfo.width}px"
        height: "#{slotInfo.height}px"
        margin: '0 auto'
        backgroundColor: colors.$tertiary700
        position: 'relative'
    }
