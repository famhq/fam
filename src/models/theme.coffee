config = require '../config'
colors = require '../colors'

###
TODO: either use js inline styles for all colors to do dark/light themes,
or do 2 builds of bundle.css with different variables. option 2 is less flexible
but requires less effort. option 1 will be needed regardless for theming groups
###

class Theme
  constructor: ->
    null

  getColor: (color) ->
    colors[color]

  getGroupColor: (group, color) ->
    null # TODO

module.exports = Theme
