z = require 'zorium'
Rx = require 'rx-lite'

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
    id = requests.map ({route}) ->
      route.params.id
    addon = id.flatMapLatest (id) =>
      @model.addon.getById id

    @$head = new Head({
      @model
      requests
      serverData
      meta: addon.map (addon) =>
        lang = @model.addon.getLang(addon)
        {
          title: lang?.name
          description: lang?.description
        }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$addon = new Addon {@model, @router, serverData, addon}

    @state = z.state
      windowSize: @model.window.getSize()
      addon: addon

  renderHead: => @$head

  render: =>
    {windowSize, addon} = @state.getValue()

    lang = @model.addon.getLang(addon)

    z '.p-addon', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
        title: lang?.name
      }
      @$addon
