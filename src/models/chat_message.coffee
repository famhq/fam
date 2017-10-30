uuid = require 'uuid'
_sortBy = require 'lodash/sortBy'
_merge = require 'lodash/merge'
_cloneDeep = require 'lodash/cloneDeep'
_defaults = require 'lodash/defaults'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject

config = require '../config'

CHAT_MESSAGES_LIMIT = 50

module.exports = class ChatMessage
  namespace: 'chatMessages'

  constructor: ({@auth, @proxy, @exoid}) ->
    @clientChangesStream = {}

  create: (diff, localDiff) =>
    clientId = uuid.v4()

    @clientChangesStream[diff.conversationId]?.next(
      _merge diff, {clientId}, localDiff
    )
    ga? 'send', 'event', 'social_interaction', 'chat_message', "#{diff.type}"

    @auth.call "#{@namespace}.create", _merge diff, {clientId}
    .catch (err) ->
      console.log 'err', err

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
    }

  getAllByConversationId: (conversationId) =>
    # buffer 0 so future streams don't try to add the client changes
    # (causes smooth scroll to bottom in conversations)
    @clientChangesStream[conversationId] ?= new RxReplaySubject(0)

    options = {
      initialSortFn: ((items) -> _sortBy items, 'time')
      limit: CHAT_MESSAGES_LIMIT
      clientChangesStream: @clientChangesStream[conversationId]
      isStreamed: true
    }

    @auth.stream "#{@namespace}.getAllByConversationId", {
      conversationId
    }, options

  uploadImage: (file) =>
    formData = new FormData()
    formData.append 'file', file, file.name

    @proxy config.API_URL + '/upload', {
      method: 'post'
      qs:
        path: "#{@namespace}.uploadImage"
      body: formData
    }
    .then (response) =>
      @exoid.invalidateAll()
      response
