migrate((db) => {
  const collection = new Collection({
    "id": "zj87b7dnthzfnoc",
    "created": "2023-01-16 17:32:26.250Z",
    "updated": "2023-01-16 17:32:26.250Z",
    "name": "books",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "xzprp1hy",
        "name": "media",
        "type": "file",
        "required": true,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "maxSize": 100000000,
          "mimeTypes": [
            "application/pdf"
          ],
          "thumbs": []
        }
      },
      {
        "system": false,
        "id": "xepbisj7",
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
  const collection = dao.findCollectionByNameOrId("zj87b7dnthzfnoc");

  return dao.deleteCollection(collection);
})
