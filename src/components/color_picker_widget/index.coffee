z = require 'zorium'
_map = require 'lodash/map'

Dialog = require '../dialog'
config = require '../../config'

if window?
  require './index.styl'

hasInputColorSupport = ->
  $$input = document.createElement 'input'
  $$input.type = 'color'
  $$input.value = '!'
  $$input.type is 'color' && $$input.value isnt '!'

module.exports = class ColorPicker
  type: 'Widget'

  constructor: ({@model, @onSubmitFn}) ->
    @color = null
    @$dialog = new Dialog()

    @state = z.state {
      color: null
    }

  afterMount: (@$$el) =>
    @hasInputColorSupport = hasInputColorSupport()
    unless @hasInputColorSupport
      @model.additionalScript.add 'css', '/lib/colorpicker/colorpicker.css'
      @model.additionalScript.add 'js', '/lib/colorpicker/colorpicker.js'
      .then =>
        $$input = @$$el.querySelector '.z-color-picker_picker'
        if $$input
          @picker = new CP $$input
          @picker.on 'change', (color) =>
            color = "##{color}"
            $$input.style.backgroundColor = color
            @color = color

  beforeUnmount: =>
    @colorPicker = null

  onSubmit: (@onSubmitFn) => null

  render: ({isBase}) =>
    {color} = @state.getValue()

    z '.z-color-picker',
      z @$dialog,
        isVanilla: true
        $title: @model.l.get 'colorPicker.title'
        $content:
          if isBase
            z '.z-color-picker_colors',
              _map config.BASE_NAME_COLORS, (hex) =>
                z '.color',
                  className: z.classKebab {isSelected: hex is @color}
                  style:
                    backgroundColor: hex
                  onclick: =>
                    @state.set color: hex
                    @color = hex
          else
            z 'input.z-color-picker_picker',
              type: if @hasInputColorSupport then 'color' else 'text'
              onchange: (e) =>
                if @hasInputColorSupport
                  @color = e.target.value
        submitButton:
          text: @model.l.get 'general.submit'
          onclick: =>
            if @color and @color isnt '#000000'
              @onSubmitFn @color
