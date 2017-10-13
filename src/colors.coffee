_defaults = require 'lodash/defaults'

materialColors = require './material_colors.json'

module.exports = _defaults {
  '$primary100': materialColors.$red100
  '$primary200': materialColors.$red200
  '$primary300': materialColors.$red300
  '$primary400': '#fc5b61'
  '$primary500': '#fc373e'
  '$primary50096': 'rgba(252, 55, 62, 0.96)'
  '$primary600': '#e63239'
  '$primary700': '#cf2e33'
  '$primary800': materialColors.$red800
  '$primary900': materialColors.$red900
  '$primary100Text': materialColors.$red900Text
  '$primary200Text': materialColors.$red900Text
  '$primary300Text': materialColors.$red900Text
  '$primary400Text': materialColors.$red900Text
  '$primary500Text': materialColors.$red900Text
  '$primary600Text': materialColors.$red600Text
  '$primary700Text': materialColors.$red700Text
  '$primary800Text': materialColors.$red800Text
  '$primary900Text': materialColors.$red900Text

  '$secondary100': materialColors.$white
  '$secondary200': materialColors.$white
  '$secondary300': materialColors.$white
  '$secondary400': materialColors.$white
  '$secondary500': '#ffc800'
  '$secondary600': materialColors.$white
  '$secondary700': materialColors.$white
  '$secondary800': materialColors.$white
  '$secondary900': materialColors.$white
  '$secondary100Text': materialColors.$blueGrey900
  '$secondary200Text': materialColors.$blueGrey900
  '$secondary300Text': materialColors.$blueGrey900
  '$secondary400Text': materialColors.$blueGrey900
  '$secondary500Text': materialColors.$blueGrey900
  '$secondary600Text': materialColors.$blueGrey900
  '$secondary700Text': materialColors.$blueGrey900
  '$secondary800Text': materialColors.$blueGrey900
  '$secondary900Text': materialColors.$blueGrey900

  '$tertiary100': materialColors.$grey100
  '$tertiary200': materialColors.$grey200
  '$tertiary300': '#84898a'
  '$tertiary400': materialColors.$grey400
  '$tertiary500': '#202527'
  '$tertiary600': '#282828'
  '$tertiary700': '#171a1c'
  '$tertiary800': materialColors.$grey800
  '$tertiary900': '#0e1011'
  '$tertiary100Text': materialColors.$white
  '$tertiary200Text': materialColors.$white
  '$tertiary300Text': materialColors.$white
  '$tertiary400Text': materialColors.$white
  '$tertiary500Text': materialColors.$white
  '$tertiary600Text': materialColors.$white
  '$tertiary700Text': materialColors.$white
  '$tertiary800Text': materialColors.$white
  '$tertiary900Text': materialColors.$white

  '$white4': 'rgba(255, 255, 255, 0.04)'
  '$white54': 'rgba(255, 255, 255, 0.54)'

  '$black': '#0c0c0c'

  '$purple500': '#dd00e2'

  '$tabSelected': materialColors.$white
  '$tabUnselected': '#1a1a1a'

  '$tabSelectedAlt': materialColors.$white
  '$tabUnselectedAlt': materialColors.$white54

  '$transparent': 'rgba(0, 0, 0, 0)'
  '$common': '#00E676'
  '$rare': '#3D5AFE'
  '$epic': '#D500F9'
  '$legendary': '#FF9100'
  '$commonText': materialColors.$blueGrey900
  '$rareText': materialColors.$white
  '$epicText': materialColors.$white
  '$legendaryText': materialColors.$white
}, materialColors
