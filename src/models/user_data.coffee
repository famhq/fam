_some = require 'lodash/collection/some'

config = require '../config'

module.exports = class UserData
  constructor: ({@auth}) -> null

  getMe: ({embed} = {}) =>
    @auth.stream 'userData.getMe', {embed}

  getByUserId: (userId, {embed} = {}) =>
    @auth.stream 'userData.getByUserId', {userId, embed}

  updateMe: (diff) =>
    @auth.call 'userData.updateMe', _.pick(diff, ['presetAvatarId']), {
      invalidateAll: true
    }

  blockByUserId: (userId) =>
    @auth.call 'userData.blockByUserId', {userId}, {invalidateAll: true}

  unblockByUserId: (userId) =>
    @auth.call 'userData.unblockByUserId', {userId}, {invalidateAll: true}

  deleteConversationByUserId: (userId) =>
    @auth.call 'userData.deleteConversationByUserId', {userId}, {
      invalidateAll: true
    }

  followByUserId: (userId) =>
    @auth.call 'userData.followByUserId', {userId}, {invalidateAll: true}

  unfollowByUserId: (userId) =>
    @auth.call 'userData.unfollowByUserId', {userId}, {invalidateAll: true}
