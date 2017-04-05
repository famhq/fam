z = require 'zorium'

Head = require '../../components/head'
ForumSignature = require '../../components/forum_signature'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class ForumSignaturePage
  hideDrawer: true

  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Forum Signature'
        description: 'Forum Signature'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$forumSignature = new ForumSignature {model, @router, serverData}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-forum-signature', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: 'Forum Signature'
        style: 'secondary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {color: colors.$primary500}
      }
      @$forumSignature
