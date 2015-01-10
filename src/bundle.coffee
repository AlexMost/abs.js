Rx = require 'rx'
{fromStream} = Rx.Node
through = require 'through2'
l = require 'lodash'
concat = require 'gulp-concat'


get_bundle_sources = (modules) ->
    ###
    Gets modules list and retreives casted_module
    attribute from each module object
    ###

    l.map modules, (m) -> m.casted_module


resolve_bundle_processor = (bundle_name, config) ->
    ###
    Resolves appropriate bundle processor
    from config. If no processor found - default
    bundle is used by default.
    ###

    if bundle_name of config.bundles
        config.bundles[bundle_name]
    else
        config.bundles["default"]


process_bundle = (config, bundle, modules) ->
    sources = get_bundle_sources modules
    Rx.Observable.create (observer) ->

        bundle_processor = resolve_bundle_processor(
            bundle.name, config)

        bundle_cast = bundle_processor.cast

        unless bundle_cast
            observer.onError(
                "Failed to resolve cast for bundle #{bundle.name}")
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
