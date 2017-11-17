z = require 'zorium'
Chartist = if window? then require 'chartist' else null

if window?
  require './index.styl'

module.exports = class Graph
  type: 'Widget'

  constructor: ->
    @labels = []
    @series = []
    @options = {}

  afterMount: (@$$el) =>
    @chart = new Chartist.Line @$$el, {@labels, @series}, @options

  beforeUnmount: =>
    @chart.detach()

  render: ({@labels, @series, @options}) =>
    @chart?.update {@labels, @series}, @options
    z '.z-graph-widget'
