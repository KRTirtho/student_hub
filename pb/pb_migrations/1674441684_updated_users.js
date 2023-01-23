migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = "(id = @request.auth.id || (@request.auth.id ?= @collection.users.id && @request.auth.isMaster = true)) && ((isMaster = true && ban_until = '') || isMaster = false)"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = null

  return dao.saveCollection(collection)
})
