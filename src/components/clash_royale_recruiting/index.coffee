z = require 'zorium'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxMap = require 'rxjs/add/operator/map'

Threads = require '../threads'
Icon = require '../icon'
Fab = require '../fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Recruiting
  constructor: ({@model, @router, group}) ->

    @$fab = new Fab()
    @$addIcon = new Icon()

    filter = new RxBehaviorSubject {sort: 'new', filter: 'clan'}
    @$threads = new Threads {@model, @router, filter, group}

    @state = z.state
      windowSize: @model.window.getSize()
      group: group

  renderHead: => @$head

  render: =>
    {windowSize, group} = @state.getValue()

    z '.z-recruiting', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.recruiting'
        isFlat: true
        $topLeftButton: z @$buttonMenu, {color: colors.$primary500}
      }
      @$threads

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$white
          }
          onclick: =>
            @router.go 'groupNewThreadWithCategory', {
              groupId: group.key or group.id, category: 'clan'
            }
