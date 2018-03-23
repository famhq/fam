module.exports = class DynamicImage
  namespace: 'lfg'

  constructor: ({@auth}) -> null

  getByGroupIdAndMe: (groupId) =>
    @auth.stream "#{@namespace}.getByGroupIdAndMe", {groupId}

  getAllByGroupId: (groupId) =>
    @auth.stream "#{@namespace}.getAllByGroupId", {groupId}

  deleteByGroupIdAndUserId: (groupId, userId) =>
    @auth.call "#{@namespace}.deleteByGroupIdAndUserId", {groupId, userId}, {
      invalidateAll: true
    }

  upsert: (lfg, diff) =>
    @auth.call "#{@namespace}.upsert", lfg, {
      invalidateAll: true
    }
