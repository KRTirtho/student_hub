migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "hswr0d2z",
    "name": "comments",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": null,
      "collectionId": "klc6jxs27mknd61",
      "cascadeDelete": false
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  // remove
  collection.schema.removeField("hswr0d2z")

  return dao.saveCollection(collection)
})
