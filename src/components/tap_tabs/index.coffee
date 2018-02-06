z = require 'zorium'
_map = require 'lodash/map'

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class TapTabs
  constructor: ({@selectedPage}) ->
    @state = z.state
      selectedPage: @selectedPage

  render: ({items, isFullWidth}) =>
    {selectedPage} = @state.getValue()

    z '.z-tap-tabs', {
      className: z.classKebab {isFullWidth}
    },
      z '.menu',
        _map items, ({name, page}) =>
          z '.item', {
            className: z.classKebab {
              isSelected: selectedPage is page
            }
            onclick: =>
              @selectedPage.next page
          },
            name
