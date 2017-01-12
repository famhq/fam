module.exports = class GroupRecordType
  namespace: 'groupRecordTypes'

  constructor: ({@auth}) -> null

  create: ({name, timeScale, groupId}) =>
    @auth.call "#{@namespace}.create", {name, timeScale, groupId}, {
      invalidateAll: true
    }

  getAllByGroupId: (groupId, {embed}) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId, embed}

  deleteById: (id) =>
    @auth.call "#{@namespace}.deleteById", {id}, {
      invalidateAll: true
    }
  #
  # getById: (id) =>
  #   @auth.stream "#{@namespace}.getById", {id}
  #
  #
  # getByGroupId: (groupId) =>
  #   @auth.stream "#{@namespace}.getByGroupId", {groupId}
