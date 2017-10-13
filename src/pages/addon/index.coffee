z = require 'zorium'
Rx = require 'rxjs'
_camelCase = require 'lodash/camelCase'

Head = require '../../components/head'
Addon = require '../../components/addon'
AppBar = require '../../components/app_bar'
ButtonBack = require '../../components/button_back'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class AddonPage
  hideDrawer: true

  constructor: ({@model, requests, @router, serverData}) ->
    key = requests.map ({route}) ->
      route.params.key
    addon = key.switchMap (key) =>
      @model.addon.getByKey _camelCase key
    testUrl = requests.map ({req}) ->
      req.query.testUrl

    @$head = new Head({
      @model
      requests
      serverData
      meta: addon.map (addon) =>
        if addon
          {
            title: @model.l.get "#{addon.key}.title", {file: 'addons'}
            description: addon.metaDescription or
              @model.l.get "#{addon.key}.description", {file: 'addons'}
          }
    })
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$addon = new Addon {@model, @router, serverData, addon, testUrl}
    @$thumbsUpIcon = new Icon()
    @$thumbsDownIcon = new Icon()

    @state = z.state
      windowSize: @model.window.getSize()
      me: @model.user.getMe()
      addon: addon

  renderHead: => @$head

  render: =>
    {windowSize, addon, me} = @state.getValue()

    hasVotedUp = addon?.myVote?.vote is 1
    hasVotedDown = addon?.myVote?.vote is -1

    z '.p-addon', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        style: 'primary'
        isFlat: true
        $topLeftButton: z @$buttonBack, {
          color: colors.$primary500
          onclick: =>
            @router.go '/addons'
        }
        $topRightButton:
          z '.p-addon_vote',
            z @$thumbsUpIcon,
              icon: 'thumb-up'
              color: if hasVotedUp \
                     then colors.$primary500
                     else colors.$white
              size: '18px'
              onclick: =>
                unless hasVotedUp
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @model.addon.voteById addon.id, {vote: 'up'}
            z @$thumbsDownIcon,
              icon: 'thumb-down'
              color: if hasVotedDown \
                     then colors.$primary500
                     else colors.$white
              size: '18px'
              onclick: =>
                unless hasVotedDown
                  @model.signInDialog.openIfGuest me
                  .then =>
                    @model.addon.voteById addon.id, {vote: 'down'}
        title: @model.l.get "#{addon?.key}.title", {file: 'addons'}
      }
      @$addon
