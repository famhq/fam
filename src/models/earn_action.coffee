module.exports = class EarnAction
  namespace: 'earnActions'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  incrementByGroupIdAndKey: (groupId, key, options = {}) =>
    {timestamp, successKey} = options
    @auth.call "#{@namespace}.incrementByGroupIdAndKey", {
      groupId, key, timestamp, successKey
    }, {invalidateAll: true}
