module.exports = class UserFollower
  namespace: 'userFollowers'

  constructor: ({@auth}) -> null

  getAllFollowingIds: =>
    @auth.stream "#{@namespace}.getAllFollowingIds", {}

  followByUserId: (userId) =>
    @auth.call "#{@namespace}.followByUserId", {userId}, {invalidateAll: true}

  unfollowByUserId: (userId) =>
    @auth.call "#{@namespace}.unfollowByUserId", {userId}, {invalidateAll: true}

  isFollowing: (followingIds, userId) ->
    followingIds.indexOf(userId) isnt -1
