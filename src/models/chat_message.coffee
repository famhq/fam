Rx = require 'rx-lite'
uuid = require 'uuid'
_sortBy = require 'lodash/sortBy'

Changefeed = require './changefeed'
config = require '../config'

module.exports = class ChatMessage extends Changefeed
  namespace: 'chatMessages'

  getAllByConversationId: (conversationId) =>
    @stream "#{@namespace}.getAllByConversationId", {conversationId}, {
      initialSortFn: ((items) -> _sortBy items, 'time')
    }

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
