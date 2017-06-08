z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
Star = require '../../components/star'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
DonateDialog = require '../../components/donate_dialog'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class StarPage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    username = requests.map ({route}) ->
      route.params.username
    star = username.flatMapLatest (username) ->
      model.star.getByUsername username

    @isDonateDialogVisible = new Rx.BehaviorSubject null

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'starPage.title'
        description: model.l.get 'starPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$star = new Star {model, @router, serverData, star, @isDonateDialogVisible}
    @$donateDialog = new DonateDialog {
      model, @router, isVisible: @isDonateDialogVisible, username
    }

    @state = z.state
      windowSize: model.window.getSize()
      isDonateDialogVisible: @isDonateDialogVisible

  renderHead: => @$head

  render: =>
    {windowSize, isDonateDialogVisible} = @state.getValue()

    z '.p-players-search', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: ''
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$star
      if isDonateDialogVisible
        @$donateDialog
