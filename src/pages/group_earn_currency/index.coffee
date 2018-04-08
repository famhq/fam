z = require 'zorium'

AppBar = require '../../components/app_bar'
ButtonMenu = require '../../components/button_menu'
GroupEarnCurrency = require '../../components/group_earn_currency'
Icon = require '../../components/icon'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class GroupEarnCurrencyPage
  isGroup: true

  constructor: (options) ->
    {@model, @requests, @router, serverData, overlay$, group} = options

    @$appBar = new AppBar {@model}
    @$buttonMenu = new ButtonMenu {@model, @router}
    @$groupEarnCurrency = new GroupEarnCurrency {@model, @router, group}

    @state = z.state
      me: @model.user.getMe()
      group: group
      windowSize: @model.window.getSize()

  getMeta: =>
    {group} = @state.getValue()

    {
      title: @model.l.get 'groupEarnCurrencyPage.title', {
        replacements:
          currency: group?.currency?.name
      }
    }

  render: =>
    {me, windowSize, group} = @state.getValue()

    z '.p-group-earn-currency', {
      style:
        height: "#{windowSize.height}px"
    },
      z @$appBar, {
        title: @model.l.get 'groupEarnCurrencyPage.title', {
          replacements:
            currency: group?.currency?.name
        }
        isFlat: true
        $topLeftButton: z @$buttonMenu, {
          color: colors.$header500Icon
        }
      }
      z @$groupEarnCurrency
