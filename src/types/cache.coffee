l = require 'lodash'
{CachedModule} = require './cached_module'

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

    ###
    Gets cached module from cache if exists.
    @param [String] module_name name of the module.
    @return [CachedModule, null] cached module if found else null.
    ###
    getCachedModule: (module_name) ->
        return null unless @isEmpty()
        return null unless module_name of @data
        new CachedModuleJ(@data.modules[module_name])

module.exports = {Cache}