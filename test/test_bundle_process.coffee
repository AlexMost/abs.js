gulp = require 'gulp'
path = require 'path'
Rx = require 'rx'
concat = require 'gulp-concat'
header = require 'gulp-header'
{resolve_bundle_processor,
process_bundle} = require '../src/bundle_process'
File = require 'vinyl'
{Module} = require '../src/types/module'
{Bundle} = require '../src/types/bundle'
{Config} = require '../src/types/config'


exports.test_resolve_bundle_processor = (test) ->
    config_mock = new Config
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
    bundle_mock = new Bundle {name: "bundle1"}

    config_mock = new Config
        bundles:
            default:
                cast: (stream, bundle) ->
                    stream
                    .pipe(concat(
                        "#{bundle.get_name()}.js"
                        {newLine: ";"}))

    # some module mocks with casted module attribute
    module1_contents = "module1_contents"
    module1 = new Module
        name: "module1"
        compiled_module:
            new File({
                cwd: "/"
                base: "/test/"
                path: "/test/module2.js"
                contents: new Buffer(module1_contents)
            })

    module2_contents = "module2_contents"
    module2 = new Module
        name: "module2"
        compiled_module:
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
        (bundle_file) ->
            test.ok(
                path.basename(bundle_file.path) is "bundle1.js",
                "Bundle name must be bundle1.js")

            contents = bundle_file.contents.toString()
            test.ok(
                contents is (module1_contents + ";" + module2_contents),
                "Bundle must contain concatenated modules")

            test.done()
        (error) ->
            test.ok(false, "Must not fail process bundle")
    )

