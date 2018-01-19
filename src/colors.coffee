_defaults = require 'lodash/defaults'
_mapValues = require 'lodash/mapValues'

materialColors = require './material_colors'

colors = _defaults {
  # TODO: move this to db
  playhard:
    '--header-100': '#66696E' # t300
    '--header-500': '#1B1E24' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#E92734' #p500

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
    '--tertiary-100': '#E5E5E6'
    '--tertiary-200': '#BEBFC1'
    '--tertiary-300': '#929498'
    '--tertiary-400': '#46484F'
    '--tertiary-500': '#252830'
    '--tertiary-600': '#21242B'
    '--tertiary-700': '#1B1E24'
    '--tertiary-800': '#16181E'
    '--tertiary-900': '#0D0F13'
    '--tertiary-900-text-12': 'rgba(0, 0, 0, 0.12)'
    '--tertiary-90054': 'rgba(0, 0, 0, 0.54)'
  clashroyaledark:
    '--header-100': '#80A4C3' # t300
    '--header-500': '#003973' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#FFAA00' #p500

    '--primary-50': '#FFF5E0'
    '--primary-100': '#FFE6B3'
    '--primary-200': '#FFD580'
    '--primary-300': '#FFC44D'
    '--primary-400': '#FFB726'
    '--primary-500': '#FFAA00'
    '--primary-50096': 'rgba(255, 172, 0, 96)'
    '--primary-600': '#FFA300'
    '--primary-700': '#FF9900'
    '--primary-800': '#FF9000'
    '--primary-900': '#FF7F00'
    '--primary-500-text': materialColors.$black

    '--tertiary-50': '#E0E9F0'
    '--tertiary-100': '#E0E9F0'
    '--tertiary-200': '#B3C8DB'
    '--tertiary-300': '#80A4C3'
    '--tertiary-400': '#266498'
    '--tertiary-500': '#004986'
    '--tertiary-600': '#00427E'
    '--tertiary-700': '#003973'
    '--tertiary-800': '#003169'
    '--tertiary-900': '#002156'

  clashroyalelight:
    '--header-100': '#C8DCFC' # p100
    '--header-500': '#488BF4' # p500
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': materialColors.$white

    '--primary-50': '#E9F1FE'
    '--primary-100': '#C8DCFC'
    '--primary-200': '#A4C5FA'
    '--primary-300': '#7FAEF7'
    '--primary-400': '#639CF6'
    '--primary-500': '#488BF4'
    '--primary-600': '#4183F3'
    '--primary-700': '#3878F1'
    '--primary-800': '#306EEF'
    '--primary-900': '#215BEC'

    '--tertiary-50': '#444444'
    '--tertiary-100': '#555555'
    '--tertiary-200': '#777777'
    '--tertiary-300': '#888888'
    '--tertiary-400': '#CCCCCC'
    '--tertiary-500': '#eaeaea'
    '--tertiary-600': '#efefef'
    '--tertiary-700': '#ffffff'
    '--tertiary-800': '#f0f0f0'
    '--tertiary-900': '#f4f4f4'
    '--tertiary-90012': 'rgba(255, 255, 255, 0.12)'
    '--tertiary-90054': 'rgba(255, 255, 255, 0.54)'
    '--tertiary-100-text': materialColors.$black
    '--tertiary-200-text': materialColors.$black
    '--tertiary-300-text': materialColors.$black
    '--tertiary-400-text': materialColors.$black
    '--tertiary-500-text': materialColors.$black
    '--tertiary-500-text-70': materialColors.$black70
    '--tertiary-600-text': materialColors.$black
    '--tertiary-700-text': materialColors.$black
    '--tertiary-800-text': materialColors.$black
    '--tertiary-900-text': materialColors.$black
    '--tertiary-900-text-12': materialColors.$black12
    '--tertiary-900-text-54': materialColors.$black54
  default:
    '--header-500': '#171a1c' # t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#fc373e' # p500

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
    '--primary-500-text': materialColors.$white

    '--tertiary-100': materialColors.$grey100
    '--tertiary-200': materialColors.$grey200
    '--tertiary-300': '#84898a'
    '--tertiary-400': '#3e4447'
    '--tertiary-500': '#202527'
    '--tertiary-600': '#1d2226'
    '--tertiary-700': '#171a1c'
    '--tertiary-800': materialColors.$grey800
    '--tertiary-900': '#0e1011'
    '--tertiary-90012': 'rgba(0, 0, 0, 0.12)'
    '--tertiary-90054': 'rgba(0, 0, 0, 0.54)'
    '--tertiary-100-text': materialColors.$white
    '--tertiary-200-text': materialColors.$white
    '--tertiary-300-text': materialColors.$white
    '--tertiary-400-text': materialColors.$white
    '--tertiary-500-text': materialColors.$white
    '--tertiary-500-text-70': materialColors.$white70
    '--tertiary-600-text': materialColors.$white
    '--tertiary-700-text': materialColors.$white
    '--tertiary-800-text': materialColors.$white
    '--tertiary-900-text': materialColors.$white
    '--tertiary-900-text-12': materialColors.$white12
    '--tertiary-900-text-54': materialColors.$white54

    '--test-color': '#000' # don't change













  '$header500': 'var(--header-500)'
  '$header500Text': 'var(--header-500-text)'
  '$header500Text54': 'var(--header-500-text54)'
  '$header500Icon': 'var(--header-500-icon)'

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

  '$primary500Text': 'var(--primary-500-text)'

  # TODO: move rest to vars
  '$primary100Text': materialColors.$red900Text
  '$primary200Text': materialColors.$red900Text
  '$primary300Text': materialColors.$red900Text
  '$primary400Text': materialColors.$red900Text

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
  '$tertiary90012': 'var(--tertiary-90012)'
  '$tertiary90054': 'var(--tertiary-90054)'
  '$tertiary100Text': 'var(--tertiary-100-text)'
  '$tertiary200Text': 'var(--tertiary-200-text)'
  '$tertiary300Text': 'var(--tertiary-300-text)'
  '$tertiary400Text': 'var(--tertiary-400-text)'
  '$tertiary500Text': 'var(--tertiary-500-text)'
  '$tertiary500Text70': 'var(--tertiary-500-text-70)'
  '$tertiary600Text': 'var(--tertiary-600-text)'
  '$tertiary700Text': 'var(--tertiary-700-text)'
  '$tertiary800Text': 'var(--tertiary-800-text)'
  '$tertiary900Text': 'var(--tertiary-900-text)'
  '$tertiary900Text12': 'var(--tertiary-900-text-12)'
  '$tertiary900Text54': 'var(--tertiary-900-text-54)'

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

# https://stackoverflow.com/a/4900484
getChromeVersion = ->
  raw = navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./)
  if raw then parseInt(raw[2], 10) else false

# no css-variable support
if window?
  $$el = document.getElementById('css-variable-test')
  isCssVariableSupported = not $$el or
    window.CSS?.supports?('--fake-var', 0) or
    getComputedStyle($$el, null)?.backgroundColor is 'rgb(0, 0, 0)'
  unless isCssVariableSupported
    colors = _mapValues colors, (color, key) ->
      if typeof color is 'string' and matches = color.match(/\(([^)]+)\)/)
        colors.default[matches[1]]
      else
        color

module.exports = colors
