z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
SlideSteps = require '../../components/slide_steps'
SlideStep = require '../../components/slide_step'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class LearnMorePage
  constructor: ({model, portal, @router, serverData}) ->
    @$head = new Head({
      model
      serverData
      meta:
        canonical: "https://#{config.HOST}"
    })

    @$slideSteps = new SlideSteps {model, portal}
    @$step1 = new SlideStep()
    @$step2 = new SlideStep()
    @$step3 = new SlideStep()

  renderHead: => @$head

  render: =>
    z '.p-home', {
      style:
        height: "#{window?.innerHeight}px"
    },
      z @$slideSteps,
        isButtonVisible: false
        steps: [
          {
            $step: @$step1
            colorName: 'tertiary'
            $stepTitle: 'Exclusive Membership'
            $stepImage:
              z '.p-learn-more_step-image.number-1'
            $stepContent:
              z '.p-learn-more_step-content',
                'Red Tritium is host to only the most elite players
                Members receive a black anodized stainless steel
                membership card with their unique member ID'
          }
          {
            $step: @$step2
            colorName: 'tertiary'
            $stepImage:
              z '.p-learn-more_step-image.number-2'
            $stepContent:
              z '.p-learn-more_step-content',
                z '.icon',
                  z @$icon2,
                    icon: 'focus'
                    isTouchTarget: false
                    color: colors.$black26
                    size:
                      if window?.matchMedia('(min-width: 768px)').matches
                      then '40px'
                      else '24px'
                z '.title', 'Good lighting'
                z '.description',
                  'test'
          }
          {
            $step: @$step3
            colorName: 'tertiary'
            $stepImage:
              z '.p-learn-more_step-image.number-3'
            $stepContent:
              z '.p-learn-more_step-content',
                z '.icon',
                  z @$icon3,
                    icon: 'light'
                    isTouchTarget: false
                    color: colors.$black26
                    size:
                      if window?.matchMedia('(min-width: 768px)').matches
                      then '40px'
                      else '24px'
                z '.title', 'Sharp focus'
                z '.description',
                  'test'

                z '.button',
                  'Upload photo'
          }
        ]
