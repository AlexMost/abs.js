l = require 'lodash'

# Application cache is used for storing compiled modules and
#   bundles data and metadata
#
class Cache
    ###
    @param [Object] data object parsed from json
    @option data [Array<Object>] modules data
    @option data [Array<Object>] bundles data
    @param [String] cache_path cache path
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