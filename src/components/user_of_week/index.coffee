z = require 'zorium'

if window?
  require './index.styl'

module.exports = class UserOfWeek
  constructor: ({@model, @router}) ->
    null

  render: =>
    z '.z-user-of-week',
      z '.g-grid',
        z '.subhead',
          @model.l.get 'userOfWeek.title'
        z 'p',
          @model.l.get 'userOfWeek.text1'
        z 'p',
          @model.l.get 'userOfWeek.text2'
        z 'p',
          @model.l.get 'userOfWeek.text3'
