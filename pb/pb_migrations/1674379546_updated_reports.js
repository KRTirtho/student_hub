migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("n5d6n9wfl83iccf")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "o7gpdb2v",
    "name": "reason",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "violence",
        "nudity",
        "harassment",
        "hate_speech",
        "spam",
        "fake",
        "other"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("n5d6n9wfl83iccf")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "o7gpdb2v",
    "name": "reason",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "violence",
        "nudity",
        "harrasment",
        "hate_speech",
        "spam",
        "fake",
        "other"
      ]
    }
  }))

  return dao.saveCollection(collection)
})
