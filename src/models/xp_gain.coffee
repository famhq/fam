RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

module.exports = class XpGain
  constructor: ->
    @_xp = new RxBehaviorSubject null

  getXp: =>
    @_xp

  show: (xp) =>
    @_xp.next xp

  hide: =>
    @_xp.next null
