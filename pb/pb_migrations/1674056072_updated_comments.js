migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "rdmgdayj",
    "name": "media",
    "type": "file",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 3,
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
        "0x50"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "rdmgdayj",
    "name": "media",
    "type": "file",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 3,
      "maxSize": 5000000,
      "mimeTypes": [
        "image/jpg",
        "image/jpeg",
        "image/png",
        "image/svg+xml",
        "image/gif",
        "image/webp"
      ],
      "thumbs": []
    }
  }))

  return dao.saveCollection(collection)
})
