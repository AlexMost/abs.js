path = require 'path'
Rx = require 'rx'
gulp = require 'gulp'
through = require 'through2'
{fromStream} = Rx.Node
{run_gulp_task} = require './lib'
l = require 'lodash'


default_compiler =
    name: "default"
    cast: (stream) -> stream


get_is_module_changed = (module, adapter, cached_module) ->
    Rx.Observable.create (observer) ->
        unless cached_module
            observer.onNext true
            observer.onCompleted()
            return

        adapter.was_changed module, cached_module, (err, is_changed) ->
            if err
                observer.onError err
            else
                observer.onNext is_changed
                observer.onCompleted()


get_module_files = (module, adapter, config) ->
    Rx.Observable.create (observer) ->
        adapter.get_files module, config, (err, files) ->
            if err
                observer.onError err
            else
                observer.onNext files
                observer.onCompleted()


get_module_from_cache = (module_name, cache_data) ->
    return null unless cache_data.modules
    cache_data.modules[module_name]


process_module = (config, cache, module) ->
    cached_module = get_module_from_cache(
        module.name, cache.read())

    Rx.Observable.create (observer) ->
        adapter = config.adapters[module.type]

        unless adapter
            observer.onError(
                "Adapter not found for module #{module.name}")
            return

        get_module_files(module, adapter, config)
        .flatMap((file_paths) ->
            module.file_paths = file_paths
            get_is_module_changed(
                module, adapter, cached_module, file_paths))
        .first()
        .subscribe(
            (is_changed) ->
                module.is_changed = is_changed
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )


get_compiler = (config, file) ->
    ###
    Resolves compiler from config by file extension.
    If compiler wasn't resolved - get's default compiler.
    returns: compiler with cast function for file processing.
    ###
    
    file_ext = path.extname file
    compilers = l.filter config.compilers, (compiler) ->
        if l.isArray compiler.ext
            file_ext in compiler.ext
        else
            file_ext is compiler.ext
    (l.first compilers) or default_compiler


compile_file = (config, file) ->
    ###
    Retreives compiler with cast function and use it's
    cast function to compile file
    returns: Observable with compiled vinyl File object
    ###

    compiler = get_compiler config, file

    (fromStream gulp.src(file))
    .flatMapLatest(run_gulp_task compiler.cast)
    .first()


compile_module = (config, module) ->
    ###
    Accepts module from recipe that need to be compiled.
    Compiles all resolved paths from module.file_paths attribute.
    Adds compiled_files attribute with compiled sources to module object
    returns: Observable module
    ###

    Rx.Observable.create (observer) ->
        Rx.Observable
        .fromArray(module.file_paths)
        .flatMap(l.partial(compile_file, config))
        .toArray()
        .subscribe(
            (compiled_files) ->
                module.compiled_files = compiled_files
                observer.onNext module
                observer.onCompleted()
            (err) ->
                # TODO: provide more clear explanation if failed due to
                # module file was not found
                observer.onError(
                    "Failed to compile module #{module.name} #{err}")
        )


compile_modules = (config, modules) ->
    Rx.Observable
    .fromArray(modules)
    .flatMap(l.partial(compile_module, config))


cast_module = (config, module) ->
    Rx.Observable.create (observer) ->
        module_cast = config.modules[module.type]?.cast

        unless module_cast
            observer.onError(
                """
                Failed to resolve cast for module #{module.name}\n
                type - #{module.type}\n
                path - #{module.path}
                """)
            return

        stream = through.obj()
        fromStream(module_cast(stream, module))
        .first()
        .subscribe(
            (file) ->
                module.casted_module = file
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )
        stream.write f for f in module.compiled_files
        stream.end()


module.exports = {
    process_module, compile_modules, get_compiler, compile_file,
    compile_module, cast_module, get_is_module_changed
}
