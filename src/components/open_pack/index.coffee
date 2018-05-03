z = require 'zorium'
_map = require 'lodash/map'
_some = require 'lodash/some'
_isEqual = require 'lodash/isEqual'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
require 'rxjs/add/operator/map'

Icon = require '../icon'
ItemOpen = require '../item_open'
OpenItemsDeck = require '../open_items_deck'
FlatButton = require '../flat_button'
SecondaryButton = require '../secondary_button'
FormatService = require '../../services/format'
Ripple = require '../ripple'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

STARTING_ROTATION = 0
ROTATION_PER_ITEM = 2
SLIDE_OUT_TIME_MS = 300
SPREAD_DELAY_MS = 1000
FLIP_DELAY_MS = 250

module.exports = class OpenPack
  constructor: ({@model, @router, @items, @onClose, pack, group}) ->
    @$doneButton = new SecondaryButton()
    @$goToCollectionButton = new FlatButton()
    @$ripple = new Ripple()

    isDone = new RxBehaviorSubject false
    isDeckSpread = new RxBehaviorSubject false
    @$openItemsDeck = new OpenItemsDeck {@model, @items, isDone, isDeckSpread}

    me = @model.user.getMe()

    @state = z.state
      me: me
      isVisible: false
      isDone: isDone
      isDeckSpread: isDeckSpread
      group: group
      itemsSwiped: 0

  afterMount: =>
    {items} = @state.getValue()

    setTimeout =>
      @$ripple.ripple({
        color: colors.$primary500
        isCenter: true
        fadeIn: true
      }).then =>
        @state.set
          isVisible: true

        @$openItemsDeck.show()
    , 0

  buyAnotherPack: -> null # TODO

  render: =>
    {me, isDeckSpread, isDeckSpread, group,
      isVisible, isDone} = @state.getValue()

    z '.z-open-pack', {
      className: z.classKebab {
        isVisible
        isDeckSpread
        isDone
      }
    },
      z @$ripple

      z '.content',
        z '.items-deck',
          @$openItemsDeck

        z '.bottom',
          z '.action',
            # z @$goToCollectionButton,
            #   text: @model.l.get 'openPack.goToCollection'
            #   onclick: =>
            #     @onClose()
            #     @model.group.goPath group, 'groupCollection', {
            #       @router
            #     }
            z @$doneButton,
              text: @model.l.get 'general.done'
              onclick: =>
                @onClose()
          z '.tap-to-reveal',
            'Tap to reveal the next item'
