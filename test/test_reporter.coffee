{createReport} = require '../lib/reporter'
{testCase} = require 'nodeunit'

exports.testReporterWithErrors = (test) ->
    test.expect 4

    stores_conf = [
        {
            'storeName': 'store',
            'errors': [
                "Error 1",
                "Error 2"
            ],
            'children': {
                'primary' : {
                    'storeName': 'primary',
                    'errors': [
                        "Error 3"
                    ]
                }
            }
        },
        {
            'storeName': 'store',
            'errors': [
                'Error 4'
            ]
        }
    ]
    report = createReport stores_conf

    test.equal report.noError, false
    test.equal report.errors['store 1'].length, 2
    test.equal report.errors['store 1:primary'].length, 1
    test.equal typeof report.errors['store 1:secondary'], 'undefined'

    test.done()


exports.testReporterWithNoErrors = (test) ->
    test.expect 1
    stores_conf = []

    report = createReport stores_conf

    test.equal report.noError, true

    test.done()

