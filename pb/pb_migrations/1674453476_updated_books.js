migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  collection.listRule = "@request.auth.id != '' && (user.ban_until = '' || (user.ban_until != '' && user.ban_until < @now))"
  collection.viewRule = "@request.auth.id != '' && (user.ban_until = '' || (user.ban_until != '' && user.ban_until < @now))"

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  collection.listRule = null
  collection.viewRule = null

  return dao.saveCollection(collection)
})
