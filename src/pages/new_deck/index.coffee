z = require 'zorium'
Rx = require 'rx-lite'
Button = require 'zorium-paper/button'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
NewDeck = require '../../components/new_deck'

if window?
  require './index.styl'

module.exports = class NewDeckPage
  constructor: ({model, requests, @router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'New Deck'
        description: 'New Deck'
      }
    })
    @$newDeck = new NewDeck {model, @router}

  renderHead: => @$head

  render: =>
    z '.p-new-thread', {
      style:
        height: "#{window?.innerHeight}px"
    },
      @$newDeck
