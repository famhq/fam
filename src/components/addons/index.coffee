z = require 'zorium'
Rx = require 'rx-lite'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
_kebabCase = require 'lodash/kebabCase'

Base = require '../base'
Avatar = require '../avatar'
Icon = require '../icon'
Spinner = require '../spinner'
FormatService = require '../../services/format'
colors = require '../../colors'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class Addons extends Base
  constructor: ({@model, @router, sort, filter}) ->
    @$spinner = new Spinner()

    me = @model.user.getMe()
    addons = @model.addon.getAll({sort, filter})
    # streams = @model.stream.getAll({sort, filter})

    @state = z.state
      me: @model.user.getMe()
      addons: addons.map (addons) ->
        _map addons, (addon) ->
          {
            addon
            $rating: null # TODO
          }

  render: =>
    {me, addons} = @state.getValue()

    z '.z-addons',
      z 'h2.title', @model.l.get 'addons.discover'
      z '.addons',
        if addons and _isEmpty addons
          'No addons found'
        else if addons
          _map addons, ({addon, $rating}) =>
            [
              @router.link z 'a.addon', {
                href: "/addon/clash-royale/#{_kebabCase(addon.key)}"
              },
                z 'img.icon',
                  src: addon.iconUrl
                z '.info',
                  z '.name',
                    @model.l.get "#{addon.key}.title", {file: 'addons'}
                    z 'span.creator',
                      " #{@model.l.get 'general.by'} #{addon.creator.name}"
                  z '.description',
                    @model.l.get "#{addon.key}.description", {file: 'addons'}
            ]
        else
          @$spinner
