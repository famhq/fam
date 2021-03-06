z = require 'zorium'

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
