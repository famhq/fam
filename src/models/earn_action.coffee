module.exports = class EarnAction
  namespace: 'earnActions'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId, {platform} = {}) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId, platform}

  incrementByGroupIdAndAction: (groupId, action, options = {}) =>
    {timestamp, successKey} = options
    @auth.call "#{@namespace}.incrementByGroupIdAndAction", {
      groupId, action, timestamp, successKey
    }, {invalidateAll: true}
