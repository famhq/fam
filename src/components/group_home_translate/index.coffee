z = require 'zorium'
_map = require 'lodash/map'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'

Base = require '../base'
Spinner = require '../spinner'
UiCard = require '../ui_card'
FormatService = require '../../services/format'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class GroupHomeChat
  constructor: ({@model, @router, group, @isTranslateCardVisibleStreams}) ->
    me = @model.user.getMe()

    @$spinner = new Spinner()
    @$uiCard = new UiCard()

    @state = z.state {
      group
      language: @model.l.getLanguage()
    }

  render: =>
    {group, language} = @state.getValue()

    translation =
      ko: '한국어'
      ja: '日本語'
      zh: '中文'
      de: 'deutsche'
      es: 'español'
      pt: 'português'


    z '.z-group-home-translate',
      z @$uiCard,
        # isHighlighted: true
        $title: @model.l.get 'translateCard.request1'
        $content:
          @model.l.get 'translateCard.request2', {
            replacements:
              language: translation[language]
            }
        cancel:
          text: @model.l.get 'translateCard.cancelText'
          onclick: =>
            localStorage['hideTranslateCard'] = '1'
            @isTranslateCardVisibleStreams.next(
              RxObservable.of false
            )
        submit:
          text: @model.l.get 'translateCard.submit'
          onclick: =>
            ga? 'send', 'event', 'translate', 'click', language
            @model.portal.call 'browser.openWindow',
              url: 'https://crowdin.com/project/starfire'
              target: '_system'
