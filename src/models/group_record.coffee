module.exports = class GroupRecord
  namespace: 'groupRecords'

  constructor: ({@auth}) -> null

  save: ({userId, groupRecordTypeId, value}) =>
    @auth.call "#{@namespace}.save", {userId, groupRecordTypeId, value}, {
      invalidateAll: true
    }

  bulkSave: (changes) =>
    @auth.call "#{@namespace}.bulkSave", {changes}, {
      invalidateAll: true
    }

  getAllByUserIdAndGroupId: ({userId, groupId}) =>
    @auth.stream "#{@namespace}.getAllByUserIdAndGroupId", {userId, groupId}
  #
  # getById: (id) =>
  #   @auth.stream "#{@namespace}.getById", {id}
  #
  #
  # getByGroupId: (groupId) =>
  #   @auth.stream "#{@namespace}.getByGroupId", {groupId}
