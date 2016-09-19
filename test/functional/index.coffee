_ = require 'lodash'
b = require 'b-assert'
request = require 'clay-request'
Promise = require 'bluebird'
revision = require 'git-rev'
url = require 'url'

config = require '../../src/config'
Client = require './client'

# Wait for server to be up
before ->
  count = 0
  check = ->
    request config.SELENIUM_TARGET_URL, {timeout: 200}
    .catch (err) ->
      count += 1
      if count > 10
        throw new Error "Could not connect to #{config.SELENIUM_TARGET_URL}"
      Promise.delay 100
      .then check

  # race condition for server-reload
  Promise.delay 1000
  .then check
  .then ->
    Client.init()

after ->
  new Promise (resolve) ->
    revision.short resolve
  .then (build) =>
    Client
      .sauceJobStatus
        passed: _.every this.test.parent.tests, {state: 'passed'}
        public: 'public'
        build: build
      .end()

describe 'functional tests', ->
  client = null

  before ->
    client = Client
      .url config.SELENIUM_TARGET_URL
      .pause(100) # don't question it

  it 'checks title', ->
    client
      .getTitle()
      .then (title) ->
        b title, 'Zorium Seed'

  it 'checks root node', ->
    client
      .isVisible '#zorium-root'
      .then (isVisible) ->
        b isVisible, true

  it 'navigates on button click', ->
    client
      .click '.p-home .z-hello-world .t-click-me'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/red'
      .waitForVisible '.p-red .z-red .t-click-me'
      .click '.p-red .z-red .t-click-me'
      .url()
      .then ({value}) ->
        b url.parse(value).pathname, '/'
