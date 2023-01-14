migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.updateRule = "@request.auth.id != \"\" && user = @request.auth.id && ((user.isMaster=false && type != 'announcement') || user.isMaster=true)"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.updateRule = null

  return dao.saveCollection(collection)
})
