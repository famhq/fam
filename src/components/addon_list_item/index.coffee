z = require 'zorium'
Environment = require '../../services/environment'
_kebabCase = require 'lodash/kebabCase'

config = require '../../config'

if window?
  require './index.styl'

module.exports = class AddonListItem
  constructor: ({@model, @router, addon, isHighlighted}) ->
    @state = z.state
      addon: addon
      isHighlighted: isHighlighted

  render: ({hasPadding, replacements, onclick} = {}) =>
    hasPadding ?= true
    {addon, isHighlighted} = @state.getValue()

    unless addon?.key
      return null

    z 'a.z-addon-list-item', {
      href: @router.get 'toolByKey', {
        key: _kebabCase(addon.key)
      }
      className: z.classKebab {hasPadding, isHighlighted}
      onclick: (e) =>
        e?.preventDefault()

        if onclick
          onclick()
        else
          @router.openAddon addon, {replacements}
    },
      z '.icon-wrapper',
        z 'img.icon',
          src: addon.data?.iconUrl
      z '.info',
        z '.name',
          @model.l.get "#{addon.key}.title", {file: 'addons'}
          z 'span.creator',
            " #{@model.l.get 'general.by'} #{addon.data?.creatorName}"
        z '.description',
          @model.l.get "#{addon.key}.description", {file: 'addons'}
