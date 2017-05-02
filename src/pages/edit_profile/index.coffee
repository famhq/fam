z = require 'zorium'

Head = require '../../components/head'
EditProfile = require '../../components/edit_profile'

module.exports = class EditProfilePage
  constructor: ({model, requests, router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: model.l.get 'editProfilePage.title'
        description: model.l.get 'editProfilePage.title'
      }
    })
    @$editProfile = new EditProfile {model, router}

  renderHead: => @$head

  render: =>
    z '.p-edit-profile',
      @$editProfile
