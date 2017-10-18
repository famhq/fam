MIN_TIME_UNTIL_NEXT_UPDATE_MS = 60 * 10 * 1000 # 10 min

module.exports = class Player
  namespace: 'players'

  constructor: ({@auth}) -> null

  getByUserIdAndGameId: (userId, gameId, {embed} = {}) =>
    @auth.stream "#{@namespace}.getByUserIdAndGameId", {userId, gameId, embed}

  getByPlayerIdAndGameId: (playerId, gameId, {embed, refreshIfStale} = {}) =>
    @auth.stream "#{@namespace}.getByPlayerIdAndGameId", {
      playerId, gameId, embed, refreshIfStale
    }

  getIsAutoRefreshByPlayerIdAndGameId: (playerId, gameId) =>
    @auth.stream "#{@namespace}.getIsAutoRefreshByPlayerIdAndGameId", {
      playerId, gameId
    }

  setAutoRefreshByPlayerIdAndGameId: (playerId, gameId) =>
    @auth.call "#{@namespace}.setAutoRefreshByGameId", {gameId}, {
      invalidateSingle:
        body:
          gameId: gameId
          playerId: playerId
        path: "#{@namespace}.getIsAutoRefreshByPlayerIdAndGameId"
    }

  getTop: =>
    @auth.stream "#{@namespace}.getTop", {}

  getMeFollowing: =>
    @auth.stream "#{@namespace}.getMeFollowing", {}

  search: (playerId) =>
    @auth.call "#{@namespace}.search", {playerId}

  # verifyMe: ({gold, lo}) =>
  #   @auth.call "#{@namespace}.verifyMe", {gold, lo}, {invalidateAll: true}

  canRefresh: (player, hasUpdated, isRefreshing) ->
    lastUpdate = player?.lastUpdateTime

    msSinceUpdate = new Date() - new Date(lastUpdate)
    canRefresh = not hasUpdated and
                  not isRefreshing and (not player?.lastQueuedTime or
                  msSinceUpdate >= MIN_TIME_UNTIL_NEXT_UPDATE_MS)
