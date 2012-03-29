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


    if not commander.file
        log "--file is required".red
        process.exit 1

    report = parse commander.file

    process.exit 1 if report is false

    exitCode = 1

    if report.noError is true
        log "No errors found in #{commander.file}".yellow
        exitCode = 0
    else
        for store, errors of report.errors
            log "Section #{store}".red
            (log "* #{error.green.underline}") for error in errors

    process.exit exitCode


