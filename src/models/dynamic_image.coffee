module.exports = class DynamicImage
  namespace: 'dynamicImage'

  constructor: ({@auth}) -> null

  getMeByImageKey: (imageKey) =>
    @auth.stream "#{@namespace}.getMeByImageKey", {imageKey}

  upsertMeByImageKey: (imageKey, diff) =>
    @auth.call "#{@namespace}.upsertMeByImageKey", {imageKey, diff}, {
      invalidateAll: true
    }
