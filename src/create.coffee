monmigrate = require './monmigrate'
helper = require './helper'
{exec} = require 'child_process'

module.exports =
    command: 'create <description...>'
    # aliases: ''
    describe: 'Create a new DB version'
    builder: (yargs) ->
        yargs
        .positional 'description', {describe:'Describe the changes of the new migration'}
        .options
            c: {alias:'coffee', type:'boolean', default:no, describe:'Create coffeescript template'}
            a: {alias:'auto', type:'boolean', default:no, describe:'Try to process models and generate migration code'}
            e: {alias:'edit', type:'boolean', default:no, describe:'Open file on default editor'}

    handler: (argv) ->
        # console.log 'criando....'
        # console.log argv

        cfg = helper.prepareConfig argv

        monmigrate.create argv.description.join(' '), cfg
        .then (fn) ->
            # console.log 'terminaou', fn
            exec "#{cfg.editor} #{fn}" if cfg.edit
        .catch (err) ->
            console.log err
            process.exit 1
