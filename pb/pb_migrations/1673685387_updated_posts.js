migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("i81wdbi331ytw3z")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "pp6thhol",
    "name": "type",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "announcement",
        "question",
        "informative"
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
    "id": "pp6thhol",
    "name": "type",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "announcement",
        "question"
      ]
    }
  }))

  return dao.saveCollection(collection)
})
