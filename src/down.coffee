monmigrate = require './monmigrate'
helper = require './helper'


module.exports =
    command: 'down [database...]'
    # aliases: ''
    describe: 'Rollback migrations to database'

    builder: (yargs) ->
        yargs
        .positional 'database', {describe:'Database name'}
        .options
            n: {alias:'count', default:1, type:'number', describe:'number of levels to go back'}
            host: {type:'string', default:'localhost', describe:'mongoDB server'}
            p: {alias: 'port', type:'number', default:27017, describe:'mongoDB port'}
            collection: {type:'string', default:'_migrations', describe:'name of collections use for tracking'}

    handler: (argv) ->

        cfg = helper.prepareConfig argv

        monmigrate.down cfg
        .then () ->
            console.log 'DOWN terminado'
        .catch (err) ->
            console.log err
            process.exit 1
