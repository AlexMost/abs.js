Rx = require 'rx'
l = require 'lodash'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{process_module, compile_modules, cast_module} = require './module'
{process_bundle} = require './bundle'
{init_cache} = require './cache'

get_recipe_data_source = Rx.Node.fromNodeCallback get_recipe_data


any_module_changed = (modules) ->
    l.any modules.map (m) -> m.is_changed


abs_build = (config, recipe, cache) ->
    _process_module = l.partial(
        process_module, config, cache)
    
    modules_source =
    Rx.Observable
    .fromArray(recipe.modules)
    .flatMap(_process_module)

    compiled_modules_stream = new Rx.Subject()

    recipe.bundles.map (bundle) ->
        compiled_modules_stream
            .filter((m) -> m.name in bundle.modules)
            .bufferWithCount(bundle.modules.length)
            .first()
            .filter(any_module_changed)
            .flatMap(l.partial(compile_modules, config))
            .flatMap(l.partial(cast_module, config))
            .toArray()
            .flatMap(l.partial(process_bundle, config, bundle))
            .subscribe(
                (r) ->
                    # console.log '------------------------------------'
                    # console.log 'bundle', bundle.name
                    # console.log r.contents.toString()
                (err) ->
                    console.log "[Err]", err
                    console.log err.stack
                )

    modules_source.subscribe(
        (b) -> compiled_modules_stream.onNext(b)
        (err) -> compiled_modules_stream.onError err
    )


abs = (raw_config) ->
    # TODO: check if recipe path
    # TODO: config validation
    # TODO: make abs observable (returns bundles)
    recipe_path = raw_config.recipe_path
    config = parse_config raw_config
    Rx.Observable.zip(
        get_recipe_data_source(recipe_path),
        init_cache('.abscache'),
        (recipe, cache) -> [recipe, cache])
    .subscribe(
        ([recipe, cache]) ->
            abs_build config, recipe, cache
        (error) ->
            console.log "[Err]", error
            console.log error.stack
    )


module.exports = abs