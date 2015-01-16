Rx = require 'rx'
fs = require 'fs'
readFile = Rx.Node.fromNodeCallback fs.readFile
l = require 'lodash'
{Cache} = require './types/cache'

# Is used for default filename for storing application cache.
DEFAULT_CACHE_PATH = ".abscache"

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
                observer.onNext(new Cache {}, cache_file_path)
                observer.onCompleted
        )


module.exports = {init_cache, Cache}