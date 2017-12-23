_every = require 'lodash/every'
_find = require 'lodash/find'

config = require '../config'

module.exports = class GroupRole
  namespace: 'groupRoles'

  constructor: ({@auth}) -> null

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}
