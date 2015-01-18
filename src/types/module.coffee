# Type is used for representing application module
class Module

    ###
    @param [Object] module_data contains initial data for module.
    @option module_data [String] name module name.
    @option module_data [String] path module path.
    @option module_data [Array<String>] deps module dependencies.
    @option module_data [Object] opts module additional options.
    ###
    constructor: (@module_data) ->

    ###
    Gets module name.
    @return [String] module name.
    ###
    get_name: -> @module_data.name

    ###
    Gets module path (relative to recipe file).
    @return [String] module path.
    ###
    get_path: -> @module_data.path

    ###
    Gets module type.
    @return [String] module type.
    ###
    get_type: -> @module_data.type

    ###
    Sets absolute file paths for module.
    @param [Array<String>] file paths.
    ###
    set_file_paths: (file_paths) ->
        @module_data.file_paths = file_paths

    ###
    Gets file paths.
    @return [Array<String>] module file paths.
    ###
    get_file_paths: -> @module_data.file_paths


    ###
    Sets module compiled files.
    @param [Array<File>] compiled_files vinyl file objects.
    ###
    set_compiled_files: (compiled_files) ->
        @module_data.compiled_files = compiled_files

    ###
    Gets compiled files.
    @return [Array<File>] compiled vinyl file objects.
    ###
    get_compiled_files: -> @module_data.compiled_files or []


    ###
    Sets compiled module.
    @param [File] sets result of compiled and concatenated module files.
    ###
    set_compiled_module: (compiled_module) ->
        @module_data.compiled_module = compiled_module

    ###
    Gets compiled module.
    @return [File] single vinyl file object with compiled and
        casted module files.
    ###
    get_compiled_module: -> @module_data.compiled_module

    ###
    Sets if module was changed.
    @param [Boolean] is_changed defines if module was modified.
    ###
    set_is_changed: (is_changed) ->
        @module_data.is_changed = is_changed

    ###
    Defines if module was changed.
    @return [Boolean] was module changed.
    ###
    is_changed: -> @module_data.is_changed


module.exports = {Module}