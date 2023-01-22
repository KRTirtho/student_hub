migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mtxkr5yw",
    "name": "sessions",
    "type": "text",
    "required": false,
    "unique": true,
    "options": {
      "min": null,
      "max": null,
      "pattern": "(^((20\\d{2}-[1-12]{1,2}-[1-9][0-9]{0,3}),?)+$)|(^20\\d{2}-(bangla|english|math|physics|chemistry|biology|ict|accounting|economics|religion|art|music|physical_education|social_studies|bushiness_studies|agriculture)-[1-9][0-9]{0,3}$)"
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("_pb_users_auth_")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "mtxkr5yw",
    "name": "sessions",
    "type": "text",
    "required": false,
    "unique": true,
    "options": {
      "min": null,
      "max": null,
      "pattern": "^((20\\d{2}-[1-12]{1,2}-[1-9][0-9]{0,3})|(20\\d{2}-(bangla|english|math|physics|chemistry|biology|ict|accounting|economics|religion|art|music|physical_education|social_studies|bushiness_studies|agriculture)-[1-9][0-9]{0,3}),?)+$"
    }
  }))

  return dao.saveCollection(collection)
})
