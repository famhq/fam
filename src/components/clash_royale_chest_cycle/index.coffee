z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_snakeCase = require 'lodash/snakeCase'
_uniqBy = require 'lodash/uniqBy'

colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

IMAGES_LOAD_TIMEOUT_MS = 3000

module.exports = class ClashRoyaleChestCycle
  constructor: ({@model, @router, player, showAll}) ->
    me = @model.user.getMe()

    @imagesLoaded = false
    @upcomingChests = player.map (player) ->
      if player?.data?.upcomingChests
        _filter player.data.upcomingChests.items, (item) ->
          item.index? and (showAll or item.index < 8)
      else
        null
    .publishReplay(1).refCount()

    @state = z.state {
      upcomingChests: @upcomingChests
      me: me
      showAll: showAll
    }

  afterMount: (@$$el) =>
    unless @imagesLoaded
      @upcomingChests.take(1).subscribe (upcomingChests) =>
        chests = _uniqBy upcomingChests, 'name'

        loadedTimeout = setTimeout ->
          imagesLoaded
        , IMAGES_LOAD_TIMEOUT_MS

        imagesLoaded = =>
          # don't want to re-render entire state every time a pic loads in
          @$$el?.classList.add 'images-loaded'
          @imagesLoaded = true
          clearTimeout loadedTimeout

        Promise.all _map chests, ({name}) =>
          chest = _snakeCase name
          @model.image.load "#{config.CDN_URL}/chests/#{chest}.png"
        .then imagesLoaded

  render: =>
    {me, showAll, upcomingChests} = @state.getValue()

    z '.z-clash-royale-chest-cycle', {
      className: z.classKebab {@imagesLoaded, showAll}
    },
      z '.chests', {
        ontouchstart: (e) ->
          e?.stopPropagation()
      },
        if upcomingChests
          _map upcomingChests, ({name, index}, i) =>
            chest = _snakeCase name
            z '.chest',
              z 'img.image',
                src: "#{config.CDN_URL}/chests/#{chest}.png"
                width: 90
                height: 90
              if showAll
                z '.count',
                  if index is 0
                  then @model.l.get('general.next')
                  else "+#{index}"
