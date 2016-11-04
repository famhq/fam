_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

if window?
  require './index.styl'

module.exports = class InfoBlock
  render: ({$title, $content, $form}) ->
    z '.z-info-block',
      z '.inner',
        z '.top'
        z '.title', $title
        z '.content',
          $content
        if $form
          z '.form',
            $form
        z '.bottom'
