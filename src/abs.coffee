Rx = require 'rx'
l = require 'lodash'
parse_config = require './config_parser'
{get_recipe_data} = require 'recipejs'
{process_module} = require './module'


abs_build = (config, recipe) ->
    _process_module = l.partial process_module, config

    modules_source = Rx.Observable
                       .fromArray(recipe.modules)
                       .flatMap(_process_module)
    
    compiled_modules_stream = new Rx.Subject()

    recipe.bundles.map (bundle) ->
        compiled_modules_stream
            .filter((m) -> m.name in bundle.modules)
            .bufferWithCount(bundle.modules.length)
            .first()
            .subscribe(
                (r) -> console.log r
                (err) -> console.log "[Err]", err)

    modules_source.subscribe(
        (b) -> compiled_modules_stream.onNext(b)
        (err) -> compiled_modules_stream.onError err
    )


abs = (raw_config) -> (recipe_path) ->
    config = parse_config raw_config
    get_recipe_data recipe_path, (err, recipe) ->
        abs_build config, recipe


module.exports = abs