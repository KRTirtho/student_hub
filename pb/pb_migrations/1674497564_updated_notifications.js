migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "nso8am6k",
    "name": "record",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "posts",
        "comments",
        "users"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "nso8am6k",
    "name": "record",
    "type": "select",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "values": [
        "posts",
        "comments",
        "users",
        "comments"
      ]
    }
  }))

  return dao.saveCollection(collection)
})
