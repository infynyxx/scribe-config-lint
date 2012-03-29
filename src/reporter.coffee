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

