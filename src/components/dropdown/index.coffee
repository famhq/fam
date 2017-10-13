z = require 'zorium'
Rx = require 'rxjs'
_map = require 'lodash/map'
_kebabCase = require 'lodash/kebabCase'

if window?
  require './index.styl'

module.exports = class Dropdown
  constructor: ({@value, @valueStreams, @error} = {}) ->
    @value ?= new Rx.BehaviorSubject null
    @error ?= new Rx.BehaviorSubject null

    @isFocused = new Rx.BehaviorSubject false

    @state = z.state {
      isFocused: @isFocused
      value: @valueStreams?.switch() or @value
      error: @error
    }

  render: ({hintText, isFloating, isDisabled, options}) =>
    {value, error, isFocused} = @state.getValue()

    hintText ?= ''
    isFloating ?= true
    isDisabled ?= false
    options = [{value: '', text: ''}].concat options

    z '.zp-dropdown',
      # vdom doesn't key defaultValue correctly if elements are switched
      key: _kebabCase hintText
      className: z.classKebab {
        hasValue: value isnt ''
        isFocused
        isFloating
        isDisabled
        isError: error?
      }
      z '.hint',
        hintText
      z 'select.select', {
        attributes:
          disabled: if isDisabled then true else undefined
        value: value
        oninput: z.ev (e, $$el) =>
          if @valueStreams
            @valueStreams.next Rx.Observable.of $$el.value
          else
            @value.next $$el.value
          $$el.blur()
        onfocus: z.ev (e, $$el) =>
          @isFocused.next true
        onblur: z.ev (e, $$el) =>
          @isFocused.next false
      },
        _map options, (option) ->
          z 'option.option', {
            value: option?.value
            attributes:
              if "#{option?.value}" is "#{value}"
                selected: true
          },
            option?.text
      z '.underline'
      if error?
        z '.error', error
