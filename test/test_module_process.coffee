l = require 'lodash'
compiler_mock = require '../src/compiler_mock'
path = require 'path'
{compile_module, compile_modules, cast_module,
get_is_module_changed} = require '../src/module'


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

            test.ok(
                module.compiled_files.length is 1
                "Must be only one compiled source file"
            )

            source = compiled_file.contents.toString()
            compiled = compiled_file.compiled.toString()
            
            test.ok(
                prefix + source is compiled
                "Module file must be with prefix #{prefix}"
            )
            test.done()
        (err) ->
            test.ok(false, "Failed to compile module")
            test.done()
    )


exports.test_compile_modules = (test) ->
    prefix = "test_compile_module_file"

    mock_config =
        compilers: [
            name: "mycomp"
            ext: ".mycomp"
            cast: (stream) -> stream.pipe(compiler_mock {prefix})
        ]

    compile_modules(mock_config, [mock_module1, mock_module2])
    .toArray()
    .subscribe(
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
            test.ok false, "must not fail"
            test.done()
    )


exports.test_cast_module = (test) ->
    prefix = "prefix1_"
    cast_prefix = "prefix2_"

    mock_config =
        compilers: [
            name: "mycomp"
            ext: ".mycomp"
            cast: (stream) ->
                stream.pipe(compiler_mock {prefix})
        ]
        modules:
            single_file:
                cast: (stream, module) ->
                    stream.pipe(compiler_mock {prefix: cast_prefix})

    (compile_module mock_config, mock_module1)
    .flatMap(l.partial(cast_module, mock_config))
    .subscribe(
        (module) ->
            test.ok(
                module.casted_module
                "Must be casted module after module cast")

            test.ok(
                module.compiled_files.length is 1
                "Must be only one compiled source file")

            src_content = module.compiled_files[0].contents.toString()
            compiled = module.casted_module.compiled.toString()

            test.ok(
                (compiled is (cast_prefix + prefix + src_content))
                "Module cast return's wrong result"
            )
            test.done()
        (err) ->
            test.ok false, "should not fail when casting module"
            test.done()
    )


exports.test_get_is_module_changed_with_no_cache = (test) ->
    module =
        name: "module1"
        path: "module1.coffee"

    get_is_module_changed(module, {}, null)
    .subscribe(
        (is_changed) ->
            test.ok(
                is_changed,
                "Should be changed if no cached module")
            test.done()
        (err) ->
            test.ok false, "Should not fail"
    )


exports.test_get_is_module_changed_with_cache_changed = (test) ->
    module =
        name: "module1"
        path: "module1.coffee"

    adapter_mock =
        was_changed: (module, cached_module, cb) ->
            cb null, true

    get_is_module_changed(
        module, adapter_mock, {cache: "cache_mock"})
    .subscribe(
        (is_changed) ->
            test.ok(
                is_changed,
                "Should be changed")
            test.done()
        (err) ->
            test.ok false, "Should not fail"
    )


exports.test_get_is_module_changed_with_cache_not_changed = (test) ->
    module =
        name: "module1"
        path: "module1.coffee"

    adapter_mock =
        was_changed: (module, cached_module, cb) ->
            cb null, false

    get_is_module_changed(
        module, adapter_mock, {cache: "cache_mock"})
    .subscribe(
        (is_changed) ->
            test.ok(
                not is_changed,
                "Should not be changed")
            test.done()
        (err) ->
            test.ok false, "Should not fail"
    )
