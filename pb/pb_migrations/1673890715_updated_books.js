migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "lkccd0zd",
    "name": "external_url",
    "type": "url",
    "required": false,
    "unique": false,
    "options": {
      "exceptDomains": null,
      "onlyDomains": null
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc")

  // remove
  collection.schema.removeField("lkccd0zd")

  return dao.saveCollection(collection)
})
