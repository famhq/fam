Rx = require 'rx-lite'
_find = require 'lodash/find'

addons = [
  {
    id: '401472e2-d9b2-4a30-9dd3-b1434e1c5e17'
    key: 'cardMaker'
    url: 'https://www.clashroyalecardmaker.com/?lang={lang}'
    iconUrl: 'https://www.clashroyalecardmaker.com/android-icon-192x192.png'
    creator:
      username: 'dabolus'
      name: 'Dabolus'
  }
  {
    id: 'f537f4b0-08cb-453c-8122-ae80e4163226'
    key: 'shopOffers'
    url: '/shop-offers'
    iconUrl: 'https://cdn.wtf/d/images/starfire/chests/legendary_chest.png'
    creator:
      username: 'austin'
      name: 'Austin'
  }
  {
    id: '8787842f-bc03-4070-a541-39062be97fdc'
    key: 'chestSimulator'
    metaDescription: 'Open Clash Royale Chests online for free.
                      Everything from Super Magical to Legendary chests.'
    url: '/simulatorTest'
    iconUrl: 'https://cdn.wtf/d/images/starfire/chests/super_magical_chest.png'
    creator:
      username: 'austin'
      name: 'Austin'
  }
  {
    id: 'db0593b5-114f-43db-9d98-0b0a88ce3d12'
    key: 'forumSignature'
    url: '/forum-signature'
    iconUrl: 'https://cdn.wtf/d/images/starfire/cards/archers_small.png'
    creator:
      username: 'austin'
      name: 'Austin'
  }
  # {
  #   id: 'db0593b5-114f-43db-9d98-0b0a88ce3d12'
  #   key: 'popularDecks'
  #   url: 'https://cr-api.com/decks'
  #   iconUrl: 'https://cdn.wtf/d/images/starfire/cards/archers_small.png'
  #   creator:
  #     username: 'smlbiobot'
  #     name: 'smlbiobot'
  # }
  # {
  #   id: '123'
  #   key: 'test'
  #   url: 'http://192.168.0.109.xip.io:3004/'
  # }
  # no https...
  # {
  #   id: '351e143d-337f-447e-880f-78e682c1183b'
  #   lang:
  #     en:
  #       name: 'Wiki'
  #       description: 'Knowledgebase of Clash Royale facts'
  #       url: 'http://clashroyale.wikia.com/wiki/Clash_Royale_Wiki'
  #       iconUrl: 'https://cdn.wtf/d/images/starfire/addons/wiki.png'
  #     es:
  #       name: 'Wiki'
  #       description: 'Knowledgebase of Clash Royale facts'
  #       url: 'http://es.clash-royale.wikia.com/wiki/Inicio'
  #       iconUrl: 'https://cdn.wtf/d/images/starfire/addons/wiki.png'
  #   creator:
  #     username: 'community'
  #     name: 'Community'
  # }
]

module.exports = class Addon
  namespace: 'addon'

  constructor: ({@auth, @l}) -> null

  getLang: (addon) =>
    addon?.lang[@l.getLanguageStr()] or addon?.lang['en']

  getById: (id) ->
    Rx.Observable.just _find addons, {id}

  getByKey: (key) ->
    Rx.Observable.just _find addons, {key}

  getAll: ->
    Rx.Observable.just addons
    # @auth.stream "#{@namespace}.getAll", {}
