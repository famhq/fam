Rx = require 'rx-lite'
uuid = require 'uuid'
_sortBy = require 'lodash/sortBy'
Changefeed = require './changefeed'

module.exports = class ChatMessage extends Changefeed
  namespace: 'chatMessages'
  # flag: (id) =>
  #   @auth.call 'chatMessages.flag', {id}

  getAllByConversationId: (conversationId) =>
    @stream(
      @auth.stream("#{@namespace}.getAllByConversationId", {conversationId})
      {initialSortFn: ((items) -> _sortBy items, 'time')}
    )
