module.exports = class FindFriend
  namespace: 'findFriends'

  constructor: ({@auth}) -> null

  create: ({language, link}) =>
    @auth.call "#{@namespace}.create", {language, link}, {
      invalidateAll: true
    }

  getAll: ({language}) =>
    @auth.stream "#{@namespace}.getAll", {language}
