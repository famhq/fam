semverCompare = require 'semver-compare'

class SemverService
  gte: (v1, v2) ->
    semverCompare(v1, v2) is 1

module.exports = new SemverService()
