Rx = require 'rx-lite'
_find = require 'lodash/find'

addons = [
  {
    id: '401472e2-d9b2-4a30-9dd3-b1434e1c5e17'
    lang:
      en:
        name: 'Card Maker'
        description: 'Create any imaginary card you want!'
    url: 'https://www.clashroyalecardmaker.com/'
    iconUrl: 'https://www.clashroyalecardmaker.com/android-icon-192x192.png'
    creator:
      username: 'dabolus'
      name: 'Dabolus'
  }
]

module.exports = class Addon
  namespace: 'addon'

  constructor: ({@auth, @l}) -> null

  getLang: (addon) =>
    addon?.lang[@l.getLanguageStr()] or addon?.lang['en']

  getById: (id) ->
    Rx.Observable.just _find addons, {id}

  getAll: ->
    Rx.Observable.just addons
    # @auth.stream "#{@namespace}.getAll", {}
