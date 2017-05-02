z = require 'zorium'
Rx = require 'rx-lite'
_max = require 'lodash/max'
_map = require 'lodash/map'

Icon = require '../icon'
CardList = require '../card_list'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

IMAGE_KEY = 'crForumSig'
IMAGE_WIDTH = 500
IMAGE_HEIGHT = 100
COLORS = ['blue', 'gray', 'green', 'light_blue', 'pink',
          'purple', 'red', 'yellow']

module.exports = class ForumSignature
  constructor: ({@model, @portal, @router}) ->
    forumSignature = @model.dynamicImage.getMeByImageKey IMAGE_KEY

    @selectedColorStreams = new Rx.ReplaySubject 1
    @selectedColorStreams.onNext forumSignature.map ({data}) ->
      data?.color

    @selectedFavoriteCardStreams = new Rx.ReplaySubject 1
    @selectedFavoriteCardStreams.onNext forumSignature.map ({data}) ->
      {key: data?.favoriteCard}

    cards = @model.clashRoyaleCard.getAll()

    @$selectedColorIcon = new Icon()
    @$selectedFavoriteCardIcon = new Icon()
    @$copyIcon = new Icon()
    @$cardList = new CardList {
      cards, selectedCardStreams: @selectedFavoriteCardStreams
    }

    @state = z.state
      me: @model.user.getMe()
      windowSize: @model.window.getSize()
      selectedColor: @selectedColorStreams.switch()
      selectedFavoriteCard: @selectedFavoriteCardStreams.switch()
      cacheBuster: Date.now()
      isImageVisible: true

  afterMount: (@$$el) => null

  render: =>
    {me, windowSize, selectedColor, selectedFavoriteCard,
      cacheBuster, isImageVisible} = @state.getValue()

    imageWidth = Math.min IMAGE_WIDTH, (windowSize?.width - 32)
    imageHeight = imageWidth / (IMAGE_WIDTH / IMAGE_HEIGHT)

    imageSrc =
      "#{config.PUBLIC_API_URL}/di/crForumSig/#{me?.id}.png"

    z '.z-forum-signature',
      z '.top',
        z '.g-grid',
          z '.g-cols',
            z '.g-col.g-xs-12.g-md-6',
              z '.image', {
                style:
                  width: "#{imageWidth}px"
                  height: "#{imageHeight}px"
              },
                if me and isImageVisible
                  z 'img',
                    src: imageSrc + '?' + cacheBuster
                    width: imageWidth
                    height: imageHeight
            z '.g-col.g-xs-12.g-md-6',
              z '.labels',
                z '.label', @model.l.get 'forumSignature.label'
                @router.link z 'a.help', {
                  href:
                    'https://forum.supercell.com/profile.php?do=editsignature'
                }, @model.l.get 'forumSignature.help'
              z '.input-wrapper',
                z 'input.input#image-url',
                  value: imageSrc
                  onclick: (e) ->
                    e?.target.select()

                z '.copy',
                  z @$copyIcon,
                    icon: 'copy'
                    color: colors.$primary500
                    onclick: =>
                      $$input = @$$el.querySelector('#image-url')
                      $$input.select()
                      try
                        successful = document.execCommand('copy')
                      catch err
                        null
      z '.options',
        z '.g-grid',
          z '.subhead', @model.l.get 'forumSignature.subheadColors'
          z '.g-cols',
            _map COLORS, (color) =>
              z '.g-col.g-xs-3.g-md-1',
                z '.color', {
                  className: z.classKebab {
                    "#{color}": true
                  }
                  onclick: =>
                    @selectedColorStreams.onNext(
                      Rx.Observable.just color
                    )
                    @state.set isImageVisible: false
                    @model.dynamicImage.upsertMeByImageKey IMAGE_KEY, {
                      color: color
                    }
                    .then =>
                      @state.set cacheBuster: Date.now(), isImageVisible: true
                },
                  if color is selectedColor
                    z '.selected',
                      z @$selectedColorIcon,
                        icon: 'check'
                        isTouchTarget: false
                        color: colors.$white

        z '.g-grid.cards',
          z '.subhead', @model.l.get 'forumSignature.subheadFavoriteCard'
          z @$cardList,
            onCardClick: (card) =>
              @state.set isImageVisible: false
              @model.dynamicImage.upsertMeByImageKey IMAGE_KEY, {
                favoriteCard: card.key
              }
              .then =>
                @state.set cacheBuster: Date.now(), isImageVisible: true
