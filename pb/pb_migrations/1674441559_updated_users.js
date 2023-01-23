migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = "id = @request.auth.id || (@request.auth.id ?= @collection.users.id && @request.auth.isMaster = true)"

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "igg8upqn",
    "name": "ban_until",
    "type": "date",
    "required": false,
    "unique": false,
    "options": {
      "min": "",
      "max": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = null

  // remove
  collection.schema.removeField("igg8upqn")

  return dao.saveCollection(collection)
})
