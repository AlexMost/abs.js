l = require 'lodash'
Rx = require 'rx'
path = require 'path'
gulp = require 'gulp'

{Compiler} = require './types/compiler'
{fromStream} = Rx.Node
{run_gulp_task} = require './lib'


default_compiler =
    name: "default"
    cast: (stream) -> stream


###
Resolves compiler from config by file extension.
    If compiler wasn't resolved - get's default compiler.
@param [Config] config application config.
@param [String] filepath.
@return [Compiler] compiler with cast function for file processing.
###
get_compiler = (config, filepath) ->
    file_ext = path.extname filepath
    compilers = l.filter config.get_compilers(), (compiler) ->
        ext = compiler.ext

        if l.isArray ext
            file_ext in ext
        else
            file_ext is ext

    new Compiler((l.first compilers) or default_compiler)


###
Gets compiler with cast function and use it's
    cast function to compile file
@param [Config] config application config.
@param [String] filepath.
@return [Rx.Observable File] with compiled vinyl File object
###
compile_file = (config, filepath) ->
    compiler = get_compiler config, filepath
    (fromStream gulp.src(filepath))
    .flatMapLatest(run_gulp_task compiler.cast)
    .first()


###
Accepts module from recipe that need to be compiled.
    Compiles all resolved paths from module.get_file_paths().
    Sets compiled files attribute with compiled sources to module object
@param [Config] config application config.
@module [Module] module application module.
@return [Observable Module] compiled module
###
compile_module = (config, module) ->

    Rx.Observable.create (observer) ->
        Rx.Observable
        .fromArray(module.get_file_paths())
        .flatMap(l.partial(compile_file, config))
        .toArray()
        .subscribe(
            (compiled_files) ->
                module.set_compiled_files compiled_files
                observer.onNext module
                observer.onCompleted()
            (err) ->
                # TODO: provide more clear explanation if failed due to
                # module file was not found
                observer.onError(
                    "Failed to compile module #{module.get_name()} #{err}")
        )


module.exports = {get_compiler, compile_file, compile_module}