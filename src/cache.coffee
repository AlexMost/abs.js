Rx = require 'rx'
fs = require 'fs'
readFile = Rx.Node.fromNodeCallback fs.readFile
l = require 'lodash'


make_cache = (data) ->
    read: -> data
    isEmpty: -> l.isEmpty data


init_cache = (cache_file_path) ->
    ###
    Returns observable with cache object
    If no file were found while reading cache_filte_path then
    empty cache is returned.
    ###

    Rx.Observable.create (observer) ->
        readFile(cache_file_path)
        .map((file_buffer) -> JSON.parse file_buffer)
        .map(make_cache)
        .subscribe(
            (cache_dump) ->
                observer.onNext cache_dump
                observer.onCompleted()
            (error) ->
                observer.onNext(make_cache {})
                observer.onCompleted
        )


module.exports = {init_cache}