z = require 'zorium'
Rx = require 'rxjs'

if window?
  require './index.styl'

module.exports = class Toggle
  constructor: ({@isSelected, @isSelectedStreams}) ->
    unless @isSelectedStreams
      @isSelectedStreams = new Rx.ReplaySubject 1
      @isSelected ?= Rx.Observable.of ''
      @isSelectedStreams.next @isSelected

    @state = z.state
      isSelected: @isSelectedStreams.switch()

  render: ({onToggle} = {}) =>
    {isSelected} = @state.getValue()

    z '.z-toggle', {
      className: z.classKebab {isSelected}
      onclick: =>
        @isSelectedStreams.next Rx.Observable.of not isSelected
        onToggle? not isSelected
    },
      z '.track'
      z '.knob'
