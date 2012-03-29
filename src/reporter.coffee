###
class Reporter

    constructor: (@lines, @data) ->
        @errorCount = 0
        @errors =
            'generic': [],
            'store': []
        @process()

    process: ->
        if @data['generic'] and @data['generic'] instanceof Array and @data['generic'].length > 0
            for value, index in @data['generic']
                msg = "Line #{value}: #{@lines[value-1]}"
                @errors['generic'].push msg
                @errorCount += 1


        if @data['store']
            for store, value of @data['store']
                if value instanceof Array and value.length > 0
                    for line in value
                        msg = "#{line}: #{@lines[line-1]}"
                        @errors['store'].push msg
                        @errorCount += 1
                        
        return
###

class Reporter
    constructor: (@storesConf) ->
        @errors = {}
        @noError = true
        @process()

    process: ->
        for store_conf in @storesConf
            if store_conf.errors.length > 0
                @errors[store_conf.storeName] = store_conf.errors
                @noError = false
            for child_store, child of store_conf.children
                if child.errors.length > 0
                    @errors["#{store_conf.storeName}:#{child.storeName}"] = child.errors
                    @noError = false
                

exports.createReport = (lines, data) ->
    new Reporter lines, data

