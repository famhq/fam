z = require 'zorium'
Rx = require 'rx-lite'

Compose = require '../compose'
ClanBadge = require '../clan_badge'
DeckCards = require '../deck_cards'
PlayerDeckStats = require '../player_deck_stats'
Spinner = require '../spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class NewThread
  constructor: ({@model, @router, category, thread, id}) ->
    @titleValueStreams ?= new Rx.BehaviorSubject ''
    @bodyValueStreams ?= new Rx.ReplaySubject 1
    @attachmentsValueStreams ?= new Rx.ReplaySubject 1
    @attachmentsValueStreams.onNext new Rx.BehaviorSubject []
    category ?= Rx.Observable.just null

    if thread
      @titleValueStreams.onNext thread.map (thread) -> thread?.title
      @bodyValueStreams.onNext thread.map (thread) -> thread?.body
    else
      @titleValueStreams.onNext new Rx.BehaviorSubject ''
      @bodyValueStreams.onNext new Rx.BehaviorSubject ''


    @$clanBadge = new ClanBadge()
    @$spinner = new Spinner()

    @$compose = new Compose {
      @model
      @router
      @titleValueStreams
      @bodyValueStreams
      @attachmentsValueStreams
    }

    categoryAndMe = Rx.Observable.combineLatest(
      category
      @model.user.getMe()
      (vals...) -> vals
    )
    categoryAndId = Rx.Observable.combineLatest(
      category
      id
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      titleValue: @titleValueStreams.switch()
      bodyValue: @bodyValueStreams.switch()
      attachmentsValue: @attachmentsValueStreams.switch()
      category: category
      thread: thread
      attachedContent: categoryAndId.flatMapLatest ([category, id]) =>
        if category is 'deckGuide'
          @model.clashRoyalePlayerDeck.getById id
          .map (playerDeck) =>
            {
              playerDeck
              $deck: new DeckCards {
                @model, @router, deck: playerDeck.deck, cardsPerRow: 8
              }
              $deckStats: new PlayerDeckStats {@model, @router, playerDeck}
            }
        else
          Rx.Observable.just null
      clan: categoryAndMe.flatMapLatest ([category, me]) =>
        if category is 'clan'
          @model.player.getByUserIdAndGameId me.id, config.CLASH_ROYALE_ID
          .flatMapLatest (player) =>
            if player?.data?.clan?.tag
              @model.clan.getById player?.data?.clan?.tag?.replace('#', '')
            else
              Rx.Observable.just false
        else
          Rx.Observable.just null
      .map (clan) ->
        if clan then clan else false

  render: =>
    {me, titleValue, bodyValue, attachmentsValue, attachedContent, clan,
      category, thread} = @state.getValue()

    if clan
      data =
        clan:
          id: clan.id
          name: clan.data.name
          badge: clan.data.badge
    else if category is 'deckGuide'
      data =
        playerDeckId: attachedContent?.playerDeck?.id
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
              title: titleValue
              body: bodyValue
              attachments: attachmentsValue
              category: category
              data: data
            }
            if thread
              @model.thread.updateById thread.id, newThread
            else
              @model.thread.create newThread
          .then (thread) =>
            @bodyValueStreams.onNext Rx.Observable.just null
            @attachmentsValueStreams.onNext Rx.Observable.just null
            @router.go @model.thread.getPath(thread), {reset: true}
