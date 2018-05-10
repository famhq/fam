z = require 'zorium'

config = require '../../config'

if window?
  require './index.styl'

module.exports = class CurrencyIcon
  constructor: ({itemKey} = {}) ->
    @state = z.state
      itemKey: itemKey

  render: ({size}) =>
    {itemKey} = @state.getValue()

    dir = itemKey?.split('_')?[0]

    z '.z-currency-icon',
      style:
        width: size
        height: size
        backgroundImage:
          if itemKey
          then "url(#{config.CDN_URL}/items/#{dir}/currency/#{itemKey}.png?4)"
          else 'none'
