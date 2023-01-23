migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // remove
  collection.schema.removeField("ncegxhhm")

  // remove
  collection.schema.removeField("nso8am6k")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "pwwcubfu",
    "name": "collection",
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

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "4nctnsoe",
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

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ncegxhhm",
    "name": "collection",
    "type": "text",
    "required": true,
    "unique": false,
    "options": {
      "min": 15,
      "max": 15,
      "pattern": ""
    }
  }))

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
        "users"
      ]
    }
  }))

  // remove
  collection.schema.removeField("pwwcubfu")

  // remove
  collection.schema.removeField("4nctnsoe")

  return dao.saveCollection(collection)
})
