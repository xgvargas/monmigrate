###!
--- monmigrate ---

Released under MIT license.

by Gustavo Vargas - @xgvargas - 2018

Original coffee code and issues at: https://github.com/xgvargas/monmigrate
###

yargs = require 'yargs'

argv = yargs
.wrap yargs.terminalWidth()
.strict yes
.alias 'h', 'help'
# .config 'cfg'
.usage 'Usage: $0 [options] [command]'
.epilogue 'copyright 2018'
.demandCommand 1
.command require './create'
.command require './up'
.command require './down'
.options
    cfg: {describe:'Configuration file', default:'.monmigrate.json'}
.argv

# console.dir argv

# if argv._.length != 1
#     yargs.showHelp()
#     process.exit 1

# ....
