path = require 'path'
fs = require 'fs'

lookUp = (filename, start) ->

    folders = (start or process.cwd()).split /\/|\\/g
    loop
        base = path.join '/', path.join folders...
        try
            file = fs.readFileSync path.join(base, filename), 'utf-8'
        break if file
        folders.pop()
        unless folders.length
            console.log "\nCould not found `#{filename}` in current tree\n"
            process.exit 1

    process.chdir base
    JSON.parse file #.toString()


module.exports =
    prepareConfig: (ops) ->

        cfg = lookUp ops.cfg

        config = Object.assign cfg, ops

        config.root = path.resolve config.root
        config.models = path.resolve config.models if config.models

        config.dbs = ops.database if ops.database?.length

        config.editor ?= 'xdg-open'

        config.backend ?= require.resolve './backend-mongo'
        config.backend = require path.resolve config.backend

        config.parser ?= require.resolve './parser-reston'
        config.parser = require path.resolve config.parser

        unless config.dbs.length
            console.log "\nMissing database name(s)\n"
            process.exit 1

        return config
