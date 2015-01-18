# Application config
class Config

    ###
    @param [Object] config_data initial config data.
    @option config_data [String] name bundle name
    @option config_data [String] recipe_path recipe path.
    @option config_data [Object] adapters module adapters.
    @option config_data [Array<Object>] compilers list of file compilers.
    @option config_data [Object] modules dict with modules.
    @option config_data [Object] bundles dict with bundles.
    ###
    constructor: (@config_data) ->

    ###
    @return [String] bundle name
    ###
    get_bundle_name: ->
        @config_data.name

    ###
    @return [String] recipe path.
    ###
    get_recipe_path: ->
        @config_data.recipe_path

    ###
    @return [Object] modules adapters.
    ###
    get_adapters: ->
        @config_data.adapters

    ###
    @return [Array<Object>] file compilers.
    ###
    get_compilers: ->
        @config_data.compilers

    ###
    @return [Object] modules.
    ###
    get_modules: ->
        @config_data.modules

    ###
    @return [Object] bundles.
    ###
    get_bundles: ->
        @config_data.bundles


module.exports = {Config}
