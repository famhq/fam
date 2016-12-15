module.exports = class ChatMessage
  constructor: ({@auth}) -> null

  create: ({body, conversationId}) =>
    @auth.call 'chatMessages.create', {
      body, conversationId
    }

  # flag: (id) =>
  #   @auth.call 'chatMessages.flag', {id}

  getAllByConversationId: (conversationId, {ignoreCache} = {}) =>
    @auth.stream 'chatMessages.getAllByConversationId', {conversationId}, {
      ignoreCache
    }
