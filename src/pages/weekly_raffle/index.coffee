z = require 'zorium'

WeeklyRaffle = require '../../components/weekly_raffle'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class WeeklyRafflePage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$weeklyRaffle = new WeeklyRaffle {@model, @router, serverData, group}

    @state = z.state
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'weeklyRafflePage.title'
    }

  render: =>
    {windowSize} = @state.getValue()

    z '.p-weekly-raffle', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'weeklyRafflePage.title'
        style: 'primary'
        $topLeftButton: z @$buttonBack, {color: colors.$header500Icon}
      }
      @$weeklyRaffle
