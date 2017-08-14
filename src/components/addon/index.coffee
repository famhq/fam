z = require 'zorium'

colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class Addon
  constructor: ({@model, @router, addon, @isDonateDialogVisible}) ->
    @state = z.state
      addon: addon

  render: =>
    {addon} = @state.getValue()

    z '.z-addon',
      z 'iframe.iframe',
        src: addon?.url
