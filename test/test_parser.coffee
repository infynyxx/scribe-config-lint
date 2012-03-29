{parse} = require '../lib/parser'
{testCase} = require 'nodeunit'

exports.testParserWithInvalidFile = (test) ->
    test.expect 1
    
    report = parse '/tmp/file_doesnt_exist'

    test.equal report, false

    test.done()

exports.testParserWithValidFile = (test) ->
    report = parse './test/fixtures/valid.conf'

    test.equal report.noError, true
    
    count = 0
    for key, errors of report.errors
        (count += 1) for error in errors
    
    test.equal count, 0

    test.expect 2

    test.done()

exports.testParserWithCategoryError = (test) ->
    report = parse './test/fixtures/invalid_category.conf'

    count = 0
    for key, errors of report.errors
        for error in errors
            count += 1
            test.notEqual error.indexOf("Category not found"), -1

    test.equal count,  2

    test.expect count+1

    test.done()

exports.testParserWithStoreChildError = (test) ->
    report = parse './test/fixtures/invalid_child_store.conf'
    duplicate_count = 0
    for key, errors of report.errors
        for error in errors
            duplicate_count += 1 if error.indexOf("Duplicate key:") isnt -1

    test.equal duplicate_count, 1
    test.expect 1
    test.done()

