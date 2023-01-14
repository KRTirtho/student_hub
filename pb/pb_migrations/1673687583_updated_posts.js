migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.listRule = "@request.auth.id != \"\""
  collection.viewRule = "@request.auth.id != \"\""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  collection.listRule = null
  collection.viewRule = null

  return dao.saveCollection(collection)
})
