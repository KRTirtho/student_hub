migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "zq26g6lm",
    "name": "thumbnail",
    "type": "file",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "maxSize": 2000000,
      "mimeTypes": [
        "image/jpg",
        "image/jpeg",
        "image/png",
        "image/webp"
      ],
      "thumbs": []
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // remove
  collection.schema.removeField("zq26g6lm")

  return dao.saveCollection(collection)
})
