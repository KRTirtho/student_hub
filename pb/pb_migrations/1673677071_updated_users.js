migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // remove
  collection.schema.removeField("lsyrsxjp")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mtxkr5yw",
    "name": "sessions",
    "type": "text",
    "required": true,
    "unique": true,
    "options": {
      "min": null,
      "max": null,
      "pattern": "^(20\\d{2}-[1-12]{1,2}-[1-9][0-9]{0,3},?)+$"
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "lsyrsxjp",
    "name": "standard_serial",
    "type": "text",
    "required": true,
    "unique": true,
    "options": {
      "min": 3,
      "max": 6,
      "pattern": "^[1-12]{1,2}-[0-9]{1,4}$"
    }
  }))

  // remove
  collection.schema.removeField("mtxkr5yw")

  return dao.saveCollection(collection)
})
