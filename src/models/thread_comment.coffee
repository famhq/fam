module.exports = class ThreadComment
  namespace: 'threadComments'
  constructor: ({@auth}) -> null

  create: ({body, parentId, parentType}) =>
    @auth.call "#{@namespace}.create", {body, parentId, parentType}, {
      invalidateAll: true
    }

  flag: (id) =>
    @auth.call "#{@namespace}.flag", {id}

  getAllByParentIdAndParentType: ({parentId, parentType}) =>
    @auth.stream "#{@namespace}.getAllByParentIdAndParentType", {
      parentId, parentType
    }
