_pick = require 'lodash/pick'

module.exports = class UserData
  namespace: 'userData'

  constructor: ({@auth}) -> null

  getMe: ({embed} = {}) =>
    @auth.stream "#{@namespace}.getMe", {embed}

  getMeFollowers: =>
    @auth.stream "#{@namespace}.getMeFollowers"

  getByUserId: (userId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserId", {userId, embed}

  updateMe: (diff) =>
    keys = ['presetAvatarId', 'unreadGroupInvites']
    @auth.call "#{@namespace}.updateMe", _pick(diff, keys), {
      invalidateAll: true
    }

  setAddress: (address) =>
    @auth.call "#{@namespace}.setAddress", address, {invalidateAll: true}

  setClashRoyaleDeckId: (clashRoyaleDeckId) =>
    @auth.call "#{@namespace}.setClashRoyaleDeckId", {clashRoyaleDeckId}, {
      invalidateAll: true
    }

  blockByUserId: (userId) =>
    @auth.call "#{@namespace}.blockByUserId", {userId}, {invalidateAll: true}

  unblockByUserId: (userId) =>
    @auth.call "#{@namespace}.unblockByUserId", {userId}, {invalidateAll: true}

  deleteConversationByUserId: (userId) =>
    @auth.call "#{@namespace}.deleteConversationByUserId", {userId}, {
      invalidateAll: true
    }
