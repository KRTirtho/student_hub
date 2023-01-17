migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("6thsws73q7ot4kc")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "coj3dg7p",
    "name": "tag",
    "type": "text",
    "required": false,
    "unique": true,
    "options": {
      "min": null,
      "max": null,
      "pattern": "^\\w*[0-9a-zA-Z]+\\w*[0-9a-zA-Z]$"
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("6thsws73q7ot4kc")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "coj3dg7p",
    "name": "tag",
    "type": "text",
    "required": false,
    "unique": true,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
})
