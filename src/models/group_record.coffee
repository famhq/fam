module.exports = class GroupRecord
  namespace: 'groupRecords'

  constructor: ({@auth}) -> null

  getAllByGroupIdAndRecordTypeKey: (groupId, recordTypeKey) =>
    @auth.stream "#{@namespace}.getAllByGroupIdAndRecordTypeKey", {
      groupId, recordTypeKey
    }
