compiler = require '../src/compiler_mock'
gulp = require 'gulp'


exports.test_compiler_mock_adds_default_prefix = (test) ->
    prefix = "mock_compiler_test"
    compiler_stream = compiler {prefix}
    gulp.src('./test/fixtures/src/file_for_mock_compiler')
        .pipe(compiler_stream)
        .on('data', (file) ->
            old_content = file.contents.toString()
            compiled_content = file.compiled.toString()
            
            test.ok(
                (prefix + old_content) is compiled_content
                "Compiled source must contain prefix"
            )
            test.done()
        )

