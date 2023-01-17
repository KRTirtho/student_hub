migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("6thsws73q7ot4kc")

  collection.createRule = "@request.auth.id != '' && user = @request.auth.id && user.isMaster = true"
  collection.updateRule = "@request.auth.id != '' && user = @request.auth.id && user.isMaster = true"
  collection.deleteRule = "@request.auth.id != '' && user = @request.auth.id && user.isMaster = true"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("6thsws73q7ot4kc")

  collection.createRule = null
  collection.updateRule = null
  collection.deleteRule = null

  return dao.saveCollection(collection)
})
