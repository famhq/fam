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

module.exports = class NewThread
  constructor: ({@model, @router, category, @thread, id, group}) ->
    @titleValueStreams ?= new RxReplaySubject 1
    @bodyValueStreams ?= new RxReplaySubject 1
    @attachmentsValueStreams ?= new RxReplaySubject 1
    @attachmentsValueStreams.next new RxBehaviorSubject []
    category ?= RxObservable.of null

    @resetValueStreams()

    @$clanBadge = new ClanBadge()
    @$spinner = new Spinner()

    @$compose = new Compose {
      @model
      @router
      @titleValueStreams
      @bodyValueStreams
      @attachmentsValueStreams
    }

    categoryAndMe = RxObservable.combineLatest(
      category
      @model.user.getMe()
      (vals...) -> vals
    )
    categoryAndId = RxObservable.combineLatest(
      category
      id or RxObservable.of null
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      titleValue: @titleValueStreams.switch()
      bodyValue: @bodyValueStreams.switch()
      attachmentsValue: @attachmentsValueStreams.switch()
      language: @model.l.getLanguage()
      category: category
      thread: @thread
      group: group
      attachedContent: categoryAndId.switchMap ([category, id]) =>
        if category is 'deckGuide'
          [deckId, playerId] = decodeURIComponent(id).split ':'
          @model.clashRoyalePlayerDeck.getByDeckIdAndPlayerId deckId, playerId
          .map (playerDeck) =>
            {
              playerId
              deckId
              playerDeck
              $deck: new DeckCards {
                @model, @router, deck: playerDeck.deck, cardsPerRow: 8
              }
              $deckStats: new PlayerDeckStats {@model, @router, playerDeck}
            }
        else
          RxObservable.of null
      clan: categoryAndMe.switchMap ([category, me]) =>
        if category is 'clan'
          @model.player.getByUserIdAndGameId me.id, config.CLASH_ROYALE_ID
          .switchMap (player) =>
            if player?.data?.clan?.tag
              @model.clan.getById player?.data?.clan?.tag?.replace('#', '')
            else
              RxObservable.of false
        else
          RxObservable.of null
      .map (clan) ->
        if clan then clan else false

  beforeUnmount: =>
    @resetValueStreams()

  resetValueStreams: =>
    if @thread
      @titleValueStreams.next @thread.map (thread) -> thread?.data?.title or ''
      @bodyValueStreams.next @thread.map (thread) -> thread?.data?.body or ''
    else
      @titleValueStreams.next new RxBehaviorSubject ''
      @bodyValueStreams.next new RxBehaviorSubject ''

  render: =>
    {me, titleValue, bodyValue, attachmentsValue, attachedContent, clan,
      category, thread, language, group} = @state.getValue()

    if clan
      data =
        clan:
          id: clan.id
          name: clan.data.name
          badge: clan.data.badge
    else if category is 'deckGuide'
      data =
        playerId: attachedContent?.playerId
        deckId: attachedContent?.deckId
    else
      data = {}

    z '.z-new-thread',
      z @$compose,
        $head:
          if category is 'clan'
            z '.z-new-thread_head',
              if clan
                z '.clan',
                  z '.badge',
                    z @$clanBadge, {clan, size: '34px'}
                  z '.info',
                    z '.name', clan?.data.name
                    z '.tag', "##{clan?.id}"
              else if clan is false
                @model.l.get 'newThread.link'
              else
                z @$spinner
          else if category is 'deckGuide'
            z '.z-new-thread_head',
              z attachedContent?.$deck
              z attachedContent?.$deckStats
        onDone: (e) =>
          if category is 'clan' and not clan
            return Promise.resolve null

          @model.signInDialog.openIfGuest me
          .then =>
            newThread = {
              thread:
                id: thread?.id
                data:
                  title: titleValue
                  body: bodyValue
                  attachments: attachmentsValue
                  extras: data
              language: language
              groupId: group.id
            }
            (if thread
              @model.thread.upsert _defaults({id: thread.id}, newThread)
            else
              @model.thread.upsert newThread)
            .then (newThread) =>
              @resetValueStreams()
              @router.goPath(
                @model.thread.getPath(
                  _defaults(newThread, thread), group, @router
                )
                {reset: true}
              )
