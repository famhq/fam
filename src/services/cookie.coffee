config = require '../config'

COOKIE_DURATION_MS = 365 * 24 * 3600 * 1000 # 1 year

class CookieService
  getCookieOpts: ->
    hostname = config.HOST.split(':')[0]

    path: '/'
    expires: new Date(Date.now() + COOKIE_DURATION_MS)
    # Set cookie for subdomains
    domain: '.' + hostname

module.exports = new CookieService()
