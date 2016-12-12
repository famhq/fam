module.exports = class ThreadMessage
  constructor: ({@auth}) -> null

  create: ({body, threadId}) =>
    @auth.call 'threadMessages.create', {body, threadId}, {invalidateAll: true}

  flag: (id) =>
    @auth.call 'threadMessages.flag', {id}
