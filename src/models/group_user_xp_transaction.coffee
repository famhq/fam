module.exports = class GroupUser
  namespace: 'groupUserXpTransactions'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  incrementByGroupIdAndActionKey: (groupId, actionKey, options = {}) =>
    {timestamp, successKey} = options
    @auth.call "#{@namespace}.incrementByGroupIdAndActionKey", {
      groupId, actionKey, timestamp, successKey
    }, {invalidateAll: true}
