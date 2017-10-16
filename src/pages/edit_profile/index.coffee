z = require 'zorium'

Head = require '../../components/head'
EditProfile = require '../../components/edit_profile'
config = require '../../config'

module.exports = class EditProfilePage
  constructor: ({model, requests, router, serverData}) ->
    gameKey = requests.map ({route}) ->
      route.params.gameKey or config.DEFAULT_GAME_KEY

    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'editProfilePage.title'
        description: model.l.get 'editProfilePage.title'
      }
    })
    @$editProfile = new EditProfile {model, router, gameKey}

  renderHead: => @$head

  render: =>
    z '.p-edit-profile',
      @$editProfile
