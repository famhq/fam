RxBehaviorSubject = require('rxjs/BehaviorSubject').BehaviorSubject

module.exports = class XpGain
  constructor: ->
    @_xp = new RxBehaviorSubject null

  getXp: =>
    @_xp

  show: (xp) =>
    console.log 'showwwww'
    @_xp.next xp

  hide: =>
    console.log 'hideeeee'
    @_xp.next null
