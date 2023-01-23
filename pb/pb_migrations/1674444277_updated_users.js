migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = "(id = @request.auth.id || (@request.auth.id ?= @collection.users.id && @request.auth.isMaster = true)) && ((isMaster = true && ban_until = '') || isMaster = false) && ((ban_until != '' && ban_reason != '') || ban_until = '')"

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "i6xphmp4",
    "name": "ban_reason",
    "type": "select",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 6,
      "values": [
        "hate_speech",
        "violence",
        "nudity",
        "harassment",
        "spam",
        "fake"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  collection.updateRule = null

  // remove
  collection.schema.removeField("i6xphmp4")

  return dao.saveCollection(collection)
})
