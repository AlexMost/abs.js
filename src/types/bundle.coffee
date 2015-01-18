# Type for representing bundle with bunch of modules
class Bundle

    ###
    @param [Object] bundle_data contains initial data for bundle
    @option bundle_data [string] bundle name
    @option bundle_data [Array<Module>] modules
    ###
    constructor: (@bundle_data) ->

    ###
    Gets bundle name.
    @return [String] bundle name
    ###
    get_name: -> @bundle_data.name


    ###
    Gets bundle modules.
    @return [Array<String>] returns modules names that must be
        included in bundle
    ###
    get_modules: -> @bundle_data.modules or []


module.exports = {Bundle}
