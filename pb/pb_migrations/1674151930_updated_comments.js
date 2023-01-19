migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  collection.updateRule = "(user = @request.auth.id || @request.auth.id = post.user) && (solve = false || (solve = true && post.type = 'question'))"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  collection.updateRule = null

  return dao.saveCollection(collection)
})
