{get_compiler} = require '../src/module'


exports.test_get_compiler_for_single_ext = (test) ->
    mock_config =
        compilers:
            coffee:
                ext: ".coffee"

    file = "some/file/name.coffee"

    compiler = get_compiler mock_config, file
    test.deepEqual compiler, {ext: ".coffee"}, "must resolve coffee compiler"
    test.done()


exports.test_get_compiler_for_list_of_exts = (test) ->
    mock_config =
        compilers:
            coffee:
                ext: [".coffee"]

    file = "some/file/name.coffee"

    compiler = get_compiler mock_config, file
    test.deepEqual compiler, {ext: [".coffee"]}, "must resolve coffee compiler"
    test.done()


exports.test_get_default_compiler_if_not_resolved = (test) ->
    mock_config =
        compilers:
            coffee:
                ext: ".coffee"

    file = "some/file/name.js"

    compiler = get_compiler mock_config, file
    test.ok compiler.name is "default", "must resolve to default compiler"
    test.done()
