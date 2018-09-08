z = require 'zorium'
request = require 'clay-request'
qs = require 'qs'
RxObservable = require('rxjs/Observable').Observable

colors = require '../../colors'
config = require '../../config'

module.exports = class AerservAd
  constructor: ({@model, group}) ->
    @unique = Math.random()

    ad =
      if window?
        RxObservable.fromPromise request 'https://ads.aerserv.com/as/',
          qs:
            plc: '1038744' # sets width and height, in aerserv dash
            key: 3 # json
            # appname: 'Fam'
            # appversion: ''
            # bundleid: 'com.openfam.fortnite'
            cb: @unique
            # network: ''
            dnt: 0 # 1 don't track, 0 ok to track
            # adid: '6D92078A-8246-4BA4-AE5B-76104861E7DC' # idfa
            ip: if config.ENV is config.ENVS.DEV \
                then '70.122.23.236'
                else @model.cookie.get 'ip'
            # make: '', model: '', os: '', osv: '', type: ''
            ua: navigator.userAgent
            # carrier: '', locationsource: ''
            # carrier: '', dw: '', dh: '', pchain: ''
            pl: 0 # 0 display right away, 1 just preload
            # site_appstore_id: '1363619767'
            # site_url: 'https://fam.gg'
            # url: 'https://fam.gg'
            site_url: "https://#{config.HOST}"
            url: "https://#{config.HOST}"
      else
        RxObservable.of null

    @state = z.state {group, ad}

  render: ({slot} = {}) =>
    {group, ad} = @state.getValue()

    if not ad or ad.error or not @model.ad.isVisible({isWebOnly: true})
      return

    [width, height] = ad.size.split 'x'

    z '.z-aerserv-ad', {
      key: "aerserv-#{@unique}"
      style:
        width: "#{width}px"
        height: "#{height}px"
        margin: '0 auto'
        backgroundColor: colors.$tertiary700
        position: 'relative'
        overflow: 'hidden'
      innerHTML: ad.content.replace /_blank/ig, '_system'
    }
