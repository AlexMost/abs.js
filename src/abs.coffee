Rx = require 'rx'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{liftCbToRx} = require './lib'


module_to_observable = (config) -> (recipe) -> (mod) ->
    console.log "---- module ----", mod.name
    Rx.Observable.create (observer) ->
        if mod.name is "module1"
            setTimeout(
                ->
                    observer.onNext mod
                    observer.onCompleted()
                2000
            )
        else
            observer.onNext mod
            observer.onCompleted()


get_modules_source = (config, recipe) ->
    Rx.Observable
      .fromArray(recipe.modules)
      .flatMap(module_to_observable(config)(recipe))


bundle_to_observable = (modules_source) -> (bundle) ->
    modules_source.filter((m) -> m.name in bundle.modules)
                  .take(bundle.modules.length)
                  .toArray()


get_bundles_source = (config, recipe, modules_source) ->
    Rx.Observable.fromArray(recipe.bundles)
                 .flatMap(bundle_to_observable(modules_source))


abs_build = (config, recipe) ->
    modules_source = get_modules_source(config, recipe)
    bundles_source = get_bundles_source(config, recipe, modules_source)
    bundles_source.subscribe(
        (b) ->
            console.log (new Date()).toString()
            console.log b
        (er) -> console.log 'err', er
        () -> console.log 'done'
    )

abs = (raw_config) -> (recipe_path) ->
    config = parse_config raw_config
    get_recipe_data recipe_path, (err, recipe) ->
        abs_build config, recipe


module.exports = abs