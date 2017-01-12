Rx = require 'rx-lite'
uuid = require 'uuid'
_merge = require 'lodash/merge'
_defaults = require 'lodash/defaults'

module.exports = class Changefeed
  constructor: ({@auth, @proxy, @exoid}) ->
    # buffer 0 so future streams don't try to add the client changes
    # (causes smooth scroll to bottom in conversations)
    @clientChangesStream = new Rx.ReplaySubject(0)

  create: (diff, localDiff) =>
    clientId = uuid.v4()

    @clientChangesStream.onNext _merge diff, {clientId}, localDiff

    @auth.call "#{@namespace}.create", _merge diff, {clientId}
    .catch (err) ->
      console.log 'err'

  stream: (path, body, options) =>
    @auth.stream path, body, _defaults({@clientChangesStream}, options)
