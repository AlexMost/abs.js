Rx = require 'rx'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{liftCbToRx} = require './lib'


module_to_observable = (config) -> (recipe) -> (mod) ->
    console.log "---- module ----", mod.name
    Rx.Observable.create (observer) ->
        if mod.name is "module4"
            setTimeout(
                ->
                    observer.onNext mod
                    observer.onCompleted()
                2000
            )
        else
            observer.onNext mod
            observer.onCompleted()


abs_build = (config, recipe) ->
    modules_source = Rx.Observable
                       .fromArray(recipe.modules)
                       .flatMap(module_to_observable(config)(recipe))

    compiled_modules_stream = new Rx.Subject()

    recipe.bundles.map (bundle) ->
        compiled_modules_stream
            .filter((m) -> m.name in bundle.modules)
            .bufferWithCount(bundle.modules.length)
            .first()
            .subscribe((r) -> console.log r)

    modules_source.subscribe(
        (b) -> compiled_modules_stream.onNext(b)
        (err) -> compiled_modules_stream.onError err
    )


abs = (raw_config) -> (recipe_path) ->
    config = parse_config raw_config
    get_recipe_data recipe_path, (err, recipe) ->
        abs_build config, recipe


module.exports = abs