z = require 'zorium'
Rx = require 'rx-lite'
moment = require 'moment'
require 'moment-timezone'
_merge = require 'lodash/merge'
_defaults = require 'lodash/defaults'

DeckInput = require '../deck_input'
LongForm = require '../long_form'
MarkdownEditor = require '../markdown_editor'
StepBar = require '../step_bar'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EditGuide
  constructor: ({@model, @router, guide}) ->
    step = new Rx.BehaviorSubject 1
    @$stepBar = new StepBar {step}

    selectedCards = new Rx.BehaviorSubject []
    selectedCardsStreams = new Rx.ReplaySubject 1
    selectedCardsStreams.onNext guide?.flatMapLatest((guide) =>
      @model.clashRoyaleDeck.getById guide.data.deckId
      .map (deck) ->
        deck.cards
    ) or Rx.Observable.just []
    @$deckInput = new DeckInput {@model, @router, selectedCardsStreams}

    @$step1Form = new LongForm {
      @model
      data: guide
      fields: [
        {
          hintText: 'Deck name'
          icon: 'info'
          type: 'text'
          field: 'title'
        }
        {
          hintText: 'YouTube URL (optional)'
          icon: 'video'
          type: 'text'
          field: 'data.videoUrl'
          isDataField: true
          isOptional: true
        }
        {
          hintText: 'Brief summary'
          icon: 'ellipsis'
          type: 'text'
          field: 'summary'
        }
        {
          icon: 'decks'
          field: 'deck'
          $el: @$deckInput
        }
      ]
    }
    @writeupValueStreams = new Rx.ReplaySubject 1
    @writeupValueStreams.onNext guide?.map((guide) ->
      guide.body or ''
    ) or Rx.Observable.just ''
    @$markdownEditor = new MarkdownEditor {
      @model
      valueStreams: @writeupValueStreams
    }

    @state = z.state
      guide: guide
      step: step
      isLoading: false
      writeupValue: @writeupValueStreams.switch()

  save: (isNewGuide) =>
    {guide, writeupValue} = @state.getValue()
    diff = _merge @$step1Form.getSaveDiff(), {
      body: writeupValue
    }

    @state.set isLoading: true
    (if isNewGuide
      @model.thread.create _defaults diff, {
        type: 'guide'
      }
    else
      @model.thread.updateById guide.id, diff
    ).then (newGuide) =>
      @state.set isLoading: false
      id = newGuide?.id or guide?.id
      @router.go "/thread/#{id}"

  render: ({isNewGuide} = {}) =>
    {step, isLoading, writeupValue} = @state.getValue()

    z '.z-edit-guide',
      z '.g-grid',
        z '.content',
          if step is 1
            @$step1Form
          else
            z @$markdownEditor, {hintText: 'Full guide writeup...'}
      z @$stepBar, {
        isLoading: isLoading
        isStepCompleted: if step is 1 \
                          then @$step1Form.isCompleted()
                          else true
        save:
          text: if isNewGuide then 'Create' else 'Save'
          onclick: =>
            @save isNewGuide
        steps: 2
      }
