z = require 'zorium'

Sheet = require '../sheet'

module.exports = class AddToHomeSheet
  constructor: ({@model, router, @isVisible}) ->
    @$sheet = new Sheet {@model, router, @isVisible}


  render: ({message}) =>
    z '.z-add-to-home-sheet',
      z @$sheet, {
        message: message
        icon: 'home'
        submitButton:
          text: 'Add to home'
          onclick: =>
            console.log '123', @model.portal.call
            @model.portal.call 'app.install'
            @isVisible.onNext false
      }
