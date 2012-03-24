{spawn, exec} = require 'child_process'
{log} = require 'util'

build = (watch, callback) ->
    if typeof watch is 'function'
        callback = watch
        watch = false
    options = ['-c', '-o', 'lib', 'src']
    options.unshift '-w' if watch

    coffee = spawn 'coffee', options
    coffee.stdout.on 'data', (data) ->
        log data.toString()
    coffee.stderr.on 'data', (data) ->
        log data.toString()
    coffee.on 'exit', (status) ->
        callback?() if status is 0

task 'build', 'Compile CoffeeScript files', ->
    build()

task 'watch', 'Recompile CoffeeScript when source files are modified', ->
    build true

task 'test', 'Run the test suite', ->
    build ->
        {reporters} = require 'nodeunit'
        process.chdir __dirname
        reporters.default.run ['test']
