module.exports = class Clan
  namespace: 'clan'

  constructor: ({@auth}) -> null

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  # getTop: =>
  #   @auth.stream "#{@namespace}.getTop", {}
  #
  # getMeFollowing: =>
  #   @auth.stream "#{@namespace}.getMeFollowing", {}
  #
  claimById: (id) =>
    @auth.call "#{@namespace}.claimById", {id}

  createGroupById: (id, {groupName, clanPassword}) =>
    @auth.call "#{@namespace}.createGroupById", {id, groupName, clanPassword}, {
      invalidateAll: true
    }

  joinById: (id, {clanPassword}) =>
    @auth.call "#{@namespace}.joinById", {id, clanPassword}, {
      invalidateAll: true
    }
