Rx = require 'rx'
fs = require 'fs'
readFile = Rx.Node.fromNodeCallback fs.readFile
l = require 'lodash'

DEFAULT_CACHE_PATH = ".abscache"

# Application cache is used for storing compiled modules and
#   bundles data and metadata
#
class Cache
    ###
    @param [Object] data object parsed from json
    @param [String] cache_path cache path
    @example internal structure of data object
      {modules: [], bundles: []}
    ###
    constructor: (@data, @cache_path) ->

    ###
    Reads cache data
    @return [Object] cache data
    ###
    read: -> @data

    ###
    Defines wether cache data is empty
    @return [Boolean] is cache empty
    ###
    isEmpty: -> l.isEmpty @data


###
Factory function for creating new cache instance

@param [String] cache file path
@return [Rx.Observable] observable with cache instance
###
init_cache = (cache_file_path) ->
    cache_file_path or= DEFAULT_CACHE_PATH

    Rx.Observable.create (observer) ->
        readFile(cache_file_path)
        .map((file_buffer) -> JSON.parse file_buffer)
        .map((data) -> new Cache data, cache_file_path)
        .subscribe(
            (cache_dump) ->
                observer.onNext cache_dump
                observer.onCompleted()
            (error) ->
                observer.onNext(make_cache {})
                observer.onCompleted
        )


module.exports = {init_cache, Cache}