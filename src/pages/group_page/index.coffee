z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
GroupPage = require '../../components/group_page'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupPagePage
  constructor: ({@model, requests, @router, @overlay$, serverData, group}) ->
    # allow reset beforeUnmount so stale groupPage doesn't show when loading new
    @groupPage = new RxBehaviorSubject null

    groupAndRequests = RxObservable.combineLatest(
      group, requests, (vals...) -> vals
    )

    loadedGroupPage = groupAndRequests.switchMap ([group, {route}]) =>
      @model.groupPage.getByGroupIdAndKey group.id, route.params.key
    groupPage = RxObservable.merge @groupPage, loadedGroupPage

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupPage = new GroupPage {@model, @router, @overlay$, groupPage, group}

    @state = z.state
      windowSize: @model.window.getSize()
      groupPage: groupPage

  getMeta: =>
    @groupPage.map (groupPage) ->
      {
        title: groupPage?.data.title
        description: groupPage?.data.title
      }

  # beforeUnmount: =>
  #   @groupPage.next {}

  render: =>
    {windowSize, groupPage} = @state.getValue()

    z '.p-groupPage', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        style: 'primary'
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
        title: groupPage?.data.title
      }
      z @$groupPage
