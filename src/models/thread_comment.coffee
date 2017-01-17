module.exports = class ThreadComment
  namespace: 'threadComments'
  constructor: ({@auth}) -> null

  create: ({body, threadId}) =>
    @auth.call "#{@namespace}.create", {body, threadId}, {invalidateAll: true}

  flag: (id) =>
    @auth.call "#{@namespace}.flag", {id}
