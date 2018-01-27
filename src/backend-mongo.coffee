# monk = require 'monk'
{MongoClient} = require 'mongodb'


module.exports =

    createAPI: (dbname, ops) ->
        new Promise (resolve, reject) ->

            MongoClient.connect ops.serverURL, (err, client) ->
                return reject ''+err if err

                db = client.db dbname

                api = {
                    db
                    _extra: {client}
                    insertFields: (coll, query, field) ->
                    dropFields: (coll, query, field) ->
                    renameField: (coll, query, from, to) ->

                    editDocs: (coll, query, editor) ->
                        new Promise (resolve, reject) ->
                            coll = db.collection(coll)
                            coll.find(query).each (err, doc) ->
                                return reject err if err
                                return resolve() unless doc

                                newdoc = editor JSON.parse JSON.stringify doc

                                coll.updateOne {_id: doc._id}, newdoc

                    insertDoc: (coll, doc) ->
                        new Promise (resolve, reject) ->
                            db.collection(coll).insertOne doc, (err, res) ->
                                return reject err if err
                                resolve res

                    dropDocs: (coll, query) ->
                        new Promise (resolve, reject) ->
                            db.collection(coll).deleteMany query, (err, res) ->
                                return reject err if err
                                resolve res

                    createColl: (coll, ops) ->
                        new Promise (resolve, reject) ->
                            db.createCollection coll, (ops || {}), (err, res) ->
                                return reject err if err
                                resolve res

                    dropColl: (coll) ->
                        new Promise (resolve, reject) ->
                            db.collection(coll).drop (err, res) ->
                                return reject err if err
                                resolve res

                    createIndex: (coll, index, ops) ->
                        new Promise (resolve, reject) ->
                            db.collection(coll).createIndex index, (ops || {}), (err, res) ->
                                return reject err if err
                                resolve res

                    dropIndex: (coll, index) ->
                        new Promise (resolve, reject) ->
                            db.collection(coll).dropIndex index, (err, res) ->
                                return reject err if err
                                resolve res
                }

                resolve api

    closeAPI: (api) ->
        api._extra.client.close()
