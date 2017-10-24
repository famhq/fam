module.exports = class Reward
  namespace: 'rewards'

  constructor: ({@auth}) -> null

  setup: ({}) =>
    @auth.call "#{@namespace}.setup", {}

  getAll: (options) =>
    @auth.stream "#{@namespace}.getAll", options
