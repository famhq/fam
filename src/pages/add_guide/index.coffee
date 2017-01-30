z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
EditGuide = require '../../components/edit_guide'
AppBar = require '../../components/app_bar'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class AddGuidePage
  hideDrawer: true
  isPrivate: true

  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Add Guide'
        description: 'Add Guide'
      }
    })
    @$appBar = new AppBar {@model}
    @$closeIcon = new Icon()
    @$editGuide = new EditGuide {
      @model
      @router
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-add-guide', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Add Guide'
        bgColor: colors.$tertiary700
        isFlat: true
        $topLeftButton: z @$closeIcon, {
          icon: 'close'
          isAlignedLeft: true
          color: colors.$primary500
          onclick: =>
            @router.back()
        }
      }
      z @$editGuide, {isNewGuide: true}
