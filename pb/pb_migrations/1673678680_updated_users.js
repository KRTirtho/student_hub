migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.createRule = "(isMaster = true && sessions = \"\") || (isMaster = false && sessions != \"\")"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.createRule = null

  return dao.saveCollection(collection)
})
