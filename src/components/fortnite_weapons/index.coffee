z = require 'zorium'
_map = require 'lodash/map'
_filter = require 'lodash/filter'
_startCase = require 'lodash/startCase'
_omit = require 'lodash/omit'
_orderBy = require 'lodash/orderBy'
RxObservable = require('rxjs/Observable').Observable
require 'rxjs/add/observable/combineLatest'

Environment = require '../../services/environment'
FormatService = require '../../services/format'
Spinner = require '../spinner'
Card = require '../card'
config = require '../../config'
colors = require '../../colors'

if window?
  require './index.styl'

module.exports = class FortniteWeapons
  constructor: ({@model, @router}) ->
    @$spinner = new Spinner()

    language = @model.l.getLanguage()
    weaponsAndLanguage = RxObservable.combineLatest(
      @model.fortniteWeapon.getAll()
      language
      (vals...) -> vals
    )


    @state = z.state {
      language: language
      weapons: weaponsAndLanguage.map ([weapons, language]) =>
        weapons = _map weapons, (weapon) =>
          weapon.name = @model.fortniteWeapon.getNameTranslation(
            weapon.nameKey, language
          )
          weapon
        weapons = _orderBy weapons, 'name'
    }

  render: =>
    {language, weapons} = @state.getValue()

    z '.z-fortnite-weapons',
      z '.g-grid',
        # z '.header',
        #   z '.card'
        #   z '.name', @model.l.get 'simulator.card'
        #   z '.win-rate', @model.l.get 'profileInfo.statWinRate'
        _map weapons, (weapon, i) =>
          rarity = @model.fortniteWeapon.getNameTranslation(
            weapon.rarity, language
          )
          z '.weapon',
            z '.name', "#{weapon.name} (#{rarity})"
            _map _omit(weapon, ['nameKey', 'name']), (value, key) =>
              name = @model.fortniteWeapon.getNameTranslation key, language
              if key is 'rarity'
                value = rarity
              else
                value = FormatService.number value
              z '.stat',
                z '.name', "#{name}: "
                z '.value', value
