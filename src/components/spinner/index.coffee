z = require 'zorium'

colors = require '../../colors'

if window?
  require './index.styl'

DEFAULT_SIZE = 50

module.exports = class Spinner
  render: ({size, hasTopMargin} = {})->
    size ?= DEFAULT_SIZE
    hasTopMargin ?= true

    z '.z-spinner', {
      style:
        width: "#{size}px"
        height: "#{size}px"
    },
      z '.circle',
        style:
          border: "#{size / 10}px solid #{colors.$primary500}"
          marginTop: if hasTopMargin then '16px' else 0
