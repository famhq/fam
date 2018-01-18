_defaults = require 'lodash/defaults'

materialColors = require './material_colors'

module.exports = _defaults {
  # TODO: move this to db
  playhard:
    '--primary-50': '#FCE5E7'
    '--primary-100': '#F8BEC2'
    '--primary-200': '#F4939A'
    '--primary-300': '#F06871'
    '--primary-400': '#EC4752'
    '--primary-500': '#E92734'
    '--primary-50096': '#E92734'
    '--primary-600': '#E6232F'
    '--primary-700': '#E31D27'
    '--primary-800': '#DF1721'
    '--primary-900': '#D90E15'

    '--tertiary-50': '#E5E5E6'
    '--tertiary-100': '#BEBFC1'
    '--tertiary-200': '#929498'
    '--tertiary-300': '#66696E'
    '--tertiary-400': '#46484F'
    '--tertiary-500': '#252830'
    '--tertiary-600': '#21242B'
    '--tertiary-700': '#1B1E24'
    '--tertiary-800': '#16181E'
    '--tertiary-900': '#0D0F13'
  default:
    '--primary-100': materialColors.$red100
    '--primary-200': materialColors.$red200
    '--primary-300': materialColors.$red300
    '--primary-400': '#fc5b61'
    '--primary-500': '#fc373e'
    '--primary-50096': 'rgba(252, 55, 62, 0.96)'
    '--primary-600': '#e63239'
    '--primary-700': '#cf2e33'
    '--primary-800': materialColors.$red800
    '--primary-900': materialColors.$red900

    '--tertiary-100': materialColors.$grey100
    '--tertiary-200': materialColors.$grey200
    '--tertiary-300': '#84898a'
    '--tertiary-400': '#3e4447'
    '--tertiary-500': '#202527'
    '--tertiary-600': '#1d2226'
    '--tertiary-700': '#171a1c'
    '--tertiary-800': materialColors.$grey800
    '--tertiary-900': '#0e1011'














  '$primary50': 'var(--primary-50)'
  '$primary100': 'var(--primary-100)'
  '$primary200': 'var(--primary-200)'
  '$primary300': 'var(--primary-300)'
  '$primary400': 'var(--primary-400)'
  '$primary500': 'var(--primary-500)'
  '$primary50096': 'var(--primary-50096)'
  '$primary600': 'var(--primary-600)'
  '$primary700': 'var(--primary-700)'
  '$primary800': 'var(--primary-800)'
  '$primary900': 'var(--primary-900)'
  # TODO: move rest to vars
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


  '$tertiary50': 'var(--tertiary-50)'
  '$tertiary100': 'var(--tertiary-100)'
  '$tertiary200': 'var(--tertiary-200)'
  '$tertiary300': 'var(--tertiary-300)'
  '$tertiary400': 'var(--tertiary-400)'
  '$tertiary500': 'var(--tertiary-500)'
  '$tertiary600': 'var(--tertiary-600)'
  '$tertiary700': 'var(--tertiary-700)'
  '$tertiary800': 'var(--tertiary-800)'
  '$tertiary900': 'var(--tertiary-900)'
  '$tertiary100Text': materialColors.$white
  '$tertiary200Text': materialColors.$white
  '$tertiary300Text': materialColors.$white
  '$tertiary400Text': materialColors.$white
  '$tertiary500Text': materialColors.$white
  '$tertiary500Text70': materialColors.$white70
  '$tertiary600Text': materialColors.$white
  '$tertiary700Text': materialColors.$white
  '$tertiary800Text': materialColors.$white
  '$tertiary900Text': materialColors.$white

  '$quaternary500': '#ff7b45'

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
