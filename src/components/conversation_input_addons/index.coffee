z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_kebabCase = require 'lodash/kebabCase'
supportsWebP = window? and require 'supports-webp'
RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/of'
require 'rxjs/add/observable/combineLatest'
require 'rxjs/add/operator/filter'
require 'rxjs/add/operator/map'
require 'rxjs/add/operator/debounceTime'

SearchInput = require '../search_input'
AddonListItem = require '../addon_list_item'
Spinner = require '../spinner'
colors = require '../../colors'

if window?
  require './index.styl'

SEARCH_DEBOUNCE = 300

module.exports = class ConversationInputAddons
  constructor: ({@model, @router, @message, @onPost, currentPanel, group}) ->
    @searchValue = new RxBehaviorSubject null
    debouncedSearchValue = @searchValue.debounceTime(SEARCH_DEBOUNCE)

    @$searchInput = new SearchInput {@model, @searchValue}
    @$spinner = new Spinner()

    allAddons = group.switchMap (group) =>
      @model.addon.getAllByGroupId group?.id

    currentPanelAndSearchValueAndAllAddons = RxObservable.combineLatest(
      currentPanel
      debouncedSearchValue
      allAddons
      (vals...) -> vals
    )

    addons = currentPanelAndSearchValueAndAllAddons.map (vals) =>
      [currentPanel, query, allAddons] = vals
      if currentPanel is 'addons'
        if query
          filteredAddons = _filter allAddons, (addon) =>
            title = @model.l.get("#{addon.key}.title", {file: 'addons'})
            title.toLowerCase().indexOf(query.toLowerCase()) isnt -1
        else
          filteredAddons = allAddons
        _map filteredAddons, (addon) =>
          addon: addon
          $el: new AddonListItem {
            @model
            @router
            addon
          }
      else
        RxObservable.of null

    @state = z.state
      addons: addons
      windowSize: @model.window.getSize()

  getHeightPx: ->
    RxObservable.of 114

  render: =>
    {addons, windowSize} = @state.getValue()

    isLoading = false

    z '.z-conversation-input-addons',
      z @$searchInput, {
        isSearchIconRight: true
        height: '36px'
        bgColor: colors.$tertiary500
        placeholder: @model.l.get 'conversationInputAddons.hintText'
      }
      z '.addons', {
        # style: width: "#{windowSize.width - drawerWidth}px"
        ontouchstart: (e) ->
          e?.stopPropagation()
      },
        if isLoading
          z @$spinner, {hasTopMargin: false}
        else
          _map addons, (addonItem = {}) =>
            {addon, $el} = addonItem
            z '.addon',
              z $el, {
                hasPadding: false
                onclick: =>
                  title = @model.l.get("#{addon.key}.title", {file: 'addons'})
                  path = @router.get 'toolByKey', {
                    key: _kebabCase addon.key
                  }

                  @message.next "[#{title}](#{path} " +
                                "\"addon:#{addon.key}\")"
                  @onPost()
              }
