Rx = require 'rx'


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


module.exports = {process_module}


