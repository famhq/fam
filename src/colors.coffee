paperColors = require 'zorium-paper/colors.json'
_defaults = require 'lodash/defaults'

module.exports = _defaults {
  '$primary100': paperColors.$red100
  '$primary200': paperColors.$red200
  '$primary300': paperColors.$red300
  '$primary400': '#fc5b61'
  '$primary500': '#fc373e'
  '$primary50096': 'rgba(252, 55, 62, 0.96)'
  '$primary600': '#e63239'
  '$primary700': '#cf2e33'
  '$primary800': paperColors.$red800
  '$primary900': paperColors.$red900
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
  '$secondary500': '#ffc800'
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
  '$tertiary300': '#84898a'
  '$tertiary400': paperColors.$grey400
  '$tertiary500': '#202527'
  '$tertiary600': '#282828'
  '$tertiary700': '#171a1c'
  '$tertiary800': paperColors.$grey800
  '$tertiary900': '#0e1011'
  '$tertiary100Text': paperColors.$white
  '$tertiary200Text': paperColors.$white
  '$tertiary300Text': paperColors.$white
  '$tertiary400Text': paperColors.$white
  '$tertiary500Text': paperColors.$white
  '$tertiary600Text': paperColors.$white
  '$tertiary700Text': paperColors.$white
  '$tertiary800Text': paperColors.$white
  '$tertiary900Text': paperColors.$white

  '$white4': 'rgba(255, 255, 255, 0.04)'
  '$white54': 'rgba(255, 255, 255, 0.54)'

  '$black': '#0c0c0c'

  '$purple500': '#dd00e2'

  '$tabSelected': paperColors.$white
  '$tabUnselected': '#1a1a1a'

  '$tabSelectedAlt': paperColors.$white
  '$tabUnselectedAlt': paperColors.$white54

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
