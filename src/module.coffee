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

###
Defines wether module was changed.
@param [Object] module application module
@param [Object] adapter module adapter
@param [Object] cached_module cached module
@return [Rx.Observable Boolean] is module changed
###
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

###
Attaching file paths to module object.
  Uses config to resolve appropriate adapter for module
  and retreives module file paths

@param [Object] config abs.js config
@param [Object] module module
@return [Rx.Observable] observable with the same module 
  with 'file_paths' property attached
###
attach_module_files = (config, module) ->
    adapter = config.adapters[module.type]

    Rx.Observable.create (observer) ->
        unless adapter
            observer.onError(
                "Adapter not found for module #{module.name}")
            return

        get_module_files(module, adapter, config)
        .subscribe(
            (file_paths) ->
                module.file_paths = file_paths
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err)

###
Attaching is_changed flag to module object.
  Uses config to resolve appropriate adapter for module
  and defines wether module is changed.

@param [Object] config abs.js config
@param [Cache] cache application cache
@param [Object] module module
@return [Rx.Observable] observable with the same module 
  with 'is_changed' property attached
###
attach_is_changed = (config, cache, module) ->
    cached_module = get_module_from_cache(
        module.name, cache.read())

    adapter = config.adapters[module.type]

    Rx.Observable.create (observer) ->
        unless adapter
            observer.onError(
                "Adapter not found for module #{module.name}")
            return

        get_is_module_changed(module, adapter, cached_module)
        .subscribe(
            (is_changed) ->
                module.is_changed = is_changed
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )


###
    Resolves compiler from config by file extension.
    If compiler wasn't resolved - get's default compiler.
    returns: compiler with cast function for file processing.
###
get_compiler = (config, file) ->
    file_ext = path.extname file
    compilers = l.filter config.compilers, (compiler) ->
        if l.isArray compiler.ext
            file_ext in compiler.ext
        else
            file_ext is compiler.ext
    (l.first compilers) or default_compiler


###
    Retreives compiler with cast function and use it's
    cast function to compile file
    returns: Observable with compiled vinyl File object
###
compile_file = (config, file) ->
    compiler = get_compiler config, file

    (fromStream gulp.src(file))
    .flatMapLatest(run_gulp_task compiler.cast)
    .first()


###
    Accepts module from recipe that need to be compiled.
    Compiles all resolved paths from module.file_paths attribute.
    Adds compiled_files attribute with compiled sources to module object
    returns: Observable module
###
compile_module = (config, module) ->

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

###
Compile module files with [Config.compilers] and casts each
    separate module with appropriate module adapter form [Config.adapters]
@param [Object] config application config
@param [Array<Module>] modules array of modules
@return [Rx.Observable Module] observable with compiled module
###
process_modules = (config, modules) ->
    Rx.Observable
    .fromArray(modules)
    .flatMap(l.partial(compile_module, config))
    .flatMap(l.partial(cast_module, config))


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
    attach_is_changed, process_modules, get_compiler, compile_file,
    compile_module, cast_module, get_is_module_changed, attach_module_files
}
