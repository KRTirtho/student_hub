migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "xzprp1hy",
    "name": "media",
    "type": "file",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "maxSize": 40000000,
      "mimeTypes": [
        "application/pdf"
      ],
      "thumbs": []
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "xzprp1hy",
    "name": "media",
    "type": "file",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "maxSize": 100000000,
      "mimeTypes": [
        "application/pdf"
      ],
      "thumbs": []
    }
  }))

  return dao.saveCollection(collection)
})
