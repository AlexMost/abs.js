# Module adapter.
class Adapter
    ###
    @param adapter_data [Object] initial data for adapter.
    @option adapter_data [Function] was_changed
    @option adapter_data [Function] get_files
    ###
    constructor: (@adapter_data) ->

    ###
    Defines if module was changed.
    @param [Module] module.
    @param [CachedModule] cached_module cached module.
    @param [Function] cb nodejs callback (err, result) ->
    ###
    was_changed: (module, cached_module, cb) ->
        @adapter_data.was_changed(
            module, cached_module, cb)

    ###
    Gets module filepaths.
    @param [Module] module.
    @param [Config] config module config.
    @param [Function] cb nodejs callback (err, result) ->
    ###
    get_files: (module, config, cb) ->
        @adapter_data.get_files(
            module, config, cb)


module.exports = {Adapter}