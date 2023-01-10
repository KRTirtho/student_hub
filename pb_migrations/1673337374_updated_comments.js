migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "tj1udwm4",
    "name": "post",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "i81wdbi331ytw3z",
      "cascadeDelete": true
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "uizfmbtr",
    "name": "user",
    "type": "relation",
    "required": true,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "_pb_users_auth_",
      "cascadeDelete": true
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "tj1udwm4",
    "name": "post",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "i81wdbi331ytw3z",
      "cascadeDelete": true
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "uizfmbtr",
    "name": "user",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "maxSelect": 1,
      "collectionId": "_pb_users_auth_",
      "cascadeDelete": true
    }
  }))

  return dao.saveCollection(collection)
})
