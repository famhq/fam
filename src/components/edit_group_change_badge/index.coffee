_ = require 'lodash'
z = require 'zorium'
log = require 'loga'
Rx = require 'rx-lite'

Icon = require '../icon'
AppBar = require '../app_bar'
ButtonBack = require '../button_back'
GroupHeader = require '../group_header'
GroupBadge = require '../group_badge'
colors = require '../../colors'
config = require '../../config'

if window?
  require './index.styl'

module.exports = class EditGroupChangeBadge
  constructor: (options) ->
    {@model, @router, @group,
      @selectedBadgeStreams, @selectedBackgroundStreams} = options

    me = @model.user.getMe()

    @$appBar = new AppBar {@model}
    @$buttonBack = new ButtonBack {@model, @router}
    @$groupHeader = new GroupHeader {@group}

    @$groupBadges = _.map config.BADGES, (id) =>
      new GroupBadge {@group}

    @state = z.state
      me: me
      group: @group
      selectedBadge: @selectedBadgeStreams.switch()
      selectedBackground: @selectedBackgroundStreams.switch()

  render: ({onBack}) =>
    {me, selectedBadge, selectedBackground, group} = @state.getValue()

    z '.z-edit-group-change-badge',
      z @$appBar, {
        title: 'Group badge'
        $topLeftButton: z @$buttonBack, {
          color: colors.$tertiary900
          onclick: onBack
        }
        isFlat: true
      }
      z @$groupHeader, {
        badgeId: selectedBadge
        background: selectedBackground
      }
      z '.content',
        z '.g-grid',
          z '.title', 'Background Color'
        z '.g-grid',
          z '.g-cols',
            _.map config.BACKGROUNDS, (background) =>
              bgUrl = "#{config.CDN_URL}/groups/backgrounds/" +
                      "#{background}_bg.jpg"
              z '.g-col.g-xs-3.g-md-1',
                z '.background-color', {
                  className: z.classKebab {
                    isSelected: background is selectedBackground
                  }
                  style:
                    backgroundImage: if bgUrl \
                                     then "url(#{bgUrl})"
                                     else 'none'
                  onclick: =>
                    @selectedBackgroundStreams.onNext(
                      Rx.Observable.just background
                    )
                }
        z '.g-grid',
          z '.title', 'Badge'
        z '.g-grid',
          z '.g-cols',
            _.map config.BADGES, (id) =>
              z '.g-col.g-xs-3.g-md-1',
                z @$groupBadges[id], {
                  badgeId: id
                  onclick: =>
                    @selectedBadgeStreams.onNext Rx.Observable.just id
                }
