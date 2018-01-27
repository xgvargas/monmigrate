monmigrate = require './monmigrate'
helper = require './helper'


module.exports =
    command: 'up [database...]'
    # aliases: ''
    describe: 'Apply migrations to database'

    builder: (yargs) ->
        yargs
        .positional 'database', {describe:'Database name'}
        # .demandOption ['db']
        .options
            host: {type:'string', default:'localhost', describe:'mongoDB server'}
            p: {alias: 'port', type:'number', default:27017, describe:'mongoDB port'}
            collection: {type:'string', default:'_migrations', describe:'name of collections use for tracking'}

    handler: (argv) ->

        cfg = helper.prepareConfig argv

        # monmigrate.on 'ready', (ops) -> console.log 'Pronto para atualizar', ops
        monmigrate.on 'open_db', (name) -> console.log 'Trabalhando no DB', name
        # monmigrate.on 'new_api', (api) -> console.log 'Criada API', api
        monmigrate.on 'done_db', (name) -> console.log 'Concluido DB', name
        monmigrate.on 'done', -> console.log 'Concluido!'
        monmigrate.on 'error', (err) -> console.log 'DEU MERDA!!!', err

        monmigrate.up cfg
        .then () ->
            console.log 'UP terminado'
        .catch (err) ->
            console.log '@@@@@ ',err
            process.exit 1
