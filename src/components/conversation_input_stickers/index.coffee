z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_isEmpty = require 'lodash/isEmpty'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/map'
require 'rxjs/add/observable/of'

Sticker = require '../sticker'
PrimaryButton = require '../primary_button'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

DEFAULT_TEXTAREA_HEIGHT = 54

module.exports = class ConversationInputStickers
  constructor: (options) ->
    {@model, @router, @onPost, @message, @currentPanel,
      @selectionStart, @selectionEnd, conversation, getTextareaFn} = options

    @$getStickersButton = new PrimaryButton()

    @state = z.state
      conversation: conversation
      $stickers: @model.userItem.getAll().map (items) =>
        _filter _map items, (itemInfo) =>
          if itemInfo.item.type is 'sticker'
            {
              itemInfo
              $sticker: new Sticker {
                @model
                itemInfo: itemInfo
                isLocked: RxObservable.of false
                hasCount: false
                sizePx: 40
              }
            }

  getHeightPx: ->
    RxObservable.of 69

  render: =>
    {$stickers, conversation} = @state.getValue()

    z '.z-conversation-input-stickers',
      z '.stickers', [
        if $stickers? and _isEmpty $stickers
          z '.empty',
            @model.l.get 'conversationInputStickers.empty'
            if conversation?.groupId
              z '.button-wrapper',
                z '.button',
                  z @$getStickersButton,
                    text: @model.l.get 'conversationInputStickers.getStickers'
                    isFullWidth: false
                    onclick: =>
                      @model.group.goPath group, 'groupCollectionWithTab', {
                        @router
                        replacements:
                          tab: 'shop'
                      }
        else
          _map $stickers, ({itemInfo, $sticker}) =>
            z '.sticker',
              z $sticker, {
                onclick: (e, sticker) =>
                  message = @message.getValue()
                  startPos = @selectionStart.getValue()
                  endPos = @selectionEnd.getValue()
                  selectedText = message.substring startPos, endPos
                  stickerText = ":#{sticker.key}^#{itemInfo.itemLevel or 1}:"
                  newMessage = message.substring(0, startPos) + stickerText +
                             message.substring(endPos, message.length)
                  @message.next newMessage
                  newCursorPos = startPos + stickerText.length
                  @selectionStart.next newCursorPos
                  @selectionEnd.next newCursorPos
                  @currentPanel.next 'text'
              }
      ]
