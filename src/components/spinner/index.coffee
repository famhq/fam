z = require 'zorium'

colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class Spinner
  render: ({size, hasTopMargin} = {})->
    size ?= 50
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
