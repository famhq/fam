_filter = require 'lodash/filter'
_map = require 'lodash/map'
_find = require 'lodash/find'
_defaults = require 'lodash/defaults'
_isEmpty = require 'lodash/isEmpty'

colors = require '../colors'
config = require '../config'

class SpecialOfferService
  constructor: ->
    @cachedUsageStats = {}

  getUsageStats: ({model, packageNames}) =>
    key = if packageNames then packageNames.join('|') else ''
    if @cachedUsageStats[key]
      Promise.resolve @cachedUsageStats[key]
    else
      model.portal.callWithError 'usageStats.getStats', {packageNames}
      .then (stats) ->
        # legacy < 1.0.16
        if typeof stats is 'string'
          usageStats = try
            JSON.parse stats
          if _isEmpty usageStats
            throw new Error 'no perms'
          usageStats
        else
          stats
      .then (stats) =>
        @cachedUsageStats[key] = stats
        stats

  clearUsageStatsCache: =>
    @cachedUsageStats = {}

  embedStatsAndFilter: ({offers, usageStats, model, deviceId}) ->
    offers = _filter _map offers, (offer) ->
      stats = _find usageStats, {PackageName: offer.androidPackage}

      isInstalled = Boolean stats
      wasPreviouslyInstalled = isInstalled and not offer.transaction

      countryData = offer.meCountryData or {}
      data = _defaults countryData, offer.defaultData

      {days, dailyPayout, installPayout,
        minutesPerDay} = data
      totalPayout = installPayout + days * dailyPayout
      unless totalPayout
        return

      isCompleted = offer.transaction?.status is 'completed'
      if (wasPreviouslyInstalled or isCompleted) #and config.ENV isnt config.ENVS.DEV
        return
      else if isInstalled and offer.transaction?.status is 'clicked'
        # give fire for installing
        model.specialOffer.giveInstallReward {
          offer, deviceId, usageStats: stats
        }
      else if isInstalled and offer.transaction?.status is 'installed'
        minutesPlayed = Math.floor(
          offer.androidPackageStats?.TotalTimeInForeground / (60 * 1000)
        )
        data = _defaults offer.meCountryData, offer.defaultData
        hasCompletedDailyMinutes = minutesPlayed > data.minutesPerDay
        if hasCompletedDailyMinutes
          model.specialOffer.giveDailyReward {
            offer, deviceId, usageStats: stats
          }
      else
        console.log 'none', isInstalled, offer.transaction

      _defaults {
        androidPackageStats: stats
      }, offer


module.exports = new SpecialOfferService()
