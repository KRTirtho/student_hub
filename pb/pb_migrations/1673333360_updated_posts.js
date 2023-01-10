migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.createRule = "@request.auth.id != \"\" && user = @request.auth.id"
  collection.updateRule = "@request.auth.id != \"\" && user = @request.auth.id"
  collection.deleteRule = "@request.auth.id != \"\" && user = @request.auth.id"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.createRule = null
  collection.updateRule = null
  collection.deleteRule = null

  return dao.saveCollection(collection)
})
