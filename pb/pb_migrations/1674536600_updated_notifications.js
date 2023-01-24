migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  collection.updateRule = "@request.auth.id = user"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  collection.updateRule = null

  return dao.saveCollection(collection)
})
