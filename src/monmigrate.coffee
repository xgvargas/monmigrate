###!
--- monmigrate ---

Released under MIT license.

by Gustavo Vargas - @xgvargas - 2018

Original coffee code and issues at: https://github.com/xgvargas/monmigrate
###

fs = require 'fs'
shifting = require 'shifting'
path = require 'path'
Promise = require 'bluebird'
EventEmitter = require 'events'
babel = require 'babel-core'
{presets} = require('../package.json').babel
coffee = null


emitter = new EventEmitter()

getCode = (fn, funcname, ops) ->

    try
        code = fs.readFileSync path.join(ops.root, fn), 'utf-8'

        if fn.endsWith '.coffee'
            coffee ?= require 'coffee'
            code = coffee.compile code, {header: false, bare: true} #, transpile: {presets}}

        code = eval babel.transform(code, {ast:no, presets}).code

        return code[funcname]
    catch err
        console.error err

    throw new Error 'Can´t open '+fn


module.exports =

    on: -> emitter.on arguments...

    create: (name, ops) ->
        new Promise (resolve, reject) ->
            # console.log name, ops

            if ops.auto
                return reject new Error 'Missing `models` for automatic code generation.' unless ops.models
                # TODO...

                # executar o plugin que deve converter algum tipo de esqueme para o formato o meu formato
                # depois analisar o esquema interno para decidir as modificacoes que deve ser aplicadas
                # e gerar o codigo para estas modificacoes... e salvar o esquema para ter base na
                # comparacao de mudancas em futuras versoes...

                console.log 'criando codigo automatico...'


            counter = +(fs.readdirSync(ops.root)
                        .filter((f) -> /^\d{4}-.+\.(js|coffee)$/.test f)
                        .sort().pop() or '0')
                            .split('-')[0]

            fn = "#{('0000'+(++counter)).slice(-4)}-#{name.replace(/[^\s\w]/g, '').replace(/\s+/g, '-')}"

            if ops.coffee
                fn += '.coffee'
                csmodel = """
                    # Created on #{new Date().toJSON()}\n
                    module.exports =\n
                    \tdescribe: '#{name}'\n
                    \tup: (cb) ->\n\t\tcb()\n
                    \tdown: (cb) ->\n\t\tcb()\n
                """
            else
                fn += '.js'
                jsmodel = """
                    // Created on #{new Date().toJSON()}\n
                    module.exports = {
                    \tdescribe: '#{name}',\n
                    \tup: function (cb) {\n\t\tcb()\n\t},\n
                    \tdown: function (cb) {\n\t\tcb()\n\t}\n};\n
                """

            fullname = path.join ops.root, fn
            fs.writeFile fullname, (if ops.coffee then csmodel else jsmodel), 'utf8', (err) ->
                return reject err if err
                resolve fullname

    up: (ops) ->
        new Promise (resolve, reject) ->
            emitter.emit 'ready', ops

            Promise.mapSeries ops.dbs, (dbname) ->

                emitter.emit 'open_db', dbname

                ops.backend.createAPI dbname, ops
                .then (api) ->
                    emitter.emit 'new_api', api
                    api.print = (mesg) -> console.log '>>> ', mesg

                    versions = fs.readdirSync(ops.root).filter((f) -> /^\d{4}-.+\.(js|coffee)$/.test f).sort()

                    Promise.mapSeries versions, (file) ->

                        script = getCode file, 'up', ops

                        shifting.call [api, script]
                        .then (res) ->
                            console.log 'finalizado', res
                        .catch (err) ->
                            emitter.emit 'error', err
                            console.log 'fudeu!', err

                    .then ->
                        ops.backend.closeAPI api
                        emitter.emit 'done_db', dbname

                    .catch (err) ->
                        emitter.emit 'error', err
                        console.log err
                        try
                            ops.backend.closeAPI api
                        return reject err

                .catch (err) ->
                    emitter.emit 'error', err
                    return reject err

            .then ->
                emitter.emit 'done'
                resolve()

            .catch (err) ->
                emitter.emit 'error', err
                reject err


    down: (levels, ops) ->
        new Promise (resolve, reject) ->
            console.log 'desfazendo....', ops
            resolve()
