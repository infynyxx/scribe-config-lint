
log = (str) ->
    str = str.trim("\n") if typeof str is 'string'
    console.log str

exports.log = log
