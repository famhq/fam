paperColors = require 'zorium-paper/colors.json'
_defaults = require 'lodash/object/defaults'

module.exports = _defaults {
  '$primary100': paperColors.$red100
  '$primary200': paperColors.$red200
  '$primary300': paperColors.$red300
  '$primary400': paperColors.$red400
  '$primary500': '#ff0926'
  '$primary600': paperColors.$red600
  '$primary700': '#ea0b25'
  '$primary800': paperColors.$red800
  '$primary900': '#d60e25'
  '$primary100Text': paperColors.$red900Text
  '$primary200Text': paperColors.$red900Text
  '$primary300Text': paperColors.$red900Text
  '$primary400Text': paperColors.$red900Text
  '$primary500Text': paperColors.$red900Text
  '$primary600Text': paperColors.$red600Text
  '$primary700Text': paperColors.$red700Text
  '$primary800Text': paperColors.$red800Text
  '$primary900Text': paperColors.$red900Text

  '$secondary100': paperColors.$white
  '$secondary200': paperColors.$white
  '$secondary300': paperColors.$white
  '$secondary400': paperColors.$white
  '$secondary500': paperColors.$white
  '$secondary600': paperColors.$white
  '$secondary700': paperColors.$white
  '$secondary800': paperColors.$white
  '$secondary900': paperColors.$white
  '$secondary100Text': paperColors.$blueGrey900
  '$secondary200Text': paperColors.$blueGrey900
  '$secondary300Text': paperColors.$blueGrey900
  '$secondary400Text': paperColors.$blueGrey900
  '$secondary500Text': paperColors.$blueGrey900
  '$secondary600Text': paperColors.$blueGrey900
  '$secondary700Text': paperColors.$blueGrey900
  '$secondary800Text': paperColors.$blueGrey900
  '$secondary900Text': paperColors.$blueGrey900

  '$tertiary100': paperColors.$grey100
  '$tertiary200': paperColors.$grey200
  '$tertiary300': paperColors.$grey300
  '$tertiary400': '#2D3740'
  '$tertiary500': '#252f39'
  '$tertiary600': paperColors.$grey600
  '$tertiary700': '#1c262f'
  '$tertiary800': paperColors.$grey800
  '$tertiary900': '#171f26'
  '$tertiary100Text': paperColors.$grey100Text
  '$tertiary200Text': paperColors.$grey200Text
  '$tertiary300Text': paperColors.$grey300Text
  '$tertiary400Text': paperColors.$grey400Text
  '$tertiary500Text': paperColors.$grey500Text
  '$tertiary600Text': paperColors.$grey600Text
  '$tertiary700Text': paperColors.$grey700Text
  '$tertiary800Text': paperColors.$grey800Text
  '$tertiary900Text': paperColors.$grey900Text

  '$tabSelected': paperColors.$blueGrey900
  '$tabUnselected': paperColors.$blueGrey300

  '$tabSelectedAlt': paperColors.$white
  '$tabUnselectedAlt': paperColors.$white30

  '$kik': '#82bc23'
  '$messenger': '#0084ff'
  '$discord': '#7289da'

  '$transparent': 'rgba(0, 0, 0, 0)'
  '$common': '#00E676'
  '$rare': '#3D5AFE'
  '$epic': '#D500F9'
  '$legendary': '#FF9100'
  '$commonText': paperColors.$blueGrey900
  '$rareText': paperColors.$white
  '$epicText': paperColors.$white
  '$legendaryText': paperColors.$white
}, paperColors
