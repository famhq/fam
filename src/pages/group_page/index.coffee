z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
GroupPage = require '../../components/group_page'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupPagePage
  hideDrawer: true

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
    @$buttonBack = new ButtonBack {@router}
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

  beforeUnmount: =>
    @groupPage.next {}

  render: =>
    {windowSize, groupPage} = @state.getValue()

    console.log 'gpppp'

    z '.p-groupPage', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        style: 'primary'
        $topLeftButton: z @$buttonBack, {
          color: colors.$header500Icon
        }
        title: groupPage?.data.title
      }
      z @$groupPage
