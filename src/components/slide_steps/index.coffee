z = require 'zorium'
_map = require 'lodash/collection/map'
Rx = require 'rx-lite'
colors = require '../../colors'
log = require 'loga'

Head = require '../head'
Tabs = require '../tabs'
Icon = require '../icon'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class SlideSteps
  constructor: ({@model, @portal, steps}) ->
    @$head = new Head {@model}

    @selectedIndex = new Rx.BehaviorSubject 0
    @$tabs = new Tabs {@model, hideTabBar: true, @selectedIndex}
    @$backIcon = new Icon()
    @$forwardIcon = new Icon()

    @state = z.state
      selectedIndex: @selectedIndex

  render: ({onBack, onDone, steps, isButtonVisible, buttonText, buttonOnClick,
      secondaryButtonText, secondaryButtonOnClick}) =>

    {selectedIndex} = @state.getValue()


    windowHeight = window?.innerHeight or 320

    z '.p-slide-steps', {
      style:
        height: "#{windowHeight}px"
    },
      z @$tabs,
        height: windowHeight
        isBarFixed: false
        tabs: _map steps, (options, i) ->
          {$step} = options
          {
            $menuText: "#{i}"
            $el: $step
          }


      if isButtonVisible
        [
          z '.button-wrapper',
            z '.button', {
              onclick: buttonOnClick
              style:
                color: colors["$#{steps[selectedIndex].colorName}900"]
            }, buttonText

            if secondaryButtonText
              z '.button.secondary', {
                onclick: secondaryButtonOnClick
              }, secondaryButtonText
        ]

      z '.bottom-bar',
        z '.icon',
          if selectedIndex > 0 and isButtonVisible
            z @$backIcon,
              icon: 'back'
              color: colors.$white
              onclick: =>
                @selectedIndex.onNext Math.max(selectedIndex - 1, 0)
          else if onBack
            z '.text', {
              onclick: onBack
            },
              'Back'
        z '.step-counter',
          _map steps, (step, i) ->
            isActive = i is selectedIndex
            z '.step-dot',
              className: z.classKebab {isActive}
        z '.icon',
          if selectedIndex < steps?.length - 1 and isButtonVisible
            z @$forwardIcon,
              icon: 'forward'
              color: colors.$white
              onclick: =>
                @selectedIndex.onNext \
                  Math.min(selectedIndex + 1, steps?.length - 1)
          else if onDone
            z '.text', {
              onclick: onDone
            },
              'Done'
