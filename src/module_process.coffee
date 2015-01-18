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
Defines if module was changed.
@param [Module] module application module.
@param [Object] adapter module adapter.
@param [CachedModule] cached_module cached module.
@return [Rx.Observable Boolean] is module changed.
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

###
Gets module files.
@param [Module] module.
@param [Object] adapter.
@param [Config] config application config.
@return [Array<String>] array with module files.
###
get_module_files = (module, adapter, config) ->
    Rx.Observable.create (observer) ->
        adapter.get_files module, config, (err, files) ->
            if err
                observer.onError err
            else
                observer.onNext files
                observer.onCompleted()


###
Attaching file paths to module object.
  Uses config to resolve appropriate adapter for module
  and gets module file paths.

@param [Config] config abs.js config.
@param [Module] module module.
@return [Rx.Observable Module] observable with the same module
  with 'file_paths' property attached.
###
attach_module_files = (config, module) ->
    adapters = config.get_adapters() 
    adapter = adapters[module.get_type()]

    Rx.Observable.create (observer) ->
        unless adapter
            observer.onError(
                "Adapter not found for module #{module.get_name()}")
            return

        get_module_files(module, adapter, config)
        .subscribe(
            (file_paths) ->
                module.set_file_paths file_paths
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err)


###
Attaching is_changed flag to module object.
  Uses config to resolve appropriate adapter for module
  and defines wether module is changed.

@param [Config] config abs.js config.
@param [Cache] cache application cache.
@param [Module] module module.
@return [Rx.Observable Module] observable with the same module
  with 'is_changed' property attached.
###
attach_is_changed = (config, cache, module) ->
    cached_module = cache.getCachedModule(module.get_name())
    adapters = config.get_adapters()
    adapter = adapters[module.get_type()]

    Rx.Observable.create (observer) ->
        unless adapter
            observer.onError(
                "Adapter not found for module #{module.get_name()}")
            return

        get_is_module_changed(module, adapter, cached_module)
        .subscribe(
            (is_changed) ->
                module.set_is_changed is_changed
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )


###
Resolves compiler from config by file extension.
    If compiler wasn't resolved - get's default compiler.
@param [Config] config application config.
@param [String] filepath.
@return [Object] compiler with cast function for file processing.
###
get_compiler = (config, filepath) ->
    file_ext = path.extname filepath
    compilers = l.filter config.get_compilers(), (compiler) ->
        if l.isArray compiler.ext
            file_ext in compiler.ext
        else
            file_ext is compiler.ext
    (l.first compilers) or default_compiler


###
Gets compiler with cast function and use it's
    cast function to compile file
@param [Config] config application config.
@param [String] filepath.
@return [Rx.Observable File] with compiled vinyl File object
###
compile_file = (config, filepath) ->
    compiler = get_compiler config, filepath

    (fromStream gulp.src(filepath))
    .flatMapLatest(run_gulp_task compiler.cast)
    .first()


###
Accepts module from recipe that need to be compiled.
    Compiles all resolved paths from module.file_paths attribute.
    Adds compiled_files attribute with compiled sources to module object
@param [Config] config application config.
@module [Module] module application module.
@return [Observable Module] compiled module
###
compile_module = (config, module) ->

    Rx.Observable.create (observer) ->
        Rx.Observable
        .fromArray(module.get_file_paths())
        .flatMap(l.partial(compile_file, config))
        .toArray()
        .subscribe(
            (compiled_files) ->
                module.set_compiled_files compiled_files
                observer.onNext module
                observer.onCompleted()
            (err) ->
                # TODO: provide more clear explanation if failed due to
                # module file was not found
                observer.onError(
                    "Failed to compile module #{module.get_name()} #{err}")
        )

###
Compile module files with [Config.compilers] and casts each
    separate module with appropriate module adapter form [Config.adapters]
@param [Config] config application config
@param [Array<Module>] modules array of modules
@return [Rx.Observable Module] observable with compiled module
###
process_modules = (config, modules) ->
    Rx.Observable
    .fromArray(modules)
    .flatMap(l.partial(compile_module, config))
    .flatMap(l.partial(cast_module, config))


###
Executes cast function with module sources.
@param [Config] config application config.
@param [Module] module module.
@return [Rx.Observable Module] observable module with compiled
    files.
###
cast_module = (config, module) ->
    Rx.Observable.create (observer) ->
        module_cast = config.get_modules()[module.get_type()]?.cast

        unless module_cast
            observer.onError(
                """
                Failed to resolve cast for module #{module.get_name()}\n
                type - #{module.get_type()}\n
                path - #{module.get_path()}
                """)
            return

        stream = through.obj()
        fromStream(module_cast(stream, module))
        .first()
        .subscribe(
            (file) ->
                module.set_compiled_module file
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )
        stream.write f for f in module.get_compiled_files()
        stream.end()


module.exports = {
    attach_is_changed, process_modules, get_compiler, compile_file,
    compile_module, cast_module, get_is_module_changed, attach_module_files
}
