_find = require 'lodash/find'

module.exports = class Addon
  namespace: 'addons'

  constructor: ({@auth, @l}) -> null

  getLang: (addon) =>
    addon?.lang[@l.getLanguageStr()] or addon?.lang['en']

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getByKey: (key) =>
    @auth.stream "#{@namespace}.getByKey", {key}

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  voteById: (id, {vote}) =>
    @auth.call "#{@namespace}.voteById", {id, vote}, {invalidateAll: true}
