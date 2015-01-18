Rx = require 'rx'
{fromStream} = Rx.Node
through = require 'through2'
l = require 'lodash'
concat = require 'gulp-concat'

###
Gets modules list from modules (Module)
@param [Array<Module>] modules
@return [Array<File>] vinyl files
###
get_bundle_sources = (modules) ->
    l.map modules, (m) -> m.get_compiled_module()


###
Resolves appropriate bundle processor
    from config. If no processor found - default
    bundle is used by default.
@param [String] bundle_name bundle name.
@param [Config] application config.
@return [Object] bundle processor.
###
resolve_bundle_processor = (bundle_name, config) ->
    bundles = config.get_bundles()

    if bundle_name of bundles
        bundles[bundle_name]
    else
        bundles["default"]

###
Processes bundle casts with appropriate transformations from config.
@param [Config] config application config.
@param [Bundle] bundle application bundle.
@param [Array<Module>] modules array of modules.
@return [Rx.Observable File] observable compiled file object.
###
process_bundle = (config, bundle, modules) ->
    sources = get_bundle_sources modules
    Rx.Observable.create (observer) ->

        bundle_processor = resolve_bundle_processor(
            bundle.get_name(), config)

        bundle_cast = bundle_processor.cast

        unless bundle_cast
            observer.onError(
                "Failed to resolve cast for bundle #{bundle.get_name()}")
            return

        stream = through.obj()
        fromStream(bundle_cast(stream, bundle))
        .subscribe(
            (bundle) ->
                observer.onNext bundle
                observer.onCompleted()
            (err) -> observer.onError err
        )
        stream.write s for s in sources
        stream.end()


module.exports = {process_bundle, resolve_bundle_processor}
