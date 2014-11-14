path = require 'path'
Rx = require 'rx'
gulp = require 'gulp'
through = require 'through2'
{fromStream} = require Rx.Node
l = require 'lodash'


default_compiler =
    name: "default"
    cast: (stream) -> stream

get_is_module_changed = (module, adapter) ->
    Rx.Observable.create (observer) ->
        adapter.was_changed module, (err, is_changed) ->
            if err
                observer.onError err
            else
                observer.onNext is_changed
                observer.onCompleted()


get_module_files = (module, adapter) ->
    Rx.Observable.create (observer) ->
        adapter.get_files module, (err, files) ->
            if err
                observer.onError err
            else
                observer.onNext files
                observer.onCompleted()    



process_module = (config, module) ->
    Rx.Observable.create (observer) ->
        adapter = config.adapters[module.type]

        unless adapter
            observer.onError(
                "Adapter not found for module #{module.name}")
            return

        Rx.Observable.zip(
            (get_is_module_changed module, adapter)
            (get_module_files module, adapter)
            (is_changed, file_paths) -> [is_changed, file_paths])
        .first()
        .subscribe(
            ([is_changed, file_paths]) ->
                module.is_changed = is_changed
                module.file_paths = file_paths
                observer.onNext module
                observer.onCompleted()
            (err) -> observer.onError err
        )


get_compiler = (config, file) ->
    file_ext = path.extname file
    compilers = l.filter config.compilers, (compiler) ->
        if l.isArray compiler.ext
            file_ext in compiler.ext
        else
            file_ext is compiler.ext
    (l.first compilers) or default_compiler


run_gulp_task = (sequence) -> (file) ->
    Rx.Observable.create((obs)->
        stream = through.obj()
        sequence(stream)
        .on('data', (data) ->
            obs.onNext data
            obs.onCompleted()
        )
        stream.write file
    )


compile_file = (config, file) ->
    compiler = get_compiler config, file
    file_source.map(run_gulp_task compiler.cast)


compile_modules = (config, modules) ->
    Rx.Observable.create (observer) ->
        observer.onNext modules
        observer.onCompleted()


module.exports = {
    process_module, compile_modules, get_compiler, compile_file}


