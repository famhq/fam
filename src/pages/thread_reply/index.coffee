z = require 'zorium'

Head = require '../../components/head'
ThreadReply = require '../../components/thread_reply'

if window?
  require './index.styl'

module.exports = class ThreadReplyPage
  constructor: ({model, requests, @router, serverData}) ->
    threadId = requests.map ({route}) ->
      route.params.id

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Reply to Thread'
        description: 'Reply to Thread'
      }
    })
    @$threadReply = new ThreadReply {model, @router, threadId}

    @state = z.state
      windowSize: model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-thread-reply', {
      style:
        height: "#{windowSize.height}px"
    },
      @$threadReply
