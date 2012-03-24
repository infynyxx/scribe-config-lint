{log} = require './util'
fs = require 'fs'

is_valid = (config_file) ->
    true

parse_line = (line) ->
    true

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
    pattern = /^([a-z0-9_]+)\=([a-z0-9_\/]+)([\*]?)$/i
    arr = pattern.exec line
    if arr is null then false else true

is_valid_category = (line) ->
    line = discard_comment_in_line line
    pattern = /^category\=([a-z0-9_\/]+)([\*]?)$/i
    arr = pattern.exec line
    if arr is null then false else true


exports.parse = (config_file) ->
    try
        content = fs.readFileSync config_file, 'utf8'
    catch error
        log error.toString().red
        return false
    
    store_meta = {}
    key_value_meta = []
    category_meta = []
    check_for_valid_category = false
    has_valid_category = false
    for line, index in content.split "\n"
        line_number = index + 1
        line = line.trim()
        length = line.length
            
        continue if length is 0
        
        continue if is_comment_line line

        store_start = get_store_start line
        if store_start isnt false
            store_meta[store_start] =
                name: store_start
                start_line: line_number
            check_for_valid_category = true
            continue

        store_end = get_store_end line
        #console.log store_end
        if store_end isnt false and store_meta[store_end] isnt 'undefined'
            #category_meta.push store_meta['store_end']['start_line'] if has_valid_category is false and check_for_valid_category is true
            #check_for_valid_category = false
            
            delete store_meta[store_end]
            continue

        key_value_meta.push line_number if not is_valid_key_value line

        #has_valid_category = true if check_for_valid_category is true and is_valid_category(line) is true

    console.log store_meta
    console.log key_value_meta if key_value_meta.length isnt 0
    console.log category_meta if category_meta.length isnt 0
            
    true
