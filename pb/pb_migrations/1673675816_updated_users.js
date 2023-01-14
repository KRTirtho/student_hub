migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "b2b4qrhz",
    "name": "serial",
    "type": "number",
    "required": false,
    "unique": true,
    "options": {
      "min": 0,
      "max": 500
    }
  }))

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "pc5fs91a",
    "name": "standard",
    "type": "number",
    "required": false,
    "unique": true,
    "options": {
      "min": 0,
      "max": 12
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // remove
  collection.schema.removeField("b2b4qrhz")

  // remove
  collection.schema.removeField("pc5fs91a")

  return dao.saveCollection(collection)
})
