# Module compiler
class Compiler
    ###
    @param compiler_data [Object] initial data for compiler.
    @option compiler_data [String] name compiler name.
    @option compiler_data [String] ext file extension.
    ###
    constructor: (@compiler_data) ->

    ###
    @return [String] name compiler name.
    ###
    get_name: ->
        @compiler_data.name

    ###
    @return [String Array<String>] file extensions for compiler.
    ###
    get_ext: ->
        @compiler_data.ext

    ###
    Proxy function for calling compiler cast method.
    @param [Stream] stream stream with module files.
    ###
    cast: (stream) =>
        @compiler_data.cast stream


module.exports = {Compiler}
