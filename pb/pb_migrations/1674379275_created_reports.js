migrate((db) => {
  const collection = new Collection({
    "id": "n5d6n9wfl83iccf",
    "created": "2023-01-22 09:21:15.704Z",
    "updated": "2023-01-22 09:21:15.704Z",
    "name": "reports",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "owibhcay",
        "name": "collection",
        "type": "select",
        "required": true,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "values": [
            "post",
            "user",
            "comment",
            "book"
          ]
        }
      },
      {
        "system": false,
        "id": "xfqdwzmc",
        "name": "record",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": 15,
          "max": 15,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "o7gpdb2v",
        "name": "reason",
        "type": "select",
        "required": true,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "values": [
            "violence",
            "nudity",
            "harrasment",
            "hate_speech",
            "spam",
            "fake",
            "other"
          ]
        }
      },
      {
        "system": false,
        "id": "degqk8lz",
        "name": "description",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "gtpsuh3k",
        "name": "user",
        "type": "relation",
        "required": true,
        "unique": false,
        "options": {
          "maxSelect": 1,
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": true
        }
      }
    ],
    "listRule": "@request.auth.id != ''",
    "viewRule": "@request.auth.id != ''",
    "createRule": "@request.auth.id != '' && @request.auth.id = user",
    "updateRule": "@request.auth.id != '' && @request.auth.id = user",
    "deleteRule": "@request.auth.id != '' && @request.auth.id = user",
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("n5d6n9wfl83iccf");

  return dao.deleteCollection(collection);
})
