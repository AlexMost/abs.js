gulp = require 'gulp'
path = require 'path'
Rx = require 'rx'
{concat_bundle_files} = require '../src/bundle'
concat = require 'gulp-concat'
{fromStream} = Rx.Node


exports.test_concat_bundle_files = (test) ->
    bundle =
        name: "default"
        cast: (stream, bundle) ->
            stream.pipe(concat())

    files = [
        path.resolve("./test/fixtures/src/test_bundle_cast_0")
        path.resolve("./test/fixtures/src/test_bundle_cast_1")
    ]

    fromStream(gulp.src(files))
    .toArray()
    .flatMap((files) -> fromStream(concat_bundle_files files, bundle))
    .subscribe(
        (b) ->
            fname = path.basename b.path
            test.ok(fname is "default.js", "Bundle filename must be default.js")
            test.done()
        (err) ->
            test.ok "false", "must not fail while concating bundle files"
    )
