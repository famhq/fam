z = require 'zorium'
_isEmpty = require 'lodash/isEmpty'
_map = require 'lodash/map'
_truncate = require 'lodash/truncate'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/operator/switchMap'
require 'rxjs/add/operator/map'

Spinner = require '../spinner'
FormattedText = require '../formatted_text'

if window?
  require './index.styl'

MAX_TITLE_LENGTH = 60

module.exports = class GroupPage
  constructor: ({@model, @router, group, groupPage}) ->
    @$spinner = new Spinner()

    @$body = new FormattedText {
      @model, @router, isFullWidth: true
      text: groupPage.map (groupPage) ->
        groupPage?.data?.body
    }

    @state = z.state {
      groupPage: groupPage
    }

  afterMount: (@$$el) => null

  render: =>
    {groupPage} = @state.getValue()

    z '.z-group-page',
      if groupPage
        z '.g-grid',
          @$body
      else
        @$spinner
