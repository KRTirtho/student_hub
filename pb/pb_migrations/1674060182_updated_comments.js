migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  collection.createRule = "user = @request.auth.id && (solve = false || (solve = true && post.type = 'question'))"
  collection.updateRule = "user = @request.auth.id && (solve = false || (solve = true && post.type = 'question'))"

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "lv2aqxya",
    "name": "solve",
    "type": "bool",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61")

  collection.createRule = null
  collection.updateRule = null

  // remove
  collection.schema.removeField("lv2aqxya")

  return dao.saveCollection(collection)
})
