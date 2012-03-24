commander = require 'commander'
{parse} = require './parser'
{log} = require './util'
colors = require 'colors'

VERSION = '0.0.1'

exports.VERSION = VERSION

exports.main = ->
    commander
        .version(VERSION)
        .option('-f, --file <n>', 'Config File')
        .parse(process.argv)


    options = parseConfigFile commander.config if commander.config

    if not commander.file
        log "--file is required".red
        process.exit 0

    parse commander.file

