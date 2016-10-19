z = require 'zorium'
Rx = require 'rx-lite'
_ = require 'lodash'

config = require '../../config'
colors = require '../../colors'
Head = require '../../components/head'
EditProfile = require '../../components/edit_profile'

module.exports = class EditProfilePage
  constructor: ({model, requests, router, serverData}) ->
    @$head = new Head({
      model
      requests
      serverData
      meta: {
        title: 'Edit Profile'
        description: 'Edit your Clay profile'
      }
    })
    @$editProfile = new EditProfile {model, router}

  renderHead: => @$head

  render: =>
    z '.p-edit-profile',
      @$editProfile
