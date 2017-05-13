z = require 'zorium'

###
<script async src="//pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
<!-- Mobile web banner -->
<ins class="adsbygoogle"
     style="display:inline-block;width:320px;height:100px"
     data-ad-client="ca-pub-1232978630423169"
     data-ad-slot="3223030936"></ins>
<script>
(adsbygoogle = window.adsbygoogle || []).push({});
</script>
###

module.exports = class AdsenseAd
  constructor: ->
    @unique = Math.random()

  afterMount: ->
    if window?
      console.log 'go'
      (window.adsbygoogle = window.adsbygoogle or []).push({})

  render: ({client, slot, format} = {}) =>
    console.log 'render'
    z '.z-adsense-ad', {
      key: "adsense-#{@unique}"
    },
      z 'ins',
        className: 'adsbygoogle'
        style:
          display: 'inline-block'
        attributes:
          'data-ad-client': client
          'data-ad-slot': slot
          # 'data-ad-format': format
