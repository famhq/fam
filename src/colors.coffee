_defaults = require 'lodash/defaults'
_mapValues = require 'lodash/mapValues'

materialColors = require './material_colors'

colors = _defaults {
  # http://mcg.mbitson.com
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
  eclihpse:
    '--header-100': '#634E93' # t300
    '--header-500': '#180153' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#FF5D00' #p500

    '--primary-50': '#FFECE0'
    '--primary-100': '#FFCEB3'
    '--primary-200': '#FFAE80'
    '--primary-300': '#FF8E4D'
    '--primary-400': '#FF7526'
    '--primary-500': '#FF5D00'
    '--primary-50096': 'rgba(255, 93, 0, 0.96)'
    '--primary-600': '#FF5500'
    '--primary-700': '#FF4B00'
    '--primary-800': '#FF4100'
    '--primary-900': '#FF3000'

    '--tertiary-50': '#E3E1E7'
    '--tertiary-100': '#E3E1E7'
    '--tertiary-200': '#B8B3C4'
    '--tertiary-300': '#89809D'
    '--tertiary-400': '#362758'
    '--tertiary-500': '#12013A'
    '--tertiary-600': '#100134'
    '--tertiary-700': '#0D012C'
    '--tertiary-800': '#0A0125'
    '--tertiary-900': '#050018'
    '--tertiary-90054': 'rgba(11, 1, 55, 0.54)'
  nickatnyte:
    '--header-100': '#E7F1BD' # p100
    '--header-500': '#AED123' #p500
    '--header-500-text': materialColors.$black
    '--header-500-text-54': materialColors.$black54
    '--header-500-icon': '#3D0563' #t500

    # '--primary-50': '#E0FCF1'
    # '--primary-100': '#E0FCF1'
    # '--primary-200': '#B3F7DC'
    # '--primary-300': '#80F2C4'
    # '--primary-400': '#26E99B'
    # '--primary-500': '#00e581'
    # '--primary-600': '#00E281'
    # '--primary-700': '#00DE76'
    # '--primary-800': '#00DA6C'
    # '--primary-900': '#21ca68'
    # '--primary-90054': 'rgba(0, 211, 89, 0.54)'
    # '--primary-500-text': materialColors.$black

    '--primary-50': '#F5F9E5'
    '--primary-100': '#E7F1BD'
    '--primary-200': '#D7E891'
    '--primary-300': '#C6DF65'
    '--primary-400': '#BAD844'
    '--primary-500': '#AED123'
    '--primary-600': '#A7CC1F'
    '--primary-700': '#9DC61A'
    '--primary-800': '#94C015'
    '--primary-900': '#84B50C'
    '--primary-90054': 'rgba(132, 181, 12, 0.54)'
    '--primary-500-text': materialColors.$black

    '--tertiary-50': '#E8E1EC'
    '--tertiary-100': '#E8E1EC'
    '--tertiary-200': '#C5B4D0'
    '--tertiary-300': '#9E82B1'
    '--tertiary-400': '#5A2B7A'
    '--tertiary-500': '#3D0563'
    '--tertiary-50096': 'rgba(61, 5, 99, 0.96)'
    '--tertiary-600': '#37045B'
    '--tertiary-700': '#2F0451'
    '--tertiary-800': '#270347'
    '--tertiary-900': '#1A0135'

    # '--tertiary-50': '#EEE7FA'
    # '--tertiary-100': '#D6C4F2'
    # '--tertiary-200': '#BA9DEA'
    # '--tertiary-300': '#9E76E2'
    # '--tertiary-400': '#8A58DB'
    # '--tertiary-500': '#652bc5'
    # '--tertiary-50096': 'rgba(101, 43, 197, 0.96)'
    # '--tertiary-600': '#5927b0'
    # '--tertiary-700': '#481ca0'
    # '--tertiary-800': '#431f91'
    # '--tertiary-900': '#2d0c85'
  withzack:
    '--header-100': '#99A5A6' # t300
    '--header-500': '#273B3D' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    # '--header-500-icon': '#F237F2' #p500
    '--header-500-icon': '#FF5D00' #p500

    # pink
    # '--primary-50': '#FDE7FD'
    # '--primary-100': '#FDE7FD'
    # '--primary-200': '#FBC3FB'
    # '--primary-300': '#F99BF9'
    # '--primary-400': '#F455F4'
    # '--primary-500': '#F237F2'
    # '--primary-50096': 'rgba(245, 30, 245, 0.96)'
    # '--primary-600': '#F031F0'
    # '--primary-700': '#EE2AEE'
    # '--primary-800': '#EC23EC'
    # '--primary-900': '#E816E8'

    '--primary-50': '#FFECE0'
    '--primary-100': '#FFCEB3'
    '--primary-200': '#FFAE80'
    '--primary-300': '#FF8E4D'
    '--primary-400': '#FF7526'
    '--primary-500': '#FF5D00'
    '--primary-50096': 'rgba(255, 93, 0, 0.96)'
    '--primary-600': '#FF5500'
    '--primary-700': '#FF4B00'
    '--primary-800': '#FF4100'
    '--primary-900': '#FF3000'

    '--tertiary-50': '#E7E9EA'
    '--tertiary-100': '#E7E9EA'
    '--tertiary-200': '#C2C9CA'
    '--tertiary-300': '#99A5A6'
    '--tertiary-400': '#526668'
    '--tertiary-500': '#334B4D'
    '--tertiary-600': '#2E4446'
    '--tertiary-700': '#273B3D'
    '--tertiary-800': '#203334'
    '--tertiary-900': '#142325'
    '--tertiary-90054': 'rgba(11, 30, 32, 0.54)'
  fortnite:
    '--header-100': '#F4E5FC' # t300
    '--header-500': '#A427E3' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#fff' #p500

    '--primary-50': '#F4E5FC'
    '--primary-100': '#F4E5FC'
    '--primary-200': '#E4BEF7'
    '--primary-300': '#D293F1'
    '--primary-400': '#B247E7'
    '--primary-500': '#A427E3'
    '--primary-50096': 'rgba(164, 39, 227, 0.96)'
    '--primary-600': '#9C23E0'
    '--primary-700': '#921DDC'
    '--primary-800': '#8917D8'
    '--primary-900': '#780ED0'

    '--tertiary-500': '#191b1c'
    '--tertiary-700': '#111416'
    '--tertiary-900': '#000000'

  brawlstars:
    '--header-100': '#FFF7E0' # t300
    '--header-500': '#FFBB00' #t700
    '--header-500-text': materialColors.$black
    '--header-500-text-54': materialColors.$black54
    '--header-500-icon': materialColors.$black

    '--primary-50': '#FFF7E0'
    '--primary-100': '#FFF7E0'
    '--primary-200': '#FFEBB3'
    '--primary-300': '#FFDD80'
    '--primary-400': '#FFC526'
    '--primary-500': '#FFBB00'
    '--primary-600': '#FFB500'
    '--primary-700': '#FFAC00'
    '--primary-800': '#FFA400'
    '--primary-900': '#FF9600'
    '--primary-500-text': materialColors.$black

    '--tertiary-50': '#E8E8E8'
    '--tertiary-100': '#C7C7C7'
    '--tertiary-200': '#A1A1A1'
    '--tertiary-300': '#7B7B7B'
    '--tertiary-400': '#5F5F5F'
    '--tertiary-500': '#434343'
    '--tertiary-600': '#3D3D3D'
    '--tertiary-700': '#343434'
    '--tertiary-800': '#2C2C2C'
    '--tertiary-900': '#1E1E1E'

  clashroyale:
    '--header-100': '#80A4C3' # t300
    '--header-500': '#003973' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': materialColors.$white#'#FFAA00' #p500

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

    # '--tertiary-50': '#E0E9F0'
    # '--tertiary-100': '#E0E9F0'
    # '--tertiary-200': '#B3C8DB'
    # '--tertiary-300': '#80A4C3'
    # '--tertiary-400': '#266498'
    # '--tertiary-500': '#004986'
    # '--tertiary-600': '#00427E'
    # '--tertiary-700': '#003973'
    # '--tertiary-800': '#003169'
    # '--tertiary-900': '#002156'

  ferg:
    '--header-100': '#E7EFF3' # t300
    '--header-500': '#27648D' #t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#ff3094' #p500

    '--drawer-header-500': '#ff3094' #t700
    '--drawer-header-500-text': materialColors.$white

    '--status-bar-500': '#154772'

    '--primary-50': '#fff'#'#FDE4F0'
    '--primary-100': '#fff'#'#FDE4F0'
    '--primary-200': '#fff'#'#FBBBDA'
    '--primary-300': '#fff'#'#F88EC2'
    '--primary-400': '#fff'#'#F33F96'
    '--primary-500': '#fff'#'#F11D84'
    '--primary-600': '#fff'#'#EF1A7C'
    '--primary-700': '#fff'#'#ED1571'
    '--primary-800': '#fff'#'#EB1167'
    '--primary-900': '#fff'#'#E70A54'
    '--primary-500-text': '#ff3094'

    '--tertiary-50': '#E7EFF3'
    '--tertiary-100': '#E7EFF3'
    '--tertiary-200': '#C2D6E2'
    '--tertiary-300': '#9ABBCF'
    '--tertiary-400': '#528BAD'
    '--tertiary-500': '#34779F'
    '--tertiary-600': '#2F6F97'
    '--tertiary-700': '#27648D'
    '--tertiary-800': '#215A83'
    '--tertiary-900': '#154772'

  # clashroyalelight:
  #   '--header-100': '#C8DCFC' # p100
  #   '--header-500': '#488BF4' # p500
  #   '--header-500-text': materialColors.$white
  #   '--header-500-text-54': materialColors.$white54
  #   '--header-500-icon': materialColors.$white
  #
  #   '--primary-50': '#E9F1FE'
  #   '--primary-100': '#C8DCFC'
  #   '--primary-200': '#A4C5FA'
  #   '--primary-300': '#7FAEF7'
  #   '--primary-400': '#639CF6'
  #   '--primary-500': '#488BF4'
  #   '--primary-600': '#4183F3'
  #   '--primary-700': '#3878F1'
  #   '--primary-800': '#306EEF'
  #   '--primary-900': '#215BEC'
  #
  #   '--tertiary-50': '#444444'
  #   '--tertiary-100': '#555555'
  #   '--tertiary-200': '#777777'
  #   '--tertiary-300': '#888888'
  #   '--tertiary-400': '#CCCCCC'
  #   '--tertiary-500': '#eaeaea'
  #   '--tertiary-600': '#efefef'
  #   '--tertiary-700': '#ffffff'
  #   '--tertiary-800': '#f0f0f0'
  #   '--tertiary-900': '#f4f4f4'
  #   '--tertiary-90012': 'rgba(255, 255, 255, 0.12)'
  #   '--tertiary-90054': 'rgba(255, 255, 255, 0.54)'
  #   '--tertiary-100-text': materialColors.$black
  #   '--tertiary-200-text': materialColors.$black
  #   '--tertiary-300-text': materialColors.$black
  #   '--tertiary-400-text': materialColors.$black
  #   '--tertiary-500-text': materialColors.$black
  #   '--tertiary-500-text-70': materialColors.$black70
  #   '--tertiary-600-text': materialColors.$black
  #   '--tertiary-700-text': materialColors.$black
  #   '--tertiary-800-text': materialColors.$black
  #   '--tertiary-900-text': materialColors.$black
  #   '--tertiary-900-text-12': materialColors.$black12
  #   '--tertiary-900-text-54': materialColors.$black54
  default:
    '--header-500': '#171a1c' # t700
    '--header-500-text': materialColors.$white
    '--header-500-text-54': materialColors.$white54
    '--header-500-icon': '#ff8a00' # p500

    '--primary-100': materialColors.$orange100
    '--primary-200': materialColors.$orange200
    '--primary-300': materialColors.$orange300
    '--primary-400': materialColors.$orange300
    '--primary-500': '#ff8a00'
    '--primary-50096': 'rgba(255, 138, 0, 0.96)'
    '--primary-600': materialColors.$orange600
    '--primary-700': '#e86f00'
    '--primary-800': materialColors.$orange800
    '--primary-900': materialColors.$orange900
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

  '$drawerHeader500': 'var(--drawer-header-500)'
  '$drawerHeader500Text': 'var(--drawer-header-500-text)'

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
  '$common': '#3e4447'
  '$rare': materialColors.$blue500
  '$epic': materialColors.$purple500
  '$legendary': materialColors.$orange500
  '$commonText': materialColors.$white
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
