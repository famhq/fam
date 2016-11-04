_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

if window?
  require './index.styl'

module.exports = class Form
  render: ({$inputs, $buttons, onsubmit}) ->
    z (if onsubmit then 'form.z-form' else '.z-form'), {
      onsubmit: onsubmit
    },
      [
        if $inputs
          _.map $inputs, ($input, i) ->
            [
              z '.input', $input
              unless i is $inputs.length - 1
                z '.input-spacer'
            ]
        z '.spacer'
        if $buttons
          z '.buttons',
            _.map $buttons, ($button) ->
              z '.button', $button
      ]
