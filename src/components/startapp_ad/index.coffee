# http://s2s.startappnetwork.com/s2s/1.3/htmlads?partner=856974125
# &token=778645132&segId=65437653&adw=320&adh=50&pub=1
# &prod=%20com.foobar.app&dip=50.36.36.1&
# ua=%20Mozilla%2F5.0%20(Linux%3B%20U%3B%20Android%204.0.3%3B%20de-ch%3B%20HTC%20Sensation%20Build%2FIML74K)%20AppleWebKit%2F534.30%20(KHTML%2C%20like%20Gecko)%20Version%2F4.0%20Mobile%20Safari%2F534.30&os=0
# &osVer=4.1&loc=44.000000%2C-2.000000&isp=42501&gen=0&age=25&maturity=1
# &test=true&advId=17e3ce3518af76e4&reqId=1245

module.exports = class StartappAd
  render: ({client, slot, format} = {}) =>
    # TODO
    # z '.z-adsense-ad', {
    #   key: "adsense-#{@unique}"
    # },
    #   z 'ins',
    #     className: 'adsbygoogle'
    #     style:
    #       display: 'inline-block'
    #     attributes:
    #       'data-ad-client': client
    #       'data-ad-slot': slot
    #       # 'data-ad-format': format
