z = require 'zorium'
_defaults = require 'lodash/defaults'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switch'
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Compose = require '../compose'
ClanBadge = require '../clan_badge'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
Spinner = require '../spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupNewPage
  constructor: ({@model, @router, category, id, group}) ->
    @titleValueStreams ?= new RxReplaySubject 1
    @bodyValueStreams ?= new RxReplaySubject 1
    @keyValueStreams ?= new RxReplaySubject 1

    @resetValueStreams()

    @$spinner = new Spinner()

    @$compose = new Compose {
      @model
      @router
      @titleValueStreams
      @bodyValueStreams
    }

    @state = z.state
      me: @model.user.getMe()
      titleValue: @titleValueStreams.switch()
      bodyValue: @bodyValueStreams.switch()
      keyValue: @keyValueStreams.switch()
      language: @model.l.getLanguage()
      group: group

  beforeUnmount: =>
    @resetValueStreams()

  resetValueStreams: =>
    if @page
      @titleValueStreams.next @page.map (page) -> page?.data?.title or ''
      @bodyValueStreams.next @page.map (page) -> page?.data?.body or ''
      @keyValueStreams.next @page.map (page) -> page?.key or ''
    else
      @titleValueStreams.next new RxBehaviorSubject ''
      @bodyValueStreams.next new RxBehaviorSubject ''
      @keyValueStreams.next new RxBehaviorSubject ''

  setKey: (e) =>
    @keyValueStreams.next RxObservable.of e.target.value
    
  render: =>
    {me, titleValue, bodyValue, keyValue, page,
      language, group} = @state.getValue()

    data = {}

    z '.z-new-page',
      z @$compose,
        $head:
          z '.z-new-page_compose-head',
            z '.url',
              "https://#{config.HOST}/g/#{group?.key or group?.id}/page/"
              z 'input.key',
                type: 'text'
                onkeyup: @setKey
                onchange: @setKey
                # bug where cursor goes to end w/ just value
                defaultValue: keyValue or ''
                placeholder: @model.l.get 'groupNewPage.keyHintText'

            z '.divider'
        onDone: (e) =>
          newPage = {
            key: keyValue
            title: titleValue
            body: bodyValue
            groupId: group.id
          }
          @model.groupPage.upsert newPage
          .then (newPage) =>
            @resetValueStreams()
            @router.goPath(
              @model.page.getPath(
                _defaults(newPage, page), group, @router
              )
              {reset: true}
            )
