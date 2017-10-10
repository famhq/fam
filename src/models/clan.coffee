MIN_TIME_UNTIL_NEXT_UPDATE_MS = 60 * 10 * 1000 # 10 min

module.exports = class Clan
  namespace: 'clan'

  constructor: ({@auth}) -> null

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  claimById: (id) =>
    @auth.call "#{@namespace}.claimById", {id}, {
      invalidateAll: true
    }

  updateById: (id, {clanPassword}) =>
    @auth.call "#{@namespace}.updateById", {id, clanPassword}, {
      invalidateAll: true
    }

  joinById: (id, {clanPassword}) =>
    @auth.call "#{@namespace}.joinById", {id, clanPassword}, {
      invalidateAll: true
    }

  canRefresh: (clan, hasUpdated) ->
    msSinceUpdate = new Date() - new Date(clan?.lastUpdateTime)
    canRefresh = not hasUpdated and
      msSinceUpdate >= MIN_TIME_UNTIL_NEXT_UPDATE_MS
