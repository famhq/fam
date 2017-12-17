module.exports = class ThreadComment
  namespace: 'threadComments'
  constructor: ({@auth}) -> null

  create: ({body, threadId, parentId, parentType}) =>
    ga? 'send', 'event', 'social_interaction', 'thread_comment', "#{parentId}"
    @auth.call "#{@namespace}.create", {body, threadId, parentId, parentType}, {
      invalidateAll: true
    }

  flag: (id) =>
    @auth.call "#{@namespace}.flag", {id}

  getAllByThreadId: (threadId, {sort, skip, limit} = {}) =>
    @auth.stream "#{@namespace}.getAllByThreadId", {threadId, sort, skip, limit}
