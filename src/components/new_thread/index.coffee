z = require 'zorium'
Rx = require 'rx-lite'

Compose = require '../compose'
ClanBadge = require '../clan_badge'
Spinner = require '../spinner'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class NewThread
  constructor: ({@model, @router, category}) ->
    @titleValue ?= new Rx.BehaviorSubject ''
    @bodyValueStreams ?= new Rx.ReplaySubject 1
    @bodyValueStreams.onNext new Rx.BehaviorSubject ''
    @attachmentsValueStreams ?= new Rx.ReplaySubject 1
    @attachmentsValueStreams.onNext new Rx.BehaviorSubject []

    @$clanBadge = new ClanBadge()
    @$spinner = new Spinner()

    @$compose = new Compose {
      @model, @router, @titleValue, @bodyValueStreams, @attachmentsValueStreams
    }

    categoryAndMe = Rx.Observable.combineLatest(
      category
      @model.user.getMe()
      (vals...) -> vals
    )

    @state = z.state
      me: @model.user.getMe()
      bodyValue: @bodyValueStreams.switch()
      attachmentsValue: @attachmentsValueStreams.switch()
      category: category
      clan: categoryAndMe.flatMapLatest ([category, me]) =>
        if category is 'clan'
          @model.player.getByUserIdAndGameId me.id, config.CLASH_ROYALE_ID
          .flatMapLatest (player) =>
            if player?.data?.clan?.tag
              @model.clan.getById player?.data?.clan?.tag
            else
              Rx.Observable.just false
        else
          Rx.Observable.just null
      .map (clan) ->
        if clan then clan else false

  render: =>
    {me, bodyValue, attachmentsValue, clan, category} = @state.getValue()

    if clan
      data =
        clan:
          id: clan.id
          name: clan.data.name
          badge: clan.data.badge
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
        onDone: (e) =>
          if category is 'clan' and not clan
            return Promise.resolve null

          @model.signInDialog.openIfGuest me
          .then =>
            @model.thread.create {
              title: @titleValue.getValue()
              body: bodyValue
              attachments: attachmentsValue
              category: category
              data: data
            }
          .then ({id}) =>
            @bodyValueStreams.onNext Rx.Observable.just null
            @attachmentsValueStreams.onNext Rx.Observable.just null
            @router.go "/thread/#{id}", {reset: true}
