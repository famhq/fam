z = require 'zorium'
isUuid = require 'isuuid'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

Head = require '../../components/head'
GroupForum = require '../../components/threads'
AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
BottomBar = require '../../components/bottom_bar'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupForumPage
  isGroup: true

  constructor: ({@model, requests, @router, serverData}) ->
    group = requests.switchMap ({route}) =>
      if isUuid route.params.id
        @model.group.getById route.params.groupId or route.params.id
      else
        @model.group.getByKey route.params.groupId or route.params.id
    filter = new RxBehaviorSubject {
      sort: 'popular'
      filter: 'all'
    }

    @$head = new Head({
      @model
      requests
      serverData
      meta: {
        title: @model.l.get 'groupForumPage.title'
        description: @model.l.get 'groupForumPage.title'
      }
    })
    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$bottomBar = new BottomBar {@model, @router, requests}
    @$groupForum = new GroupForum {
      @model, @router, serverData, group, filter
    }

    @state = z.state
      windowSize: @model.window.getSize()

  renderHead: => @$head

  render: =>
    {windowSize} = @state.getValue()

    z '.p-group-home', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupForumPage.title'
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$groupForum
      @$bottomBar
