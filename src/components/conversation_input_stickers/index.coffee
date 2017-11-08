z = require 'zorium'
_map = require 'lodash/map'
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
SEARCH_DEBOUNCE = 300

module.exports = class ConversationInputStickers
  constructor: (options) ->
    {@model, @router, @onPost, @message, @currentPanel,
      @selectionStart, @selectionEnd, gameKey} = options

    @$getStickersButton = new PrimaryButton()

    @state = z.state
      gameKey: gameKey
      $stickers: @model.userItem.getAll().map (items) =>
        _map items, (itemInfo) =>
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
    69

  render: =>
    {$stickers, gameKey} = @state.getValue()

    z '.z-conversation-input-stickers',
      z '.stickers', [
        if $stickers? and _isEmpty $stickers
          z '.empty',
            @model.l.get 'conversationInputStickers.empty'
            z '.button-wrapper',
              z '.button',
                z @$getStickersButton,
                  text: @model.l.get 'conversationInputStickers.getStickers'
                  isFullWidth: false
                  onclick: =>
                    @router.go 'fire', {gameKey}
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
                  # document.getElementById('textarea').value = message
                  @currentPanel.next 'text'
                  # @onPost()
              }

        # _map config.STICKERS, (sticker) =>
        #   z '.sticker',
        #     onclick: (e) =>
        #       @message.next ":#{sticker}:"
        #       # @onPost()
        #     style:
        #       backgroundImage:
        #         "url(#{config.CDN_URL}/groups/emotes/#{sticker}.png)"
      ]
