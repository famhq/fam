z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'
_map = require 'lodash/collection/map'
_mapValues = require 'lodash/object/mapValues'
_isEmpty = require 'lodash/lang/isEmpty'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
Threads = require '../../components/threads'
Groups = require '../../components/groups'
Conversations = require '../../components/conversations'
Tabs = require '../../components/tabs'
Icon = require '../../components/icon'
Spinner = require '../../components/spinner'

if window?
  require './index.styl'

module.exports = class CommunityPage
  constructor: ({@model, requests, @router, serverData}) ->
    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: 'Community'
        description: 'Community'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model}
    @$threads = new Threads {@model, @router}
    @$groups = new Groups {@model, @router}
    @$conversations = new Conversations {@model, @router}
    @$tabs = new Tabs {@model}
    @$threadsIcon = new Icon()
    @$groupsIcon = new Icon()
    @$conversationsIcon = new Icon()

  renderHead: => @$head

  render: =>
    z '.p-community', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$appBar, {
        title: 'Community'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$tertiary900}
      }
      z @$tabs,
        isBarFixed: false
        tabs: [
          {
            $menuIcon:
              z @$threadsIcon,
                icon: 'chat'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Threads'
            $el: @$threads
          }
          {
            $menuIcon:
              z @$groupsIcon,
                icon: 'grid'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Groups'
            $el: @$groups
          }
          {
            $menuIcon:
              z @$conversationsIcon,
                icon: 'inbox'
                isTouchTarget: false
                color: colors.$white
            $menuText: 'Conversations'
            $el: @$conversations
          }
        ]
