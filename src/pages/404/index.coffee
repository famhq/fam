z = require 'zorium'

config = require '../../config'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Head = require '../../components/head'
PrimaryButton = require '../../components/primary_button'
colors = require '../../colors'

module.exports = class FourOhFourPage
  constructor: ({@model, @router, requests, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta:
        title: 'Starfire - 404'
        description: 'Page not found'
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$homeButton = new PrimaryButton()

  renderHead: =>
    @$head

  render: =>
    z '.p-404',
      z @$appBar, {
        title: @model.l.get '404Page.text'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      z '.content', {
        style:
          padding: '16px'
      },
        @model.l.get '404Page.text'
        z 'br'
        '(╯°□°)╯︵ ┻━┻'
        z @$homeButton,
          text: @model.l.get 'stepBar.back'
          onclick: =>
            @router.goPath '/'
