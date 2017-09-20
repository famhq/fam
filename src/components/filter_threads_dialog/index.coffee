z = require 'zorium'
Rx = require 'rx-lite'
_map = require 'lodash/map'
_upperFirst = require 'lodash/upperFirst'
_camelCase = require 'lodash/camelCase'

Dialog = require '../dialog'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class FilterThreadsDialog
  constructor: ({@model, @isVisible, @filter}) ->
    @selectedSort = new Rx.BehaviorSubject 'popular'
    @selectedFilter = new Rx.BehaviorSubject 'all'

    @$dialog = new Dialog()

    @state = z.state
      selectedSort: @selectedSort
      selectedFilter: @selectedFilter

  updateFilter: =>
    {selectedSort, selectedFilter} = @state.getValue()
    @filter.onNext {
      sort: selectedSort
      filter: selectedFilter
    }

  render: =>
    {selectedSort, selectedFilter} = @state.getValue()

    sortOptions = [
      {key: 'popular'}
      {key: 'new'}
    ]

    filterOptions = [
      {key: 'all'}
      {key: 'deckGuide'}
    ]

    z '.z-filter-threads-dialog',
      z @$dialog,
        isVanilla: true
        onLeave: =>
          @isVisible.onNext false
        # $title: @model.l.get 'general.filter'
        $content:
          z '.z-filter-threads-dialog_dialog',
            z '.subhead', @model.l.get 'general.sort'
            _map sortOptions, ({key}) =>
              pascalKey = _upperFirst _camelCase key
              z 'label.option',
                z 'input.radio',
                  type: 'radio'
                  name: 'sort'
                  value: key
                  checked: selectedSort is key
                  onchange: =>
                    @selectedSort.onNext key
                z '.text',
                  @model.l.get "filterThreadsDialog.sort#{pascalKey}"

            z '.subhead', @model.l.get 'general.filter'
            _map filterOptions, ({key, name}) =>
              pascalKey = _upperFirst _camelCase key
              z 'label.option',
                z 'input.radio',
                  type: 'radio'
                  name: 'filter'
                  value: key
                  checked: selectedFilter is key
                  onchange: =>
                    @selectedFilter.onNext key
                z '.text',
                  @model.l.get "filterThreadsDialog.filter#{pascalKey}"

        cancelButton:
          text: @model.l.get 'general.cancel'
          onclick: =>
            @isVisible.onNext false
        submitButton:
          text: @model.l.get 'general.done'
          onclick: =>
            @updateFilter()
            @isVisible.onNext false
