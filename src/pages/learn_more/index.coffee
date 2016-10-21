z = require 'zorium'

config = require '../../config'
Head = require '../../components/head'
SlideSteps = require '../../components/slide_steps'
SlideStep = require '../../components/slide_step'
RequestInvite = require '../../components/request_invite'
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
    @$requestInvite = new RequestInvite {model, @router}

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
            $step:
              z @$step1,
                $title: 'Superior chat'
                $image:
                  z '.p-learn-more_step-image.number-1'
                $content:
                  z '.p-learn-more_step-content',
                    z '.description',
                      z 'p',
                        'Red Tritium is host to only the most elite players'
                      z 'p',
                        'Members receive a black anodized stainless steel
                        membership card with their unique member ID'
          }
          {
            $step:
              z @$step2,
                $title: 'Superior chat'
                $image:
                  z '.p-learn-more_step-image.number-2'
                $content:
                  z '.p-learn-more_step-content',
                    z '.description',
                      z 'p',
                        'Communication is at the heart of Red Tritium'
                      z 'p',
                        'Discuss strategies and socialize with the absolute best
                        players in the world'
          }
          {
            $step:
              z @$step3,
                $title: 'First class support'
                $image:
                  z '.p-learn-more_step-image.number-3'
                $content:
                  z '.p-learn-more_step-content',
                    z '.description',
                      z 'p',
                        'Red Tritium will make your experience better'
                      z 'p',
                        'Fast and reliable support will ensure that nothing
                        detracts from the game experience'
          }
          {
            $step:
              z @$requestInvite
          }
        ]
