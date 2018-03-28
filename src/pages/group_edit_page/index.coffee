z = require 'zorium'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

GroupNewPage = require '../../components/group_new_page'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEditPagePage
  isGroup: true

  constructor: ({@model, requests, @router, serverData, group}) ->
    groupAndRequests = RxObservable.combineLatest(
      group, requests, (vals...) -> vals
    )
    page = groupAndRequests.switchMap ([group, {route}]) =>
      @model.groupPage.getByGroupIdAndKey group.id, route.params.key

    @$groupEditPage = new GroupNewPage {
      @model
      @router
      group
      page
    }

    @state = z.state
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {
      title: @model.l.get 'groupEditPagePage.title'
    }

  render: =>
    {group, windowSize, titleValue, bodyValue} = @state.getValue()

    z '.p-group-new-page', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$groupEditPage
