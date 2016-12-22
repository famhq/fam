z = require 'zorium'
Rx = require 'rx-lite'

if window?
  require './index.styl'

module.exports = class Toggle
  constructor: ({@isSelected, @isSelectedStreams}) ->
    unless @isSelectedStreams
      @isSelectedStreams = new Rx.ReplaySubject 1
      @isSelected ?= Rx.Observable.just ''
      @isSelectedStreams.onNext @isSelected

    @state = z.state
      isSelected: @isSelectedStreams.switch()

  render: ({onToggle} = {}) =>
    {isSelected} = @state.getValue()

    z '.z-toggle', {
      className: z.classKebab {isSelected}
      onclick: =>
        @isSelectedStreams.onNext Rx.Observable.just not isSelected
        onToggle? not isSelected
    },
      z '.track'
      z '.knob'
