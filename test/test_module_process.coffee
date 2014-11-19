l = require 'lodash'
compiler_mock = require '../src/compiler_mock'
path = require 'path'
{compile_module, compile_modules} = require '../src/module'


mock_module1 =
    name: 'module4'
    path: './fixtures/src/test_module_compiler.mycomp'
    deps: []
    opts: {}
    type: 'single_file'
    is_changed: true
    file_paths: [
        path.resolve('./test/fixtures/src/test_module_compiler.mycomp')]


mock_module2 =
    name: 'module5'
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

    module_source = compile_module mock_config, mock_module1
    
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


exports.test_compile_modules = (test) ->
    prefix = "test_compile_module_file"

    mock_config =
        compilers: [
            name: "mycomp"
            ext: ".mycomp"
            cast: (stream) -> stream.pipe(compiler_mock {prefix})
        ]

    modules_source = compile_modules mock_config, [mock_module1, mock_module2]
    modules_source.subscribe(
        (modules) ->
            test.ok(
                modules.length is 2,
                "must be 2 compiled modules")
            
            [module1, module2] = modules

            mod_1_source = module1.compiled_files[0].contents.toString()
            mod_1_compiled = module1.compiled_files[0].compiled.toString()

            test.ok(
                prefix + mod_1_source is mod_1_compiled
                "Module must be compiled")

            mod_2_source = module2.compiled_files[0].contents.toString()
            mod_2_compiled = module2.compiled_files[0].compiled.toString()

            test.ok(
                prefix + mod_2_source is mod_2_compiled
                "Module must be compiled")

            test.done()
        (err) ->
            console.log err
            test.ok false, "must not fail"
    )


