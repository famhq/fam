_camelCase = require 'lodash/camelCase'

module.exports = class ClashRoyaleCard
  namespace: 'clashRoyaleCards'

  constructor: ({@auth, @l}) -> null

  getAll: ({sort, filter} = {}) =>
    @auth.stream "#{@namespace}.getAll", {sort, filter}

  getById: (id) =>
    @auth.stream "#{@namespace}.getById", {id}

  getByKey: (key) =>
    @auth.stream "#{@namespace}.getByKey", {key}

  getChestCards: ({arena, chest}) =>
    @auth.call "#{@namespace}.getChestCards", {arena, chest}

  getNameTranslation: (key, language) =>
    @l.get "crCard.#{_camelCase key}", {file: 'cards'}
