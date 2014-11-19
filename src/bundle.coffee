Rx = require 'rx'
through = require 'through2'
l = require 'lodash'


get_bundle_sources = (modules) ->
    l.compose(
        l.flatten
        l.map modules, (m) -> m.compiled_files
    )


dispatch_bundle_cast = (config, bundle) ->
    if bundle.name of config.bundles
        config.bundles[bundle.name]
    else
        config.bundles['default']


run_bundle_cast = (files, bundle, cast, cb) ->
    # XXX. To test this func
    stream = through.obj()
    cast_stream = cast stream, bundle
    stream.write f for f in files
    stream.end()
    cast_stream.on('end', -> cb?())


process_bundle = (config, bundle, modules) ->
    Rx.Observable.create (observer) ->
        sources = get_bundle_sources modules
        bundle_cast = dispatch_bundle_cast config, bundle

        if not bundle_cast
            observer.onError(
                "Can't resolve bundle cast for bundle #{bundle.name}")
            return

        run_bundle_cast sources, bundle, bundle_cast.cast


module.exports = {process_bundle}