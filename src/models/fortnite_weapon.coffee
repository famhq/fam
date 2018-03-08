_camelCase = require 'lodash/camelCase'

module.exports = class FortniteWeapon
  namespace: 'fortniteWeapons'

  constructor: ({@auth, @l}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {}

  getNameTranslation: (key) =>
    unless key
      return ''
    @l.get "fortniteWeapon.#{_camelCase key}", {
      file: 'fortnite_weapons'
    }
