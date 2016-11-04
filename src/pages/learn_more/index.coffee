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
  hideDrawer: true
  isPublic: true

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
                $title: 'Exclusive community'
                $image:
                  z '.p-learn-more_step-image.number-1'
                $content:
                  z '.p-learn-more_step-content',
                    z '.description',
                      z 'p',
                        'Red Tritium is host to only the best players'
                      z 'p',
                        'Members receive a black anodized stainless steel
                        membership card with their unique member ID'
          }
          {
            $step:
              z @$step2,
                $title: 'Top-tier chat'
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
                $title: 'Data analysis'
                $image:
                  z '.p-learn-more_step-image.number-3'
                $content:
                  z '.p-learn-more_step-content',
                    z '.description',
                      z 'p',
                        'Get access to helpful data about cards and decks'
                      z 'p',
                        'Learn how powerful each card is, track your decks
                        win-rates and compare against others'
          }
          {
            $step:
              z @$requestInvite
          }
        ]
