z = require 'zorium'
_map = require 'lodash/map'

Icon = require '../icon'
Fab = require '../fab'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupManagePages
  constructor: ({@model, @router, group}) ->

    @$fab = new Fab()
    @$addIcon = new Icon()

    @state = z.state {
      group
      pages: group.switchMap (group) =>
        @model.groupPage.getAllByGroupId group.id
      me: @model.user.getMe()
    }

  render: =>
    {me, group, pages} = @state.getValue()

    z '.z-group-manage-pages',
      z '.pages',
        _map pages, (page) =>
          @router.link z 'a.page', {
            href: @model.group.getPath group, 'groupEditPage', {@router}
          },
            page.data.title

      z '.fab',
        z @$fab,
          colors:
            c500: colors.$primary500
          $icon: z @$addIcon, {
            icon: 'add'
            isTouchTarget: false
            color: colors.$primary500Text
          }
          onclick: =>
            @model.group.goPath group, 'groupNewPage', {@router}
