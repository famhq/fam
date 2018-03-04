MIN_TIME_UNTIL_NEXT_UPDATE_MS = 60 * 10 * 1000 # 10 min

module.exports = class Player
  namespace: 'players'

  constructor: ({@auth}) -> null

  getByUserIdAndGameKey: (userId, gameKey, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserIdAndGameKey", {userId, gameKey, embed}

  getByPlayerIdAndGameKey: (playerId, gameKey, {embed, refreshIfStale} = {}) =>
    @auth.stream "#{@namespace}.getByPlayerIdAndGameKey", {
      playerId, gameKey, embed, refreshIfStale
    }

  getIsAutoRefreshByPlayerIdAndGameKey: (playerId, gameKey) =>
    @auth.stream "#{@namespace}.getIsAutoRefreshByPlayerIdAndGameKey", {
      playerId, gameKey
    }

  setAutoRefreshByPlayerIdAndGameKey: (playerId, gameKey) =>
    @auth.call "#{@namespace}.setAutoRefreshByGameKey", {gameKey}, {
      invalidateSingle:
        body:
          gameKey: gameKey
          playerId: playerId
        path: "#{@namespace}.getIsAutoRefreshByPlayerIdAndGameKey"
    }

  getTop: =>
    @auth.stream "#{@namespace}.getTop", {}

  getMeFollowing: =>
    @auth.stream "#{@namespace}.getMeFollowing", {}

  getAllByMe: =>
    @auth.stream "#{@namespace}.getAllByMe", {}

  search: (playerId) =>
    @auth.call "#{@namespace}.search", {playerId}

  getVerifyDeckId: =>
    @auth.stream "#{@namespace}.getVerifyDeckId", {}

  verifyMe: =>
    @auth.call "#{@namespace}.verifyMe", {}, {invalidateAll: true}

  unlinkByMeAndGameKey: ({gameKey}) =>
    @auth.call "#{@namespace}.unlinkByMeAndGameKey", {gameKey}, {
      invalidateAll: true
    }

  canRefresh: (player, hasUpdated, isRefreshing) ->
    lastUpdate = player?.lastUpdateTime

    msSinceUpdate = new Date() - new Date(lastUpdate)
    canRefresh = not hasUpdated and
                  not isRefreshing and (not player?.lastQueuedTime or
                  msSinceUpdate >= MIN_TIME_UNTIL_NEXT_UPDATE_MS)
