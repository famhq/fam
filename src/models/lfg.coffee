module.exports = class DynamicImage
  namespace: 'lfg'

  constructor: ({@auth}) -> null

  getByGroupIdAndMe: (groupId) =>
    @auth.stream "#{@namespace}.getByGroupIdAndMe", {groupId}

  getAllByGroupIdAndHashtag: (groupId, hashtag) =>
    @auth.stream "#{@namespace}.getAllByGroupIdAndHashtag", {groupId, hashtag}

  deleteByGroupIdAndUserId: (groupId, userId) =>
    @auth.call "#{@namespace}.deleteByGroupIdAndUserId", {groupId, userId}, {
      invalidateAll: true
    }

  upsert: (lfg, diff) =>
    ga? 'send', 'event', 'lfg', 'upsert'

    @auth.call "#{@namespace}.upsert", lfg, {
      invalidateAll: true
    }
