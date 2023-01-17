migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "7a3xbkqs",
    "name": "tags",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": null,
      "collectionId": "6thsws73q7ot4kc",
      "cascadeDelete": false
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // remove
  collection.schema.removeField("7a3xbkqs")

  return dao.saveCollection(collection)
})
