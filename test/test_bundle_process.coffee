gulp = require 'gulp'
path = require 'path'
Rx = require 'rx'
concat = require 'gulp-concat'
header = require 'gulp-header'
{resolve_bundle_processor,
process_bundle} = require '../src/bundle'
File = require 'vinyl'


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


exports.test_process_bundle = (test) ->
    bundle_mock =
        name: "bundle1"

    config_mock =
        bundles:
            default:
                cast: (stream, bundle) ->
                    stream
                    .pipe(concat(
                        "#{bundle.name}.js"
                        {newLine: ";"}))

    # some module mocks with casted module attribute
    module1_contents = "module1_contents"
    module1 =
        name: "module1"
        casted_module:
            new File({
                cwd: "/"
                base: "/test/"
                path: "/test/module2.js"
                contents: new Buffer(module1_contents)
            })

    module2_contents = "module2_contents"
    module2 =
        name: "module2"
        casted_module:
            new File({
                cwd: "/"
                base: "/test/"
                path: "/test/module1.js"
                contents: new Buffer(module2_contents)
            })

    process_bundle(
        config_mock
        bundle_mock
        [module1, module2])
    .subscribe(
        (bundle) ->
            test.ok(
                path.basename(bundle.path) is "bundle1.js",
                "Bundle name must be bundle1.js")

            contents = bundle.contents.toString()
            test.ok(
                contents is (module1_contents + ";" + module2_contents),
                "Bundle must contain concatenated modules")

            test.done()
        (error) ->
            tets.done()
    )

