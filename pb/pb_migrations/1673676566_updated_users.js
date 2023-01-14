migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // remove
  collection.schema.removeField("b2b4qrhz")

  // remove
  collection.schema.removeField("pc5fs91a")

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

  return dao.saveCollection(collection)
}, (db) => {
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

  // remove
  collection.schema.removeField("lsyrsxjp")

  return dao.saveCollection(collection)
})
