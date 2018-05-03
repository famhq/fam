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

  getMeta: =>
    meta:
      title: @model.l.get 'newTradePage.title'

  render: =>
    {windowSize, group} = @state.getValue()

    z '.z-recruiting', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'general.recruiting'
        $topLeftButton: z @$buttonMenu, {color: colors.$header500Icon}
      }
      @$threads

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$primary500Text
          }
          onclick: =>
            @model.group.goPath group, 'groupNewThreadWithCategory', {
              @router, replacements: {category: 'clan'}
            }
