z = require 'zorium'
Environment = require '../../services/environment'
_map = require 'lodash/map'
_isEmpty = require 'lodash/isEmpty'
_every = require 'lodash/every'
_find = require 'lodash/find'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable

config = require '../../config'
colors = require '../../colors'
Button = require '../button'
Dialog = require '../dialog'
Icon = require '../icon'
Spinner = require '../spinner'
Item = require '../item'
Sticker = require '../sticker'
Avatar = require '../avatar'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
PrimaryButton = require '../primary_button'
SecondaryButton = require '../secondary_button'
# CardInfo = require '../card_info'
ProfileDialog = require '../profile_dialog'
ItemService = require '../../services/item'

if window?
  require './index.styl'

ITEM_SIZE = 100

module.exports = class Trade
  constructor: ({@model, @router, trade}) ->
    @selectedProfileDialogUser = new RxBehaviorSubject null
    @selectedItemInfo = new RxReplaySubject 1

    @$spinner = new Spinner()
    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@router, @model}
    @$declineButton = new SecondaryButton()
    @$counterButton = new SecondaryButton()
    @$sendButton = new PrimaryButton()
    @$cancelButton = new PrimaryButton()
    @$declineIcon = new Icon()
    @$kikIcon = new Icon()
    @$avatar = new Avatar()
    @$errorDialog = new Dialog()
    @$acceptTradeDialog = new Dialog()
    @$closeButton = new Button()
    @$acceptTradeDialogCancelButton = new Button()
    @$acceptTradeDialogAcceptButton = new Button()
    # @$cardInfo = new CardInfo {
    #   @model
    #   @router
    #   infoStreams: @selectedItemInfo
    # }

    @state = z.state
      me: @model.user.getMe()
      meUserItems: @model.userItem.getAll()
      trade: trade
      isAcceptTradeDialogVisible: false
      isAcceptLoading: false
      isDeclineLoading: false
      tradeError: null
      selectedItemInfo: @selectedItemInfo.switch()
      selectedProfileDialogUser: @selectedProfileDialogUser
      platform: Environment.getPlatform {gameKey: config.GAME_KEY}
      receiveItemsWithComponents: trade.map ({receiveItems} = {}) =>
        _map receiveItems, (itemInfo) =>
          ItemClass = if itemInfo.item.type is 'sticker' \
                      then Sticker
                      else Item
          {
            itemInfo: itemInfo
            $item: new ItemClass {@model, @router, itemInfo}
            # $ownedCount: new ItemCount()
          }
      sendItemsWithComponents: trade.map ({sendItems} = {}) =>
        _map sendItems, (itemInfo) =>
          ItemClass = if itemInfo.item.type is 'sticker' \
                      then Sticker
                      else Item

          {
            itemInfo: itemInfo
            $item: new ItemClass {@model, @router, itemInfo}
            # $ownedCount: new ItemCount()
          }

  acceptTrade: ({trade}) =>
    @state.set isAcceptLoading: true
    @model.trade.updateById trade?.id, {
      status: 'accepted'
    }
    .then (trade) =>
      @state.set isAcceptLoading: false
    .catch (err) =>
      @state.set
        tradeError: err?.detail or 'Unable to complete that trade!'
        isAcceptLoading: false
        isAcceptTradeDialogVisible: false
      throw err

  render: =>
    {me, trade, isAcceptLoading, receiveItemsWithComponents, tradeError,
      sendItemsWithComponents, platform, selectedProfileDialogUser,
      meUserItems, selectedItemInfo, isDeclineLoading,
      isAcceptTradeDialogVisible} = @state.getValue()

    isTradeRecipient = me and trade and me.id isnt trade.fromId
    hasItems = isTradeRecipient and _every(
      trade.receiveItemKeys, ({itemKey, count}) =>
        return @model.userItem.isOwnedByUserItemsAndItemKey(
          meUserItems, itemKey, count
        )
    )
    # FIXME: check that the other user still has all the items they need
    # FIXME: check that trade is still pending

    $tradeSendItems =
      z '.items',
        _map sendItemsWithComponents, (sendItem) =>
          {itemInfo, $item, $ownedCount} = sendItem
          {item, count} = itemInfo

          # ownedCount = _find(me?.data.itemKeys, {id: item.id})?.count
          # isLastItem = falseownedCount <= count and not isTradeRecipient

          z '.item',
            z $item, {
              countOverlay: count
              sizePx: ITEM_SIZE
              hasRarityBar: true
              onclick: =>
                @selectedItemInfo.next RxObservable.of itemInfo
            }
            z '.name',
              item.name
            # z '.count',
            #   z $ownedCount, {count: ownedCount, isLastItem}

    $tradeReceiveItems =
      z '.items',
        _map receiveItemsWithComponents, (receiveItem) =>
          {itemInfo, $item, $ownedCount} = receiveItem
          {item, count} = itemInfo
          # ownedCount = _find(me?.data.itemKeys, {id: itemInfo.id})?.count
          # isLastItem = ownedCount <= count and isTradeRecipient
          z '.item',
            z $item, {
              countOverlay: count
              sizePx: ITEM_SIZE
              hasRarityBar: true
              onclick: =>
                @selectedItemInfo.next RxObservable.of itemInfo
            }
            z '.name',
              item.name
            # z '.count',
            #   z $ownedCount, {count: ownedCount, isLastItem}

    z '.z-trade',
      z @$appBar,
        # color: colors.$primary900
        # bgColor: colors.$white
        isFlat: true
        $topLeftButton:
          z @$buttonBack#,
            # color: colors.$header
        $topRightButton: z '.z-trade_top-right', {
          onclick: =>
            @selectedProfileDialogUser.next trade?.from
        },
          z @$avatar, {user: trade?.from}
        title:
          if isTradeRecipient
            @model.l.get 'trade.from', {
              replacements:
                name: @model.user.getDisplayName(trade?.from)
            }
          else
            @model.l.get 'trade.fromMe'

      if tradeError
        z @$errorDialog,
          $title: @model.l.get 'general.error'
          $content: tradeError
          isVanilla: true
          cancelButton:
            text: 'close'
            onclick: =>
              @state.set tradeError: null


      if trade?.error
        z '.g-grid',
          z '.error', trade.error
      else [
        z '.top',
          z '.g-grid',
            z '.title',
              if isTradeRecipient
              then @model.l.get 'trade.offering'
              else @model.l.get 'trade.asked'
            if isTradeRecipient then $tradeSendItems else $tradeReceiveItems
        z '.bottom',
          z '.g-grid',
            [
              z '.title', @model.l.get 'trade.giving'
              if isTradeRecipient then $tradeReceiveItems else $tradeSendItems

              if trade and trade.status isnt 'pending'
                z '.actions',
                  z '.cant-complete', @model.l.get 'trade.notAvailable'
              else if isTradeRecipient
                z '.actions',
                  z '.decline-button',
                    z @$declineButton,
                      text:
                        if isDeclineLoading
                          '...'
                        else
                          z @$declineIcon,
                            icon: 'close'
                            color: colors.$white
                            isTouchTarget: false

                      onclick: =>
                        @state.set isDeclineLoading: true
                        @model.trade.declineById trade?.id
                        .then =>
                          @state.set isDeclineLoading: false
                          @router.back()
                        .catch =>
                          @state.set isDeclineLoading: false
                          @router.back()

                  z '.other-buttons',
                    z '.button',
                      z @$counterButton,
                        text: 'Counter'
                        onclick: =>
                          @router.go 'newTradeCounter', {
                            counterTradeId: trade?.id
                          }

                    if hasItems
                      z '.button',
                        z @$sendButton,
                          text: @model.l.get 'general.accept'
                          onclick: =>
                            @state.set isAcceptTradeDialogVisible: true
                    else
                      z '.cant-complete',
                        @model.l.get 'trade.cantComplete'
              else if trade
                z '.actions',
                  z @$cancelButton,
                    text: @model.l.get 'trade.cancel'
                    onclick: =>
                      @model.trade.deleteById trade.id
                      .then =>
                        @router.back()
            ]
      ]
      # if selectedItemInfo?.item
      #   z @$cardInfo, {
      #     onClose: =>
      #       @selectedItemInfo.next RxObservable.of null
      #   }

      if selectedProfileDialogUser
        z @$profileDialog

      if isAcceptTradeDialogVisible
        z @$acceptTradeDialog,
          $content: @model.l.get 'trade.confirm', {
            replacements:
              name: @model.user.getDisplayName(trade?.from)
          }
          isVanilla: true
          cancelButton:
            text: @model.l.get 'general.cancel'
            onclick: =>
              @state.set isAcceptTradeDialogVisible: false
          submitButton:
            text: if isAcceptLoading \
                  then @model.l.get 'general.loading'
                  else @model.l.get 'general.accept'
            onclick: =>
              unless isAcceptLoading
                @acceptTrade {trade}
                .then =>
                  @state.set
                    isAcceptTradeDialogVisible: false
                    isAcceptLoading: false
                  @router.back()
