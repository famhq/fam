z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_mapValues = require 'lodash/mapValues'
_isEmpty = require 'lodash/isEmpty'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Conversations = require '../../components/conversations'
Spinner = require '../../components/spinner'
Icon = require '../../components/icon'

if window?
  require './index.styl'

module.exports = class ConversationsPage
  constructor: ({@model, requests, @router, serverData}) ->
    isRefreshing = new Rx.BehaviorSubject false
    selectedProfileDialogUser = new Rx.BehaviorSubject null

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Private Messages'
        description: 'Private Messages'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$conversations = new Conversations {
      @model, @router, isRefreshing, selectedProfileDialogUser
    }
    @$profileDialog = new ProfileDialog {
      @model, @router, selectedProfileDialogUser
    }
    @$refreshingSpinner = new Spinner()

    @state = z.state
      isRefreshing: isRefreshing
      selectedProfileDialogUser: selectedProfileDialogUser

  renderHead: => @$head

  render: =>
    {isRefreshing, selectedProfileDialogUser} = @state.getValue()

    z '.p-conversations', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Private Messages'
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
        $topRightButton: if isRefreshing
          z @$refreshingSpinner,
            size: 20
            hasTopMargin: false
        else
          null
      }
      @$conversations

      if selectedProfileDialogUser
        z @$profileDialog
