z = require 'zorium'
_map = require 'lodash/map'
_each = require 'lodash/each'
_defaults = require 'lodash/defaults'
_filter = require 'lodash/filter'
_pick = require 'lodash/pick'
_isEmpty = require 'lodash/isEmpty'
RxObservable = require('rxjs/Observable').Observable
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/switchMap'

config = require '../../config'
colors = require '../../colors'
Icon = require '../icon'
Spinner = require '../spinner'
PickItems = require '../new_trade_pick_items'
Confirm = require '../new_trade_confirm'
ItemService = require '../../services/item'

if window?
  require './index.styl'

module.exports = class NewTrade
  constructor: (options) ->
    {@model, @router, @sendItem, @receiveItem, @toId,
        @counterTradeId, @group} = options

    @$spinner = new Spinner()
    @$caretLeftIcon = new Icon()
    @$caretRightIcon = new Icon()

    @receiveAddedItemsStreams = new RxReplaySubject 1
    @sendAddedItemsStreams = new RxReplaySubject 1
    @toStreams = new RxReplaySubject 1

    @state = z.state
      me: @model.user.getMe()
      receiveItems: @receiveAddedItemsStreams.switch()
      sendItems: @sendAddedItemsStreams.switch()
      to: @toStreams.switch()

    @setup()

  setup: =>
    me = @model.user.getMe()
    counterTrade = @counterTradeId.switchMap (tradeId) =>
      if tradeId
        @model.trade.getById tradeId
      else
        RxObservable.of null

    toIdAndCounterTrade = RxObservable.combineLatest(
      @toId
      counterTrade
      (vals...) -> vals
    )

    toUser = toIdAndCounterTrade.switchMap ([toId, counterTrade]) =>
      if toId
        @model.user.getById toId
      else if counterTrade
        @model.user.getById counterTrade.fromId
      else
        RxObservable.of null

    toUserItems = toIdAndCounterTrade.switchMap ([toId, counterTrade]) =>
      if toId
        @model.userItem.getAllByUserId toId
      else if counterTrade
        @model.userItem.getAllByUserId counterTrade.fromId
      else
        RxObservable.of null

    toUserItemsAndGroup = RxObservable.combineLatest(
      toUserItems, @group, (vals...) -> vals
    )

    to = toUser.map (user) ->
      if user
        [user]
      else
        []

    # when all items are listed, don't limit item quantities
    isReceiveUnlimited = toUserItems.map (to) -> not to

    #
    # RECEIVE ADDED ITEMS
    #

    receiveItemAndCounterTrade = RxObservable.combineLatest(
      @receiveItem
      counterTrade
      (vals...) -> vals
    )
    @receiveAddedItemsStreams.next(
      receiveItemAndCounterTrade.map ([receiveItem, counterTrade]) ->
        if receiveItem
          [{item: receiveItem, count: 1}]
        else if counterTrade
          # opposite since countering
          counterTrade.sendItems
        else
          []
    )

    #
    # RECEIVE ITEMS
    #
    receiveItems = toUserItemsAndGroup.switchMap ([toUserItems, group]) =>
      userItems = if to \
                  then RxObservable.of(toUserItems)
                  else @model.item.getAllByGroupId(group.id).map (items) ->
        _map items, (item) -> {item, count: 1}

      RxObservable.combineLatest(
        @receiveAddedItemsStreams.switch()
        userItems
        isReceiveUnlimited
        (vals...) -> vals
      ).map ([addedItems, userItems, isReceiveUnlimited]) ->
        if isReceiveUnlimited
          return userItems
        # ignore added userItems
        _each addedItems, (itemInfo) ->
          userItems = ItemService.removeItem userItems, itemInfo, itemInfo.count
        userItems

    #
    # SEND ADDED ITEMS
    #

    sendItemAndCounterTrade = RxObservable.combineLatest(
      @sendItem
      counterTrade
      (vals...) -> vals
    )
    @sendAddedItemsStreams.next(
      sendItemAndCounterTrade.map ([sendItem, counterTrade]) ->
        if sendItem
          [{item: sendItem, count: 1}]
        else if counterTrade
          # opposite since countering
          counterTrade.receiveItems
        else
          []
    )


    #
    # SEND ITEMS
    #
    sendItems = RxObservable.combineLatest(
      @sendAddedItemsStreams.switch()
      @model.userItem.getAll()
      (vals...) -> vals
    ).map ([addedItems, userItems]) ->
      _each addedItems, (itemInfo) ->
        userItems = ItemService.removeItem userItems, itemInfo, itemInfo.count
      userItems

    @toStreams.next to

    @steps = [
      # receive items
      new PickItems {
        @model
        addedItemsSteams: @receiveAddedItemsStreams
        items: receiveItems
        otherUserItems: sendItems
        toUserItems: toUserItems
        type: 'receive'
        isUnlimited: isReceiveUnlimited
      }
      # send items
      new PickItems {
        @model
        addedItemsSteams: @sendAddedItemsStreams
        items: sendItems
        otherUserItems: receiveItems
        toUserItems: toUserItems
        type: 'send'
        isUnlimited: false
      }
      new Confirm {
        @model
        receiveItems: @receiveAddedItemsStreams.switch()
        sendItems: @sendAddedItemsStreams.switch()
        to: @toStreams.switch()
      }
    ]

    @state.set
      selectedStep: 0
      isSending: false

  beforeUnmount: =>
    @setup()

  sendTrade: =>
    {receiveItems, sendItems, to} = @state.getValue()

    @model.trade.create
      receiveItemKeys: _map receiveItems, (item) ->
        _pick item, ['itemKey', 'count']
      sendItemKeys: _map sendItems, (item) ->
        _pick item, ['itemKey', 'count']
      toIds: _filter _map to, 'id'
    .then (trade) ->
      {receiveItems, sendItems, id: trade.id}

  render: =>
    {me, selectedStep, sendItems,
      receiveItems, to, isSending} = @state.getValue()

    isFirstStep = selectedStep is 0
    isLastStep = selectedStep is @steps.length - 1

    $step = @steps[selectedStep]
    canContinue = not $step?.canContinue or $step?.canContinue()

    z '.z-new-trade',
      z $step, {onSend: @sendTrade}

      z '.step-bar',
        z '.g-grid',
          z '.previous', {
            onclick: =>
              if isFirstStep
                @router.back()
              else
                @state.set selectedStep: selectedStep - 1
          },
            if isFirstStep
            then @model.l.get 'general.cancel'
            else z @$caretLeftIcon,
              icon: 'caret-right'
              flipX: true
              isTouchTarget: false
              color: colors.$tertiary900Text

          z '.step-counter',
            _map @steps, (step, i) ->
              isActive = i is selectedStep
              z '.step-dot',
                className: z.classKebab {isActive}

          z '.next', {
            className: z.classKebab {canContinue}
            onclick: =>
              unless canContinue
                return
              if isLastStep and not isSending
                @state.set isSending: true
                @sendTrade()
                .then =>
                  @state.set isSending: false
                  @router.go 'trades', {reset: true}
                .catch =>
                  @state.set isSending: false
              else
                @state.set selectedStep: selectedStep + 1
          },
            z '.text',
              if isSending
              then @model.l.get 'general.loading'
              else if isLastStep
              then @model.l.get 'stepBar.send'
              else @model.l.get 'stepBar.next'
            z '.icon',
              z @$caretRightIcon,
                icon: 'caret-right'
                isTouchTarget: false
                color: if canContinue \
                       then colors.$tertiary900Text
                       else colors.$tertiary300
