z = require 'zorium'
RxReplaySubject = require('rxjs/ReplaySubject').ReplaySubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

if window?
  require './index.styl'

module.exports = class Toggle
  constructor: ({@isSelected, @isSelectedStreams}) ->
    unless @isSelectedStreams
      @isSelectedStreams = new RxReplaySubject 1
      @isSelected ?= RxObservable.of ''
      @isSelectedStreams.next @isSelected

    @state = z.state
      isSelected: @isSelectedStreams.switch()

  render: ({onToggle} = {}) =>
    {isSelected} = @state.getValue()

    z '.z-toggle', {
      className: z.classKebab {isSelected}
      onclick: =>
        # @isSelectedStreams.next RxObservable.of not isSelected
        @isSelected.next not isSelected
        onToggle? not isSelected
    },
      z '.track'
      z '.knob'
