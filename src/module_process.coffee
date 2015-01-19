path = require 'path'
Rx = require 'rx'
gulp = require 'gulp'
through = require 'through2'
l = require 'lodash'
{fromStream} = Rx.Node
{Adapter} = require './types/adapter'
{compile_module} = require './compiler_process'


###
Defines if module was changed.
@param [Module] module application module.
@param [Adapter] adapter module adapter.
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
@param [Adapter] adapter.
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
    adapter = new Adapter(adapters[module.get_type()])

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
    adapter = new Adapter(adapters[module.get_type()])

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
    attach_is_changed, process_modules, cast_module, get_is_module_changed,
    attach_module_files
}
