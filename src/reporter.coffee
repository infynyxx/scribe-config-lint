class Reporter
    constructor: (@storesConf) ->
        @errors = {}
        @noError = true
        @process()

    process: ->
        for store_conf, index in @storesConf
            key = "#{store_conf.storeName} #{index+1}"
            if store_conf.errors.length > 0
                @errors[key] = store_conf.errors
                @noError = false
            for child_store, child of store_conf.children
                if child.errors.length > 0
                    @errors["#{key}:#{child.storeName}"] = child.errors
                    @noError = false
                

exports.createReport = (storesConf) ->
    new Reporter storesConf

