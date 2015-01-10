gulp = require 'gulp'
path = require 'path'
Rx = require 'rx'
{resolve_bundle_processor} = require '../src/bundle'


exports.test_resolve_bundle_processor = (test) ->
    config_mock =
        bundles:
            default:
                cast: -> "default"
            test_bundle:
                cast: -> "test_bundle"

    default_bundle_processor = resolve_bundle_processor(
        "not_existing_bundle", config_mock)

    test.ok(
        default_bundle_processor.cast() is "default",
        "Must resolve default bundle")

    test_bundle_processor = resolve_bundle_processor(
        "test_bundle", config_mock)

    test.ok(
        test_bundle_processor.cast() is "test_bundle",
        "Must resolve test bundle")

    test.done()
