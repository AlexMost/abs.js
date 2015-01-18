path = require 'path'
{get_compiler, compile_file} = require '../src/module_process'
compiler_mock = require '../src/compiler_mock'
{Config} = require '../src/types/config'


exports.test_get_compiler_for_single_ext = (test) ->
    mock_config = new Config
        compilers:
            coffee:
                ext: ".coffee"

    file = "some/file/name.coffee"

    compiler = get_compiler mock_config, file
    test.deepEqual compiler, {ext: ".coffee"}, "must resolve coffee compiler"
    test.done()


exports.test_get_compiler_for_list_of_exts = (test) ->
    mock_config = new Config
        compilers:
            coffee:
                ext: [".coffee"]

    file = "some/file/name.coffee"

    compiler = get_compiler mock_config, file
    test.deepEqual compiler, {ext: [".coffee"]}, "must resolve coffee compiler"
    test.done()


exports.test_get_default_compiler_if_not_resolved = (test) ->
    mock_config = new Config
        compilers:
            coffee:
                ext: ".coffee"

    file = "some/file/name.js"

    compiler = get_compiler mock_config, file
    test.ok compiler.name is "default", "must resolve to default compiler"
    test.done()


exports.test_compile_file = (test) ->
    prefix = "test_compile_module_file"
    file = path.resolve './test/fixtures/src/test_module_compiler.mycomp'

    mock_config = new Config
        compilers: [
            name: "mycomp"
            ext: ".mycomp"
            cast: (stream) -> stream.pipe(compiler_mock {prefix})
        ]

    file_source = compile_file mock_config, file

    file_source.subscribe(
        (file) ->
            compiled = file.compiled.toString()
            contents = file.contents.toString()
            test.ok(
                (prefix + contents) is compiled
                "file must be compiled")
            test.done()
        (err) -> test.ok(false, err)
    )




