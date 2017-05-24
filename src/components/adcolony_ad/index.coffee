z = require 'zorium'
request = require 'clay-request'

PARTNER_ID = 'cf573dc449ad1281' # FIXME: move to kaiser
SITE_ID = '206778'
module.exports = class AdColonyAd
  constructor: ->
    @unique = Math.random()

    allowedTagsRegex = RegExp(
      '<(?:img|a){1}.*/?>(?:(?:.|\n)*</(?:img|a|br){1}>)?', 'g'
    )

    if window?
      userAgent = encodeURIComponent navigator.userAgent
      adUrl = 'https://ads.admarvel.com/fam/postGetAd.php?partner_id=' +
        "#{PARTNER_ID}&site_id=#{SITE_ID}&timeout=30000&language=php" +
        "&format=wap&phone_headers=HTTP_USER_AGENT=%3E#{userAgent}"

    @state = z.state {
      adHtml: if window?
        Rx.Observable.fromPromise request adUrl
        .map (html) ->
          # strip anything we don't want
          html = html.replace /<[^\/?a|img\b]/g, ''
          html.replace '<a', '<a target="_SYSTEM" '
    }


  render: =>
    {adHtml} = @state.getValue()

    z '.z-adcolony-ad', {
      key: "adcolony-#{@unique}"
      innerHTML: adHtml
    }
