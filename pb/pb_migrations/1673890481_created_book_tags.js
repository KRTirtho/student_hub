migrate((db) => {
  const collection = new Collection({
    "id": "6thsws73q7ot4kc",
    "created": "2023-01-16 17:34:41.611Z",
    "updated": "2023-01-16 17:34:41.611Z",
    "name": "book_tags",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "coj3dg7p",
        "name": "tag",
        "type": "text",
        "required": false,
        "unique": true,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "clpqyvlw",
        "name": "user",
        "type": "relation",
        "required": true,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": false
        }
      }
    ],
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != '' && user = @request.auth.id",
    "updateRule": "@request.auth.id != '' && user = @request.auth.id",
    "deleteRule": "@request.auth.id != '' && user = @request.auth.id",
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("6thsws73q7ot4kc");

  return dao.deleteCollection(collection);
})
