module.exports = class Videos
  namespace: 'videos'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId, {sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId, sort, filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  logViewById: (id) =>
    @auth.call "#{@namespace}.logViewById", {id}#, {invalidateAll: true}
