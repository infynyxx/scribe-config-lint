{log} = require './util'
{createReport} = require './reporter'
fs = require 'fs'

is_comment_line = (line) ->
    line[0] is '#'

discard_comment_in_line = (line) ->
    lines = line.split ' '
    return lines[0]

get_store_start = (line) ->
    line = discard_comment_in_line line
    return false if line[0] isnt '<'

    # <store_name>
    store_pattern = /^<([a-z0-9_]+)>$/i
    arr = store_pattern.exec line
    return false if arr not instanceof Array or arr.length > 2

    return arr[1]

get_store_end = (line) ->
    line = discard_comment_in_line line
    return false if line.length <= 2 and line[0] is '<' and line[1] is '/'

    # </store_name>
    store_pattern = /^<\/([a-z0-9_]+)>$/i
    arr = store_pattern.exec line
    return false if arr not instanceof Array or arr.length > 2

    return arr[1]

is_valid_key_value = (line) ->
    line = discard_comment_in_line line
    # file_path=/tmp/scribetest/bucket0
    # category=tps_report*
    pattern = /^([a-z0-9_]+)\=([a-z0-9-_\/]+)([\*]?)$/i
    arr = pattern.exec line
    if arr is null then false else true

is_valid_category = (line) ->
    line = discard_comment_in_line line
    pattern = /^category\=([a-z0-9_\/]+)([\*]?)$/i
    arr = pattern.exec line
    arr isnt null

class StoreParser
    constructor: (@lines, @storeName, @startLine) ->
        @children = {}
        @errors = []
        @hasEnd = false
        @keys = []
        @parse()

    parse: ->
        category_found = (@storeName isnt 'store') # no need for non-store
        duplicates = []
        dont_search_for_duplicates = false
        
        for line, index in @lines when index >= @startLine
            line_number = index + 1
            continue if line.length is 0
            continue if is_comment_line(line) is true

            line = discard_comment_in_line line
            
            # set to true only if category is valid and the flag variable is false
            category_found = true if is_valid_category(line) is true and category_found is false
            
            store_start = get_store_start line
            if store_start is @storeName
                @errors.push "Line #{line_number}: Closing tag before *#{@storeName}* not found"
                break

            if store_start isnt false
                if not @children[store_start]
                    @children[store_start] = new StoreParser @lines, store_start, line_number
                    dont_search_for_duplicates = true
                    continue
                else
                    @errors.push "Duplicate store name: #{store_start}"
                    break

            store_end = get_store_end line
            
            if store_end is @storeName
                @hasEnd = true
                @errors.push "Line #{@startLine+1}: Category not found" if category_found is false
                break
            
            childEnd = @findByName store_end
            if childEnd
                childEnd.hasEnd = true
                continue
            
            @errors.push "line #{line_number}: Invalid key value" if is_valid_key_value(line) is false
            
            if dont_search_for_duplicates is false
                splits = line.trim().split("=")
                if splits.length is 2
                    #log "#{splits[0]} #{@storeName}"
                    #console.log duplicates
                    if duplicates.indexOf(splits[0]) is -1 then duplicates.push splits[0] else @errors.push "Line #{line_number}: Duplicate key: #{splits[0]}"

        return

    findByName: (name) ->
        return @children[name]


exports.parse = (config_file) ->
    # try / catch is anti pattern; using it only for catching errors 
    # like when file is not found or some unexpected File IO error
    try
        content = fs.readFileSync config_file, 'utf8'
    catch error
        log error.toString().red
        return false
    
    store_meta = {}
    key_value_meta = []
    duplicate_meta = []
    lines = content.split "\n"
    stores_conf = []
    for line, index in lines
        line_number = index + 1
        line = line.trim()
        length = line.length
            
        continue if length is 0
        
        continue if is_comment_line(line) is true

        store_start = get_store_start line
        if store_start is 'store'
            stores_conf.push new StoreParser lines, store_start, line_number
            continue

    return createReport stores_conf
