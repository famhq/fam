module.exports = class EarnAction
  namespace: 'earnActions'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  incrementByGroupIdAndAction: (groupId, action, options = {}) =>
    {timestamp, successKey} = options
    @auth.call "#{@namespace}.incrementByGroupIdAndAction", {
      groupId, action, timestamp, successKey
    }, {invalidateAll: true}
