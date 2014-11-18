l = require 'lodash'
compiler_mock = require '../src/compiler_mock'
path = require 'path'
{compile_module} = require '../src/module'


mock_module =
    name: 'module4'
    path: './fixtures/src/test_module_compiler.mycomp'
    deps: []
    opts: {}
    type: 'single_file'
    is_changed: true
    file_paths: [
        path.resolve('./test/fixtures/src/test_module_compiler.mycomp')]


exports.test_compile_module = (test) ->
    prefix = "test_compile_module_file"

    mock_config =
        compilers: [
            name: "mycomp"
            ext: ".mycomp"
            cast: (stream) -> stream.pipe(compiler_mock {prefix})
        ]

    module_source = compile_module mock_config, mock_module
    module_source.subscribe(
        (module) ->
            compiled_file = (l.first module.compiled_files)
            source = compiled_file.contents.toString()
            compiled = compiled_file.compiled.toString()
            test.ok(
                prefix + source is compiled
                "Module file must be with prefix #{prefix}"
            )
            test.done()
        (err) -> test.ok(false, "Failed to compile module")
    )

