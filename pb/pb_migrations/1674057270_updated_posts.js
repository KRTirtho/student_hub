migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "7zkjduqe",
    "name": "media",
    "type": "file",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 6,
      "maxSize": 5000000,
      "mimeTypes": [
        "image/jpg",
        "image/jpeg",
        "image/png",
        "image/svg+xml",
        "image/gif",
        "image/webp"
      ],
      "thumbs": [
        "0x200"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "7zkjduqe",
    "name": "media",
    "type": "file",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 6,
      "maxSize": 5000000,
      "mimeTypes": [
        "image/jpg",
        "image/jpeg",
        "image/png",
        "image/svg+xml",
        "image/gif",
        "image/webp"
      ],
      "thumbs": [
        "0x100"
      ]
    }
  }))

  return dao.saveCollection(collection)
})
