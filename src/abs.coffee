Rx = require 'rx'
l = require 'lodash'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{attach_is_changed, process_modules, cast_module,
attach_module_files, compile_module} = require './module_process'
{process_bundle} = require './bundle_process'
{init_cache} = require './cache'
{Module} = require './types/module'
{Bundle} = require './types/bundle'

get_recipe_data_source = Rx.Node.fromNodeCallback get_recipe_data


any_module_changed = (modules) ->
    l.any modules.map (m) -> m.is_changed


abs_build = (config, recipe, cache) ->
    _attach_file_paths = l.partial(attach_module_files, config)
    _attach_is_changed = l.partial(attach_is_changed, config, cache)

    modules_source =
    Rx.Observable
    .fromArray(recipe.modules)
    .map((m) -> new Module m)
    .flatMap(_attach_file_paths)
    .flatMap(_attach_is_changed)

    compiled_modules_stream = new Rx.Subject()

    recipe.bundles.map (bundle_data) ->
        bundle = new Bundle bundle_data
        compiled_modules_stream
            .filter((m) -> m.name in bundle.get_modules())
            .bufferWithCount(bundle.get_modules().length)
            .first()
            .filter(any_module_changed)
            .flatMap(l.partial(process_modules, config))
            .toArray()
            .flatMap(l.partial(process_bundle, config, bundle))
            .subscribe(
                (r) ->
#                    console.log '------------------------------------'
#                    console.log 'bundle', bundle.name
#                    console.log r.contents.toString()
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
        init_cache(),
        (recipe, cache) -> [recipe, cache])
    .subscribe(
        ([recipe, cache]) ->
            abs_build config, recipe, cache
        (error) ->
            console.log "[Err]", error
            console.log error.stack
    )


module.exports = abs