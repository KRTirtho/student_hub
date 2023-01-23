migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // remove
  collection.schema.removeField("rgetwdzj")

  // add
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
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "rgetwdzj",
    "name": "record",
    "type": "text",
    "required": true,
    "unique": false,
    "options": {
      "min": 15,
      "max": 15,
      "pattern": ""
    }
  }))

  // remove
  collection.schema.removeField("nso8am6k")

  return dao.saveCollection(collection)
})
