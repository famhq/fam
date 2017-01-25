z = require 'zorium'

Head = require '../../components/head'
Splash = require '../../components/splash'
Spinner = require '../../components/spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class HomePage
  hideDrawer: true

  constructor: ({@model, @router, serverData}) ->
    @$head = new Head({
      @model
      serverData
      meta:
        canonical: "https://#{config.HOST}"
    })
    @$splash = new Splash {@model, @router}
    @$spinner = new Spinner()

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()

  afterMount: =>
    # TODO: replace with cookie so server-side rendering works
    if localStorage?['isMember']
      @router.go '/community'
    else
      @model.user.getMe().take(1).subscribe (me) =>
        if me?.isMember
          localStorage?['isMember'] = '1'
          @router.go '/community'
        else
          @router.go '/events'

  renderHead: => @$head

  render: =>
    {me, windowSize} = @state.getValue()

    z '.p-home', {
      style:
        height: "#{windowSize.height}px"
    },
      @$spinner
