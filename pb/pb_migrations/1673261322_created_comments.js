migrate((db) => {
  const collection = new Collection({
    "id": "klc6jxs27mknd61",
    "created": "2023-01-09 10:48:42.717Z",
    "updated": "2023-01-09 10:48:42.717Z",
    "name": "comments",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "hjiy6kwu",
        "name": "comment",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
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
      },
      {
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
      }
    ],
    "listRule": "",
    "viewRule": "",
    "createRule": "user = @request.auth.id",
    "updateRule": "user = @request.auth.id",
    "deleteRule": "user = @request.auth.id",
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("klc6jxs27mknd61");

  return dao.deleteCollection(collection);
})
