migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = "id = @request.auth.id || (banned_by != '' && banned_by = @request.auth.id && banned_by.isMaster = true)"

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "yneeit92",
    "name": "banned_by",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "_pb_users_auth_",
      "cascadeDelete": false
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = null

  // remove
  collection.schema.removeField("yneeit92")

  return dao.saveCollection(collection)
})
