webdriverio = require 'webdriverio'
SauceLabs = require 'saucelabs'

config = require '../../src/config'

client = if config.REMOTE_SELENIUM
  webdriverio.remote
    desiredCapabilities:
      browserName: config.SELENIUM_BROWSER
      name: 'Zorium Seed'
      tags: ['zorium_seed']
    host: 'ondemand.saucelabs.com'
    port: 80
    user: config.SAUCE_USERNAME
    key: config.SAUCE_ACCESS_KEY
else
  webdriverio.remote
    desiredCapabilities:
      browserName: config.SELENIUM_BROWSER

client.addCommand 'sauceJobStatus', (status) ->
  unless config.REMOTE_SELENIUM
    return

  sessionID = client.requestHandler.sessionID
  sauceAccount = new SauceLabs
    username: config.SAUCE_USERNAME
    password: config.SAUCE_ACCESS_KEY

  new Promise (resolve, reject) ->
    sauceAccount.updateJob sessionID, status, (err) ->
      if err
        reject err
      else
        resolve null

module.exports = client
