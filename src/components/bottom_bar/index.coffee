z = require 'zorium'

BottomBarOld = require '../bottom_bar_old'
BottomBarNew = require '../bottom_bar_new'

if window?
  require './index.styl'

module.exports = class BottomBar
  constructor: ({@model, @router, requests, group}) ->
    @$bottomBarOld = new BottomBarOld {@model, @router, requests}
    @$bottomBarNew = new BottomBarNew {@model, @router, requests, group}

  render: =>
    z '.z-bottom-bar-wrapper',
      if @model.experiment.get('newHome') is 'new'
        @$bottomBarNew
      else
        @$bottomBarOld
