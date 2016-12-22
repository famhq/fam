module.exports = class Thread
  namespace: 'threads'

  constructor: ({@auth}) -> null

  create: ({body, title}) =>
    @auth.call "#{@namespace}.create", {body, title}, {invalidateAll: true}

  getAll: ({ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getAll", {}, {ignoreCache}

  getById: (id, {ignoreCache} = {}) =>
    @auth.stream "#{@namespace}.getById", {id}, {ignoreCache}
