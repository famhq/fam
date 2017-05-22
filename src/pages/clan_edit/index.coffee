z = require 'zorium'
Rx = require 'rx-lite'

Head = require '../../components/head'
ClanEdit = require '../../components/clan_edit'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ClanEditPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    clan = requests.flatMapLatest ({route}) =>
      if route.params.id
        @model.clan.getById route.params.id
      else
        Rx.Observable.just null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'clanEditPage.title'
        description: @model.l.get 'clanEditPage.title'
      }
    })
    @$clanEdit = new ClanEdit {
      @model
      @router
      clan
    }

    @state = z.state
      windowSize: @model.window.getSize()
      clan: clan

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-clan-edit', {
      style:
        height: "#{windowSize.height}px"
    },
      @$clanEdit
