class FormatService
  number: (number) ->
    # http://stackoverflow.com/a/2901298
    if number?
      Math.round(number).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
    else
      '...'

  rank: (rank) ->
    if rank
      "##{Math.round(rank).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')}"
    else '...'

  percentage: (value) ->
    "#{Math.round(value * 100)}%"

  countdown: (s) ->
    seconds = Math.floor(s % 60)
    if seconds < 10
      seconds = "0#{seconds}"
    days = Math.floor(s / 86400)
    minutes = Math.floor(s / 60) % 60
    if minutes < 10
      minutes = "0#{minutes}"
    if days > 2
      hours = Math.floor(s / 3600) % 24
      if hours < 10
        hours = "0#{hours}"
      prettyTimer = "#{days} days"
    else
      hours = Math.floor(s / 3600)
      if hours < 10
        hours = "0#{hours}"
      prettyTimer = "#{hours}:#{minutes}:#{seconds}"

    return prettyTimer

module.exports = new FormatService()
