migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // add
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
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // remove
  collection.schema.removeField("rdmgdayj")

  return dao.saveCollection(collection)
})
