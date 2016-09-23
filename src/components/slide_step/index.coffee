z = require 'zorium'
colors = require '../../colors'
Rx = require 'rx-lite'

if window?
  require './index.styl'

STEPS_WITH_STYLES = 3

module.exports = class SlideStep
  render: ({$title, $content, $image, colorName}) ->
    isPrimary = colorName is 'primary'
    isTertiary = colorName is 'tertiary'

    z '.z-slide-step', {
      className: z.classKebab {
        isPrimary
        isTertiary
      }
    },
      z '.title-block',
        $title
      z '.screenshot-block',
        $image
      z '.info-block',
        $content
