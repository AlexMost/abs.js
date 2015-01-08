Rx = require 'rx'
{fromStream} = Rx.Node
through = require 'through2'
l = require 'lodash'
concat = require 'gulp-concat'


get_bundle_sources = (modules) ->
    l.map modules, (m) -> m.casted_module


process_bundle = (config, bundle, modules) ->
    sources = get_bundle_sources modules
    Rx.Observable.create (observer) ->

        # TODO: write bundles resolver 
        # (default name as default)
        bundle_cast = config.bundles.default.cast

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

module.exports = {process_bundle}