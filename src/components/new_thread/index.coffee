z = require 'zorium'
Rx = require 'rxjs'

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
    @attachmentsValueStreams.next new Rx.BehaviorSubject []
    category ?= Rx.Observable.of null

    if thread
      @titleValueStreams.next thread.map (thread) -> thread?.title
      @bodyValueStreams.next thread.map (thread) -> thread?.body
    else
      @titleValueStreams.next new Rx.BehaviorSubject ''
      @bodyValueStreams.next new Rx.BehaviorSubject ''


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
      language: @model.l.getLanguage()
      category: category
      thread: thread
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
          Rx.Observable.of null
      clan: categoryAndMe.switchMap ([category, me]) =>
        if category is 'clan'
          @model.player.getByUserIdAndGameId me.id, config.CLASH_ROYALE_ID
          .switchMap (player) =>
            if player?.data?.clan?.tag
              @model.clan.getById player?.data?.clan?.tag?.replace('#', '')
            else
              Rx.Observable.of false
        else
          Rx.Observable.of null
      .map (clan) ->
        if clan then clan else false

  render: =>
    {me, titleValue, bodyValue, attachmentsValue, attachedContent, clan,
      category, thread, language} = @state.getValue()

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
              title: titleValue
              body: bodyValue
              attachments: attachmentsValue
              category: category
              data: data
              language: language
              gameId: config.CLASH_ROYALE_ID
            }
            if thread
              @model.thread.updateById thread.id, newThread
            else
              @model.thread.create newThread
          .then (thread) =>
            @bodyValueStreams.next Rx.Observable.of null
            @attachmentsValueStreams.next Rx.Observable.of null
            @router.go @model.thread.getPath(thread, @router), {reset: true}
