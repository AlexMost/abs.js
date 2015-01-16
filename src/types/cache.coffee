l = require 'lodash'

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


module.exports = {Cache}