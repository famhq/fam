Rx = require 'rx-lite'
_find = require 'lodash/find'

addons = [
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
    id: 'e27297be-ee97-4216-b854-cfc0d15811b5'
    key: 'deckGenerator'
    url: 'https://starfire.clashstat.com/deckgen/?lang={lang}'
    iconUrl: 'https://cdn.wtf/d/images/starfire/addons/random_deck.png'
    creator:
      username: 'the1nk'
      name: 'The1nk'
  }
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
    id: '5c35294e-7315-44c2-ae1b-0cdc65c73a5c'
    key: 'cardChanceCalculator'
    url: 'https://pixelcrux.com/Clash_Royale/Card_Chance/Starfire'
    iconUrl: 'https://pixelcrux.com/Clash_Royale/Card_Chance/Icon.png'
    creator:
      username: 'pixelcrux'
      name: 'Pixel Crux'
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
  {
    id: 'f537f4b0-08cb-453c-8122-ae80e4163226'
    key: 'shopOffers'
    url: '/shop-offers'
    iconUrl: 'https://cdn.wtf/d/images/starfire/chests/legendary_chest.png'
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

  # SDK ids. These will eventually be stored in database,
  # but hardcoded until then.
  # htmldino: 005862d0-a474-4329-9b6d-20cf31c46be0
  # t.lombart97: 93d9d6b7-aec2-4ae1-a1a2-b76bb81ddb98
  # the1nk: e27297be-ee97-4216-b854-cfc0d15811b5
  # tzelon: 18ec096a-0826-458e-8d8e-114ba3292cc2
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

  voteById: (id, {vote}) =>
    @auth.call "#{@namespace}.voteById", {id, vote}, {invalidateAll: true}
