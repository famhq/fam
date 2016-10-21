z = require 'zorium'
colors = require '../../colors'

Icon = require '../icon'

module.exports = class Base
  getCached$: (id, component, args...) =>
    @cachedComponents or= []

    if @cachedComponents[id]
      return @cachedComponents[id]
    else
      console.log args
      $component = new component args...
      @cachedComponents[id] = $component
      return $component
