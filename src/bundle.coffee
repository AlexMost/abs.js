Rx = require 'rx'
through = require 'through2'
l = require 'lodash'
concat = require 'gulp-concat'


get_bundle_sources = (modules) ->
    l.compose(l.flatten, (l.map modules, (m) -> m.compiled_files))


concat_bundle_files = (files, bundle) ->
    stream = through.obj()
    cast_stream = stream.pipe(concat("#{bundle.name}.js"))
    stream.write f for f in files
    stream.end()
    cast_stream


process_bundle = (config, bundle, modules) ->
    sources = get_bundle_sources modules
    Rx.Node.fromStream(concat_bundle_files sources, bundle)


module.exports = {process_bundle, concat_bundle_files}