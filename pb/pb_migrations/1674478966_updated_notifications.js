migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "efzu0w5n",
    "name": "viewed",
    "type": "bool",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "0tv7m5ar",
    "name": "user",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "_pb_users_auth_",
      "cascadeDelete": true
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // remove
  collection.schema.removeField("efzu0w5n")

  // remove
  collection.schema.removeField("0tv7m5ar")

  return dao.saveCollection(collection)
})
