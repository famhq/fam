z = require 'zorium'
Rx = require 'rx-lite'
_camelCase = require 'lodash/camelCase'

Head = require '../../components/head'
Addon = require '../../components/addon'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class AddonPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    key = requests.map ({route}) ->
      route.params.key
    addon = key.flatMapLatest (key) =>
      @model.addon.getByKey _camelCase key
    testUrl = requests.map ({req}) ->
      req.query.testUrl

    @$head = new Head({
      @model
      requests
      serverData
      meta: addon.map (addon) =>
        if addon
          {
            title: @model.l.get "#{addon.key}.title", {file: 'addons'}
            description: addon.metaDescription or
              @model.l.get "#{addon.key}.description", {file: 'addons'}
          }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$addon = new Addon {@model, @router, serverData, addon, testUrl}

    @state = z.state
      windowSize: @model.window.getSize()
      addon: addon

  renderHead: => @$head

  render: =>
    {windowSize, addon} = @state.getValue()

    z '.p-addon', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {
          color: colors.$primary500
          onclick: =>
            @router.go '/addons'
        }
        title: @model.l.get "#{addon?.key}.title", {file: 'addons'}
      }
      @$addon
