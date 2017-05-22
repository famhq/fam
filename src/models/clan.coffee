module.exports = class Clan
  namespace: 'clan'

  constructor: ({@auth}) -> null

  getById: (id, {embed} = {}) =>
    @auth.stream "#{@namespace}.getById", {id, embed}

  claimById: (id) =>
    @auth.call "#{@namespace}.claimById", {id}

  updateById: (id, {clanPassword}) =>
    @auth.call "#{@namespace}.updateById", {id, clanPassword}, {
      invalidateAll: true
    }

  joinById: (id, {clanPassword}) =>
    @auth.call "#{@namespace}.joinById", {id, clanPassword}, {
      invalidateAll: true
    }
