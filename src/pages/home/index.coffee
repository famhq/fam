z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
Splash = require '../../components/splash'
Spinner = require '../../components/spinner'

if window?
  require './index.styl'

module.exports = class HomePage
  hideDrawer: true
  isPublic: true

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

  afterMount: =>
    @model.user.getMe().take(1).subscribe (me) =>
      if me?.isMember
        @router.go '/threads'

  renderHead: => @$head

  render: =>
    {me} = @state.getValue()

    z '.p-home', {
      style:
        height: "#{window?.innerHeight}px"
    },
      if me?.isMember or not me
        @$spinner
      else if me
        @$splash
