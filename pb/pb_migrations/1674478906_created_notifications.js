migrate((db) => {
  const collection = new Collection({
    "id": "d2lpjer86424fzz",
    "created": "2023-01-23 13:01:46.535Z",
    "updated": "2023-01-23 13:01:46.535Z",
    "name": "notifications",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "rgetwdzj",
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
      },
      {
        "system": false,
        "id": "8npjervt",
        "name": "message",
        "type": "text",
        "required": true,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("d2lpjer86424fzz");

  return dao.deleteCollection(collection);
})
